import 'package:dio/dio.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  late Dio dio;
  String? _token;

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://reqres.in/api',
        connectTimeout: Duration(seconds: 5),
        receiveTimeout: Duration(seconds: 3),
      ),
    );

     dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          print('REQUEST[${options.method}] => PATH: ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('RESPONSE[${response.statusCode}] => DATA: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) {
          print(
            'ERROR[${error.response?.statusCode}] => MESSAGE: ${error.message}',
          );
          return handler.next(error);
        },
      ),
    );
  }

  void setToken(String token) {
    _token = token;
  }

  String? getToken() {
    return _token;
  }

  void clearToken() {
    _token = null;
  }

   Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      if (response.data['token'] != null) {
        setToken(response.data['token']);
      }

      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['error'] ?? 'Login failed',
      };
    }
  }

   Future<Map<String, dynamic>> register(String email, String password) async {
    try {
      final response = await dio.post(
        '/register',
        data: {'email': email, 'password': password},
      );

      if (response.data['token'] != null) {
        setToken(response.data['token']);
      }

      return {'success': true, 'data': response.data};
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['error'] ?? 'Registration failed',
      };
    }
  }


}
