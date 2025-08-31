class LoginResponse {
  final String username;
  final String token;

  LoginResponse({required this.username, required this.token});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(username: json["username"], token: json["token"]);
  }
}
