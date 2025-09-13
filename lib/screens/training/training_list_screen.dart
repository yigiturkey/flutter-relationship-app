import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/training_provider.dart';
import '../../models/training_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/loading_indicator.dart';

class TrainingListScreen extends StatefulWidget {
  const TrainingListScreen({super.key});

  @override
  State<TrainingListScreen> createState() => _TrainingListScreenState();
}

class _TrainingListScreenState extends State<TrainingListScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTrainings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadTrainings() {
    final trainingProvider = context.read<TrainingProvider>();
    trainingProvider.loadAvailableTrainings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eğitimler'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Tümü'),
            Tab(text: 'Devam Eden'),
            Tab(text: 'Tamamlanan'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search and filters
          _buildSearchAndFilters(),
          
          // Training list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllTrainings(),
                _buildInProgressTrainings(),
                _buildCompletedTrainings(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Eğitim ara...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.lightGray),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.lightGray),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Category filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('all', 'Tümü'),
                _buildFilterChip('communication', 'İletişim'),
                _buildFilterChip('empathy', 'Empati'),
                _buildFilterChip('conflictResolution', 'Çatışma Çözümü'),
                _buildFilterChip('emotionalIntelligence', 'Duygusal Zeka'),
                _buildFilterChip('personalDevelopment', 'Kişisel Gelişim'),
                _buildFilterChip('relationshipSkills', 'İlişki Becerileri'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String category, String label) {
    final isSelected = _selectedCategory == category;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = category;
          });
        },
        backgroundColor: Colors.white,
        selectedColor: AppColors.primary.withOpacity(0.1),
        labelStyle: AppFonts.bodySmall.copyWith(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.lightGray,
        ),
      ),
    );
  }

  Widget _buildAllTrainings() {
    return Consumer<TrainingProvider>(
      builder: (context, trainingProvider, child) {
        if (trainingProvider.isLoadingTrainings) {
          return const Center(child: LoadingIndicator());
        }

        var trainings = trainingProvider.availableTrainings;
        
        // Apply filters
        if (_selectedCategory != 'all') {
          trainings = trainings.where((training) => 
            training.type.toString().split('.').last == _selectedCategory
          ).toList();
        }
        
        if (_searchQuery.isNotEmpty) {
          trainings = trainingProvider.searchTrainings(_searchQuery);
        }

        if (trainings.isEmpty) {
          return _buildEmptyState('Eğitim bulunamadı');
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: trainings.length,
          itemBuilder: (context, index) {
            return _buildTrainingCard(trainings[index]);
          },
        );
      },
    );
  }

  Widget _buildInProgressTrainings() {
    return Consumer<TrainingProvider>(
      builder: (context, trainingProvider, child) {
        final inProgressTrainings = trainingProvider.getInProgressTrainings();
        
        if (inProgressTrainings.isEmpty) {
          return _buildEmptyState('Devam eden eğitim bulunamadı');
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: inProgressTrainings.length,
          itemBuilder: (context, index) {
            final progress = inProgressTrainings[index];
            final training = trainingProvider.availableTrainings
                .where((t) => t.id == progress.trainingId)
                .firstOrNull;
            
            if (training == null) return const SizedBox.shrink();
            
            return _buildTrainingCard(training, progress: progress);
          },
        );
      },
    );
  }

  Widget _buildCompletedTrainings() {
    return Consumer<TrainingProvider>(
      builder: (context, trainingProvider, child) {
        final completedTrainings = trainingProvider.getCompletedTrainings();
        
        if (completedTrainings.isEmpty) {
          return _buildEmptyState('Tamamlanan eğitim bulunamadı');
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: completedTrainings.length,
          itemBuilder: (context, index) {
            final progress = completedTrainings[index];
            final training = trainingProvider.availableTrainings
                .where((t) => t.id == progress.trainingId)
                .firstOrNull;
            
            if (training == null) return const SizedBox.shrink();
            
            return _buildTrainingCard(training, progress: progress);
          },
        );
      },
    );
  }

  Widget _buildTrainingCard(TrainingModel training, {UserTrainingProgress? progress}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/training-detail', arguments: {
            'trainingId': training.id,
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
                  // Training image/icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _getTrainingTypeColor(training.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getTrainingTypeIcon(training.type),
                      color: _getTrainingTypeColor(training.type),
                      size: 30,
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                training.title,
                                style: AppFonts.bodyMedium.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (training.isPremium)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'PRO',
                                  style: AppFonts.caption.copyWith(
                                    color: AppColors.warning,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        
                        const SizedBox(height: 4),
                        
                        Text(
                          training.description,
                          style: AppFonts.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Progress bar (if progress exists)
              if (progress != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: progress.progressPercentage / 100,
                        backgroundColor: AppColors.lightGray,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getTrainingTypeColor(training.type),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${progress.progressPercentage.toInt()}%',
                      style: AppFonts.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              
              // Training info
              Row(
                children: [
                  _buildInfoChip(
                    Icons.schedule,
                    '${training.estimatedDuration} dk',
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.signal_cellular_alt,
                    _getDifficultyLabel(training.difficulty),
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.star,
                    '${training.rating.toStringAsFixed(1)}',
                  ),
                  const Spacer(),
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

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.lightGray.withOpacity(0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppFonts.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 80,
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
      ),
    );
  }

  Color _getTrainingTypeColor(TrainingType type) {
    switch (type) {
      case TrainingType.communication:
        return AppColors.primary;
      case TrainingType.empathy:
        return AppColors.secondary;
      case TrainingType.conflictResolution:
        return AppColors.error;
      case TrainingType.emotionalIntelligence:
        return AppColors.accent;
      case TrainingType.personalDevelopment:
        return AppColors.success;
      case TrainingType.relationshipSkills:
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  IconData _getTrainingTypeIcon(TrainingType type) {
    switch (type) {
      case TrainingType.communication:
        return Icons.chat_bubble_outline;
      case TrainingType.empathy:
        return Icons.favorite_outline;
      case TrainingType.conflictResolution:
        return Icons.handshake_outlined;
      case TrainingType.emotionalIntelligence:
        return Icons.psychology_outlined;
      case TrainingType.personalDevelopment:
        return Icons.trending_up;
      case TrainingType.relationshipSkills:
        return Icons.people_outline;
      default:
        return Icons.school_outlined;
    }
  }

  String _getDifficultyLabel(TrainingDifficulty difficulty) {
    switch (difficulty) {
      case TrainingDifficulty.beginner:
        return 'Başlangıç';
      case TrainingDifficulty.intermediate:
        return 'Orta';
      case TrainingDifficulty.advanced:
        return 'İleri';
      default:
        return 'Bilinmeyen';
    }
  }
}