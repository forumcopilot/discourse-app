import 'dart:convert';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart';
import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';
import 'package:pointycastle/export.dart' as pc;
import 'package:shared_preferences/shared_preferences.dart';

/// The User API Key handshake, with this test playing Discourse.
///
/// [DiscourseAuthManager.beginHandshake] builds the `/user-api-key/new`
/// URL; the server encrypts `{key, nonce, push, api}` to the public key in
/// that URL and redirects back with it as `payload`;
/// [DiscourseAuthManager.completeHandshake] decrypts, checks the nonce and
/// stores the key. Everything here is pure Dart (RSA via pointycastle), so
/// it runs without a network or a webview — the two halves the real flow
/// needs a person for.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const url = 'https://forum.example';
  SiteContext freshContext() => SiteContext(
        siteType: 'discourse',
        site: Site(
          id: null,
          name: 'Example',
          url: url,
          description: 'handshake test site',
          endpoint: null,
          baseUrl: url,
          logoUrl: null,
          backgroundUrl: null,
          siteType: 'discourse',
        ),
      );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  Future<DiscourseUserApiHandshakeRequest> begin(
    DiscourseAuthManager manager, {
    List<String> scopes = const ['read', 'write'],
    String? pushUrl,
  }) =>
      manager.beginHandshake(
        applicationName: 'Handshake Test',
        scopes: scopes,
        authRedirect: 'discourse://auth_redirect',
        pushUrl: pushUrl,
      );

  test('the request URL carries what Discourse needs', () async {
    final manager = DiscourseAuthManager(freshContext());
    final request = await begin(manager, pushUrl: 'https://relay.example/discourse/push');
    final uri = Uri.parse(request.url);
    final q = uri.queryParameters;

    expect(uri.path, '/user-api-key/new');
    expect(q['application_name'], 'Handshake Test');
    expect(q['scopes'], 'read,write');
    expect(q['nonce'], request.nonce);
    expect(q['client_id'], request.clientId);
    expect(q['auth_redirect'], 'discourse://auth_redirect');
    expect(q['push_url'], 'https://relay.example/discourse/push');
    expect(q['padding'], 'oaep');
    expect(q['public_key'], startsWith('-----BEGIN PUBLIC KEY-----'));
    // Parseable as X.509 SubjectPublicKeyInfo, 2048-bit.
    expect(_publicKeyFromPem(q['public_key']!).modulus!.bitLength, 2048);
  });

  test('the client id is stable across handshakes', () async {
    final manager = DiscourseAuthManager(freshContext());
    final first = await begin(manager);
    final second = await begin(manager);
    // Discourse destroys the previous key for the same (user, client_id)
    // on every grant, which is what makes re-login replace rather than
    // strand keys server-side.
    expect(second.clientId, first.clientId);
    expect(second.nonce, isNot(first.nonce));
  });

  for (final oaep in [true, false]) {
    test(
        'a ${oaep ? 'RSA-OAEP' : 'PKCS1 v1.5'} payload completes the handshake '
        'and signs the context in', () async {
      final context = freshContext();
      final manager = DiscourseAuthManager(context);
      final request = await begin(manager);
      final publicKey = _publicKeyFromPem(
          Uri.parse(request.url).queryParameters['public_key']!);

      final payload = _encrypt(
        {'key': 'k-from-server', 'nonce': request.nonce, 'push': false, 'api': 4},
        publicKey,
        oaep: oaep,
      );
      final key = await manager.completeHandshake(payload);

      expect(key.key, 'k-from-server');
      expect(key.clientId, request.clientId);
      expect(key.pushEnabled, isFalse);
      expect(context.hasUserApiKey, isTrue);
      expect(context.userApiAuthHeaders()['User-Api-Key'], 'k-from-server');
      expect(context.userApiAuthHeaders()['User-Api-Client-Id'], request.clientId);

      // And a fresh context reads it back from storage.
      final restored = freshContext();
      await restored.loadUserApiCredentials();
      expect(restored.userApiKey, 'k-from-server');
    });
  }

  test('a payload with the wrong nonce is rejected and nothing is stored',
      () async {
    final context = freshContext();
    final manager = DiscourseAuthManager(context);
    final request = await begin(manager);
    final publicKey = _publicKeyFromPem(
        Uri.parse(request.url).queryParameters['public_key']!);

    final replayed = _encrypt(
      {'key': 'k-attacker', 'nonce': 'not-the-nonce', 'push': false, 'api': 4},
      publicKey,
      oaep: true,
    );
    await expectLater(manager.completeHandshake(replayed), throwsStateError);
    expect(context.hasUserApiKey, isFalse);
  });

  test('a second handshake supersedes the first', () async {
    final manager = DiscourseAuthManager(freshContext());
    final first = await begin(manager);
    final firstKey = _publicKeyFromPem(
        Uri.parse(first.url).queryParameters['public_key']!);
    await begin(manager);

    // Encrypted to the first keypair, with the first nonce: stale.
    final stale = _encrypt(
      {'key': 'k-stale', 'nonce': first.nonce, 'push': false, 'api': 4},
      firstKey,
      oaep: true,
    );
    await expectLater(manager.completeHandshake(stale), throwsA(anything));
  });

  test('push is recorded only when this app asked for it', () async {
    // The server echoes push: true for the `notifications` scope too, so
    // its word alone must not flip userApiPushEnabled.
    final withoutPush = freshContext();
    final m1 = DiscourseAuthManager(withoutPush);
    final r1 = await begin(m1, scopes: ['read', 'notifications']);
    final k1 = await m1.completeHandshake(_encrypt(
      {'key': 'k1', 'nonce': r1.nonce, 'push': true, 'api': 4},
      _publicKeyFromPem(Uri.parse(r1.url).queryParameters['public_key']!),
      oaep: true,
    ));
    expect(k1.pushEnabled, isFalse);
    expect(withoutPush.userApiPushEnabled, isFalse);

    final withPush = freshContext();
    final m2 = DiscourseAuthManager(withPush);
    final r2 = await begin(m2,
        scopes: ['read', 'push'], pushUrl: 'https://relay.example/discourse/push');
    final k2 = await m2.completeHandshake(_encrypt(
      {'key': 'k2', 'nonce': r2.nonce, 'push': true, 'api': 4},
      _publicKeyFromPem(Uri.parse(r2.url).queryParameters['public_key']!),
      oaep: true,
    ));
    expect(k2.pushEnabled, isTrue);
    expect(withPush.userApiPushEnabled, isTrue);
  });
}

