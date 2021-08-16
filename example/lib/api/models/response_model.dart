class ResponseModel {
  const ResponseModel();

  Map<String, dynamic> toJson() => <String, dynamic>{};
}

class VoidResponseModel extends ResponseModel {}

class ResponseErrorModel extends ResponseModel {
  const ResponseErrorModel(this.errorData);

  final dynamic errorData;
}
