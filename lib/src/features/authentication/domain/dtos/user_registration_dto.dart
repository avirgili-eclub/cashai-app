class UserRegistrationDTO {
  final String username;
  final String email;
  final String password;
  final String? celular;
  final String? nickName;
  final String? codigoIdentificador;
  final String? googleId;
  final String? appleId;
  final String preferredCurrency;

  UserRegistrationDTO({
    required this.username,
    required this.email,
    required this.password,
    this.celular,
    this.nickName,
    this.codigoIdentificador,
    this.googleId,
    this.appleId,
    this.preferredCurrency = "PYG",
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'email': email,
        'password': password,
        if (celular != null) 'celular': celular,
        if (nickName != null) 'nickName': nickName,
        if (codigoIdentificador != null)
          'codigoIdentificador': codigoIdentificador,
        if (googleId != null) 'googleId': googleId,
        if (appleId != null) 'appleId': appleId,
        'preferredCurrency': preferredCurrency,
      };
}
