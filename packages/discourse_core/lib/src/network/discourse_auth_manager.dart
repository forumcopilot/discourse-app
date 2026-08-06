import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:pointycastle/export.dart' as pc;
import 'package:shared_preferences/shared_preferences.dart';

import '../context/discourse_site_context_extension.dart';
import 'discourse_client.dart';

/// Discourse User API Key handshake.
///
/// Wire-level spec: https://meta.discourse.org/t/-/32504. The flow is:
///
///   1. App generates an RSA-2048 keypair, a random nonce, and a stable
///      `client_id`. [beginHandshake] returns the URL the app should open in
///      a webview. The user logs in to Discourse there (handles 2FA / passkey
///      / SSO via Discourse's UI), then sees a permission grant page listing
///      the requested scopes.
///   2. After the user clicks "Authorize", Discourse redirects to the
///      `auth_redirect` URL with `?payload=<base64-of-RSA-encrypted-JSON>`.
///      The host webview hands the payload string to [completeHandshake].
///   3. [completeHandshake] decrypts with the saved private key, verifies the
///      nonce echoes back, and persists the resulting User API Key onto the
///      [SiteContext]. Subsequent requests carry it via `User-Api-Key` and
///      `User-Api-Client-Id` headers (see [DiscourseClient]).
///
/// Notes:
///   * We request `padding=oaep`, but decrypt with an OAEP→PKCS1 v1.5 fallback
///     because the server may encrypt PKCS1 v1.5 anyway (see [_padding]).
///   * The user must already meet `SiteSetting.user_api_key_allowed_groups` —
///     by default that's staff or trust_level_4, which means a stock forum
///     blocks regular users from getting a key. Forum admins relax that
///     setting before shipping the app.
///   * Key generation is CPU-bound (~1-2s). Phase 2 should move it to an
///     isolate; Phase 1.0 keeps it on the main isolate for simplicity.
class DiscourseAuthManager {
  static const String _prefHandshakePrivateKey = '_handshake_private_key';
  static const String _prefHandshakeNonce = '_handshake_nonce';
  static const String _prefHandshakeClientId = '_handshake_client_id';
  static const String _prefHandshakePushRequested = '_handshake_push_requested';
  static const String _prefInstallClientId = '_install_client_id';

  /// Requesting `padding=oaep` opts in to RSA-OAEP (OpenSSL's
  /// RSA-OAEP-MGF1-SHA1; pointycastle's [pc.OAEPEncoding] without an explicit
  /// hash uses SHA-1, so the two agree). Note that PKCS1 v1.5 — not OAEP — is
  /// the server-side default even at Auth-Api-Version 4: the `padding` param
  /// only exists on servers with discourse/discourse#36592 (Dec 2025), older
  /// servers silently ignore it, and even patched servers can drop it through
  /// the login-redirect flow (discourse/discourse#36640). Decryption therefore
  /// tries OAEP first and falls back to PKCS1 v1.5.
  static const String _padding = 'oaep';

  final SiteContext siteContext;
  final DiscourseClient _client;

  DiscourseAuthManager(this.siteContext, {DiscourseClient? client})
      : _client = client ?? DiscourseClient();

  // ===== Public API =====

  /// Generate keypair + nonce, persist the in-flight state, and build the URL
  /// to open in a webview.
  ///
  /// [pushUrl], when non-empty, is sent as the `push_url` param and stored by
  /// Discourse on the resulting User API Key (`user_api_keys.push_url`) —
  /// Discourse later POSTs notification payloads to it (see
  /// `HubPushNotificationPusher`). For the key to actually push, the caller
  /// must ALSO include `push` in [scopes], and the forum admin must list the
  /// exact URL in the `allowed_user_api_push_urls` site setting (substring
  /// match — so use a static URL, never a per-device one).
  Future<DiscourseUserApiHandshakeRequest> beginHandshake({
    required String applicationName,
    required List<String> scopes,
    required String authRedirect,
    String? pushUrl,
  }) async {
    if (scopes.isEmpty) {
      throw ArgumentError('At least one scope is required.');
    }

    // A new handshake supersedes any in-flight one — wipe its state (in
    // particular the stale private key) before generating fresh material.
    await _clearHandshakeState();

    final keypair = _generateRsaKeypair();
    final clientId = await _getOrCreateClientId();
    final nonce = _randomHex(16);

    // Only treat the handshake as a push request when both halves were sent:
    // the `push` scope AND a push_url. (The server's `has_push?` also counts
    // the `notifications` scope, so its `push: true` echo alone is not proof
    // that we deliberately wired push — see completeHandshake.)
    final pushRequested =
        pushUrl != null && pushUrl.isNotEmpty && scopes.contains('push');

    await _persistHandshakeState(
      privateKey: keypair.privateKey,
      nonce: nonce,
      clientId: clientId,
      pushRequested: pushRequested,
    );

    final pubPem = _publicKeyToPem(keypair.publicKey);
    final query = <String, String>{
      'application_name': applicationName,
      'client_id': clientId,
      'scopes': scopes.join(','),
      'public_key': pubPem,
      'nonce': nonce,
      'auth_redirect': authRedirect,
      'padding': _padding,
    };
    if (pushUrl != null && pushUrl.isNotEmpty) {
      query['push_url'] = pushUrl;
    }

    final base = Uri.parse(siteContext.site.url);
    final url = base.replace(
      path: _joinPath(base.path, '/user-api-key/new'),
      queryParameters: query,
    );

    return DiscourseUserApiHandshakeRequest(
      url: url.toString(),
      clientId: clientId,
      nonce: nonce,
    );
  }

