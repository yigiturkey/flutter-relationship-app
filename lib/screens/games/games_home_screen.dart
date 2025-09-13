import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/widgets/custom_button.dart';

class GamesHomeScreen extends StatefulWidget {
  const GamesHomeScreen({super.key});

  @override
  State<GamesHomeScreen> createState() => _GamesHomeScreenState();
}

class _GamesHomeScreenState extends State<GamesHomeScreen> {
  final List<GameCategory> _gameCategories = [
    GameCategory(
      title: 'İletişim Oyunları',
      description: 'Partnerinizle iletişiminizi güçlendiren oyunlar',
      icon: Icons.chat_bubble_outline,
      color: AppColors.primary,
      games: [
        'Soru Cevap Oyunu',
        '20 Soru',
        'İletişim Kartları',
        'Duygu Tahmin Oyunu',
      ],
    ),
    GameCategory(
      title: 'Empati Oyunları',
      description: 'Birbirinizi daha iyi anlamanızı sağlayan oyunlar',
      icon: Icons.favorite_outline,
      color: AppColors.secondary,
      games: [
        'Rol Değişimi',
        'Empati Senaryoları',
        'Duygu Haritası',
        'Perspektif Oyunu',
      ],
    ),
    GameCategory(
      title: 'Eğlence Oyunları',
      description: 'Birlikte keyifli vakit geçireceğiniz oyunlar',
      icon: Icons.celebration,
      color: AppColors.accent,
      games: [
        'Çift Trivia',
        'Anı Paylaşımı',
        'Gelecek Planları',
        'Hayal Kurma',
      ],
    ),
    GameCategory(
      title: 'Değerlendirme',
      description: 'İlişkinizi değerlendiren interaktif testler',
      icon: Icons.assessment,
      color: AppColors.success,
      games: [
        'Uyumluluk Testi',
        'İletişim Stili Analizi',
        'Çatışma Çözme Testi',
        'Sevgi Dilleri Testi',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oyunlar'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            
            const SizedBox(height: 24),
            
            // Daily challenge
            _buildDailyChallenge(),
            
            const SizedBox(height: 24),
            
            // Game categories
            Text(
              'Oyun Kategorileri',
              style: AppFonts.headingMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            ...(_gameCategories.map((category) => _buildCategoryCard(category))),
            
            const SizedBox(height: 24),
            
            // Recent games
            _buildRecentGames(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.1), AppColors.secondary.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.games,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'İlişki Oyunları',
                      style: AppFonts.headingMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Eğlenerek öğrenin ve bağınızı güçlendirin',
                      style: AppFonts.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Partnerinizle birlikte oynayabileceğiniz interaktif oyunlarla ilişkinizi geliştirin.',
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyChallenge() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.today,
                color: AppColors.accent,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Günlük Meydan Okuma',
                style: AppFonts.headingSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '10 puan',
                  style: AppFonts.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Birbirinizin en sevdiği çocukluk anısını tahmin etmeye çalışın',
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Sırayla sorular sorun ve birbirinizin geçmişi hakkında yeni şeyler öğrenin.',
            style: AppFonts.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: 16),
          
          CustomButton(
            text: 'Oynamaya Başla',
            onPressed: () {
              Navigator.pushNamed(context, '/daily-challenge');
            },
            variant: CustomButtonVariant.outlined,
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(GameCategory category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/game-category', arguments: {
            'category': category,
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: category.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      category.icon,
                      color: category.color,
                      size: 24,
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.title,
                          style: AppFonts.bodyLarge.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          category.description,
                          style: AppFonts.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: category.games.take(3).map((game) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: category.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      game,
                      style: AppFonts.caption.copyWith(
                        color: category.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              if (category.games.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '+${category.games.length - 3} oyun daha',
                    style: AppFonts.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentGames() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Son Oynanan Oyunlar',
          style: AppFonts.headingMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        _buildRecentGameCard('Soru Cevap Oyunu', 'İletişim', Icons.chat_bubble_outline, AppColors.primary, '2 gün önce'),
        _buildRecentGameCard('Empati Senaryoları', 'Empati', Icons.favorite_outline, AppColors.secondary, '5 gün önce'),
        _buildRecentGameCard('Çift Trivia', 'Eğlence', Icons.celebration, AppColors.accent, '1 hafta önce'),
      ],
    );
  }

  Widget _buildRecentGameCard(String title, String category, IconData icon, Color color, String lastPlayed) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lightGray),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppFonts.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$category • $lastPlayed',
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          Icon(
            Icons.replay,
            size: 20,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

class GameCategory {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> games;

  GameCategory({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.games,
  });
}