import 'phone_number.dart';

class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
  });

  final int id;
  final String name;
  final String email;

  /// The WhatsApp number they sign in with, digits only (919876543210).
  final String? phone;

  String get firstName => name.trim().split(RegExp(r'\s+')).first;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  /// How the account is shown: the sign in number, else the email.
  String get contact => phone == null ? email : PhoneNumber.format(phone!);

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String?,
      );

  @override
  bool operator ==(Object other) =>
      other is User &&
      other.id == id &&
      other.name == name &&
      other.email == email &&
      other.phone == phone;

  @override
  int get hashCode => Object.hash(id, name, email, phone);
}

/// What the server says after a code is sent.
class OtpTicket {
  const OtpTicket({required this.expiresIn, required this.resendIn});

  final Duration expiresIn;
  final Duration resendIn;

  factory OtpTicket.fromJson(Map<String, dynamic> json) => OtpTicket(
        expiresIn: Duration(seconds: (json['expires_in'] as num?)?.toInt() ?? 300),
        resendIn: Duration(seconds: (json['resend_in'] as num?)?.toInt() ?? 30),
      );
}

class AuthSession {
  const AuthSession({required this.token, required this.user});

  final String token;
  final User user;

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
        token: json['token'] as String,
        user: User.fromJson(json['user'] as Map<String, dynamic>),
      );
}
