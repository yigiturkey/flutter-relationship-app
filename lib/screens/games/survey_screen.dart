import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../../models/game_model.dart';
import '../../providers/game_provider.dart';

class SurveyScreen extends StatefulWidget {
  final GameModel game;
  
  const SurveyScreen({
    super.key,
    required this.game,
  });

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  final PageController _pageController = PageController();
  Map<String, dynamic> _answers = {};
  int _currentQuestionIndex = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeAnswers();
  }

  void _initializeAnswers() {
    for (final question in widget.game.questions) {
      switch (question.type) {
        case QuestionType.multipleChoice:
        case QuestionType.yesNo:
          _answers[question.id] = null;
          break;
        case QuestionType.scale:
          _answers[question.id] = question.scaleMin ?? 1;
          break;
        case QuestionType.openText:
          _answers[question.id] = '';
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgress(),
            Expanded(
              child: _buildQuestionPage(),
            ),
            _buildNavigationButtons(),
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
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showExitDialog(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.close,
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
                  widget.game.title,
                  style: AppFonts.headingMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${widget.game.questions.length} soru • ~${widget.game.estimatedDuration} dk',
                  style: AppFonts.bodyMedium.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    final progress = (_currentQuestionIndex + 1) / widget.game.questions.length;
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Soru ${_currentQuestionIndex + 1}',
                style: AppFonts.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${_currentQuestionIndex + 1} / ${widget.game.questions.length}',
                style: AppFonts.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPage() {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _currentQuestionIndex = index;
        });
      },
      itemCount: widget.game.questions.length,
      itemBuilder: (context, index) {
        final question = widget.game.questions[index];
        return _buildQuestion(question);
      },
    );
  }

  Widget _buildQuestion(SurveyQuestion question) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question category
          if (question.category != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                question.category!.toUpperCase(),
                style: AppFonts.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Question text
          Text(
            question.text,
            style: AppFonts.headingSmall.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
          
          if (question.helpText != null) ...[
            const SizedBox(height: 8),
            Text(
              question.helpText!,
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Question image
          if (question.imageUrl != null)
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(question.imageUrl!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          
          // Answer input based on question type
          _buildAnswerInput(question),
        ],
      ),
    );
  }

  Widget _buildAnswerInput(SurveyQuestion question) {
    switch (question.type) {
      case QuestionType.multipleChoice:
        return _buildMultipleChoice(question);
      case QuestionType.scale:
        return _buildScale(question);
      case QuestionType.yesNo:
        return _buildYesNo(question);
      case QuestionType.openText:
        return _buildOpenText(question);
    }
  }

  Widget _buildMultipleChoice(SurveyQuestion question) {
    return Column(
      children: question.options!.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final isSelected = _answers[question.id] == index;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              _answers[question.id] = index;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey.shade400,
                      width: 2,
                    ),
                    color: isSelected ? AppColors.primary : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          size: 12,
                          color: Colors.white,
                        )
                      : null,
                ),
                
                const SizedBox(width: 12),
                
                Expanded(
                  child: Text(
                    option,
                    style: AppFonts.bodyMedium.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildScale(SurveyQuestion question) {
    final min = question.scaleMin ?? 1;
    final max = question.scaleMax ?? 5;
    final current = _answers[question.id] ?? min;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (question.scaleLabels != null && question.scaleLabels!.isNotEmpty)
              Text(
                question.scaleLabels!.first,
                style: AppFonts.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            if (question.scaleLabels != null && question.scaleLabels!.length > 1)
              Text(
                question.scaleLabels!.last,
                style: AppFonts.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(max - min + 1, (index) {
            final value = min + index;
            final isSelected = current == value;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _answers[question.id] = value;
                });
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.primary : Colors.white,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    value.toString(),
                    style: AppFonts.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        
        const SizedBox(height: 16),
        
        Slider(
          value: current.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: max - min,
          activeColor: AppColors.primary,
          onChanged: (value) {
            setState(() {
              _answers[question.id] = value.round();
            });
          },
        ),
      ],
    );
  }

  Widget _buildYesNo(SurveyQuestion question) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _answers[question.id] = true;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _answers[question.id] == true 
                    ? Colors.green.withOpacity(0.1) 
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _answers[question.id] == true 
                      ? Colors.green 
                      : Colors.grey.shade300,
                  width: _answers[question.id] == true ? 2 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  'Evet',
                  style: AppFonts.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _answers[question.id] == true 
                        ? Colors.green 
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _answers[question.id] = false;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _answers[question.id] == false 
                    ? Colors.red.withOpacity(0.1) 
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _answers[question.id] == false 
                      ? Colors.red 
                      : Colors.grey.shade300,
                  width: _answers[question.id] == false ? 2 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  'Hayır',
                  style: AppFonts.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _answers[question.id] == false 
                        ? Colors.red 
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOpenText(SurveyQuestion question) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        onChanged: (value) {
          _answers[question.id] = value;
        },
        maxLines: 4,
        decoration: const InputDecoration(
          hintText: 'Cevabınızı buraya yazın...',
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
        style: AppFonts.bodyMedium,
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final isFirstQuestion = _currentQuestionIndex == 0;
    final isLastQuestion = _currentQuestionIndex == widget.game.questions.length - 1;
    final currentQuestion = widget.game.questions[_currentQuestionIndex];
    final hasAnswer = _hasValidAnswer(currentQuestion);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (!isFirstQuestion)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousQuestion,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Önceki'),
              ),
            ),
          
          if (!isFirstQuestion) const SizedBox(width: 12),
          
          Expanded(
            child: ElevatedButton(
              onPressed: hasAnswer 
                  ? (isLastQuestion ? _submitSurvey : _nextQuestion)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(isLastQuestion ? 'Tamamla' : 'Sonraki'),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasValidAnswer(SurveyQuestion question) {
    final answer = _answers[question.id];
    
    switch (question.type) {
      case QuestionType.multipleChoice:
      case QuestionType.yesNo:
        return answer != null;
      case QuestionType.scale:
        return answer != null;
      case QuestionType.openText:
        return answer != null && answer.toString().trim().isNotEmpty;
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.game.questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _submitSurvey() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final gameProvider = context.read<GameProvider>();
      await gameProvider.submitSurveyAnswers(widget.game.id, _answers);
      
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/survey-result',
          arguments: {
            'game': widget.game,
            'answers': _answers,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Anket gönderilirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Anketi Bırak'),
        content: const Text(
          'Anketi şimdi bırakırsan ilerlemeniz kaybolacak. Emin misin?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Devam Et'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Bırak'),
          ),
        ],
      ),
    );
  }
}