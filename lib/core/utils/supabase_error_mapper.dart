import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseErrorMapper {
  static String mapError(dynamic error) {
    if (error is AuthException) {
      return _mapAuthException(error);
    } else if (error is PostgrestException) {
      return _mapPostgrestException(error);
    } else if (error is StorageException) {
      return 'Storage error: ${error.message}';
    } else if (error is FormatException) {
      return 'Data format error: ${error.message}';
    } else if (error is StateError) {
      return error.message;
    } else {
      // Catch network or generic errors
      final stringError = error.toString().toLowerCase();
      if (stringError.contains('socket') ||
          stringError.contains('network') ||
          stringError.contains('connection')) {
        return 'Unable to connect. Check your internet connection and try again.';
      }
      return 'An unexpected error occurred. Please try again.';
    }
  }

  static String _mapAuthException(AuthException e) {
    final message = e.message.toLowerCase();
    if (message.contains('invalid login credentials')) {
      return 'Your email or password is incorrect.';
    }
    return e.message;
  }

  static String _mapPostgrestException(PostgrestException e) {
    // Reference standard PostgreSQL error codes
    switch (e.code) {
      case '42501': // INSUFFICIENT PRIVILEGE
        return 'You do not have permission to perform this action.';
      case '23505': // UNIQUE VIOLATION
        return 'A record with this information already exists.';
      case '23503': // FOREIGN KEY VIOLATION
        return 'A related record no longer exists or is invalid.';
      case '23514': // CHECK VIOLATION
        return 'The provided data violates a business rule.';
      default:
        // Try to glean from hint or message
        if (e.message.contains('invalid input syntax for type uuid')) {
          return 'The server rejected the submitted data due to an invalid ID.';
        }
        if (e.message.toLowerCase().contains('unauthorized')) {
          return 'You do not have permission to perform this action.';
        }
        return 'Server Error: ${e.message}';
    }
  }
}
