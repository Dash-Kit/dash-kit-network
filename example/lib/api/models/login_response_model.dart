import 'package:example/api/models/response_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'login_response_model.g.dart';

@JsonSerializable()
class LoginResponseModel extends ResponseModel {
  const LoginResponseModel({
    required this.accessToken,
    required this.accessTokenExpiresAt,
    required this.refreshToken,
    required this.refreshTokenExpiresAt,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseModelFromJson(json);

  final String accessToken;
  final int accessTokenExpiresAt;
  final String refreshToken;
  final int refreshTokenExpiresAt;

  @override
  Map<String, dynamic> toJson() => _$LoginResponseModelToJson(this);
}
