import 'package:json_annotation/json_annotation.dart';

part 'error_response_model.g.dart';

@JsonSerializable()
class ResponseErrorModel extends Error {
  ResponseErrorModel({
    required this.errors,
  });

  factory ResponseErrorModel.fromJson(Map<String, dynamic> json) =>
      _$ResponseErrorModelFromJson(json);

  @JsonKey(defaultValue: {})
  final Map<String, List<String>> errors;

  Map<String, dynamic> toJson() => _$ResponseErrorModelToJson(this);
}
