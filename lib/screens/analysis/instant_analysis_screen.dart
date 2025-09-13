import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/analysis_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../core/widgets/loading_indicator.dart';

class InstantAnalysisScreen extends StatefulWidget {
  const InstantAnalysisScreen({super.key});

  @override
  State<InstantAnalysisScreen> createState() => _InstantAnalysisScreenState();
}

class _InstantAnalysisScreenState extends State<InstantAnalysisScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _contextController = TextEditingController();

  @override
  void dispose() {
    _questionController.dispose();
    _contextController.dispose();
    super.dispose();
  }

  Future<void> _submitAnalysis() async {
    if (!_formKey.currentState!.validate()) return;

    final analysisProvider = context.read<AnalysisProvider>();
    
    final success = await analysisProvider.createInstantAnalysis(
      question: _questionController.text.trim(),
      context: _contextController.text.trim(),
    );

    if (success && mounted) {
      Navigator.pushNamed(context, '/analysis-result', arguments: {
        'analysisId': analysisProvider.currentAnalysis?.id,
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(analysisProvider.errorMessage ?? 'Analiz yapılamadı'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anlık Analiz'),
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
                
                // Question field
                CustomTextField(
                  controller: _questionController,
                  label: 'Sorunuz',
                  hintText: 'İlişkiniz hakkında merak ettiğiniz soruyu yazın...',
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen bir soru yazın';
                    }
                    if (value.length < 10) {
                      return 'Soru en az 10 karakter olmalı';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Context field
                CustomTextField(
                  controller: _contextController,
                  label: 'Ek Bilgi (İsteğe bağlı)',
                  hintText: 'İlişkinizle ilgili ek detaylar ekleyebilirsiniz...',
                  maxLines: 4,
                ),
                
                const SizedBox(height: 32),
                
                // Submit button
                Consumer<AnalysisProvider>(
                  builder: (context, analysisProvider, child) {
                    return CustomButton(
                      text: 'Analizi Başlat',
                      onPressed: analysisProvider.isLoading ? null : _submitAnalysis,
                      isLoading: analysisProvider.isLoading,
                      width: double.infinity,
                      icon: const Icon(Icons.flash_on, size: 20),
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Info card
                _buildInfoCard(),
                
                const SizedBox(height: 24),
                
                // Examples
                _buildExamples(),
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
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.flash_on,
            color: AppColors.primary,
            size: 30,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Text(
          'Anlık AI Analizi',
          style: AppFonts.headingLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'İlişkiniz hakkında merak ettiğiniz herhangi bir soruyu sorun, AI uzmanımız anında analiz edip öneriler sunacak.',
          style: AppFonts.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.info,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Analiz sonuçları tamamen gizli tutulur ve sadece sizin için hazırlanır.',
              style: AppFonts.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamples() {
    final examples = [
      'Partnerimle daha iyi iletişim nasıl kurabilirim?',
      'İlişkimizde yaşadığımız sorunları nasıl çözeriz?',
      'Birbirimizi daha iyi nasıl anlayabiliriz?',
      'İlişkimizi nasıl güçlendirebiliriz?',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Örnek Sorular',
          style: AppFonts.headingSmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 12),
        
        ...examples.map((example) => _buildExampleCard(example)),
      ],
    );
  }

  Widget _buildExampleCard(String example) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          _questionController.text = example;
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.lightGray),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppColors.accent,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  example,
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textSecondary,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}