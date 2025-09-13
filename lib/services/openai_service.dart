import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  // GÜVENLIK UYARISI: Production'da API key'i client-side kullanmayın!
  // Firebase Cloud Functions veya backend üzerinden proxy yapın.
  static const String _apiKey = String.fromEnvironment('OPENAI_API_KEY');

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_apiKey',
  };

  // İlişki analizi için prompt'lar
  static const String _relationshipAnalysisPrompt = '''
Sen bir ilişki uzmanısın. Sana verilen bilgilere dayanarak kapsamlı bir ilişki analizi yap.
Analiz sonucunu Türkçe olarak JSON formatında döndür. Şu yapıyı kullan:

{
  "overall_score": 85,
  "compatibility_percentage": 78,
  "strengths": ["iletişim", "uyum", "ortak değerler"],
  "areas_for_improvement": ["zaman yönetimi", "çatışma çözümü"],
  "detailed_analysis": "Detaylı analiz metni...",
  "recommendations": ["Öneri 1", "Öneri 2", "Öneri 3"],
  "future_outlook": "Gelecek görünümü...",
  "relationship_stage": "early/developing/mature/challenging",
  "communication_style": "direct/indirect/mixed",
  "conflict_resolution": "healthy/needs_work/problematic"
}
''';

  static const String _horoscopePrompt = '''
Sen bir burç uyumluluğu uzmanısın. İki burç arasındaki uyumluluğu analiz et.
Analiz sonucunu Türkçe olarak JSON formatında döndür. Şu yapıyı kullan:

{
  "compatibility_score": 85,
  "love_compatibility": 90,
  "friendship_compatibility": 80,
  "work_compatibility": 75,
  "sexual_compatibility": 88,
  "communication_score": 82,
  "trust_score": 77,
  "overall_summary": "Genel özet...",
  "detailed_analysis": "Detaylı analiz...",
  "challenges": ["Zorluk 1", "Zorluk 2"],
  "opportunities": ["Fırsat 1", "Fırsat 2"],
  "advice": "Tavsiyeler...",
  "element_compatibility": "fire/earth/air/water uyumluluğu",
  "ruling_planet_influence": "Yönetici gezegen etkisi"
}
''';

  // WhatsApp konuşma analizi
  static Future<Map<String, dynamic>> analyzeWhatsAppConversation(String conversationText) async {
    try {
      final prompt = '''
$_relationshipAnalysisPrompt

WhatsApp konuşması analizi:
$conversationText

Bu konuşmaya dayanarak ilişkinin durumunu analiz et.
''';

      final response = await _makeGPTRequest(prompt);
      return _parseJsonResponse(response);
    } catch (e) {
      throw Exception('WhatsApp analizi yapılırken hata: $e');
    }
  }

  // Sosyal medya analizi (görselleri açıklama ile)
  static Future<Map<String, dynamic>> analyzeSocialMediaContent(
    String description,
    List<String> imageDescriptions,
  ) async {
    try {
      final imageAnalysis = imageDescriptions.join('\n- ');
      final prompt = '''
$_relationshipAnalysisPrompt

Sosyal medya içeriği analizi:
Açıklama: $description

Görsel açıklamaları:
- $imageAnalysis

Bu sosyal medya içeriğine dayanarak ilişki dinamiklerini analiz et.
''';

      final response = await _makeGPTRequest(prompt);
      return _parseJsonResponse(response);
    } catch (e) {
      throw Exception('Sosyal medya analizi yapılırken hata: $e');
    }
  }

  // Burç uyumluluğu analizi
  static Future<Map<String, dynamic>> analyzeHoroscopeCompatibility(
    String sign1,
    String sign2,
    DateTime birthDate1,
    DateTime birthDate2,
  ) async {
    try {
      final prompt = '''
$_horoscopePrompt

Burç 1: $sign1 (Doğum tarihi: ${birthDate1.toIso8601String().split('T')[0]})
Burç 2: $sign2 (Doğum tarihi: ${birthDate2.toIso8601String().split('T')[0]})

Bu iki burç arasındaki uyumluluğu detaylı analiz et.
''';

      final response = await _makeGPTRequest(prompt);
      return _parseJsonResponse(response);
    } catch (e) {
      throw Exception('Burç uyumluluğu analizi yapılırken hata: $e');
    }
  }

  // Kişi analizi
  static Future<Map<String, dynamic>> analyzePersonDescription(
    String description,
    Map<String, dynamic> personalityTraits,
  ) async {
    try {
      final traitsText = personalityTraits.entries
          .map((e) => '${e.key}: ${e.value}')
          .join('\n');

      final prompt = '''
Sen bir kişilik uzmanısın. Verilen bilgilere dayanarak kişilik analizi yap.
Analiz sonucunu Türkçe olarak JSON formatında döndür:

{
  "personality_type": "MBTI veya benzeri tip",
  "dominant_traits": ["Özellik 1", "Özellik 2"],
  "strengths": ["Güçlü yan 1", "Güçlü yan 2"],
  "weaknesses": ["Zayıf yan 1", "Zayıf yan 2"],
  "communication_style": "İletişim tarzı",
  "relationship_approach": "İlişki yaklaşımı",
  "compatibility_with": ["Uyumlu tipler"],
  "potential_challenges": ["Potansiyel zorluklar"],
  "growth_areas": ["Gelişim alanları"],
  "career_suggestions": ["Kariyer önerileri"],
  "relationship_advice": "İlişki tavsiyeleri"
}

Kişi açıklaması: $description

Kişilik özellikleri:
$traitsText
''';

      final response = await _makeGPTRequest(prompt);
      return _parseJsonResponse(response);
    } catch (e) {
      throw Exception('Kişi analizi yapılırken hata: $e');
    }
  }

  // Görseli açıklama (screenshot'lar için)
  static Future<String> describeImage(Uint8List imageBytes) async {
    try {
      final base64Image = base64Encode(imageBytes);
      
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: _headers,
        body: jsonEncode({
          'model': 'gpt-4o-mini', // Updated from deprecated gpt-4-vision-preview
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text': 'Bu görselde ne görüyorsun? WhatsApp konuşması veya sosyal medya içeriği ise, ilişki dinamikleri açısından önemli detayları açıkla. Türkçe yanıtla.',
                },
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:image/jpeg;base64,$base64Image',
                  },
                },
              ],
            },
          ],
          'max_tokens': 1000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Görsel açıklama hatası: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Görsel analizi yapılırken hata: $e');
    }
  }

  // İlişki önerileri
  static Future<List<String>> generateRelationshipAdvice(
    String relationshipType,
    Map<String, dynamic> analysisResults,
  ) async {
    try {
      final prompt = '''
İlişki uzmanı olarak, şu analiz sonuçlarına dayanarak pratik tavsiyeler ver:

İlişki türü: $relationshipType
Analiz sonuçları: ${jsonEncode(analysisResults)}

5-7 adet pratik tavsiye ver. Her tavsiye 1-2 cümle olsun ve uygulanabilir olsun.
Sadece tavsiyeleri liste halinde döndür, başka açıklama yapma.
''';

      final response = await _makeGPTRequest(prompt);
      
      // Yanıtı satır satır ayır ve temizle
      final lines = response.split('\n')
          .where((line) => line.trim().isNotEmpty)
          .map((line) => line.replaceFirst(RegExp(r'^\d+\.\s*'), ''))
          .map((line) => line.replaceFirst(RegExp(r'^-\s*'), ''))
          .where((line) => line.length > 10)
          .toList();

      return lines;
    } catch (e) {
      throw Exception('Tavsiye oluşturulurken hata: $e');
    }
  }

  // Gelecek tahmini
  static Future<String> predictRelationshipFuture(
    Map<String, dynamic> currentAnalysis,
    List<Map<String, dynamic>> historicalData,
  ) async {
    try {
      final prompt = '''
İlişki uzmanı olarak, mevcut analiz ve geçmiş verilere dayanarak ilişkinin gelecekteki muhtemel gelişimini tahmin et.

Mevcut analiz: ${jsonEncode(currentAnalysis)}
Geçmiş veriler: ${jsonEncode(historicalData)}

1-2 paragraf halinde, objektif ve umut verici bir gelecek tahmini yap.
''';

      final response = await _makeGPTRequest(prompt);
      return response.trim();
    } catch (e) {
      throw Exception('Gelecek tahmini yapılırken hata: $e');
    }
  }

  // Özel sorular için AI yanıtı
  static Future<String> askRelationshipQuestion(String question, Map<String, dynamic>? context) async {
    try {
      final contextText = context != null ? '\n\nBağlam: ${jsonEncode(context)}' : '';
      
      final prompt = '''
Sen uzman bir ilişki danışmanısın. Kullanıcının sorusunu Türkçe olarak yanıtla.
Yanıtın pratik, empatik ve uygulanabilir olsun.

Soru: $question$contextText
''';

      final response = await _makeGPTRequest(prompt);
      return response.trim();
    } catch (e) {
      throw Exception('Soru yanıtlanırken hata: $e');
    }
  }

  // Özel GPT isteği
  static Future<String> _makeGPTRequest(String prompt) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: _headers,
      body: jsonEncode({
        'model': 'gpt-4',
        'messages': [
          {
            'role': 'system',
            'content': 'Sen uzman bir ilişki danışmanı ve kişilik analisti sin. Türkçe yanıt ver.',
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        'max_tokens': 2000,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('OpenAI API hatası: ${response.statusCode} - ${response.body}');
    }
  }

  // JSON yanıtını parse et
  static Map<String, dynamic> _parseJsonResponse(String response) {
    try {
      // JSON kısmını bul ve parse et
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}') + 1;
      
      if (jsonStart == -1 || jsonEnd <= jsonStart) {
        throw Exception('JSON formatı bulunamadı');
      }

      final jsonString = response.substring(jsonStart, jsonEnd);
      return jsonDecode(jsonString);
    } catch (e) {
      // JSON parse edilemezse basit bir yanıt döndür
      return {
        'detailed_analysis': response,
        'overall_score': 75,
        'compatibility_percentage': 75,
        'strengths': ['İletişim', 'Uyum'],
        'areas_for_improvement': ['Zaman yönetimi'],
        'recommendations': ['Daha fazla kaliteli zaman geçirin'],
        'future_outlook': 'Pozitif gelişim bekleniyor',
      };
    }
  }

  // API key kontrolü
  static bool get isConfigured => _apiKey.isNotEmpty;

  // Model listesi
  static const List<String> availableModels = [
    'gpt-4',
    'gpt-4-vision-preview',
    'gpt-3.5-turbo',
  ];

  // Token hesaplama (yaklaşık)
  static int estimateTokens(String text) {
    return (text.length / 4).ceil(); // Yaklaşık hesaplama
  }

  // Maliyet hesaplama (USD)
  static double estimateCost(String model, int tokens) {
    switch (model) {
      case 'gpt-4':
        return tokens * 0.00003; // $0.03 per 1K tokens
      case 'gpt-4-vision-preview':
        return tokens * 0.00001; // $0.01 per 1K tokens
      case 'gpt-3.5-turbo':
        return tokens * 0.000001; // $0.001 per 1K tokens
      default:
        return tokens * 0.00001;
    }
  }
}