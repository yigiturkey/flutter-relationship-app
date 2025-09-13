import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../models/podcast_model.dart';
import '../../providers/podcast_provider.dart';

class PodcastsScreen extends StatefulWidget {
  const PodcastsScreen({super.key});

  @override
  State<PodcastsScreen> createState() => _PodcastsScreenState();
}

class _PodcastsScreenState extends State<PodcastsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  PodcastCategory? _selectedCategory;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPodcasts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadPodcasts() {
    final provider = context.read<PodcastProvider>();
    provider.loadPodcasts();
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
            Colors.green.shade600,
            Colors.green.shade400,
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
                  'Podcast\'ler',
                  style: AppFonts.headingMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Uzmanlardan kişisel gelişim içerikleri',
                  style: AppFonts.bodyMedium.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          
          Icon(
            Icons.headphones,
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
                  hintText: 'Podcast ara...',
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
            onTap: _showCategoryFilter,
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
                color: _selectedCategory != null 
                    ? Colors.green.shade600 
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
          Tab(text: 'Dinleniyor'),
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
        labelColor: Colors.green.shade600,
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
          _buildAllPodcasts(),
          _buildCurrentlyPlaying(),
          _buildCompletedPodcasts(),
        ],
      ),
    );
  }

  Widget _buildAllPodcasts() {
    return Consumer<PodcastProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final filteredPodcasts = _filterPodcasts(provider.podcasts);

        if (filteredPodcasts.isEmpty) {
          return _buildEmptyState('Podcast bulunamadı');
        }

        return ListView.builder(
          itemCount: filteredPodcasts.length,
          itemBuilder: (context, index) {
            final podcast = filteredPodcasts[index];
            return _buildPodcastCard(podcast);
          },
        );
      },
    );
  }

  Widget _buildCurrentlyPlaying() {
    return Consumer<PodcastProvider>(
      builder: (context, provider, child) {
        final currentPodcasts = provider.podcasts.where((p) => 
          provider.getCurrentPosition(p.id) > 0 && 
          !provider.isCompleted(p.id)
        ).toList();

        if (currentPodcasts.isEmpty) {
          return _buildEmptyState('Dinlenen podcast yok');
        }

        return ListView.builder(
          itemCount: currentPodcasts.length,
          itemBuilder: (context, index) {
            final podcast = currentPodcasts[index];
            return _buildPodcastCard(podcast, showProgress: true);
          },
        );
      },
    );
  }

  Widget _buildCompletedPodcasts() {
    return Consumer<PodcastProvider>(
      builder: (context, provider, child) {
        final completedPodcasts = provider.podcasts.where((p) => 
          provider.isCompleted(p.id)
        ).toList();

        if (completedPodcasts.isEmpty) {
          return _buildEmptyState('Tamamlanan podcast yok');
        }

        return ListView.builder(
          itemCount: completedPodcasts.length,
          itemBuilder: (context, index) {
            final podcast = completedPodcasts[index];
            return _buildPodcastCard(podcast, isCompleted: true);
          },
        );
      },
    );
  }

  Widget _buildPodcastCard(
    PodcastModel podcast, {
    bool showProgress = false,
    bool isCompleted = false,
  }) {
    return Consumer<PodcastProvider>(
      builder: (context, provider, child) {
        final isPlaying = provider.currentPodcast?.id == podcast.id && 
                         provider.isPlaying;
        final progress = provider.getProgress(podcast.id);

        return GestureDetector(
          onTap: () => _openPodcastPlayer(podcast),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
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
            child: Row(
              children: [
                // Podcast Image
                Stack(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: podcast.imageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(podcast.imageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                        gradient: podcast.imageUrl == null
                            ? LinearGradient(
                                colors: [
                                  Colors.green.shade300,
                                  Colors.green.shade500,
                                ],
                              )
                            : null,
                      ),
                      child: podcast.imageUrl == null
                          ? const Icon(
                              Icons.headphones,
                              color: Colors.white,
                              size: 24,
                            )
                          : null,
                    ),
                    
                    if (isPlaying)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.black.withOpacity(0.3),
                          ),
                          child: const Icon(
                            Icons.pause,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        podcast.title,
                        style: AppFonts.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 4),
                      
                      Text(
                        podcast.host,
                        style: AppFonts.bodyMedium.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              podcast.categoryDisplayName,
                              style: AppFonts.bodySmall.copyWith(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 8),
                          
                          Text(
                            podcast.formattedDuration,
                            style: AppFonts.bodySmall.copyWith(
                              color: Colors.grey.shade500,
                            ),
                          ),
                          
                          if (isCompleted) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.check_circle,
                              color: Colors.green.shade600,
                              size: 16,
                            ),
                          ],
                        ],
                      ),
                      
                      if (showProgress && progress > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.green.shade600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                GestureDetector(
                  onTap: () => _togglePlayPause(podcast),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 20,
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
            Icons.headphones_outlined,
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

  List<PodcastModel> _filterPodcasts(List<PodcastModel> podcasts) {
    var filtered = podcasts;

    if (_selectedCategory != null) {
      filtered = filtered.where((p) => p.category == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) =>
          p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.host.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    return filtered;
  }

  void _showCategoryFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kategori Seç',
                style: AppFonts.headingSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              ListTile(
                title: const Text('Tümü'),
                leading: Radio<PodcastCategory?>(
                  value: null,
                  groupValue: _selectedCategory,
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              
              ...PodcastCategory.values.map((category) {
                return ListTile(
                  title: Text(_getCategoryDisplayName(category)),
                  leading: Radio<PodcastCategory?>(
                    value: category,
                    groupValue: _selectedCategory,
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                      Navigator.pop(context);
                    },
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  String _getCategoryDisplayName(PodcastCategory category) {
    switch (category) {
      case PodcastCategory.relationship:
        return 'İlişkiler';
      case PodcastCategory.personalGrowth:
        return 'Kişisel Gelişim';
      case PodcastCategory.mindfulness:
        return 'Farkındalık';
      case PodcastCategory.communication:
        return 'İletişim';
      case PodcastCategory.selfCare:
        return 'Öz Bakım';
      case PodcastCategory.spirituality:
        return 'Maneviyat';
      case PodcastCategory.motivation:
        return 'Motivasyon';
    }
  }

  void _togglePlayPause(PodcastModel podcast) {
    final provider = context.read<PodcastProvider>();
    
    if (provider.currentPodcast?.id == podcast.id) {
      if (provider.isPlaying) {
        provider.pause();
      } else {
        provider.resume();
      }
    } else {
      provider.playPodcast(podcast);
    }
  }

  void _openPodcastPlayer(PodcastModel podcast) {
    Navigator.pushNamed(
      context,
      '/podcast-player',
      arguments: podcast,
    );
  }
}