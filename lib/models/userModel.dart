class UserModel {
  String name, username, token, email, password;

  UserModel(this.name, this.email, this.username, this.password,
      {this.token = ""});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'username': username,
      'email': email,
      'token': token,
      'password': password
    };
  }
}
