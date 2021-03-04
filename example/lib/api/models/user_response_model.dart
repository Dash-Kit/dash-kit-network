import 'package:json_annotation/json_annotation.dart';

part 'user_response_model.g.dart';

@JsonSerializable()
class UserResponseModel {
  UserResponseModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.avatar,
  });

  factory UserResponseModel.fromJson(Map<String, dynamic> json) =>
      _$UserResponseModelFromJson(json);

  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String avatar;

  Map<String, dynamic> toJson() => _$UserResponseModelToJson(this);

  String get fullName => '$firstName $lastName';
}
