import 'package:flutter_auth/models/user.dart';

abstract class AuthResponse {
  final bool success;
  final UserProfile? user;
  final String? error;

  const AuthResponse({
    required this.success,
    required this.user,
    required this.error,
  });
}

class Success extends AuthResponse {
  const Success(UserProfile user)
      : super(
          success: true,
          user: user,
          error: null,
        );
}

class Failed extends AuthResponse {
  const Failed(String error)
      : super(
          success: false,
          user: null,
          error: error,
        );
}
