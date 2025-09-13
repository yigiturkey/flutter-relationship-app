import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'AI Destekli İlişki Analizi',
      description: 'WhatsApp konuşmalarınızı, sosyal medya paylaşımlarınızı analiz ederek ilişkiniz hakkında derinlemesine bilgiler edinin.',
      icon: Icons.psychology,
      color: AppColors.primary,
    ),
    OnboardingData(
      title: 'Burç Uyumluluğu',
      description: 'Astrolojik uyumluluk analizleri ile partnerinizle aranızdaki kozmik bağı keşfedin.',
      icon: Icons.star_outline,
      color: AppColors.secondary,
    ),
    OnboardingData(
      title: 'Kişisel Gelişim',
      description: 'Uzman eğitmenlerden ilişki becerileri eğitimleri alın ve kendinizi geliştirin.',
      icon: Icons.trending_up,
      color: AppColors.accent,
    ),
    OnboardingData(
      title: 'Interaktif Oyunlar',
      description: 'Eğlenceli oyunlarla partnerinizle aranızdaki bağı güçlendirin.',
      icon: Icons.games,
      color: AppColors.success,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                return _buildPage(_pages[index]);
              },
            ),
          ),
          
          // Indicator ve butonlar
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Page indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index 
                            ? AppColors.primary 
                            : AppColors.lightGray,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Butonlar
                Row(
                  children: [
                    if (_currentPage > 0)
                      Expanded(
                        child: CustomButton(
                          text: 'Geri',
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          variant: CustomButtonVariant.outlined,
                        ),
                      ),
                    
                    if (_currentPage > 0) const SizedBox(width: 16),
                    
                    Expanded(
                      flex: _currentPage == 0 ? 1 : 2,
                      child: CustomButton(
                        text: _currentPage == _pages.length - 1 
                            ? 'Başlayalım' 
                            : 'İleri',
                        onPressed: () {
                          if (_currentPage == _pages.length - 1) {
                            Navigator.pushReplacementNamed(context, '/login');
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
                
                // Atla butonu
                if (_currentPage < _pages.length - 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: Text(
                        'Atla',
                        style: AppFonts.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              data.icon,
              size: 60,
              color: data.color,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Title
          Text(
            data.title,
            style: AppFonts.headingLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 20),
          
          // Description
          Text(
            data.description,
            style: AppFonts.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}