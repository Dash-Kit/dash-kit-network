// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResponseErrorModel _$ResponseErrorModelFromJson(Map<String, dynamic> json) {
  return ResponseErrorModel(
    errors: (json['errors'] as Map<String, dynamic>).map(
      (k, e) =>
          MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
    ),
  );
}

Map<String, dynamic> _$ResponseErrorModelToJson(ResponseErrorModel instance) =>
    <String, dynamic>{
      'errors': instance.errors,
    };
