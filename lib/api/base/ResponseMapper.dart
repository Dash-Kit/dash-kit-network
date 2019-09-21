import 'package:dio/dio.dart';

typedef ResponseMapper<T> = T Function(Response response);
