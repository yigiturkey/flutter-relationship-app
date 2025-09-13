import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/relationship_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/relationship_analysis_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_textfield.dart';

class HoroscopeAnalysisScreen extends StatefulWidget {
  const HoroscopeAnalysisScreen({super.key});

  @override
  State<HoroscopeAnalysisScreen> createState() => _HoroscopeAnalysisScreenState();
}

class _HoroscopeAnalysisScreenState extends State<HoroscopeAnalysisScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedSign1;
  String? _selectedSign2;
  DateTime? _birthDate1;
  DateTime? _birthDate2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Burç Uyumluluğu'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(),
                
                const SizedBox(height: 32),
                
                // Person 1
                _buildPersonSection(
                  title: '1. Kişi',
                  selectedSign: _selectedSign1,
                  birthDate: _birthDate1,
                  onSignChanged: (sign) {
                    setState(() {
                      _selectedSign1 = sign;
                    });
                  },
                  onDateChanged: (date) {
                    setState(() {
                      _birthDate1 = date;
                    });
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Person 2
                _buildPersonSection(
                  title: '2. Kişi',
                  selectedSign: _selectedSign2,
                  birthDate: _birthDate2,
                  onSignChanged: (sign) {
                    setState(() {
                      _selectedSign2 = sign;
                    });
                  },
                  onDateChanged: (date) {
                    setState(() {
                      _birthDate2 = date;
                    });
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Analyze button
                Consumer<RelationshipProvider>(
                  builder: (context, relationshipProvider, child) {
                    return CustomButton(
                      text: 'Uyumluluğu Analiz Et',
                      onPressed: _canAnalyze() && !relationshipProvider.isProcessing
                          ? _analyzeCompatibility
                          : null,
                      isLoading: relationshipProvider.isProcessing,
                      width: double.infinity,
                      icon: const Icon(Icons.star, size: 20),
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Info card
                _buildInfoCard(),
                
                const SizedBox(height: 24),
                
                // Recent analyses
                _buildRecentAnalyses(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.star_outline,
            color: AppColors.secondary,
            size: 30,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Text(
          'Burç Uyumluluğu Analizi',
          style: AppFonts.headingLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'İki kişinin astrolojik uyumluluğunu analiz ederek ilişki dinamiklerini keşfedin.',
          style: AppFonts.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPersonSection({
    required String title,
    required String? selectedSign,
    required DateTime? birthDate,
    required Function(String?) onSignChanged,
    required Function(DateTime) onDateChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Text(
            title,
            style: AppFonts.headingSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Burç seçimi
          DropdownButtonFormField<String>(
            value: selectedSign,
            decoration: InputDecoration(
              labelText: 'Burç',
              hintText: 'Burç seçin',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.star_outline),
            ),
            items: ZodiacSign.signs.map((sign) {
              return DropdownMenuItem(
                value: sign,
                child: Row(
                  children: [
                    Text(sign),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        ZodiacSign.signDescriptions[sign] ?? '',
                        style: AppFonts.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: onSignChanged,
            validator: (value) {
              if (value == null) {
                return 'Burç seçimi gerekli';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Doğum tarihi
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: birthDate ?? DateTime.now().subtract(const Duration(days: 7300)),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              
              if (date != null) {
                onDateChanged(date);
                
                // Tarihe göre burcu otomatik belirle
                final autoSign = ZodiacSign.getSignByDate(date);
                if (autoSign != 'Bilinmeyen') {
                  onSignChanged(autoSign);
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.lightGray),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: AppColors.textSecondary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      birthDate != null
                          ? '${birthDate!.day}/${birthDate!.month}/${birthDate!.year}'
                          : 'Doğum tarihini seçin',
                      style: AppFonts.bodyMedium.copyWith(
                        color: birthDate != null
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (birthDate != null && selectedSign != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Otomatik belirlenen burç: ${ZodiacSign.getSignByDate(birthDate!)}',
                style: AppFonts.caption.copyWith(
                  color: AppColors.info,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.secondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Analiz Hakkında',
                style: AppFonts.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Burç uyumluluğu analizi aşk, arkadaşlık, iş ve cinsel uyumluluk gibi farklı alanlarda değerlendirme yapar.',
            style: AppFonts.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAnalyses() {
    return Consumer<RelationshipProvider>(
      builder: (context, relationshipProvider, child) {
        final horoscopeAnalyses = relationshipProvider.horoscopeAnalyses;
        
        if (horoscopeAnalyses.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Son Burç Analizleri',
              style: AppFonts.headingSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 12),
            
            ...horoscopeAnalyses.take(3).map((analysis) => _buildAnalysisCard(analysis)),
          ],
        );
      },
    );
  }

  Widget _buildAnalysisCard(HoroscopeCompatibilityModel analysis) {
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
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.star,
              color: AppColors.secondary,
              size: 20,
            ),
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${analysis.sign1} & ${analysis.sign2}',
                  style: AppFonts.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Uyumluluk: ${analysis.overallScore}%',
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

  bool _canAnalyze() {
    return _selectedSign1 != null &&
           _selectedSign2 != null &&
           _birthDate1 != null &&
           _birthDate2 != null;
  }

  Future<void> _analyzeCompatibility() async {
    if (!_formKey.currentState!.validate() || !_canAnalyze()) return;

    final authProvider = context.read<AuthProvider>();
    final relationshipProvider = context.read<RelationshipProvider>();
    
    if (authProvider.currentUser == null) return;

    final success = await relationshipProvider.analyzeHoroscopeCompatibility(
      userId: authProvider.currentUser!.uid,
      sign1: _selectedSign1!,
      sign2: _selectedSign2!,
      birthDate1: _birthDate1!,
      birthDate2: _birthDate2!,
    );

    if (success && mounted) {
      Navigator.pushNamed(context, '/analysis-result', arguments: {
        'analysisId': relationshipProvider.currentAnalysis?.id,
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(relationshipProvider.errorMessage ?? 'Analiz yapılamadı'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}