import 'package:flutter/cupertino.dart';
import 'package:nylo_framework/nylo_framework.dart';

/// Base API Service class
class NyBaseApiService {
  late Dio _api;

  BuildContext? _context;
  BaseOptions? baseOptions;

  final String baseUrl = "";
  final bool useInterceptors = true;
  final Map<Type, Interceptor> interceptors = {};
  final Map<Type, dynamic> decoders = {};

  NyBaseApiService(BuildContext? context) {
    this._context = context;
    this.init();
  }

  /// Set the build context (optional)
  setContext(BuildContext context) {
    _context = context;
  }

  /// Initialize class
  void init() {
    baseOptions = BaseOptions(baseUrl: baseUrl, headers: {
      "Content-type": "application/json",
      "Accept": "application/json"
    });

    _api = Dio(baseOptions);

    if (useInterceptors == true) {
      _addInterceptors();
    }
  }

  /// Networking class to handle API requests
  /// Use the [request] callback to call an API
  /// [handleSuccess] overrides the response on a successful status code
  /// [handleFailure] overrides the response on a failure
  ///
  /// Usage:
  /// Future<List<User>?> fetchUsers() async {
  ///     return await network<List<User>>(
  ///         request: (request) => request.get("/users"),
  ///     );
  ///   }
  Future<T?> network<T>(
      {required Function(Dio api) request,
      Function(Response response)? handleSuccess,
      Function(DioError error)? handleFailure}) async {
    try {
      Response response = await request(_api);

      return handleResponse<T>(response, handleSuccess: handleSuccess);
    } on DioError catch (dioError) {
      if (getEnv('APP_DEBUG') == true) {
        NyLogger.error(dioError.toString());
      }
      onError(dioError);
      if (_context != null) {
        displayError(dioError, _context!);
      }

      if (handleFailure != null) {
        return handleFailure(dioError);
      }

      return null;
    } on Exception catch (e) {
      if (getEnv('APP_DEBUG') == true) {
        NyLogger.error(e.toString());
      }

      return null;
    }
  }

  /// Handle the [DioError] response if there is an issue.
  onError(DioError dioError) {}

  /// Display a error to the user
  /// This method is only called if you provide the API service
  /// with a [BuildContext].
  displayError(DioError dioError, BuildContext context) {}

  /// Handles an API network response from [Dio].
  /// [handleSuccess] overrides the return value
  /// [handleFailure] is called then the response status is not 200.
  /// You can return a different value using this callback.
  handleResponse<T>(Response response,
      {Function(Response response)? handleSuccess}) {
    bool wasSuccessful = response.statusCode == 200;

    if (wasSuccessful == true && handleSuccess != null) {
      return handleSuccess(response);
    }

    if (T.toString() != 'dynamic') {
      return _morphJsonResponse<T>(response.data);
    } else {
      return response.data;
    }
  }

  /// Morphs json into Object using the 'config/api_decoders'.
  _morphJsonResponse<T>(dynamic json) {
    DefaultResponse defaultResponse =
        DefaultResponse<T>.fromJson(json, decoders, type: T);
    return defaultResponse.data;
  }

  /// Adds all the [interceptors] to [dio].
  _addInterceptors() => _api.interceptors.addAll(interceptors.values);
}
