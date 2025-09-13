import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/widgets/custom_button.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';

class ModernDashboardScreen extends StatefulWidget {
  const ModernDashboardScreen({super.key});

  @override
  State<ModernDashboardScreen> createState() => _ModernDashboardScreenState();
}

class _ModernDashboardScreenState extends State<ModernDashboardScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section
              _buildHeader(),
              
              const SizedBox(height: 20),
              
              // Daily Affirmation Card
              _buildDailyAffirmationCard(),
              
              const SizedBox(height: 24),
              
              // Quick Actions
              _buildQuickActions(),
              
              const SizedBox(height: 24),
              
              // Featured Content Slider
              _buildFeaturedContent(),
              
              const SizedBox(height: 24),
              
              // Categories Grid
              _buildCategoriesGrid(),
              
              const SizedBox(height: 24),
              
              // Recent Activity
              _buildRecentActivity(),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.currentUser;
        final userName = user?.displayName ?? 'Kullanıcı';
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.8),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Merhaba ${userName.split(' ').first} 👋',
                        style: AppFonts.headingMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bugün kendini nasıl hissediyorsun?',
                        style: AppFonts.bodyMedium.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  
                  // Profile Avatar
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/profile'),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        image: user?.photoURL != null
                            ? DecorationImage(
                                image: NetworkImage(user!.photoURL!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: user?.photoURL == null
                          ? const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 25,
                            )
                          : null,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Stats Row
              Row(
                children: [
                  _buildStatItem('Token', '${user?.tokens ?? 0}', Icons.stars),
                  const SizedBox(width: 24),
                  _buildStatItem('Analiz', '12', Icons.analytics),
                  const SizedBox(width: 24),
                  _buildStatItem('Seviye', 'Başlangıç', Icons.emoji_events),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: AppFonts.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: AppFonts.bodySmall.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDailyAffirmationCard() {
    const affirmations = [
      'Bugün kendime karşı nazik olacağım ✨',
      'Her şey mümkün, ben güçlü ve yetenekliyim 💪',
      'İlişkilerimde sevgi ve anlayış var 💕',
      'Bugün yeni bir fırsat ve başlangıç 🌅',
      'İç sesimi dinliyorum ve ona güveniyorum 🧘‍♀️',
    ];
    
    final today = DateTime.now();
    final affirmation = affirmations[today.day % affirmations.length];
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade100,
            Colors.pink.shade100,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.shade200.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.shade200.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.favorite,
              color: Colors.pink.shade400,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Günlük Olumlamam',
                  style: AppFonts.bodyMedium.copyWith(
                    color: Colors.purple.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  affirmation,
                  style: AppFonts.bodyMedium.copyWith(
                    color: Colors.purple.shade600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickActionButton(
              'Hızlı Analiz',
              Icons.flash_on,
              Colors.orange,
              () => Navigator.pushNamed(context, '/instant-analysis'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickActionButton(
              'Günlük Soru',
              Icons.quiz,
              Colors.blue,
              () => Navigator.pushNamed(context, '/daily-question'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickActionButton(
              'Burç Uyumu',
              Icons.favorite,
              Colors.pink,
              () => Navigator.pushNamed(context, '/horoscope-analysis'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppFonts.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Senin İçin Öneriler',
            style: AppFonts.headingSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        SizedBox(
          height: 200,
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            children: [
              _buildFeaturedCard(
                'Podcast: İlişkilerde İletişim',
                'Dr. Ayşe Kaya ile birlikte',
                'assets/images/podcast1.jpg',
                Colors.green,
                () => Navigator.pushNamed(context, '/podcasts'),
              ),
              _buildFeaturedCard(
                'Test: Bağlanma Stilin',
                'Kendini daha iyi tanı',
                'assets/images/test1.jpg',
                Colors.purple,
                () => Navigator.pushNamed(context, '/games'),
              ),
              _buildFeaturedCard(
                'Eğitim: Özgüven Geliştirme',
                '5 dakikalık meditasyon',
                'assets/images/training1.jpg',
                Colors.orange,
                () => Navigator.pushNamed(context, '/trainings'),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Page indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentIndex == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentIndex == index 
                    ? AppColors.primary 
                    : AppColors.lightGray,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFeaturedCard(
    String title,
    String subtitle,
    String imagePath,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.8),
              color,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                Icons.circle,
                size: 120,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: AppFonts.headingSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    subtitle,
                    style: AppFonts.bodyMedium.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Başla',
                        style: AppFonts.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Kategoriler',
            style: AppFonts.headingSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              _buildCategoryCard(
                'İlişki Analizi',
                Icons.favorite_border,
                Colors.pink,
                () => Navigator.pushNamed(context, '/analysis'),
              ),
              _buildCategoryCard(
                'Anketler & Testler',
                Icons.quiz,
                Colors.blue,
                () => Navigator.pushNamed(context, '/games'),
              ),
              _buildCategoryCard(
                'Podcastler',
                Icons.headphones,
                Colors.green,
                () => Navigator.pushNamed(context, '/podcasts'),
              ),
              _buildCategoryCard(
                'Eğitimler',
                Icons.school,
                Colors.orange,
                () => Navigator.pushNamed(context, '/trainings'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.lightGray.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              title,
              style: AppFonts.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Son Aktiviteler',
                style: AppFonts.headingSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              TextButton(
                onPressed: () {},
                child: Text(
                  'Tümünü Gör',
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Activity items
        _buildActivityItem(
          'Burç Uyumluluğu Analizi',
          '2 saat önce',
          Icons.favorite,
          Colors.pink,
        ),
        _buildActivityItem(
          'Kişilik Testi Tamamlandı',
          'Dün',
          Icons.psychology,
          Colors.purple,
        ),
        _buildActivityItem(
          'İletişim Podcast\'i Dinlendi',
          '3 gün önce',
          Icons.headphones,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    String title,
    String time,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppFonts.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  time,
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
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.lightGray.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analiz',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz),
            label: 'Testler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.headphones),
            label: 'Podcast',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              // Ana sayfa zaten açık
              break;
            case 1:
              Navigator.pushNamed(context, '/analysis');
              break;
            case 2:
              Navigator.pushNamed(context, '/games');
              break;
            case 3:
              Navigator.pushNamed(context, '/podcasts');
              break;
            case 4:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }
}