  /// Complete the handshake using the `payload` value Discourse appended to
  /// the redirect URL. The caller is responsible for URL-decoding before
  /// calling this (so we accept the standard base64 form).
  ///
  /// On success, the User API Key is stored on the [SiteContext] via
  /// [DiscourseSiteContextExtension.setUserApiCredentials] and the in-flight
  /// handshake state is cleared.
  Future<DiscourseUserApiKey> completeHandshake(String payloadBase64) async {
    final state = await _loadHandshakeState();
    if (state == null) {
      throw StateError(
        'No handshake in flight. Call beginHandshake() before completeHandshake().',
      );
    }

    final ciphertext = base64.decode(_normalizeBase64(payloadBase64));
    final plaintext = _decryptPayload(ciphertext, state.privateKey);
    final json = jsonDecode(utf8.decode(plaintext)) as Map<String, dynamic>;

    final returnedNonce = json['nonce'] as String?;
    if (returnedNonce != state.nonce) {
      throw StateError(
        'User API Key handshake nonce mismatch — discarding payload.',
      );
    }

    final key = json['key'] as String?;
    if (key == null || key.isEmpty) {
      throw StateError('User API Key handshake returned no key.');
    }

    // The server echoes `push: key.has_push?` (scope + push_url present +
    // push_url allowlisted in `allowed_user_api_push_urls`). `has_push?`
    // also returns true for the `notifications` scope alone, so gate on
    // whether WE actually sent `push` scope + push_url in this handshake —
    // userApiPushEnabled must only record deliberate, complete push wiring.
    final pushEnabled =
        state.pushRequested && (json['push'] as bool? ?? false);

    await siteContext.setUserApiCredentials(
      userApiKey: key,
      userApiClientId: state.clientId,
      pushEnabled: pushEnabled,
    );
    await _clearHandshakeState();

    return DiscourseUserApiKey(
      key: key,
      clientId: state.clientId,
      pushEnabled: pushEnabled,
    );
  }

  /// Forget the locally stored User API Key. Does NOT call
  /// `/user-api-key/revoke` — for that, use [revokeKey].
  Future<void> clearKey() => siteContext.clearUserApiCredentials();

  /// Best-effort: ask Discourse to revoke the key, then drop it locally.
  /// A failed server revoke is logged but does not block local cleanup.
  Future<void> revokeKey() async {
    final result = await _client.post(siteContext, '/user-api-key/revoke');
    final status = result.statusCode;
    if (status < 200 || status >= 300) {
      // ignore: avoid_print
      print('⚠️ [DISCOURSE_AUTH] revokeKey: server revoke failed '
          '(HTTP $status). Dropping the key locally anyway — it remains '
          'valid server-side until revoked from the user\'s profile.');
    }
    await clearKey();
  }

  // ===== Persistence helpers =====

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  /// Per-install `client_id`, stable across handshakes. Discourse revokes a
  /// user's previous keys only for the SAME `client_id`, and keys push
  /// registrations attached to it — a fresh random id per handshake would
  /// strand old keys server-side and stale the push registration.
  Future<String> _getOrCreateClientId() async {
    final prefs = await SharedPreferences.getInstance();
    final p = _prefsPrefix();
    var clientId = prefs.getString('$p$_prefInstallClientId');
    // Adopt the id of an already-provisioned key (pre-dating this pref) so a
    // re-handshake on an existing install replaces the old key server-side.
    clientId ??= siteContext.userApiClientId;
    if (clientId == null || clientId.isEmpty) {
      clientId = _randomHex(16);
    }
    await prefs.setString('$p$_prefInstallClientId', clientId);
    return clientId;
  }