/// X.509 SubjectPublicKeyInfo PEM -> pointycastle key, the way OpenSSL on
/// the Discourse side reads what the app sent.
pc.RSAPublicKey _publicKeyFromPem(String pem) {
  final b64 = pem
      .replaceAll(RegExp(r'-----[A-Z ]+-----'), '')
      .replaceAll(RegExp(r'\s'), '');
  final spki = ASN1Parser(Uint8List.fromList(base64.decode(b64)))
      .nextObject() as ASN1Sequence;
  final bits = spki.elements[1] as ASN1BitString;
  final rsa = ASN1Parser(Uint8List.fromList(bits.stringValue)).nextObject()
      as ASN1Sequence;
  return pc.RSAPublicKey(
    (rsa.elements[0] as ASN1Integer).valueAsBigInteger,
    (rsa.elements[1] as ASN1Integer).valueAsBigInteger,
  );
}

/// What UserApiKeysController does with the key: JSON, RSA-encrypted to the
/// app's public key, base64. OAEP when the server honours `padding=oaep`,
/// PKCS1 v1.5 on older servers and through the login-redirect flow.
String _encrypt(
  Map<String, dynamic> json,
  pc.RSAPublicKey publicKey, {
  required bool oaep,
}) {
  final random = pc.FortunaRandom()
    ..seed(pc.KeyParameter(Uint8List.fromList(List.generate(32, (i) => i * 7 + 1))));
  final pc.AsymmetricBlockCipher cipher =
      oaep ? pc.OAEPEncoding(pc.RSAEngine()) : pc.PKCS1Encoding(pc.RSAEngine());
  cipher.init(
    true,
    pc.ParametersWithRandom(
      pc.PublicKeyParameter<pc.RSAPublicKey>(publicKey),
      random,
    ),
  );
  final plaintext = Uint8List.fromList(utf8.encode(jsonEncode(json)));
  return base64.encode(cipher.process(plaintext));
}
