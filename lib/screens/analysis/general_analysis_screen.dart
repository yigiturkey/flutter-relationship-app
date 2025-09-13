import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/analysis_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/widgets/custom_button.dart';

class GeneralAnalysisScreen extends StatefulWidget {
  const GeneralAnalysisScreen({super.key});

  @override
  State<GeneralAnalysisScreen> createState() => _GeneralAnalysisScreenState();
}

class _GeneralAnalysisScreenState extends State<GeneralAnalysisScreen> {
  @override
  void initState() {
    super.initState();
    _loadAnalyses();
  }

  void _loadAnalyses() {
    final analysisProvider = context.read<AnalysisProvider>();
    analysisProvider.loadUserAnalyses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analizlerim'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/instant-analysis');
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Consumer<AnalysisProvider>(
        builder: (context, analysisProvider, child) {
          if (analysisProvider.isLoading) {
            return const Center(
              child: LoadingIndicator(),
            );
          }

          if (analysisProvider.userAnalyses.isEmpty) {
            return _buildEmptyState();
          }

          return _buildAnalysesList(analysisProvider.userAnalyses);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.analytics_outlined,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'Henüz Analiz Yok',
              style: AppFonts.headingMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              'İlk analizinizi yaparak ilişkiniz hakkında derinlemesine bilgiler edinin.',
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Anlık Analiz',
                    onPressed: () {
                      Navigator.pushNamed(context, '/instant-analysis');
                    },
                    icon: const Icon(Icons.flash_on, size: 20),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                Expanded(
                  child: CustomButton(
                    text: 'Burç Uyumu',
                    onPressed: () {
                      Navigator.pushNamed(context, '/horoscope-analysis');
                    },
                    variant: CustomButtonVariant.outlined,
                    icon: const Icon(Icons.star, size: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysesList(List<dynamic> analyses) {
    return RefreshIndicator(
      onRefresh: () async {
        _loadAnalyses();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: analyses.length,
        itemBuilder: (context, index) {
          final analysis = analyses[index];
          return _buildAnalysisCard(analysis);
        },
      ),
    );
  }

  Widget _buildAnalysisCard(dynamic analysis) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/analysis-result', arguments: {
            'analysisId': analysis.id,
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
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getAnalysisColor(analysis.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getAnalysisIcon(analysis.type),
                      color: _getAnalysisColor(analysis.type),
                      size: 24,
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
                          _getAnalysisTypeLabel(analysis.type),
                          style: AppFonts.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  _buildStatusBadge(analysis.status),
                ],
              ),
              
              if (analysis.results != null && analysis.results['overall_score'] != null) ...[
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: AppColors.success,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Genel Skor: ${analysis.results['overall_score']}%',
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 12),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${analysis.createdAt.day}/${analysis.createdAt.month}/${analysis.createdAt.year}',
                    style: AppFonts.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    
    switch (status) {
      case 'completed':
        color = AppColors.success;
        label = 'Tamamlandı';
        break;
      case 'processing':
        color = AppColors.warning;
        label = 'İşleniyor';
        break;
      case 'failed':
        color = AppColors.error;
        label = 'Hata';
        break;
      default:
        color = AppColors.info;
        label = 'Bekliyor';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppFonts.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  IconData _getAnalysisIcon(String type) {
    switch (type) {
      case 'whatsappConversation':
        return Icons.chat;
      case 'socialMediaContent':
        return Icons.photo_camera;
      case 'horoscopeCompatibility':
        return Icons.star;
      case 'personalityAnalysis':
        return Icons.psychology;
      case 'relationshipAssessment':
        return Icons.favorite;
      case 'futureReport':
        return Icons.timeline;
      default:
        return Icons.analytics;
    }
  }

  Color _getAnalysisColor(String type) {
    switch (type) {
      case 'whatsappConversation':
        return AppColors.success;
      case 'socialMediaContent':
        return AppColors.accent;
      case 'horoscopeCompatibility':
        return AppColors.secondary;
      case 'personalityAnalysis':
        return AppColors.warning;
      case 'relationshipAssessment':
        return AppColors.primary;
      case 'futureReport':
        return AppColors.info;
      default:
        return AppColors.primary;
    }
  }

  String _getAnalysisTypeLabel(String type) {
    switch (type) {
      case 'whatsappConversation':
        return 'WhatsApp Analizi';
      case 'socialMediaContent':
        return 'Sosyal Medya Analizi';
      case 'horoscopeCompatibility':
        return 'Burç Uyumluluğu';
      case 'personalityAnalysis':
        return 'Kişilik Analizi';
      case 'relationshipAssessment':
        return 'İlişki Değerlendirmesi';
      case 'futureReport':
        return 'Gelecek Raporu';
      default:
        return 'Genel Analiz';
    }
  }
}