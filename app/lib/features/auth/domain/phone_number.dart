import '../../../core/config/env.dart';

/// WhatsApp numbers in the shape the API stores: digits only, country code
/// first, no "+" (919876543210). Mirrors `PhoneNumber` on the server.
abstract final class PhoneNumber {
  static final _valid = RegExp(r'^[1-9]\d{9,14}$');

  /// "+91 98765-43210", "0091 9876543210", "09876543210" and "9876543210"
  /// all become 919876543210. Null when it can't be a number.
  static String? normalize(String input) {
    final trimmed = input.trim();
    final hasPlus = trimmed.startsWith('+');
    var digits = trimmed.replaceAll(RegExp(r'\D'), '');

    if (!hasPlus) {
      if (digits.startsWith('00')) {
        digits = digits.substring(2);
      } else if (digits.length == 11 && digits.startsWith('0')) {
        digits = Env.defaultCountryCode + digits.substring(1);
      } else if (digits.length == 10) {
        digits = Env.defaultCountryCode + digits;
      }
    }

    return _valid.hasMatch(digits) ? digits : null;
  }

  /// For reading: `+91 98765 43210` for Indian numbers, `+` and the digits otherwise.
  static String format(String digits) {
    if (digits.length == 12 && digits.startsWith('91')) {
      return '+91 ${digits.substring(2, 7)} ${digits.substring(7)}';
    }
    return '+$digits';
  }
}
