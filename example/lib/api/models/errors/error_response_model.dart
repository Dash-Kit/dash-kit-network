import 'package:json_annotation/json_annotation.dart';

part 'error_response_model.g.dart';

@JsonSerializable()
class ResponseErrorModel {
  ResponseErrorModel({
    this.errors,
  });

  factory ResponseErrorModel.fromJson(Map<String, dynamic> json) =>
      _$ResponseErrorModelFromJson(json);

  final Map<String, List<String>> errors;

  Map<String, dynamic> toJson() => _$ResponseErrorModelToJson(this);
}
