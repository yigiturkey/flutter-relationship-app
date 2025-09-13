class AppConstants {
  // Uygulama Bilgileri
  static const String appName = 'İlişki Analizi';
  static const String appVersion = '1.0.0';
  
  // API ve Backend
  static const String baseUrl = 'https://api.iliski-analizi.com';
  static const int timeoutDuration = 30; // saniye
  
  // SharedPreferences Keys
  static const String userTokenKey = 'user_token';
  static const String userIdKey = 'user_id';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String onboardingKey = 'onboarding_completed';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String analysesCollection = 'analyses';
  static const String trainingsCollection = 'trainings';
  static const String gamesCollection = 'games';
  static const String achievementsCollection = 'achievements';
  static const String notificationsCollection = 'notifications';
  static const String transactionsCollection = 'transactions';
  static const String memoriesCollection = 'memories';
  
  // Free vs Premium Limitler
  static const int freeAnalysisLimit = 3;
  static const int freeTrainingLimit = 2;
  static const int freeGameLimit = 5;
  static const int premiumAnalysisLimit = -1; // sınırsız
  static const int premiumTrainingLimit = -1; // sınırsız
  static const int premiumGameLimit = -1; // sınırsız
  
  // Jeton Sistemı
  static const int tarotReadingCost = 50;
  static const int personalityAnalysisCost = 30;
  static const int extraGamePackCost = 20;
  static const int freeTokensPerDay = 10;
  static const int premiumTokensPerDay = 50;
  
  // Bildirim Limitleri
  static const int freeNotificationLimit = 3;
  static const int premiumNotificationLimit = 5;
  
  // Fiyatlandırma (TL)
  static const double monthlyPremiumPrice = 29.99;
  static const double yearlyPremiumPrice = 199.99;
  static const Map<int, double> tokenPackages = {
    100: 9.99,
    250: 19.99,
    500: 34.99,
    1000: 59.99,
  };
  
  // Analiz Tipleri
  static const String instantAnalysis = 'instant';
  static const String generalAnalysis = 'general';
  static const String coupleAnalysis = 'couple';
  static const String futureReport = 'future';
  
  // Eğitim Kategorileri
  static const List<String> trainingCategories = [
    'İletişim',
    'Empati',
    'Çatışma Yönetimi',
    'Duygusal Zeka',
    'Kişisel Gelişim',
    'İlişki Becerileri',
  ];
  
  // Oyun Tipleri
  static const List<String> gameTypes = [
    'Uyumluluk Testi',
    'Kişilik Analizi',
    'İlişki Quizi',
    'Empati Oyunu',
    'İletişim Pratiği',
  ];
  
  // Güvenlik ve Etik
  static const String privacyPolicyUrl = 'https://iliski-analizi.com/privacy';
  static const String termsOfServiceUrl = 'https://iliski-analizi.com/terms';
  static const String supportEmail = 'destek@iliski-analizi.com';
  static const String crisisHelpline = '182'; // Aile, Çalışma ve Sosyal Hizmetler Bakanlığı
  
  // Kriz Kelimeleri (Yardım için yönlendirme)
  static const List<String> crisisKeywords = [
    'intihar',
    'öldürmek',
    'zarar vermek',
    'depresyon',
    'kaygı',
    'panik',
    'yardım',
    'çıkış yok',
  ];
  
  // Yasaklı Kelimeler
  static const List<String> bannedWords = [
    'terapi yerine geçer',
    'kesin çözüm',
    'garantili sonuç',
    'doktor tavsiyes'
  ];
  
  // Uyarı Mesajları
  static const String therapyDisclaimer = 
      'Bu uygulama profesyonel terapi, psikolojik danışmanlık veya tıbbi tavsiye yerine geçmez. '
      'Ciddi sorunlar yaşıyorsanız lütfen uzman yardımı alın.';
  
  static const String ageVerificationMessage = 
      'Bu uygulama 18 yaş ve üzeri kullanıcılar için tasarlanmıştır.';
  
  static const String dataPrivacyMessage = 
      'Verileriniz KVKV ve GDPR uyumlu olarak işlenir ve korunur.';
}