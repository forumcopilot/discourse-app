// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'auth_response.dart';

class AuthResponseMapper extends ClassMapperBase<AuthResponse> {
  AuthResponseMapper._();

  static AuthResponseMapper? _instance;
  static AuthResponseMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AuthResponseMapper._());
      OAuthTokenMapper.ensureInitialized();
      DiscourseUserMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'AuthResponse';

  static bool _$success(AuthResponse v) => v.success;
  static const Field<AuthResponse, bool> _f$success =
      Field('success', _$success);
  static String? _$error(AuthResponse v) => v.error;
  static const Field<AuthResponse, String> _f$error =
      Field('error', _$error, opt: true);
  static String? _$errorCode(AuthResponse v) => v.errorCode;
  static const Field<AuthResponse, String> _f$errorCode =
      Field('errorCode', _$errorCode, opt: true);
  static OAuthToken? _$token(AuthResponse v) => v.token;
  static const Field<AuthResponse, OAuthToken> _f$token =
      Field('token', _$token, opt: true);
  static DiscourseUser? _$user(AuthResponse v) => v.user;
  static const Field<AuthResponse, DiscourseUser> _f$user =
      Field('user', _$user, opt: true);
  static Map<String, dynamic>? _$data(AuthResponse v) => v.data;
  static const Field<AuthResponse, Map<String, dynamic>> _f$data =
      Field('data', _$data, opt: true);

  @override
  final MappableFields<AuthResponse> fields = const {
    #success: _f$success,
    #error: _f$error,
    #errorCode: _f$errorCode,
    #token: _f$token,
    #user: _f$user,
    #data: _f$data,
  };

  static AuthResponse _instantiate(DecodingData data) {
    return AuthResponse(
        success: data.dec(_f$success),
        error: data.dec(_f$error),
        errorCode: data.dec(_f$errorCode),
        token: data.dec(_f$token),
        user: data.dec(_f$user),
        data: data.dec(_f$data));
  }

  @override
  final Function instantiate = _instantiate;

  static AuthResponse fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<AuthResponse>(map);
  }

  static AuthResponse fromJson(String json) {
    return ensureInitialized().decodeJson<AuthResponse>(json);
  }
}

mixin AuthResponseMappable {
  String toJson() {
    return AuthResponseMapper.ensureInitialized()
        .encodeJson<AuthResponse>(this as AuthResponse);
  }

  Map<String, dynamic> toMap() {
    return AuthResponseMapper.ensureInitialized()
        .encodeMap<AuthResponse>(this as AuthResponse);
  }

  AuthResponseCopyWith<AuthResponse, AuthResponse, AuthResponse> get copyWith =>
      _AuthResponseCopyWithImpl<AuthResponse, AuthResponse>(
          this as AuthResponse, $identity, $identity);
  @override
  String toString() {
    return AuthResponseMapper.ensureInitialized()
        .stringifyValue(this as AuthResponse);
  }

  @override
  bool operator ==(Object other) {
    return AuthResponseMapper.ensureInitialized()
        .equalsValue(this as AuthResponse, other);
  }

  @override
  int get hashCode {
    return AuthResponseMapper.ensureInitialized()
        .hashValue(this as AuthResponse);
  }
}

