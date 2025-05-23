// Mocks generated by Mockito 5.4.6 from annotations
// in dash_kit_network/test/api_client_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i10;

import 'package:dash_kit_network/src/token_storage.dart' as _i9;
import 'package:dio/src/adapter.dart' as _i4;
import 'package:dio/src/cancel_token.dart' as _i11;
import 'package:dio/src/dio.dart' as _i8;
import 'package:dio/src/dio_mixin.dart' as _i6;
import 'package:dio/src/options.dart' as _i3;
import 'package:dio/src/response.dart' as _i7;
import 'package:dio/src/transformer.dart' as _i5;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeFlutterSecureStorage_0 extends _i1.SmartFake
    implements _i2.FlutterSecureStorage {
  _FakeFlutterSecureStorage_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeBaseOptions_1 extends _i1.SmartFake implements _i3.BaseOptions {
  _FakeBaseOptions_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeHttpClientAdapter_2 extends _i1.SmartFake
    implements _i4.HttpClientAdapter {
  _FakeHttpClientAdapter_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeTransformer_3 extends _i1.SmartFake implements _i5.Transformer {
  _FakeTransformer_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeInterceptors_4 extends _i1.SmartFake implements _i6.Interceptors {
  _FakeInterceptors_4(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeResponse_5<T1> extends _i1.SmartFake implements _i7.Response<T1> {
  _FakeResponse_5(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeDio_6 extends _i1.SmartFake implements _i8.Dio {
  _FakeDio_6(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [TokenStorage].
///
/// See the documentation for Mockito's code generation for more information.
class MockTokenStorage extends _i1.Mock implements _i9.TokenStorage {
  @override
  _i2.FlutterSecureStorage get storage => (super.noSuchMethod(
        Invocation.getter(#storage),
        returnValue: _FakeFlutterSecureStorage_0(
          this,
          Invocation.getter(#storage),
        ),
        returnValueForMissingStub: _FakeFlutterSecureStorage_0(
          this,
          Invocation.getter(#storage),
        ),
      ) as _i2.FlutterSecureStorage);

  @override
  _i10.Future<bool> isAuthorized() => (super.noSuchMethod(
        Invocation.method(
          #isAuthorized,
          [],
        ),
        returnValue: _i10.Future<bool>.value(false),
        returnValueForMissingStub: _i10.Future<bool>.value(false),
      ) as _i10.Future<bool>);

  @override
  _i10.Future<String?> getAccessToken() => (super.noSuchMethod(
        Invocation.method(
          #getAccessToken,
          [],
        ),
        returnValue: _i10.Future<String?>.value(),
        returnValueForMissingStub: _i10.Future<String?>.value(),
      ) as _i10.Future<String?>);

  @override
  _i10.Future<String?> getRefreshToken() => (super.noSuchMethod(
        Invocation.method(
          #getRefreshToken,
          [],
        ),
        returnValue: _i10.Future<String?>.value(),
        returnValueForMissingStub: _i10.Future<String?>.value(),
      ) as _i10.Future<String?>);

  @override
  _i10.Future<void> saveTokens({
    required String? accessToken,
    required String? refreshToken,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #saveTokens,
          [],
          {
            #accessToken: accessToken,
            #refreshToken: refreshToken,
          },
        ),
        returnValue: _i10.Future<void>.value(),
        returnValueForMissingStub: _i10.Future<void>.value(),
      ) as _i10.Future<void>);

  @override
  _i10.Future<void> clearTokens() => (super.noSuchMethod(
        Invocation.method(
          #clearTokens,
          [],
        ),
        returnValue: _i10.Future<void>.value(),
        returnValueForMissingStub: _i10.Future<void>.value(),
      ) as _i10.Future<void>);

  @override
  _i10.Future<void> clearAll() => (super.noSuchMethod(
        Invocation.method(
          #clearAll,
          [],
        ),
        returnValue: _i10.Future<void>.value(),
        returnValueForMissingStub: _i10.Future<void>.value(),
      ) as _i10.Future<void>);
}

/// A class which mocks [Dio].
///
/// See the documentation for Mockito's code generation for more information.
class MockDio extends _i1.Mock implements _i8.Dio {
  @override
  _i3.BaseOptions get options => (super.noSuchMethod(
        Invocation.getter(#options),
        returnValue: _FakeBaseOptions_1(
          this,
          Invocation.getter(#options),
        ),
        returnValueForMissingStub: _FakeBaseOptions_1(
          this,
          Invocation.getter(#options),
        ),
      ) as _i3.BaseOptions);

  @override
  _i4.HttpClientAdapter get httpClientAdapter => (super.noSuchMethod(
        Invocation.getter(#httpClientAdapter),
        returnValue: _FakeHttpClientAdapter_2(
          this,
          Invocation.getter(#httpClientAdapter),
        ),
        returnValueForMissingStub: _FakeHttpClientAdapter_2(
          this,
          Invocation.getter(#httpClientAdapter),
        ),
      ) as _i4.HttpClientAdapter);

  @override
  _i5.Transformer get transformer => (super.noSuchMethod(
        Invocation.getter(#transformer),
        returnValue: _FakeTransformer_3(
          this,
          Invocation.getter(#transformer),
        ),
        returnValueForMissingStub: _FakeTransformer_3(
          this,
          Invocation.getter(#transformer),
        ),
      ) as _i5.Transformer);

  @override
  _i6.Interceptors get interceptors => (super.noSuchMethod(
        Invocation.getter(#interceptors),
        returnValue: _FakeInterceptors_4(
          this,
          Invocation.getter(#interceptors),
        ),
        returnValueForMissingStub: _FakeInterceptors_4(
          this,
          Invocation.getter(#interceptors),
        ),
      ) as _i6.Interceptors);

  @override
  set options(_i3.BaseOptions? _options) => super.noSuchMethod(
        Invocation.setter(
          #options,
          _options,
        ),
        returnValueForMissingStub: null,
      );

  @override
  set httpClientAdapter(_i4.HttpClientAdapter? _httpClientAdapter) =>
      super.noSuchMethod(
        Invocation.setter(
          #httpClientAdapter,
          _httpClientAdapter,
        ),
        returnValueForMissingStub: null,
      );

  @override
  set transformer(_i5.Transformer? _transformer) => super.noSuchMethod(
        Invocation.setter(
          #transformer,
          _transformer,
        ),
        returnValueForMissingStub: null,
      );

  @override
  void close({bool? force = false}) => super.noSuchMethod(
        Invocation.method(
          #close,
          [],
          {#force: force},
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i10.Future<_i7.Response<T>> head<T>(
    String? path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    _i3.Options? options,
    _i11.CancelToken? cancelToken,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #head,
          [path],
          {
            #data: data,
            #queryParameters: queryParameters,
            #options: options,
            #cancelToken: cancelToken,
          },
        ),
        returnValue: _i10.Future<_i7.Response<T>>.value(_FakeResponse_5<T>(
          this,
          Invocation.method(
            #head,
            [path],
            {
              #data: data,
              #queryParameters: queryParameters,
              #options: options,
              #cancelToken: cancelToken,
            },
          ),
        )),
        returnValueForMissingStub:
            _i10.Future<_i7.Response<T>>.value(_FakeResponse_5<T>(
          this,
          Invocation.method(
            #head,
            [path],
            {
              #data: data,
              #queryParameters: queryParameters,
              #options: options,
              #cancelToken: cancelToken,
            },
          ),
        )),
      ) as _i10.Future<_i7.Response<T>>);

  @override
  _i10.Future<_i7.Response<T>> headUri<T>(
    Uri? uri, {
    Object? data,
    _i3.Options? options,
    _i11.CancelToken? cancelToken,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #headUri,
          [uri],
          {
            #data: data,
            #options: options,
            #cancelToken: cancelToken,
          },
        ),
        returnValue: _i10.Future<_i7.Response<T>>.value(_FakeResponse_5<T>(
          this,
          Invocation.method(
            #headUri,
            [uri],
            {
              #data: data,
              #options: options,
              #cancelToken: cancelToken,
            },
          ),
        )),
        returnValueForMissingStub:
            _i10.Future<_i7.Response<T>>.value(_FakeResponse_5<T>(
          this,
          Invocation.method(
            #headUri,
            [uri],
            {
              #data: data,
              #options: options,
              #cancelToken: cancelToken,
            },
          ),
        )),
      ) as _i10.Future<_i7.Response<T>>);

  @override
  _i10.Future<_i7.Response<T>> get<T>(
    String? path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    _i3.Options? options,
    _i11.CancelToken? cancelToken,
    _i3.ProgressCallback? onReceiveProgress,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #get,
          [path],
          {
            #data: data,
            #queryParameters: queryParameters,
            #options: options,
            #cancelToken: cancelToken,
            #onReceiveProgress: onReceiveProgress,
          },
        ),
        returnValue: _i10.Future<_i7.Response<T>>.value(_FakeResponse_5<T>(
          this,
          Invocation.method(
            #get,
            [path],
            {
              #data: data,
              #queryParameters: queryParameters,
              #options: options,
              #cancelToken: cancelToken,
              #onReceiveProgress: onReceiveProgress,
            },
          ),
        )),
        returnValueForMissingStub:
            _i10.Future<_i7.Response<T>>.value(_FakeResponse_5<T>(
          this,
          Invocation.method(
            #get,
            [path],
            {
              #data: data,
              #queryParameters: queryParameters,
              #options: options,
              #cancelToken: cancelToken,
              #onReceiveProgress: onReceiveProgress,
            },
          ),
        )),
      ) as _i10.Future<_i7.Response<T>>);

  @override
  _i10.Future<_i7.Response<T>> getUri<T>(
    Uri? uri, {
    Object? data,
    _i3.Options? options,
    _i11.CancelToken? cancelToken,
    _i3.ProgressCallback? onReceiveProgress,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #getUri,
          [uri],
          {
            #data: data,
            #options: options,
            #cancelToken: cancelToken,
            #onReceiveProgress: onReceiveProgress,
          },
        ),
        returnValue: _i10.Future<_i7.Response<T>>.value(_FakeResponse_5<T>(
          this,
          Invocation.method(
            #getUri,
            [uri],
            {
              #data: data,
              #options: options,
              #cancelToken: cancelToken,
              #onReceiveProgress: onReceiveProgress,
            },
          ),
        )),
        returnValueForMissingStub:
            _i10.Future<_i7.Response<T>>.value(_FakeResponse_5<T>(
          this,
          Invocation.method(
            #getUri,
            [uri],
            {
              #data: data,
              #options: options,
              #cancelToken: cancelToken,
              #onReceiveProgress: onReceiveProgress,
            },
          ),
        )),
      ) as _i10.Future<_i7.Response<T>>);

  @override
  _i10.Future<_i7.Response<T>> post<T>(
    String? path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    _i3.Options? options,
    _i11.CancelToken? cancelToken,
    _i3.ProgressCallback? onSendProgress,
    _i3.ProgressCallback? onReceiveProgress,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #post,
          [path],
          {
            #data: data,
            #queryParameters: queryParameters,
            #options: options,
            #cancelToken: cancelToken,
            #onSendProgress: onSendProgress,
            #onReceiveProgress: onReceiveProgress,
          },
        ),
        returnValue: _i10.Future<_i7.Response<T>>.value(_FakeResponse_5<T>(
          this,
          Invocation.method(
            #post,
            [path],
            {
              #data: data,
              #queryParameters: queryParameters,
              #options: options,
              #cancelToken: cancelToken,
              #onSendProgress: onSendProgress,
              #onReceiveProgress: onReceiveProgress,
            },
          ),
        )),
        returnValueForMissingStub:
            _i10.Future<_i7.Response<T>>.value(_FakeResponse_5<T>(
          this,
          Invocation.method(
            #post,
            [path],
            {
              #data: data,
              #queryParameters: queryParameters,
              #options: options,
              #cancelToken: cancelToken,
              #onSendProgress: onSendProgress,
              #onReceiveProgress: onReceiveProgress,
            },
          ),
        )),
      ) as _i10.Future<_i7.Response<T>>);

  @override
  _i10.Future<_i7.Response<T>> postUri<T>(
    Uri? uri, {
    Object? data,
    _i3.Options? options,
    _i11.CancelToken? cancelToken,
    _i3.ProgressCallback? onSendProgress,
    _i3.ProgressCallback? onReceiveProgress,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #postUri,
          [uri],
          {
            #data: data,
            #options: options,
            #cancelToken: cancelToken,
            #onSendProgress: onSendProgress,
            #onReceiveProgress: onReceiveProgress,
          },
        ),
        returnValue: _i10.Future<_i7.Response<T>>.value(_FakeResponse_5<T>(
          this,
          Invocation.method(
            #postUri,
            [uri],
            {
              #data: data,
              #options: options,
              #cancelToken: cancelToken,
              #onSendProgress: onSendProgress,
              #onReceiveProgress: onReceiveProgress,
            },
          ),
        )),
        returnValueForMissingStub:
            _i10.Future<_i7.Response<T>>.value(_FakeResponse_5<T>(
          this,
          Invocation.method(
            #postUri,
            [uri],
            {
              #data: data,
              #options: options,
              #cancelToken: cancelToken,
              #onSendProgress: onSendProgress,
              #onReceiveProgress: onReceiveProgress,
            },
          ),
        )),
      ) as _i10.Future<_i7.Response<T>>);

  @override
  _i10.Future<_i7.Response<T>> put<T>(
    String? path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    _i3.Options? options,
    _i11.CancelToken? cancelToken,
    _i3.ProgressCallback? onSendProgress,
    _i3.ProgressCallback? onReceiveProgress,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #put,
          [path],
          {
            #data: data,
            #queryParameters: queryParameters,
            #options: options,
            #cancelToken: cancelToken,
            #onSendProgress: onSendProgress,
            #onReceiveProgress: onReceiveProgress,
          },
        ),
        returnValue: _i10.Future<_i7.Response<T>>.value(_FakeResponse_5<T>(
          this,
          Invocation.method(
            #put,
            [path],
            {
              #data: data,
              #queryParameters: queryParameters,
              #options: options,
              #cancelToken: cancelToken,
              #onSendProgress: onSendProgress,
              #onReceiveProgress: onReceiveProgress,
            },
          ),
        )),
        returnValueForMissingStub:
            _i10.Future<_i7.Response<T>>.value(_FakeResponse_5<T>(
          this,
          Invocation.method(
            #put,
            [path],
            {
              #data: data,
              #queryParameters: queryParameters,
              #options: options,
              #cancelToken: cancelToken,
              #onSendProgress: onSendProgress,
              #onReceiveProgress: onReceiveProgress,
            },
          ),
        )),
      ) as _i10.Future<_i7.Response<T>>);

  @override
  _i10.Future<_i7.Response<T>> putUri<T>(
    Uri? uri, {
    Object? data,
    _i3.Options? options,
    _i11.CancelToken? cancelToken,
    _i3.ProgressCallback? onSendProgress,
    _i3.ProgressCallback? onReceiveProgress,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #putUri,
          [uri],
          {
            #data: data,
            #options: options,
            #cancelToken: cancelToken,
            #onSendProgress: onSendProgress,
            #onReceiveProgress: onReceiveProgress,
          },
        ),
        returnValue: _i10.Future<_i7.Response<T>>.value(_FakeResponse_5<T>(
          this,
          Invocation.method(
            #putUri,
            [uri],
            {
              #data: data,
              #options: options,
              #cancelToken: cancelToken,
              #onSendProgress: onSendProgress,
              #onReceiveProgress: onReceiveProgress,
            },
          ),
        )),
        returnValueForMissingStub:
            _i10.Future<_i7.Response<T>>.value(_FakeResponse_5<T>(
          this,
          Invocation.method(
            #putUri,
            [uri],
            {
              #data: data,
              #options: options,
              #cancelToken: cancelToken,
              #onSendProgress: onSendProgress,
              #onReceiveProgress: onReceiveProgress,
            },
          ),
        )),
      ) as _i10.Future<_i7.Response<T>>);

  @override
  _i10.Future<_i7.Response<T>> patch<T>(
    String? path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    _i3.Options? options,
    _i11.CancelToken? cancelToken,
    _i3.ProgressCallback? onSendProgress,
    _i3.ProgressCallback? onReceiveProgress,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #patch,
          [path],
          {
            #data: data,
            #queryParameters: queryParameters,
            #options: options,
            #cancelToken: cancelToken,
            #onSendProgress: onSendProgress,
            #onReceiveProgress: onReceiveProgress,
          },
        ),
        returnValue: _i10.Future<_i7.Response<T>>.value(_FakeResponse_5<T>(
          this,
          Invocation.method(
            #patch,
            [path],
            {
              #data: data,
              #queryParameters: queryParameters,
              #options: options,
              #cancelToken: cancelToken,
              #onSendProgress: onSendProgress,
              #onReceiveProgress: onReceiveProgress,
            },
          ),
        )),
        returnValueForMissingStub:
            _i10.Future<_i7.Response<T>>.value(_FakeResponse_5<T>(
          this,
          Invocation.method(
            #patch,
            [path],
            {
              #data: data,
              #queryParameters: queryParameters,
              #options: options,
              #cancelToken: cancelToken,
              #onSendProgress: onSendProgress,
              #onReceiveProgress: onReceiveProgress,
            },
          ),
        )),
      ) as _i10.Future<_i7.Response<T>>);

  @override
  _i10.Future<_i7.Response<T>> patchUri<T>(
    Uri? uri, {
    Object? data,
    _i3.Options? options,
    _i11.CancelToken? cancelToken,
    _i3.ProgressCallback? onSendProgress,
    _i3.ProgressCallback? onReceiveProgress,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #patchUri,
          [uri],
          {
            #data: data,
            #options: options,
            #cancelToken: cancelToken,
            #onSendProgress: onSendProgress,
            #onReceiveProgress: onReceiveProgress,
          },
        ),
        returnValue: _i10.Future<_i7.Response<T>>.value(_FakeResponse_5<T>(
          this,
          Invocation.method(
            #patchUri,
            [uri],
            {
              #data: data,
              #options: options,
              #cancelToken: cancelToken,
              #onSendProgress: onSendProgress,
              #onReceiveProgress: onReceiveProgress,
            },
          ),
        )),
        returnValueForMissingStub:
            _i10.Future<_i7.Response<T>>.value(_FakeResponse_5<T>(
          this,
          Invocation.method(
            #patchUri,
            [uri],
            {
              #data: data,
              #options: options,
              #cancelToken: cancelToken,
              #onSendProgress: onSendProgress,
              #onReceiveProgress: onReceiveProgress,
            },
          ),
        )),
      ) as _i10.Future<_i7.Response<T>>);

  @override
  _i10.Future<_i7.Response<T>> delete<T>(
    String? path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    _i3.Options? options,
    _i11.CancelToken? cancelToken,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #delete,
          [path],
          {
            #data: data,
            #queryParameters: queryParameters,
            #options: options,
            #cancelToken: cancelToken,
          },
        ),
        returnValue: _i10.Future<_i7.Response<T>>.value(_FakeResponse_5<T>(
          this,
          Invocation.method(
            #delete,
            [path],
            {
              #data: data,
              #queryParameters: queryParameters,
              #options: options,
              #cancelToken: cancelToken,
            },
          ),
        )),
        returnValueForMissingStub:
            _i10.Future<_i7.Response<T>>.value(_FakeResponse_5<T>(
          this,
          Invocation.method(
            #delete,
            [path],
            {
              #data: data,
              #queryParameters: queryParameters,
              #options: options,
              #cancelToken: cancelToken,
            },
          ),
        )),
      ) as _i10.Future<_i7.Response<T>>);

  @override
  _i10.Future<_i7.Response<T>> deleteUri<T>(
    Uri? uri, {
    Object? data,
    _i3.Options? options,
    _i11.CancelToken? cancelToken,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #deleteUri,
          [uri],
          {
            #data: data,
            #options: options,
            #cancelToken: cancelToken,
          },
        ),
        returnValue: _i10.Future<_i7.Response<T>>.value(_FakeResponse_5<T>(
          this,
          Invocation.method(
            #deleteUri,
            [uri],
            {
              #data: data,
              #options: options,
              #cancelToken: cancelToken,
            },
          ),
        )),
        returnValueForMissingStub:
            _i10.Future<_i7.Response<T>>.value(_FakeResponse_5<T>(
          this,
          Invocation.method(
            #deleteUri,
            [uri],
            {
              #data: data,
              #options: options,
              #cancelToken: cancelToken,
            },
          ),
        )),
      ) as _i10.Future<_i7.Response<T>>);

  @override
  _i10.Future<_i7.Response<dynamic>> download(
    String? urlPath,
    dynamic savePath, {
    _i3.ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    _i11.CancelToken? cancelToken,
    bool? deleteOnError = true,
    _i3.FileAccessMode? fileAccessMode = _i3.FileAccessMode.write,
    String? lengthHeader = 'content-length',
    Object? data,
    _i3.Options? options,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #download,
          [
            urlPath,
            savePath,
          ],
          {
            #onReceiveProgress: onReceiveProgress,
            #queryParameters: queryParameters,
            #cancelToken: cancelToken,
            #deleteOnError: deleteOnError,
            #fileAccessMode: fileAccessMode,
            #lengthHeader: lengthHeader,
            #data: data,
            #options: options,
          },
        ),
        returnValue:
            _i10.Future<_i7.Response<dynamic>>.value(_FakeResponse_5<dynamic>(
          this,
          Invocation.method(
            #download,
            [
              urlPath,
              savePath,
            ],
            {
              #onReceiveProgress: onReceiveProgress,
              #queryParameters: queryParameters,
              #cancelToken: cancelToken,
              #deleteOnError: deleteOnError,
              #fileAccessMode: fileAccessMode,
              #lengthHeader: lengthHeader,
              #data: data,
              #options: options,
            },
          ),
        )),
        returnValueForMissingStub:
            _i10.Future<_i7.Response<dynamic>>.value(_FakeResponse_5<dynamic>(
          this,
          Invocation.method(
            #download,
            [
              urlPath,
              savePath,
            ],
            {
              #onReceiveProgress: onReceiveProgress,
              #queryParameters: queryParameters,
              #cancelToken: cancelToken,
              #deleteOnError: deleteOnError,
              #fileAccessMode: fileAccessMode,
              #lengthHeader: lengthHeader,
              #data: data,
              #options: options,
            },
          ),
        )),
      ) as _i10.Future<_i7.Response<dynamic>>);

  @override
  _i10.Future<_i7.Response<dynamic>> downloadUri(
    Uri? uri,
    dynamic savePath, {
    _i3.ProgressCallback? onReceiveProgress,
    _i11.CancelToken? cancelToken,
    bool? deleteOnError = true,
    _i3.FileAccessMode? fileAccessMode = _i3.FileAccessMode.write,
    String? lengthHeader = 'content-length',
    Object? data,
    _i3.Options? options,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #downloadUri,
          [
            uri,
            savePath,
          ],
          {
            #onReceiveProgress: onReceiveProgress,
            #cancelToken: cancelToken,
            #deleteOnError: deleteOnError,
            #fileAccessMode: fileAccessMode,
            #lengthHeader: lengthHeader,
            #data: data,
            #options: options,
          },
        ),
        returnValue:
            _i10.Future<_i7.Response<dynamic>>.value(_FakeResponse_5<dynamic>(
          this,
          Invocation.method(
            #downloadUri,
            [
              uri,
              savePath,
            ],
            {
              #onReceiveProgress: onReceiveProgress,
              #cancelToken: cancelToken,
              #deleteOnError: deleteOnError,
              #fileAccessMode: fileAccessMode,
              #lengthHeader: lengthHeader,
              #data: data,
              #options: options,
            },
          ),
        )),
        returnValueForMissingStub:
            _i10.Future<_i7.Response<dynamic>>.value(_FakeResponse_5<dynamic>(
          this,
          Invocation.method(
            #downloadUri,
            [
              uri,
              savePath,
            ],
            {
              #onReceiveProgress: onReceiveProgress,
              #cancelToken: cancelToken,
              #deleteOnError: deleteOnError,
              #fileAccessMode: fileAccessMode,
              #lengthHeader: lengthHeader,
              #data: data,
              #options: options,
            },
          ),
        )),
      ) as _i10.Future<_i7.Response<dynamic>>);

  @override
  _i10.Future<_i7.Response<T>> request<T>(
    String? url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    _i11.CancelToken? cancelToken,
    _i3.Options? options,
    _i3.ProgressCallback? onSendProgress,
    _i3.ProgressCallback? onReceiveProgress,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #request,
          [url],
          {
            #data: data,
            #queryParameters: queryParameters,
            #cancelToken: cancelToken,
            #options: options,
            #onSendProgress: onSendProgress,
            #onReceiveProgress: onReceiveProgress,
          },
        ),
        returnValue: _i10.Future<_i7.Response<T>>.value(_FakeResponse_5<T>(
          this,
          Invocation.method(
            #request,
            [url],
            {
              #data: data,
              #queryParameters: queryParameters,
              #cancelToken: cancelToken,
              #options: options,
              #onSendProgress: onSendProgress,
              #onReceiveProgress: onReceiveProgress,
            },
          ),
        )),
        returnValueForMissingStub:
            _i10.Future<_i7.Response<T>>.value(_FakeResponse_5<T>(
          this,
          Invocation.method(
            #request,
            [url],
            {
              #data: data,
              #queryParameters: queryParameters,
              #cancelToken: cancelToken,
              #options: options,
              #onSendProgress: onSendProgress,
              #onReceiveProgress: onReceiveProgress,
            },
          ),
        )),
      ) as _i10.Future<_i7.Response<T>>);

  @override
  _i10.Future<_i7.Response<T>> requestUri<T>(
    Uri? uri, {
    Object? data,
    _i11.CancelToken? cancelToken,
    _i3.Options? options,
    _i3.ProgressCallback? onSendProgress,
    _i3.ProgressCallback? onReceiveProgress,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #requestUri,
          [uri],
          {
            #data: data,
            #cancelToken: cancelToken,
            #options: options,
            #onSendProgress: onSendProgress,
            #onReceiveProgress: onReceiveProgress,
          },
        ),
        returnValue: _i10.Future<_i7.Response<T>>.value(_FakeResponse_5<T>(
          this,
          Invocation.method(
            #requestUri,
            [uri],
            {
              #data: data,
              #cancelToken: cancelToken,
              #options: options,
              #onSendProgress: onSendProgress,
              #onReceiveProgress: onReceiveProgress,
            },
          ),
        )),
        returnValueForMissingStub:
            _i10.Future<_i7.Response<T>>.value(_FakeResponse_5<T>(
          this,
          Invocation.method(
            #requestUri,
            [uri],
            {
              #data: data,
              #cancelToken: cancelToken,
              #options: options,
              #onSendProgress: onSendProgress,
              #onReceiveProgress: onReceiveProgress,
            },
          ),
        )),
      ) as _i10.Future<_i7.Response<T>>);

  @override
  _i10.Future<_i7.Response<T>> fetch<T>(_i3.RequestOptions? requestOptions) =>
      (super.noSuchMethod(
        Invocation.method(
          #fetch,
          [requestOptions],
        ),
        returnValue: _i10.Future<_i7.Response<T>>.value(_FakeResponse_5<T>(
          this,
          Invocation.method(
            #fetch,
            [requestOptions],
          ),
        )),
        returnValueForMissingStub:
            _i10.Future<_i7.Response<T>>.value(_FakeResponse_5<T>(
          this,
          Invocation.method(
            #fetch,
            [requestOptions],
          ),
        )),
      ) as _i10.Future<_i7.Response<T>>);

  @override
  _i8.Dio clone({
    _i3.BaseOptions? options,
    _i6.Interceptors? interceptors,
    _i4.HttpClientAdapter? httpClientAdapter,
    _i5.Transformer? transformer,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #clone,
          [],
          {
            #options: options,
            #interceptors: interceptors,
            #httpClientAdapter: httpClientAdapter,
            #transformer: transformer,
          },
        ),
        returnValue: _FakeDio_6(
          this,
          Invocation.method(
            #clone,
            [],
            {
              #options: options,
              #interceptors: interceptors,
              #httpClientAdapter: httpClientAdapter,
              #transformer: transformer,
            },
          ),
        ),
        returnValueForMissingStub: _FakeDio_6(
          this,
          Invocation.method(
            #clone,
            [],
            {
              #options: options,
              #interceptors: interceptors,
              #httpClientAdapter: httpClientAdapter,
              #transformer: transformer,
            },
          ),
        ),
      ) as _i8.Dio);
}
