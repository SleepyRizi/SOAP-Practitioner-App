class Validators {
  static String? email(String? v) =>
      v != null && RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(v)
          ? null
          : 'Enter valid e‑mail';

  static String? password(String? v) =>
      v != null && v.length >= 6 ? null : 'Min 6 chars';

  static String? notEmpty(String? v) => v?.trim().isNotEmpty == true
      ? null
      : 'Field cannot be empty';
}
