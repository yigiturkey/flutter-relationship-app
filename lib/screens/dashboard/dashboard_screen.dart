import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/analysis_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/widgets/custom_button.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<BottomNavItem> _navItems = [
    BottomNavItem(
      icon: Icons.dashboard,
      activeIcon: Icons.dashboard,
      label: 'Ana Sayfa',
    ),
    BottomNavItem(
      icon: Icons.analytics_outlined,
      activeIcon: Icons.analytics,
      label: 'Analiz',
    ),
    BottomNavItem(
      icon: Icons.school_outlined,
      activeIcon: Icons.school,
      label: 'Eğitim',
    ),
    BottomNavItem(
      icon: Icons.games_outlined,
      activeIcon: Icons.games,
      label: 'Oyunlar',
    ),
    BottomNavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profil',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    final userProvider = context.read<UserProvider>();
    final analysisProvider = context.read<AnalysisProvider>();
    
    userProvider.loadUserProfile();
    analysisProvider.loadRecentAnalyses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildAnalysisTab();
      case 2:
        return _buildTrainingTab();
      case 3:
        return _buildGamesTab();
      case 4:
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            
            const SizedBox(height: 24),
            
            // Quick actions
            _buildQuickActions(),
            
            const SizedBox(height: 24),
            
            // Recent analyses
            _buildRecentAnalyses(),
            
            const SizedBox(height: 24),
            
            // Training progress
            _buildTrainingProgress(),
            
            const SizedBox(height: 24),
            
            // Daily tip
            _buildDailyTip(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.currentUser;
        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Merhaba,',
                    style: AppFonts.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    user?.displayName ?? 'Kullanıcı',
                    style: AppFonts.headingMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // Notifications
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/notifications');
              },
              icon: Stack(
                children: [
                  const Icon(
                    Icons.notifications_outlined,
                    size: 28,
                    color: AppColors.textSecondary,
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      QuickAction(
        title: 'Anlık Analiz',
        subtitle: 'Hızlı ilişki analizi',
        icon: Icons.flash_on,
        color: AppColors.primary,
        onTap: () => Navigator.pushNamed(context, '/instant-analysis'),
      ),
      QuickAction(
        title: 'Burç Uyumu',
        subtitle: 'Astrolojik analiz',
        icon: Icons.star,
        color: AppColors.secondary,
        onTap: () => Navigator.pushNamed(context, '/horoscope-analysis'),
      ),
      QuickAction(
        title: 'WhatsApp Analizi',
        subtitle: 'Konuşma analizi',
        icon: Icons.chat,
        color: AppColors.accent,
        onTap: () => Navigator.pushNamed(context, '/whatsapp-analysis'),
      ),
      QuickAction(
        title: 'Sosyal Medya',
        subtitle: 'İçerik analizi',
        icon: Icons.photo_camera,
        color: AppColors.success,
        onTap: () => Navigator.pushNamed(context, '/social-media-analysis'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hızlı İşlemler',
          style: AppFonts.headingSmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return _buildQuickActionCard(action);
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(QuickAction action) {
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: action.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  action.icon,
                  color: action.color,
                  size: 24,
                ),
              ),
              
              const SizedBox(height: 12),
              
              Text(
                action.title,
                style: AppFonts.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 4),
              
              Text(
                action.subtitle,
                style: AppFonts.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentAnalyses() {
    return Consumer<AnalysisProvider>(
      builder: (context, analysisProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Son Analizler',
                  style: AppFonts.headingSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
                  child: Text(
                    'Tümünü Gör',
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            analysisProvider.recentAnalyses.isEmpty
                ? _buildEmptyState('Henüz analiz yapılmamış')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: analysisProvider.recentAnalyses.length > 3 
                        ? 3 
                        : analysisProvider.recentAnalyses.length,
                    itemBuilder: (context, index) {
                      final analysis = analysisProvider.recentAnalyses[index];
                      return _buildAnalysisCard(analysis);
                    },
                  ),
          ],
        );
      },
    );
  }

  Widget _buildAnalysisCard(dynamic analysis) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getAnalysisIcon(analysis.type),
              color: AppColors.primary,
              size: 20,
            ),
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  analysis.title,
                  style: AppFonts.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${analysis.createdAt.day}/${analysis.createdAt.month}/${analysis.createdAt.year}',
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

  IconData _getAnalysisIcon(String type) {
    switch (type) {
      case 'whatsapp':
        return Icons.chat;
      case 'horoscope':
        return Icons.star;
      case 'social_media':
        return Icons.photo_camera;
      default:
        return Icons.analytics;
    }
  }

  Widget _buildTrainingProgress() {
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
          Text(
            'Eğitim İlerlemeniz',
            style: AppFonts.headingSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            '3 eğitim tamamlandı, 2 eğitim devam ediyor',
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: 16),
          
          CustomButton(
            text: 'Eğitimlere Git',
            onPressed: () {
              setState(() {
                _selectedIndex = 2;
              });
            },
            variant: CustomButtonVariant.outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTip() {
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
                Icons.lightbulb_outline,
                color: AppColors.accent,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Günün Tavsiyesi',
                style: AppFonts.headingSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'İlişkinizde daha iyi iletişim kurmak için günde en az 10 dakika kaliteli sohbet zamanı ayırın.',
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisTab() {
    return Center(
      child: Text(
        'Analiz Sekmesi',
        style: AppFonts.headingMedium,
      ),
    );
  }

  Widget _buildTrainingTab() {
    return Center(
      child: Text(
        'Eğitim Sekmesi',
        style: AppFonts.headingMedium,
      ),
    );
  }

  Widget _buildGamesTab() {
    return Center(
      child: Text(
        'Oyunlar Sekmesi',
        style: AppFonts.headingMedium,
      ),
    );
  }

  Widget _buildProfileTab() {
    return Center(
      child: Text(
        'Profil Sekmesi',
        style: AppFonts.headingMedium,
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: AppFonts.caption.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppFonts.caption,
        items: _navItems.map((item) {
          final isSelected = _navItems.indexOf(item) == _selectedIndex;
          return BottomNavigationBarItem(
            icon: Icon(isSelected ? item.activeIcon : item.icon),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }
}

class QuickAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  QuickAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}