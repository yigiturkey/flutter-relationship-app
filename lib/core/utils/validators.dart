class Validators {
  // E-posta validasyonu
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-posta adresi gereklidir';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Geçerli bir e-posta adresi girin';
    }
    
    return null;
  }

  // Şifre validasyonu
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre gereklidir';
    }
    
    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalıdır';
    }
    
    // En az bir harf ve bir rakam içermeli
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(value)) {
      return 'Şifre en az bir harf ve bir rakam içermelidir';
    }
    
    return null;
  }

  // İsim validasyonu
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'İsim gereklidir';
    }
    
    if (value.length < 2) {
      return 'İsim en az 2 karakter olmalıdır';
    }
    
    if (value.length > 50) {
      return 'İsim 50 karakterden fazla olamaz';
    }
    
    return null;
  }

  // Yaş validasyonu (18+ kontrol)
  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Yaş gereklidir';
    }
    
    final age = int.tryParse(value);
    if (age == null) {
      return 'Geçerli bir yaş girin';
    }
    
    if (age < 18) {
      return 'Bu uygulama 18 yaş ve üzeri kullanıcılar içindir';
    }
    
    if (age > 100) {
      return 'Geçerli bir yaş girin';
    }
    
    return null;
  }

  // Telefon numarası validasyonu
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefon numarası gereklidir';
    }
    
    // Türkiye telefon numarası formatı
    final phoneRegex = RegExp(r'^(\+90|0)?[5][0-9]{9}$');
    
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
      return 'Geçerli bir telefon numarası girin';
    }
    
    return null;
  }
}