  Future<void> _persistHandshakeState({
    required pc.RSAPrivateKey privateKey,
    required String nonce,
    required String clientId,
    required bool pushRequested,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final p = _prefsPrefix();
    // The private key goes to secure storage (Keychain/Keystore), never to
    // plaintext SharedPreferences.
    await _secureStorage.write(
      key: '$p$_prefHandshakePrivateKey',
      value: _privateKeyToJson(privateKey),
    );
    await prefs.setString('$p$_prefHandshakeNonce', nonce);
    await prefs.setString('$p$_prefHandshakeClientId', clientId);
    await prefs.setBool('$p$_prefHandshakePushRequested', pushRequested);
  }

  Future<_HandshakeState?> _loadHandshakeState() async {
    final prefs = await SharedPreferences.getInstance();
    final p = _prefsPrefix();
    var pk = await _secureStorage.read(key: '$p$_prefHandshakePrivateKey');
    if (pk == null) {
      // Migrate-on-read: older builds kept the private key in plaintext
      // SharedPreferences. Move it to secure storage and delete the copy.
      pk = prefs.getString('$p$_prefHandshakePrivateKey');
      if (pk != null) {
        await _secureStorage.write(key: '$p$_prefHandshakePrivateKey', value: pk);
        await prefs.remove('$p$_prefHandshakePrivateKey');
      }
    }
    final nonce = prefs.getString('$p$_prefHandshakeNonce');
    final cid = prefs.getString('$p$_prefHandshakeClientId');
    if (pk == null || nonce == null || cid == null) return null;
    return _HandshakeState(
      privateKey: _privateKeyFromJson(pk),
      nonce: nonce,
      clientId: cid,
      pushRequested:
          prefs.getBool('$p$_prefHandshakePushRequested') ?? false,
    );
  }

  Future<void> _clearHandshakeState() async {
    final prefs = await SharedPreferences.getInstance();
    final p = _prefsPrefix();
    await _secureStorage.delete(key: '$p$_prefHandshakePrivateKey');
    await prefs.remove('$p$_prefHandshakePrivateKey');
    await prefs.remove('$p$_prefHandshakeNonce');
    await prefs.remove('$p$_prefHandshakeClientId');
    await prefs.remove('$p$_prefHandshakePushRequested');
  }

  String _prefsPrefix() => 'discourse:${siteContext.site.pluginUrl}';

  // ===== RSA helpers =====

  pc.AsymmetricKeyPair<pc.RSAPublicKey, pc.RSAPrivateKey> _generateRsaKeypair() {
    final secureRandom = pc.FortunaRandom();
    final seedSource = Random.secure();
    final seeds = Uint8List(32);
    for (var i = 0; i < seeds.length; i++) {
      seeds[i] = seedSource.nextInt(256);
    }
    secureRandom.seed(pc.KeyParameter(seeds));

    final params = pc.RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 64);
    final keyGen = pc.RSAKeyGenerator()
      ..init(pc.ParametersWithRandom(params, secureRandom));
    final pair = keyGen.generateKeyPair();
    return pc.AsymmetricKeyPair(
      pair.publicKey as pc.RSAPublicKey,
      pair.privateKey as pc.RSAPrivateKey,
    );
  }

  Uint8List _decryptPayload(Uint8List ciphertext, pc.RSAPrivateKey privateKey) {
    // We request `padding=oaep`, but the server may still encrypt PKCS1 v1.5:
    // servers older than Dec 2025 ignore the unknown `padding` param, and even
    // patched servers drop it through the login-redirect flow
    // (discourse/discourse#36640). Try OAEP first, then fall back.
    try {
      final oaep = pc.OAEPEncoding(pc.RSAEngine())
        ..init(false, pc.PrivateKeyParameter<pc.RSAPrivateKey>(privateKey));
      return oaep.process(ciphertext);
    } catch (_) {
      // Not OAEP — fall through to PKCS1 v1.5, the server-side default.
    }
    final pkcs1 = pc.PKCS1Encoding(pc.RSAEngine())
      ..init(false, pc.PrivateKeyParameter<pc.RSAPrivateKey>(privateKey));
    return pkcs1.process(ciphertext);
  }

