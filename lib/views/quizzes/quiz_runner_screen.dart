import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../models/quiz.dart';
import '../../providers/quiz_provider.dart';
import '../../widgets/custom_button.dart';

class QuizRunnerScreen extends ConsumerWidget {
  const QuizRunnerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(quizProvider);
    final quizNotifier = ref.read(quizProvider.notifier);
    final detail = quizState.currentQuizDetail;

    if (quizState.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (quizState.lastResult != null) {
      return _buildResultScreen(context, quizState.lastResult!);
    }

    if (detail == null || detail.questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(
          child: Text('لا توجد أسئلة داخل هذا الاختبار', style: TextStyle(color: AppColors.textMuted)),
        ),
      );
    }

    final currentQuestion = detail.questions[quizState.currentQuestionIndex];
    final selectedAnswer = quizState.userAnswers[currentQuestion.id];
    final isLastQuestion = quizState.currentQuestionIndex == detail.questions.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'سؤال ${quizState.currentQuestionIndex + 1} من ${detail.questions.length}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (quizState.currentQuestionIndex + 1) / detail.questions.length,
                  minHeight: 6,
                  backgroundColor: AppColors.surfaceLight,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const SizedBox(height: 28),

              // Question Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Text(
                  currentQuestion.questionText,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),

              // Options
              Expanded(
                child: ListView(
                  children: _buildOptions(context, currentQuestion, selectedAnswer, quizNotifier),
                ),
              ),

              // Navigation Buttons
              Row(
                children: [
                  if (quizState.currentQuestionIndex > 0)
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: CustomButton(
                          text: 'السابق',
                          backgroundColor: AppColors.surfaceLight,
                          textColor: AppColors.textSecondary,
                          onPressed: quizNotifier.previousQuestion,
                        ),
                      ),
                    ),
                  Expanded(
                    flex: 2,
                    child: CustomButton(
                      text: isLastQuestion ? 'إنهاء وإرسال الإجابات' : 'التالي',
                      onPressed: () {
                        if (isLastQuestion) {
                          quizNotifier.submitQuiz();
                        } else {
                          quizNotifier.nextQuestion();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildOptions(
    BuildContext context,
    dynamic question,
    dynamic selectedAnswer,
    QuizNotifier notifier,
  ) {
    if (question.questionType == 'multiple_choice' && question.options is List) {
      final options = question.options as List<dynamic>;
      return options.map((opt) {
        final isSelected = selectedAnswer == opt;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => notifier.recordAnswer(question.id, opt),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.cardBorder,
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
                        color: isSelected ? AppColors.primary : AppColors.textMuted,
                        width: 2,
                      ),
                      color: isSelected ? AppColors.primary : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      opt.toString(),
                      style: TextStyle(
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList();
    } else if (question.questionType == 'true_false') {
      return [
        _buildTrueFalseTile(true, 'صحيح (True)', selectedAnswer == true, question.id, notifier),
        const SizedBox(height: 12),
        _buildTrueFalseTile(false, 'خطأ (False)', selectedAnswer == false, question.id, notifier),
      ];
    }
    return [
      const Text('أجب عن هذا السؤال ذهنياً', style: TextStyle(color: AppColors.textMuted)),
    ];
  }

  Widget _buildTrueFalseTile(
    bool value,
    String label,
    bool isSelected,
    String questionId,
    QuizNotifier notifier,
  ) {
    return InkWell(
      onTap: () => notifier.recordAnswer(questionId, value),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              value ? Icons.check_circle_outline : Icons.cancel_outlined,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultScreen(BuildContext context, QuizScoreResult result) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                result.percentage >= 60 ? '🏆' : '📚',
                style: const TextStyle(fontSize: 64),
              ),
              const SizedBox(height: 16),
              Text(
                result.percentage >= 60 ? 'ممتاز! أحرزت نتيجة رائعة' : 'تحتاج لمراجعة إضافية',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Score Circle
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: result.percentage >= 60 ? AppColors.primary : AppColors.accentGold,
                    width: 3,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '${result.percentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: result.percentage >= 60 ? AppColors.primary : AppColors.accentGold,
                      ),
                    ),
                    Text(
                      '${result.score} / ${result.maxScore} نقطة',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              CustomButton(
                text: 'العودة لقائمة الاختبارات',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
