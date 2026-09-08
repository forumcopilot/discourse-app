import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The one secure store the User API Key and handshake private key go
/// through. Two call sites used to construct `FlutterSecureStorage()` with
/// library defaults independently; the options below matter and must not
/// drift between them.
///
/// Android. The default (`encryptedSharedPreferences: false`) is the
/// library's legacy scheme: an AES key wrapped by an RSA Keystore key,
/// both stored beside the data. It is the scheme behind the "signed out
/// after an update" reports the audit recorded and could not explain, and
/// the library itself recommends against it. `encryptedSharedPreferences`
/// switches to Jetpack Security's EncryptedSharedPreferences with a
/// Keystore master key; the plugin migrates existing legacy entries on
/// first use, so current installs keep their key. `resetOnError` makes an
/// undecryptable store (typically a cloud-restored file whose Keystore key
/// did not come with it) clear itself instead of throwing on every read,
/// which would leave the app unable to sign in again either.
///
/// iOS and macOS keep the library default (`kSecAttrAccessibleWhenUnlocked`)
/// deliberately. The app never reads the key while the device is locked,
/// and changing the accessibility class is not free: this plugin version's
/// `delete` includes the class in its Keychain query, so entries written
/// under the old class could no longer be removed on sign-out.
const FlutterSecureStorage discourseSecureStorage = FlutterSecureStorage(
  aOptions: AndroidOptions(
    encryptedSharedPreferences: true,
    resetOnError: true,
  ),
);
