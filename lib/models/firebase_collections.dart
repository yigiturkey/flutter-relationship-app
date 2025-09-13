// Firebase koleksiyon isimleri ve veri yapıları
class FirebaseCollections {
  // Koleksiyon isimleri
  static const String users = 'users';
  static const String analyses = 'analyses';
  static const String games = 'games';
  static const String gameResults = 'game_results';
  static const String podcasts = 'podcasts';
  static const String trainings = 'trainings';
  static const String trainingProgress = 'training_progress';
  static const String notifications = 'notifications';
  static const String userStats = 'user_stats';
  
  // Alt koleksiyonlar
  static const String userAnalyses = 'user_analyses';
  static const String userGames = 'user_games';
  static const String userTrainings = 'user_trainings';
}

// Firebase doküman yapıları
class FirebaseDocumentStructures {
  // Users koleksiyonu
  static Map<String, dynamic> userDocument = {
    'uid': 'string',
    'email': 'string',
    'displayName': 'string',
    'photoURL': 'string?',
    'birthDate': 'timestamp?',
    'zodiacSign': 'string?',
    'gender': 'string?',
    'isVerified': 'bool',
    'isPremium': 'bool',
    'tokens': 'int',
    'createdAt': 'timestamp',
    'updatedAt': 'timestamp',
    'preferences': {
      'language': 'string',
      'notifications': 'bool',
      'theme': 'string',
    },
    'stats': {
      'totalAnalyses': 'int',
      'totalGamesPlayed': 'int',
      'totalTrainingsCompleted': 'int',
      'totalPodcastsListened': 'int',
    }
  };

  // Analyses koleksiyonu
  static Map<String, dynamic> analysisDocument = {
    'id': 'string',
    'userId': 'string',
    'type': 'string', // horoscope, whatsapp, social_media, general
    'title': 'string',
    'description': 'string',
    'input': 'map', // Analiz girdileri
    'result': {
      'aiAnalysis': 'string',
      'score': 'double',
      'recommendations': 'array',
      'insights': 'array',
    },
    'status': 'string', // pending, processing, completed, failed
    'createdAt': 'timestamp',
    'updatedAt': 'timestamp',
    'isShared': 'bool',
  };

  // Games koleksiyonu
  static Map<String, dynamic> gameDocument = {
    'id': 'string',
    'title': 'string',
    'description': 'string',
    'category': 'string', // relationship, personality, career, etc.
    'difficulty': 'string', // easy, medium, hard
    'imageUrl': 'string',
    'isActive': 'bool',
    'questions': [
      {
        'id': 'string',
        'question': 'string',
        'type': 'string', // multiple_choice, scale, text
        'options': 'array?', // For multiple choice
        'scaleMin': 'int?', // For scale questions
        'scaleMax': 'int?',
        'scaleLabels': 'array?',
      }
    ],
    'analysisTemplate': 'string', // AI prompt template
    'createdAt': 'timestamp',
    'updatedAt': 'timestamp',
  };

  // Game Results koleksiyonu
  static Map<String, dynamic> gameResultDocument = {
    'id': 'string',
    'userId': 'string',
    'gameId': 'string',
    'answers': 'map', // questionId -> answer
    'result': {
      'aiAnalysis': 'string',
      'score': 'double',
      'category': 'string',
      'recommendations': 'array',
      'insights': 'array',
    },
    'completedAt': 'timestamp',
    'isShared': 'bool',
  };

  // Podcasts koleksiyonu
  static Map<String, dynamic> podcastDocument = {
    'id': 'string',
    'title': 'string',
    'description': 'string',
    'host': 'string',
    'category': 'string', // relationship, mindfulness, personal_growth
    'duration': 'int', // seconds
    'audioUrl': 'string',
    'imageUrl': 'string',
    'tags': 'array',
    'transcript': 'string?',
    'isActive': 'bool',
    'listenCount': 'int',
    'rating': 'double',
    'createdAt': 'timestamp',
    'updatedAt': 'timestamp',
  };

  // Trainings koleksiyonu
  static Map<String, dynamic> trainingDocument = {
    'id': 'string',
    'title': 'string',
    'description': 'string',
    'category': 'string', // relationship, communication, self_care
    'level': 'string', // beginner, intermediate, advanced
    'imageUrl': 'string',
    'estimatedDuration': 'int', // minutes
    'isActive': 'bool',
    'isFree': 'bool',
    'modules': [
      {
        'id': 'string',
        'title': 'string',
        'type': 'string', // video, text, quiz, exercise
        'content': 'string', // URL for video, text content, etc.
        'duration': 'int?',
        'order': 'int',
      }
    ],
    'requirements': 'array',
    'outcomes': 'array',
    'rating': 'double',
    'enrolledCount': 'int',
    'createdAt': 'timestamp',
    'updatedAt': 'timestamp',
  };

  // Training Progress koleksiyonu
  static Map<String, dynamic> trainingProgressDocument = {
    'id': 'string',
    'userId': 'string',
    'trainingId': 'string',
    'progress': 'double', // 0.0 to 1.0
    'completedModules': 'array', // moduleId array
    'currentModule': 'string?',
    'startedAt': 'timestamp',
    'lastAccessedAt': 'timestamp',
    'completedAt': 'timestamp?',
    'certificateUrl': 'string?',
  };
}