  String _publicKeyToPem(pc.RSAPublicKey publicKey) {
    // X.509 SubjectPublicKeyInfo wrapping an RSA public key.
    final algorithmSeq = ASN1Sequence();
    // OID 1.2.840.113549.1.1.1 (rsaEncryption) — pre-encoded DER.
    algorithmSeq.add(ASN1Object.fromBytes(Uint8List.fromList(const [
      0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01,
    ])));
    algorithmSeq.add(ASN1Object.fromBytes(Uint8List.fromList(const [0x05, 0x00])));

    final publicKeySeq = ASN1Sequence()
      ..add(ASN1Integer(publicKey.modulus!))
      ..add(ASN1Integer(publicKey.exponent!));
    final publicKeyBitString = ASN1BitString(
      Uint8List.fromList(publicKeySeq.encodedBytes),
    );

    final topLevelSeq = ASN1Sequence()
      ..add(algorithmSeq)
      ..add(publicKeyBitString);

    final dataBase64 = base64.encode(topLevelSeq.encodedBytes);
    final lines = <String>[];
    for (var i = 0; i < dataBase64.length; i += 64) {
      final end = i + 64 < dataBase64.length ? i + 64 : dataBase64.length;
      lines.add(dataBase64.substring(i, end));
    }
    return '-----BEGIN PUBLIC KEY-----\n${lines.join('\n')}\n-----END PUBLIC KEY-----';
  }

  String _privateKeyToJson(pc.RSAPrivateKey k) => jsonEncode({
        'n': k.modulus!.toRadixString(16),
        'd': k.privateExponent!.toRadixString(16),
        'p': k.p!.toRadixString(16),
        'q': k.q!.toRadixString(16),
      });

  pc.RSAPrivateKey _privateKeyFromJson(String src) {
    final m = jsonDecode(src) as Map<String, dynamic>;
    return pc.RSAPrivateKey(
      BigInt.parse(m['n'] as String, radix: 16),
      BigInt.parse(m['d'] as String, radix: 16),
      BigInt.parse(m['p'] as String, radix: 16),
      BigInt.parse(m['q'] as String, radix: 16),
    );
  }

  // ===== Misc helpers =====

  String _randomHex(int byteCount) {
    final r = Random.secure();
    final buf = Uint8List(byteCount);
    for (var i = 0; i < byteCount; i++) {
      buf[i] = r.nextInt(256);
    }
    return buf.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  String _normalizeBase64(String s) {
    // Discourse percent-encodes the payload in the redirect URL, but the
    // caller has already URL-decoded by the time this runs. Some webviews
    // produce URL-safe base64 (- and _) — accept both. A space can only be a
    // form-decoded '+' (standard base64 never contains spaces), so restore it.
    var out = s.replaceAll('-', '+').replaceAll('_', '/').replaceAll('\n', '').replaceAll('\r', '').replaceAll(' ', '+');
    final padding = (4 - out.length % 4) % 4;
    return out + ('=' * padding);
  }

  String _joinPath(String basePath, String suffix) {
    if (basePath.isEmpty || basePath == '/') return suffix;
    final left = basePath.endsWith('/') ? basePath.substring(0, basePath.length - 1) : basePath;
    return suffix.startsWith('/') ? '$left$suffix' : '$left/$suffix';
  }

}

/// State returned from [DiscourseAuthManager.beginHandshake]. The webview must
/// open [url], wait for a redirect to the configured `auth_redirect`, and pass
/// the `payload` query parameter to [DiscourseAuthManager.completeHandshake].
class DiscourseUserApiHandshakeRequest {
  final String url;
  final String clientId;
  final String nonce;

  const DiscourseUserApiHandshakeRequest({
    required this.url,
    required this.clientId,
    required this.nonce,
  });
}

/// The result of a successful handshake. Already persisted on the
/// [SiteContext] by the time this is returned.
class DiscourseUserApiKey {
  final String key;
  final String clientId;
  final bool pushEnabled;

  const DiscourseUserApiKey({
    required this.key,
    required this.clientId,
    required this.pushEnabled,
  });
}

class _HandshakeState {
  final pc.RSAPrivateKey privateKey;
  final String nonce;
  final String clientId;

  /// True when this handshake sent both the `push` scope and a `push_url`.
  final bool pushRequested;

  const _HandshakeState({
    required this.privateKey,
    required this.nonce,
    required this.clientId,
    required this.pushRequested,
  });
}
