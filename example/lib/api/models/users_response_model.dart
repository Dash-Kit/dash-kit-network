import 'package:example/api/models/user_response_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'users_response_model.g.dart';

@JsonSerializable()
class UsersResponseModel {
  UsersResponseModel({
    required this.data,
  });

  factory UsersResponseModel.fromJson(Map<String, dynamic> json) =>
      _$UsersResponseModelFromJson(json);

  final List<UserResponseModel> data;

  Map<String, dynamic> toJson() => _$UsersResponseModelToJson(this);
}
