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

class WhatsAppAnalysisScreen extends StatefulWidget {
  const WhatsAppAnalysisScreen({super.key});

  @override
  State<WhatsAppAnalysisScreen> createState() => _WhatsAppAnalysisScreenState();
}

class _WhatsAppAnalysisScreenState extends State<WhatsAppAnalysisScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _conversationController = TextEditingController();
  
  List<File> _selectedImages = [];
  List<Uint8List> _imageBytes = [];
  bool _hasLoadedFile = false;

  @override
  void dispose() {
    _titleController.dispose();
    _conversationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WhatsApp Analizi'),
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
                
                // How to export guide
                _buildExportGuide(),
                
                const SizedBox(height: 24),
                
                // File import options
                _buildFileImportSection(),
                
                const SizedBox(height: 24),
                
                // Manual text input
                _buildManualInputSection(),
                
                const SizedBox(height: 24),
                
                // Image attachments
                _buildImageSection(),
                
                const SizedBox(height: 32),
                
                // Analyze button
                Consumer<RelationshipProvider>(
                  builder: (context, relationshipProvider, child) {
                    return CustomButton(
                      text: 'Konuşmayı Analiz Et',
                      onPressed: _canAnalyze() && !relationshipProvider.isProcessing
                          ? _analyzeConversation
                          : null,
                      isLoading: relationshipProvider.isProcessing,
                      width: double.infinity,
                      icon: const Icon(Icons.chat, size: 20),
                    );
                  },
                ),
                
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
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.chat,
            color: AppColors.success,
            size: 30,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Text(
          'WhatsApp Konuşma Analizi',
          style: AppFonts.headingLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'WhatsApp konuşmalarınızı yükleyerek ilişki dinamiklerinizi analiz edin.',
          style: AppFonts.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildExportGuide() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.info,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'WhatsApp\'tan Konuşma Nasıl Export Edilir',
                style: AppFonts.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          const Text(
            '1. WhatsApp\'ta analiz etmek istediğiniz konuşmayı açın\n'
            '2. Üst kısımda konuşma ismine tıklayın\n'
            '3. "Konuşmayı Export Et" seçeneğini seçin\n'
            '4. "Medya olmadan" seçeneğini tercih edin\n'
            '5. .txt dosyasını bu uygulamaya yükleyin',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileImportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dosya Yükleme',
          style: AppFonts.headingSmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 12),
        
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.lightGray, style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                _hasLoadedFile ? Icons.check_circle : Icons.upload_file,
                size: 48,
                color: _hasLoadedFile ? AppColors.success : AppColors.textSecondary,
              ),
              
              const SizedBox(height: 12),
              
              Text(
                _hasLoadedFile 
                    ? 'WhatsApp dosyası yüklendi'
                    : 'WhatsApp .txt dosyasını yükleyin',
                style: AppFonts.bodyMedium.copyWith(
                  color: _hasLoadedFile ? AppColors.success : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 16),
              
              CustomButton(
                text: _hasLoadedFile ? 'Farklı Dosya Seç' : 'Dosya Seç',
                onPressed: _pickWhatsAppFile,
                variant: CustomButtonVariant.outlined,
                icon: const Icon(Icons.folder_open, size: 20),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildManualInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Manuel Giriş',
          style: AppFonts.headingSmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 12),
        
        CustomTextField(
          controller: _titleController,
          label: 'Konuşma Başlığı',
          hintText: 'Örn: Sevgilimle konuşma',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Konuşma başlığı gerekli';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        CustomTextField(
          controller: _conversationController,
          label: 'Konuşma Metni',
          hintText: 'WhatsApp konuşmanızı buraya kopyalayın...',
          maxLines: 8,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Konuşma metni gerekli';
            }
            if (value.length < 50) {
              return 'Konuşma en az 50 karakter olmalı';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ekli Resimler (İsteğe bağlı)',
              style: AppFonts.headingSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            TextButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.add_photo_alternate, size: 20),
              label: const Text('Resim Ekle'),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        if (_selectedImages.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.lightGray.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.photo_outlined,
                  size: 40,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 8),
                Text(
                  'Konuşmaya ait ekran görüntüleri ekleyebilirsiniz',
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedImages.asMap().entries.map((entry) {
              final index = entry.key;
              final image = entry.value;
              
              return Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: FileImage(image),
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
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
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
                'Gizlilik Güvencesi',
                style: AppFonts.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Yüklediğiniz konuşmalar tamamen gizli tutulur ve sadece analiz için kullanılır. Verileriniz üçüncü taraflarla paylaşılmaz.',
            style: AppFonts.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickWhatsAppFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        
        setState(() {
          _conversationController.text = content;
          _hasLoadedFile = true;
          
          // Extract title from filename
          final fileName = result.files.single.name;
          if (_titleController.text.isEmpty) {
            _titleController.text = fileName.replaceAll('.txt', '');
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('WhatsApp dosyası başarıyla yüklendi'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dosya yüklenirken hata: $e'),
          backgroundColor: AppColors.error,
        ),
      );
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
          content: Text('Resim seçilirken hata: $e'),
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
    return _titleController.text.isNotEmpty && 
           _conversationController.text.isNotEmpty &&
           _conversationController.text.length >= 50;
  }

  Future<void> _analyzeConversation() async {
    if (!_formKey.currentState!.validate() || !_canAnalyze()) return;

    final authProvider = context.read<AuthProvider>();
    final relationshipProvider = context.read<RelationshipProvider>();
    
    if (authProvider.currentUser == null) return;

    final success = await relationshipProvider.analyzeWhatsAppConversation(
      userId: authProvider.currentUser!.uid,
      conversationTitle: _titleController.text.trim(),
      conversationText: _conversationController.text.trim(),
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