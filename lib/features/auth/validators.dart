final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String? validateEmail(String? v) {
  final s = v?.trim() ?? '';
  if (s.isEmpty) return 'Email wajib diisi';
  return _emailRe.hasMatch(s) ? null : 'Format email tidak valid';
}

String? validatePassword(String? v) {
  final s = v ?? '';
  if (s.isEmpty) return 'Password wajib diisi';
  return s.length >= 8 ? null : 'Password minimal 8 karakter';
}

String? validateUsername(String? v) =>
    (v?.trim().isEmpty ?? true) ? 'Username wajib diisi' : null;
