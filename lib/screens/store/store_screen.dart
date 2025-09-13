import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/widgets/custom_button.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  final List<StorePackage> _tokenPackages = [
    StorePackage(
      id: 'tokens_100',
      title: '100 Token',
      description: '10 temel analiz',
      price: 29.99,
      currency: 'TL',
      tokens: 100,
      isPopular: false,
      features: [
        'Temel analizler',
        '30 gün geçerlilik',
        'Email desteği',
      ],
    ),
    StorePackage(
      id: 'tokens_300',
      title: '300 Token',
      description: '30 temel analiz',
      price: 79.99,
      currency: 'TL',
      tokens: 300,
      isPopular: true,
      discount: 0.2,
      features: [
        'Tüm analiz türleri',
        '60 gün geçerlilik',
        'Email desteği',
        '%20 bonus token',
      ],
    ),
    StorePackage(
      id: 'tokens_1000',
      title: '1000 Token',
      description: '100+ analiz',
      price: 199.99,
      currency: 'TL',
      tokens: 1000,
      isPopular: false,
      discount: 0.3,
      features: [
        'Tüm analiz türleri',
        '90 gün geçerlilik',
        'Öncelikli destek',
        '%30 bonus token',
        'Özel raporlar',
      ],
    ),
  ];

  final List<StorePackage> _premiumPlans = [
    StorePackage(
      id: 'premium_monthly',
      title: 'Aylık Premium',
      description: 'Tüm özellikler 1 ay',
      price: 49.99,
      currency: 'TL',
      tokens: 500,
      isPremium: true,
      period: 'Aylık',
      features: [
        'Sınırsız temel analiz',
        'Günlük 5 premium analiz',
        'Tüm eğitimlere erişim',
        'Reklamsız deneyim',
        'Öncelikli destek',
      ],
    ),
    StorePackage(
      id: 'premium_annual',
      title: 'Yıllık Premium',
      description: 'Tüm özellikler 1 yıl',
      price: 399.99,
      currency: 'TL',
      tokens: 6000,
      isPremium: true,
      period: 'Yıllık',
      isPopular: true,
      discount: 0.33,
      features: [
        'Sınırsız tüm analizler',
        'Özel AI modelleri',
        'Tüm eğitimlere erişim',
        'Reklamsız deneyim',
        '24/7 destek',
        '%33 tasarruf',
        'Gelecek tahminleri',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mağaza'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Token Paketleri'),
            Tab(text: 'Premium Planları'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Current balance
          _buildCurrentBalance(),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTokenPackages(),
                _buildPremiumPlans(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentBalance() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.1), AppColors.secondary.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.star,
              color: AppColors.warning,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mevcut Bakiyeniz',
                  style: AppFonts.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '150 Token',
                  style: AppFonts.headingMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          CustomButton(
            text: 'Geçmiş',
            onPressed: () {
              Navigator.pushNamed(context, '/purchase-history');
            },
            variant: CustomButtonVariant.outlined,
            size: CustomButtonSize.small,
          ),
        ],
      ),
    );
  }

  Widget _buildTokenPackages() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _tokenPackages.length,
      itemBuilder: (context, index) {
        return _buildPackageCard(_tokenPackages[index]);
      },
    );
  }

  Widget _buildPremiumPlans() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _premiumPlans.length,
      itemBuilder: (context, index) {
        return _buildPackageCard(_premiumPlans[index]);
      },
    );
  }

  Widget _buildPackageCard(StorePackage package) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: package.isPopular ? AppColors.primary : AppColors.lightGray,
                width: package.isPopular ? 2 : 1,
              ),
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
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            package.title,
                            style: AppFonts.headingMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            package.description,
                            style: AppFonts.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (package.discount != null) ...[
                          Text(
                            '${(package.price / (1 - package.discount!)).toStringAsFixed(2)} ${package.currency}',
                            style: AppFonts.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                        Text(
                          '${package.price.toStringAsFixed(2)} ${package.currency}',
                          style: AppFonts.headingMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (package.period != null)
                          Text(
                            package.period!,
                            style: AppFonts.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Token info
                if (package.tokens > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${package.tokens} Token',
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                // Features
                ...package.features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: AppFonts.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
                
                const SizedBox(height: 16),
                
                // Purchase button
                CustomButton(
                  text: package.isPremium ? 'Premium Ol' : 'Satın Al',
                  onPressed: () => _purchasePackage(package),
                  width: double.infinity,
                  variant: package.isPopular 
                      ? CustomButtonVariant.primary 
                      : CustomButtonVariant.outlined,
                ),
              ],
            ),
          ),
          
          // Popular badge
          if (package.isPopular)
            Positioned(
              top: -1,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'En Popüler',
                  style: AppFonts.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          
          // Discount badge
          if (package.discount != null)
            Positioned(
              top: 16,
              left: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '%${(package.discount! * 100).toInt()} İndirim',
                  style: AppFonts.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _purchasePackage(StorePackage package) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Satın Alma Onayı'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${package.title} paketini satın almak istediğinizden emin misiniz?'),
            const SizedBox(height: 8),
            Text(
              'Fiyat: ${package.price.toStringAsFixed(2)} ${package.currency}',
              style: AppFonts.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
            if (package.tokens > 0)
              Text('Token: ${package.tokens}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          CustomButton(
            text: 'Satın Al',
            onPressed: () {
              Navigator.pop(context);
              _processPurchase(package);
            },
          ),
        ],
      ),
    );
  }

  void _processPurchase(StorePackage package) {
    // TODO: Implement actual purchase logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${package.title} satın alma işlemi başlatıldı'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}

class StorePackage {
  final String id;
  final String title;
  final String description;
  final double price;
  final String currency;
  final int tokens;
  final bool isPopular;
  final bool isPremium;
  final String? period;
  final double? discount;
  final List<String> features;

  StorePackage({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.currency,
    required this.tokens,
    this.isPopular = false,
    this.isPremium = false,
    this.period,
    this.discount,
    required this.features,
  });
}