extension AuthResponseValueCopy<$R, $Out>
    on ObjectCopyWith<$R, AuthResponse, $Out> {
  AuthResponseCopyWith<$R, AuthResponse, $Out> get $asAuthResponse =>
      $base.as((v, t, t2) => _AuthResponseCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class AuthResponseCopyWith<$R, $In extends AuthResponse, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  OAuthTokenCopyWith<$R, OAuthToken, OAuthToken>? get token;
  DiscourseUserCopyWith<$R, DiscourseUser, DiscourseUser>? get user;
  MapCopyWith<$R, String, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>?
      get data;
  $R call(
      {bool? success,
      String? error,
      String? errorCode,
      OAuthToken? token,
      DiscourseUser? user,
      Map<String, dynamic>? data});
  AuthResponseCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _AuthResponseCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, AuthResponse, $Out>
    implements AuthResponseCopyWith<$R, AuthResponse, $Out> {
  _AuthResponseCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AuthResponse> $mapper =
      AuthResponseMapper.ensureInitialized();
  @override
  OAuthTokenCopyWith<$R, OAuthToken, OAuthToken>? get token =>
      $value.token?.copyWith.$chain((v) => call(token: v));
  @override
  DiscourseUserCopyWith<$R, DiscourseUser, DiscourseUser>? get user =>
      $value.user?.copyWith.$chain((v) => call(user: v));
  @override
  MapCopyWith<$R, String, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>?
      get data => $value.data != null
          ? MapCopyWith($value.data!, (v, t) => ObjectCopyWith(v, $identity, t),
              (v) => call(data: v))
          : null;
  @override
  $R call(
          {bool? success,
          Object? error = $none,
          Object? errorCode = $none,
          Object? token = $none,
          Object? user = $none,
          Object? data = $none}) =>
      $apply(FieldCopyWithData({
        if (success != null) #success: success,
        if (error != $none) #error: error,
        if (errorCode != $none) #errorCode: errorCode,
        if (token != $none) #token: token,
        if (user != $none) #user: user,
        if (data != $none) #data: data
      }));
  @override
  AuthResponse $make(CopyWithData data) => AuthResponse(
      success: data.get(#success, or: $value.success),
      error: data.get(#error, or: $value.error),
      errorCode: data.get(#errorCode, or: $value.errorCode),
      token: data.get(#token, or: $value.token),
      user: data.get(#user, or: $value.user),
      data: data.get(#data, or: $value.data));

  @override
  AuthResponseCopyWith<$R2, AuthResponse, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _AuthResponseCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class DiscourseOAuthTokenRequestMapper
    extends ClassMapperBase<DiscourseOAuthTokenRequest> {
  DiscourseOAuthTokenRequestMapper._();

  static DiscourseOAuthTokenRequestMapper? _instance;
  static DiscourseOAuthTokenRequestMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals
          .use(_instance = DiscourseOAuthTokenRequestMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'DiscourseOAuthTokenRequest';

  static String _$grantType(DiscourseOAuthTokenRequest v) => v.grantType;
  static const Field<DiscourseOAuthTokenRequest, String> _f$grantType =
      Field('grantType', _$grantType);
  static String _$clientId(DiscourseOAuthTokenRequest v) => v.clientId;
  static const Field<DiscourseOAuthTokenRequest, String> _f$clientId =
      Field('clientId', _$clientId);
  static String _$clientSecret(DiscourseOAuthTokenRequest v) => v.clientSecret;
  static const Field<DiscourseOAuthTokenRequest, String> _f$clientSecret =
      Field('clientSecret', _$clientSecret);
  static String? _$username(DiscourseOAuthTokenRequest v) => v.username;
  static const Field<DiscourseOAuthTokenRequest, String> _f$username =
      Field('username', _$username, opt: true);
  static String? _$password(DiscourseOAuthTokenRequest v) => v.password;
  static const Field<DiscourseOAuthTokenRequest, String> _f$password =
      Field('password', _$password, opt: true);
  static String? _$refreshToken(DiscourseOAuthTokenRequest v) => v.refreshToken;
  static const Field<DiscourseOAuthTokenRequest, String> _f$refreshToken =
      Field('refreshToken', _$refreshToken, opt: true);
  static String? _$scope(DiscourseOAuthTokenRequest v) => v.scope;
  static const Field<DiscourseOAuthTokenRequest, String> _f$scope =
      Field('scope', _$scope, opt: true);

  @override
  final MappableFields<DiscourseOAuthTokenRequest> fields = const {
    #grantType: _f$grantType,
    #clientId: _f$clientId,
    #clientSecret: _f$clientSecret,
    #username: _f$username,
    #password: _f$password,
    #refreshToken: _f$refreshToken,
    #scope: _f$scope,
  };

  static DiscourseOAuthTokenRequest _instantiate(DecodingData data) {
    return DiscourseOAuthTokenRequest(
        grantType: data.dec(_f$grantType),
        clientId: data.dec(_f$clientId),
        clientSecret: data.dec(_f$clientSecret),
        username: data.dec(_f$username),
        password: data.dec(_f$password),
        refreshToken: data.dec(_f$refreshToken),
        scope: data.dec(_f$scope));
  }

  @override
  final Function instantiate = _instantiate;

  static DiscourseOAuthTokenRequest fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DiscourseOAuthTokenRequest>(map);
  }

  static DiscourseOAuthTokenRequest fromJson(String json) {
    return ensureInitialized().decodeJson<DiscourseOAuthTokenRequest>(json);
  }
}

mixin DiscourseOAuthTokenRequestMappable {
  String toJson() {
    return DiscourseOAuthTokenRequestMapper.ensureInitialized()
        .encodeJson<DiscourseOAuthTokenRequest>(this as DiscourseOAuthTokenRequest);
  }

  Map<String, dynamic> toMap() {
    return DiscourseOAuthTokenRequestMapper.ensureInitialized()
        .encodeMap<DiscourseOAuthTokenRequest>(this as DiscourseOAuthTokenRequest);
  }

  DiscourseOAuthTokenRequestCopyWith<DiscourseOAuthTokenRequest,
          DiscourseOAuthTokenRequest, DiscourseOAuthTokenRequest>
      get copyWith => _DiscourseOAuthTokenRequestCopyWithImpl<
              DiscourseOAuthTokenRequest, DiscourseOAuthTokenRequest>(
          this as DiscourseOAuthTokenRequest, $identity, $identity);
  @override
  String toString() {
    return DiscourseOAuthTokenRequestMapper.ensureInitialized()
        .stringifyValue(this as DiscourseOAuthTokenRequest);
  }

  @override
  bool operator ==(Object other) {
    return DiscourseOAuthTokenRequestMapper.ensureInitialized()
        .equalsValue(this as DiscourseOAuthTokenRequest, other);
  }

  @override
  int get hashCode {
    return DiscourseOAuthTokenRequestMapper.ensureInitialized()
        .hashValue(this as DiscourseOAuthTokenRequest);
  }
}

extension DiscourseOAuthTokenRequestValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DiscourseOAuthTokenRequest, $Out> {
  DiscourseOAuthTokenRequestCopyWith<$R, DiscourseOAuthTokenRequest, $Out>
      get $asDiscourseOAuthTokenRequest => $base.as((v, t, t2) =>
          _DiscourseOAuthTokenRequestCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DiscourseOAuthTokenRequestCopyWith<
    $R,
    $In extends DiscourseOAuthTokenRequest,
    $Out> implements ClassCopyWith<$R, $In, $Out> {
  $R call(
      {String? grantType,
      String? clientId,
      String? clientSecret,
      String? username,
      String? password,
      String? refreshToken,
      String? scope});
  DiscourseOAuthTokenRequestCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _DiscourseOAuthTokenRequestCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DiscourseOAuthTokenRequest, $Out>
    implements
        DiscourseOAuthTokenRequestCopyWith<$R, DiscourseOAuthTokenRequest, $Out> {
  _DiscourseOAuthTokenRequestCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DiscourseOAuthTokenRequest> $mapper =
      DiscourseOAuthTokenRequestMapper.ensureInitialized();
  @override
  $R call(
          {String? grantType,
          String? clientId,
          String? clientSecret,
          Object? username = $none,
          Object? password = $none,
          Object? refreshToken = $none,
          Object? scope = $none}) =>
      $apply(FieldCopyWithData({
        if (grantType != null) #grantType: grantType,
        if (clientId != null) #clientId: clientId,
        if (clientSecret != null) #clientSecret: clientSecret,
        if (username != $none) #username: username,
        if (password != $none) #password: password,
        if (refreshToken != $none) #refreshToken: refreshToken,
        if (scope != $none) #scope: scope
      }));
  @override
  DiscourseOAuthTokenRequest $make(CopyWithData data) => DiscourseOAuthTokenRequest(
      grantType: data.get(#grantType, or: $value.grantType),
      clientId: data.get(#clientId, or: $value.clientId),
      clientSecret: data.get(#clientSecret, or: $value.clientSecret),
      username: data.get(#username, or: $value.username),
      password: data.get(#password, or: $value.password),
      refreshToken: data.get(#refreshToken, or: $value.refreshToken),
      scope: data.get(#scope, or: $value.scope));

  @override
  DiscourseOAuthTokenRequestCopyWith<$R2, DiscourseOAuthTokenRequest, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _DiscourseOAuthTokenRequestCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class DiscourseOAuthTokenResponseMapper
    extends ClassMapperBase<DiscourseOAuthTokenResponse> {
  DiscourseOAuthTokenResponseMapper._();

  static DiscourseOAuthTokenResponseMapper? _instance;
  static DiscourseOAuthTokenResponseMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals
          .use(_instance = DiscourseOAuthTokenResponseMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'DiscourseOAuthTokenResponse';

  static String _$accessToken(DiscourseOAuthTokenResponse v) => v.accessToken;
  static const Field<DiscourseOAuthTokenResponse, String> _f$accessToken =
      Field('accessToken', _$accessToken);
  static String? _$refreshToken(DiscourseOAuthTokenResponse v) => v.refreshToken;
  static const Field<DiscourseOAuthTokenResponse, String> _f$refreshToken =
      Field('refreshToken', _$refreshToken, opt: true);
  static String _$tokenType(DiscourseOAuthTokenResponse v) => v.tokenType;
  static const Field<DiscourseOAuthTokenResponse, String> _f$tokenType =
      Field('tokenType', _$tokenType);
  static int _$expiresIn(DiscourseOAuthTokenResponse v) => v.expiresIn;
  static const Field<DiscourseOAuthTokenResponse, int> _f$expiresIn =
      Field('expiresIn', _$expiresIn);
  static String? _$scope(DiscourseOAuthTokenResponse v) => v.scope;
  static const Field<DiscourseOAuthTokenResponse, String> _f$scope =
      Field('scope', _$scope, opt: true);
  static DateTime? _$createdAt(DiscourseOAuthTokenResponse v) => v.createdAt;
  static const Field<DiscourseOAuthTokenResponse, DateTime> _f$createdAt =
      Field('createdAt', _$createdAt, opt: true);

  @override
  final MappableFields<DiscourseOAuthTokenResponse> fields = const {
    #accessToken: _f$accessToken,
    #refreshToken: _f$refreshToken,
    #tokenType: _f$tokenType,
    #expiresIn: _f$expiresIn,
    #scope: _f$scope,
    #createdAt: _f$createdAt,
  };

  static DiscourseOAuthTokenResponse _instantiate(DecodingData data) {
    return DiscourseOAuthTokenResponse(
        accessToken: data.dec(_f$accessToken),
        refreshToken: data.dec(_f$refreshToken),
        tokenType: data.dec(_f$tokenType),
        expiresIn: data.dec(_f$expiresIn),
        scope: data.dec(_f$scope),
        createdAt: data.dec(_f$createdAt));
  }

  @override
  final Function instantiate = _instantiate;

  static DiscourseOAuthTokenResponse fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DiscourseOAuthTokenResponse>(map);
  }

  static DiscourseOAuthTokenResponse fromJson(String json) {
    return ensureInitialized().decodeJson<DiscourseOAuthTokenResponse>(json);
  }
}

mixin DiscourseOAuthTokenResponseMappable {
  String toJson() {
    return DiscourseOAuthTokenResponseMapper.ensureInitialized()
        .encodeJson<DiscourseOAuthTokenResponse>(
            this as DiscourseOAuthTokenResponse);
  }

  Map<String, dynamic> toMap() {
    return DiscourseOAuthTokenResponseMapper.ensureInitialized()
        .encodeMap<DiscourseOAuthTokenResponse>(
            this as DiscourseOAuthTokenResponse);
  }

  DiscourseOAuthTokenResponseCopyWith<DiscourseOAuthTokenResponse,
          DiscourseOAuthTokenResponse, DiscourseOAuthTokenResponse>
      get copyWith => _DiscourseOAuthTokenResponseCopyWithImpl<
              DiscourseOAuthTokenResponse, DiscourseOAuthTokenResponse>(
          this as DiscourseOAuthTokenResponse, $identity, $identity);
  @override
  String toString() {
    return DiscourseOAuthTokenResponseMapper.ensureInitialized()
        .stringifyValue(this as DiscourseOAuthTokenResponse);
  }

  @override
  bool operator ==(Object other) {
    return DiscourseOAuthTokenResponseMapper.ensureInitialized()
        .equalsValue(this as DiscourseOAuthTokenResponse, other);
  }

  @override
  int get hashCode {
    return DiscourseOAuthTokenResponseMapper.ensureInitialized()
        .hashValue(this as DiscourseOAuthTokenResponse);
  }
}

extension DiscourseOAuthTokenResponseValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DiscourseOAuthTokenResponse, $Out> {
  DiscourseOAuthTokenResponseCopyWith<$R, DiscourseOAuthTokenResponse, $Out>
      get $asDiscourseOAuthTokenResponse => $base.as((v, t, t2) =>
          _DiscourseOAuthTokenResponseCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DiscourseOAuthTokenResponseCopyWith<
    $R,
    $In extends DiscourseOAuthTokenResponse,
    $Out> implements ClassCopyWith<$R, $In, $Out> {
  $R call(
      {String? accessToken,
      String? refreshToken,
      String? tokenType,
      int? expiresIn,
      String? scope,
      DateTime? createdAt});
  DiscourseOAuthTokenResponseCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _DiscourseOAuthTokenResponseCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DiscourseOAuthTokenResponse, $Out>
    implements
        DiscourseOAuthTokenResponseCopyWith<$R, DiscourseOAuthTokenResponse, $Out> {
  _DiscourseOAuthTokenResponseCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DiscourseOAuthTokenResponse> $mapper =
      DiscourseOAuthTokenResponseMapper.ensureInitialized();
  @override
  $R call(
          {String? accessToken,
          Object? refreshToken = $none,
          String? tokenType,
          int? expiresIn,
          Object? scope = $none,
          Object? createdAt = $none}) =>
      $apply(FieldCopyWithData({
        if (accessToken != null) #accessToken: accessToken,
        if (refreshToken != $none) #refreshToken: refreshToken,
        if (tokenType != null) #tokenType: tokenType,
        if (expiresIn != null) #expiresIn: expiresIn,
        if (scope != $none) #scope: scope,
        if (createdAt != $none) #createdAt: createdAt
      }));
  @override
  DiscourseOAuthTokenResponse $make(CopyWithData data) =>
      DiscourseOAuthTokenResponse(
          accessToken: data.get(#accessToken, or: $value.accessToken),
          refreshToken: data.get(#refreshToken, or: $value.refreshToken),
          tokenType: data.get(#tokenType, or: $value.tokenType),
          expiresIn: data.get(#expiresIn, or: $value.expiresIn),
          scope: data.get(#scope, or: $value.scope),
          createdAt: data.get(#createdAt, or: $value.createdAt));

  @override
  DiscourseOAuthTokenResponseCopyWith<$R2, DiscourseOAuthTokenResponse, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _DiscourseOAuthTokenResponseCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
