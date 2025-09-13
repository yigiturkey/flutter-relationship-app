import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import '../../providers/relationship_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_textfield.dart';

class SocialMediaAnalysisScreen extends StatefulWidget {
  const SocialMediaAnalysisScreen({super.key});

  @override
  State<SocialMediaAnalysisScreen> createState() => _SocialMediaAnalysisScreenState();
}

class _SocialMediaAnalysisScreenState extends State<SocialMediaAnalysisScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  
  String _selectedPlatform = 'Instagram';
  List<File> _selectedImages = [];
  List<Uint8List> _imageBytes = [];

  final List<String> _platforms = [
    'Instagram',
    'Facebook', 
    'Twitter',
    'TikTok',
    'LinkedIn',
    'Snapchat',
    'Pinterest',
    'Diğer',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sosyal Medya Analizi'),
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
                
                // Platform selection
                _buildPlatformSelection(),
                
                const SizedBox(height: 24),
                
                // Description
                _buildDescriptionSection(),
                
                const SizedBox(height: 24),
                
                // Image upload
                _buildImageUploadSection(),
                
                const SizedBox(height: 32),
                
                // Analyze button
                Consumer<RelationshipProvider>(
                  builder: (context, relationshipProvider, child) {
                    return CustomButton(
                      text: 'İçeriği Analiz Et',
                      onPressed: _canAnalyze() && !relationshipProvider.isProcessing
                          ? _analyzeContent
                          : null,
                      isLoading: relationshipProvider.isProcessing,
                      width: double.infinity,
                      icon: const Icon(Icons.photo_camera, size: 20),
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Examples
                _buildExamples(),
                
                const SizedBox(height: 24),
                
                // Privacy info
                _buildPrivacyInfo(),
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
            color: AppColors.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.photo_camera,
            color: AppColors.accent,
            size: 30,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Text(
          'Sosyal Medya İçerik Analizi',
          style: AppFonts.headingLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'Sosyal medya paylaşımlarınızı analiz ederek ilişki dinamiklerinizi keşfedin.',
          style: AppFonts.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPlatformSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Platform',
          style: AppFonts.headingSmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 12),
        
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.lightGray),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedPlatform,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPlatform = newValue!;
                });
              },
              items: _platforms.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: [
                      Icon(
                        _getPlatformIcon(value),
                        color: _getPlatformColor(value),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(value),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'İçerik Açıklaması',
          style: AppFonts.headingSmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 12),
        
        CustomTextField(
          controller: _descriptionController,
          label: 'Paylaşım Açıklaması',
          hintText: 'Sosyal medya paylaşımınızı açıklayın...',
          maxLines: 4,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'İçerik açıklaması gerekli';
            }
            if (value.length < 20) {
              return 'Açıklama en az 20 karakter olmalı';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Görsel İçerikler',
              style: AppFonts.headingSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            TextButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.add_photo_alternate, size: 20),
              label: const Text('Görsel Ekle'),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        if (_selectedImages.isEmpty)
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.lightGray, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sosyal medya görselleri yükleyin',
                  style: AppFonts.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'PNG, JPG veya JPEG formatında',
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _selectedImages.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: FileImage(_selectedImages[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }

  Widget _buildExamples() {
    final examples = [
      'Partnerimle birlikte tatil fotoğrafları',
      'Yıldönümü kutlama paylaşımları',
      'Günlük yaşam momentleri',
      'Birlikte yapılan aktiviteler',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Örnek İçerikler',
          style: AppFonts.headingSmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 12),
        
        ...examples.map((example) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () {
              _descriptionController.text = example;
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
        )),
      ],
    );
  }

  Widget _buildPrivacyInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.privacy_tip_outlined,
                color: AppColors.warning,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Gizlilik ve Güvenlik',
                style: AppFonts.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Yüklediğiniz görseller sadece analiz için kullanılır ve güvenli şekilde saklanır. Kişisel bilgileriniz korunur.',
            style: AppFonts.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform) {
      case 'Instagram':
        return Icons.camera_alt;
      case 'Facebook':
        return Icons.facebook;
      case 'Twitter':
        return Icons.alternate_email;
      case 'TikTok':
        return Icons.music_video;
      case 'LinkedIn':
        return Icons.work;
      case 'Snapchat':
        return Icons.camera;
      case 'Pinterest':
        return Icons.push_pin;
      default:
        return Icons.share;
    }
  }

  Color _getPlatformColor(String platform) {
    switch (platform) {
      case 'Instagram':
        return Colors.purple;
      case 'Facebook':
        return Colors.blue;
      case 'Twitter':
        return Colors.lightBlue;
      case 'TikTok':
        return Colors.black;
      case 'LinkedIn':
        return Colors.indigo;
      case 'Snapchat':
        return Colors.yellow;
      case 'Pinterest':
        return Colors.red;
      default:
        return AppColors.textSecondary;
    }
  }

  Future<void> _pickImages() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null) {
        final newImages = result.files.map((file) => File(file.path!)).toList();
        final newImageBytes = <Uint8List>[];
        
        for (final image in newImages) {
          final bytes = await image.readAsBytes();
          newImageBytes.add(bytes);
        }
        
        setState(() {
          _selectedImages.addAll(newImages);
          _imageBytes.addAll(newImageBytes);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Görsel seçilirken hata: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
      _imageBytes.removeAt(index);
    });
  }

  bool _canAnalyze() {
    return _descriptionController.text.isNotEmpty && 
           _descriptionController.text.length >= 20;
  }

  Future<void> _analyzeContent() async {
    if (!_formKey.currentState!.validate() || !_canAnalyze()) return;

    final authProvider = context.read<AuthProvider>();
    final relationshipProvider = context.read<RelationshipProvider>();
    
    if (authProvider.currentUser == null) return;

    final success = await relationshipProvider.analyzeSocialMediaContent(
      userId: authProvider.currentUser!.uid,
      platform: _selectedPlatform,
      description: _descriptionController.text.trim(),
      imageFiles: _imageBytes.isNotEmpty ? _imageBytes : null,
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