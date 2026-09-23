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
/// iOS. `first_unlock` (`kSecAttrAccessibleAfterFirstUnlock`) instead of the
/// library default `unlocked`. With push, the app does read the key around
/// lock-state transitions — a notification tapped on the lock screen opens
/// the forum as the device unlocks — and a refused read used to start that
/// session signed out (verified on an iPhone 17, 2026-09-22). `first_unlock`
/// keeps the item readable from the first unlock after boot until shutdown,
/// and keeps the old class's backup behaviour (not `_this_device`), so the
/// only thing that changes is lock state.
///
/// Changing the class is not free on this plugin version: `delete` puts the
/// class in its Keychain query, so an entry written under the old class is
/// invisible to a delete through this store. Entries are therefore moved on
/// read (see `loadUserApiCredentials`; the plugin's `write` replaces an entry
/// of any class), and sign-out also deletes through
/// [legacyAppleSecureStorage].
///
/// macOS keeps the library default: a Mac has no lock-screen notification
/// path into the app.
const FlutterSecureStorage discourseSecureStorage = FlutterSecureStorage(
  aOptions: AndroidOptions(
    encryptedSharedPreferences: true,
    resetOnError: true,
  ),
  iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
);

/// The store as it was before iOS moved to `first_unlock` — the library's
/// default class. Only for deleting entries an older build wrote on iOS;
/// never write through it.
const FlutterSecureStorage legacyAppleSecureStorage = FlutterSecureStorage(
  aOptions: AndroidOptions(
    encryptedSharedPreferences: true,
    resetOnError: true,
  ),
);
