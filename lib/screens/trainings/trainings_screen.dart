import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../models/training_model.dart';
import '../../providers/training_provider.dart';

class TrainingsScreen extends StatefulWidget {
  const TrainingsScreen({super.key});

  @override
  State<TrainingsScreen> createState() => _TrainingsScreenState();
}

class _TrainingsScreenState extends State<TrainingsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  TrainingType? _selectedType;
  TrainingDifficulty? _selectedDifficulty;
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
    final provider = context.read<TrainingProvider>();
    provider.loadAvailableTrainings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchAndFilter(),
            _buildTabs(),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade600,
            Colors.purple.shade400,
          ],
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Eğitimler',
                  style: AppFonts.headingMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Kişisel gelişim yolculuğunuz',
                  style: AppFonts.bodyMedium.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          
          Icon(
            Icons.school,
            color: Colors.white,
            size: 32,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Eğitim ara...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          GestureDetector(
            onTap: _showFilters,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.filter_list,
                color: (_selectedType != null || _selectedDifficulty != null)
                    ? Colors.purple.shade600 
                    : Colors.grey.shade400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Tümü'),
          Tab(text: 'Devam Eden'),
          Tab(text: 'Tamamlanan'),
        ],
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: Colors.purple.shade600,
        unselectedLabelColor: Colors.grey.shade600,
        labelStyle: AppFonts.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppFonts.bodyMedium,
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildAllTrainings(),
          _buildInProgressTrainings(),
          _buildCompletedTrainings(),
        ],
      ),
    );
  }

  Widget _buildAllTrainings() {
    return Consumer<TrainingProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final filteredTrainings = _filterTrainings(provider.trainings);

        if (filteredTrainings.isEmpty) {
          return _buildEmptyState('Eğitim bulunamadı');
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: filteredTrainings.length,
          itemBuilder: (context, index) {
            final training = filteredTrainings[index];
            return _buildTrainingCard(training);
          },
        );
      },
    );
  }

  Widget _buildInProgressTrainings() {
    return Consumer<TrainingProvider>(
      builder: (context, provider, child) {
        final inProgressTrainings = provider.getInProgressTrainings();

        if (inProgressTrainings.isEmpty) {
          return _buildEmptyState('Devam eden eğitim yok');
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: inProgressTrainings.length,
          itemBuilder: (context, index) {
            final training = inProgressTrainings[index];
            return _buildTrainingCard(training, showProgress: true);
          },
        );
      },
    );
  }

  Widget _buildCompletedTrainings() {
    return Consumer<TrainingProvider>(
      builder: (context, provider, child) {
        final completedTrainings = provider.getCompletedTrainings();

        if (completedTrainings.isEmpty) {
          return _buildEmptyState('Tamamlanan eğitim yok');
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: completedTrainings.length,
          itemBuilder: (context, index) {
            final training = completedTrainings[index];
            return _buildTrainingCard(training, isCompleted: true);
          },
        );
      },
    );
  }

  Widget _buildTrainingCard(
    TrainingModel training, {
    bool showProgress = false,
    bool isCompleted = false,
  }) {
    return Consumer<TrainingProvider>(
      builder: (context, provider, child) {
        final progress = provider.getTrainingProgress(training.id);

        return GestureDetector(
          onTap: () => _openTraining(training),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Training Image
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    image: training.thumbnailUrl != null
                        ? DecorationImage(
                            image: NetworkImage(training.thumbnailUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    gradient: training.thumbnailUrl == null
                        ? LinearGradient(
                            colors: [
                              Colors.purple.shade300,
                              Colors.purple.shade500,
                            ],
                          )
                        : null,
                  ),
                  child: Stack(
                    children: [
                      if (training.thumbnailUrl == null)
                        const Center(
                          child: Icon(
                            Icons.school,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(training.difficulty),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getDifficultyText(training.difficulty),
                            style: AppFonts.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      
                      if (isCompleted)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.green.shade600,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          training.title,
                          style: AppFonts.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const SizedBox(height: 4),
                        
                        Text(
                          training.description,
                          style: AppFonts.bodySmall.copyWith(
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const Spacer(),
                        
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 14,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${training.estimatedDuration} dk',
                              style: AppFonts.bodySmall.copyWith(
                                color: Colors.grey.shade500,
                              ),
                            ),
                            
                            const Spacer(),
                            
                            if (training.isPremium)
                              Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.orange.shade600,
                              ),
                          ],
                        ),
                        
                        if (showProgress && progress > 0) ...[
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: progress / 100,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.purple.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${progress.round()}% tamamlandı',
                            style: AppFonts.bodySmall.copyWith(
                              color: Colors.purple.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppFonts.bodyLarge.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  List<TrainingModel> _filterTrainings(List<TrainingModel> trainings) {
    var filtered = trainings;

    if (_selectedType != null) {
      filtered = filtered.where((t) => t.type == _selectedType).toList();
    }

    if (_selectedDifficulty != null) {
      filtered = filtered.where((t) => t.difficulty == _selectedDifficulty).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((t) =>
          t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()))).toList();
    }

    return filtered;
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filtreler',
                    style: AppFonts.headingSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  Text(
                    'Eğitim Türü',
                    style: AppFonts.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildFilterChip(
                        'Tümü',
                        _selectedType == null,
                        () => setModalState(() => _selectedType = null),
                      ),
                      ...TrainingType.values.map((type) {
                        return _buildFilterChip(
                          _getTypeDisplayName(type),
                          _selectedType == type,
                          () => setModalState(() => _selectedType = type),
                        );
                      }).toList(),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  Text(
                    'Zorluk Seviyesi',
                    style: AppFonts.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildFilterChip(
                        'Tümü',
                        _selectedDifficulty == null,
                        () => setModalState(() => _selectedDifficulty = null),
                      ),
                      ...TrainingDifficulty.values.map((difficulty) {
                        return _buildFilterChip(
                          _getDifficultyText(difficulty),
                          _selectedDifficulty == difficulty,
                          () => setModalState(() => _selectedDifficulty = difficulty),
                        );
                      }).toList(),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            setModalState(() {
                              _selectedType = null;
                              _selectedDifficulty = null;
                            });
                            setState(() {
                              _selectedType = null;
                              _selectedDifficulty = null;
                            });
                          },
                          child: const Text('Temizle'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {}); // Trigger rebuild with new filters
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple.shade600,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Uygula'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple.shade600 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: AppFonts.bodySmall.copyWith(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(TrainingDifficulty difficulty) {
    switch (difficulty) {
      case TrainingDifficulty.beginner:
        return Colors.green.shade600;
      case TrainingDifficulty.intermediate:
        return Colors.orange.shade600;
      case TrainingDifficulty.advanced:
        return Colors.red.shade600;
    }
  }

  String _getDifficultyText(TrainingDifficulty difficulty) {
    switch (difficulty) {
      case TrainingDifficulty.beginner:
        return 'Başlangıç';
      case TrainingDifficulty.intermediate:
        return 'Orta';
      case TrainingDifficulty.advanced:
        return 'İleri';
    }
  }

  String _getTypeDisplayName(TrainingType type) {
    switch (type) {
      case TrainingType.communication:
        return 'İletişim';
      case TrainingType.empathy:
        return 'Empati';
      case TrainingType.conflictResolution:
        return 'Çatışma Çözme';
      case TrainingType.emotionalIntelligence:
        return 'Duygusal Zeka';
      case TrainingType.personalDevelopment:
        return 'Kişisel Gelişim';
      case TrainingType.relationshipSkills:
        return 'İlişki Becerileri';
    }
  }

  void _openTraining(TrainingModel training) {
    Navigator.pushNamed(
      context,
      '/training-detail',
      arguments: training,
    );
  }
}