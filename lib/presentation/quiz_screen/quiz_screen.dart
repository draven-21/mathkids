import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

import '../../models/quiz_result_model.dart';
import '../../services/supabase_service.dart';
import './widgets/answer_button_widget.dart';
import './widgets/celebration_widget.dart';
import './widgets/progress_bar_widget.dart';
import './widgets/question_display_widget.dart';
import './widgets/score_display_widget.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _streak = 0;
  int _correctAnswers = 0;
  bool _isAnswering = false;
  bool _showCelebration = false;
  String? _operationType;
  late DateTime _quizStartTime;
  late AnimationController _timerController;
  late AnimationController _celebrationController;

  final List<Map<String, dynamic>> _questions = [
    {
      "question": "5 + 3 = ?",
      "answers": ["6", "7", "8", "9"],
      "correctIndex": 2,
      "operation": "addition",
    },
    {
      "question": "12 - 4 = ?",
      "answers": ["6", "7", "8", "9"],
      "correctIndex": 2,
      "operation": "subtraction",
    },
    {
      "question": "6 × 2 = ?",
      "answers": ["10", "11", "12", "13"],
      "correctIndex": 2,
      "operation": "multiplication",
    },
    {
      "question": "15 ÷ 3 = ?",
      "answers": ["3", "4", "5", "6"],
      "correctIndex": 2,
      "operation": "division",
    },
    {
      "question": "9 + 7 = ?",
      "answers": ["14", "15", "16", "17"],
      "correctIndex": 2,
      "operation": "addition",
    },
    {
      "question": "20 - 8 = ?",
      "answers": ["10", "11", "12", "13"],
      "correctIndex": 2,
      "operation": "subtraction",
    },
    {
      "question": "4 × 5 = ?",
      "answers": ["18", "19", "20", "21"],
      "correctIndex": 2,
      "operation": "multiplication",
    },
    {
      "question": "24 ÷ 4 = ?",
      "answers": ["4", "5", "6", "7"],
      "correctIndex": 2,
      "operation": "division",
    },
    {
      "question": "11 + 9 = ?",
      "answers": ["18", "19", "20", "21"],
      "correctIndex": 2,
      "operation": "addition",
    },
    {
      "question": "30 - 12 = ?",
      "answers": ["16", "17", "18", "19"],
      "correctIndex": 2,
      "operation": "subtraction",
    },
  ];

  @override
  void initState() {
    super.initState();
    _quizStartTime = DateTime.now();
    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _timerController.forward();
    _timerController.addStatusListener(_onTimerComplete);
  }

  void _onTimerComplete(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_isAnswering) {
      _handleTimeout();
    }
  }

  void _handleTimeout() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _streak = 0;
        _timerController.reset();
        _timerController.forward();
      });
    } else {
      _completeQuiz();
    }
  }

  Future<void> _handleAnswer(int selectedIndex) async {
    if (_isAnswering) return;

    setState(() => _isAnswering = true);

    final currentQuestion = _questions[_currentQuestionIndex];
    final isCorrect = selectedIndex == currentQuestion["correctIndex"];

    // Track operation type (use first question's operation or 'mixed' if varied)
    if (_operationType == null) {
      _operationType = currentQuestion["operation"] as String?;
    } else if (_operationType != currentQuestion["operation"]) {
      _operationType = 'mixed';
    }

    if (isCorrect) {
      setState(() {
        _score += 10;
        _streak++;
        _correctAnswers++;
        _showCelebration = true;
      });

      _celebrationController.forward(from: 0);

      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 100);
      }

      await Future.delayed(const Duration(milliseconds: 1500));

      setState(() => _showCelebration = false);
    } else {
      setState(() => _streak = 0);

      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(pattern: [0, 100, 50, 100]);
      }

      await Future.delayed(const Duration(milliseconds: 800));
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _isAnswering = false;
        _timerController.reset();
        _timerController.forward();
      });
    } else {
      _completeQuiz();
    }
  }

  Future<void> _completeQuiz() async {
    _timerController.stop();

    final timeTaken = DateTime.now().difference(_quizStartTime).inSeconds;
    final pointsEarned = _correctAnswers * 10;

    // Save to SharedPreferences for offline access
    final prefs = await SharedPreferences.getInstance();
    final currentScore = prefs.getInt('total_score') ?? 0;
    await prefs.setInt('total_score', currentScore + _score);
    await prefs.setInt('last_quiz_score', _correctAnswers);
    await prefs.setInt('last_quiz_total', _questions.length);
    await prefs.setInt('last_quiz_time', timeTaken);

    // Save to Supabase
    final userId = await SupabaseService.instance.getCurrentUserId();
    if (userId != null) {
      final quizResult = QuizResultModel(
        userId: userId,
        score: _score,
        totalQuestions: _questions.length,
        correctAnswers: _correctAnswers,
        pointsEarned: pointsEarned,
        timeTakenSeconds: timeTaken,
        operationType: _operationType,
      );
      await SupabaseService.instance.saveQuizResult(quizResult);
    }

    if (!mounted) return;

    Navigator.of(context, rootNavigator: true).pushReplacementNamed(
      '/quiz-results-screen',
      arguments: {
        'score': _score,
        'totalQuestions': _questions.length,
        'correctAnswers': _correctAnswers,
        'timeTaken': timeTaken,
        'pointsEarned': pointsEarned,
      },
    );
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Exit Quiz?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            content: Text(
              'Your progress will be lost. Are you sure?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Continue Quiz'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                  Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pushReplacementNamed('/main-menu-screen');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Exit'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  void dispose() {
    _timerController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentQuestion = _questions[_currentQuestionIndex];

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  ProgressBarWidget(
                    currentQuestion: _currentQuestionIndex + 1,
                    totalQuestions: _questions.length,
                    timerAnimation: _timerController,
                  ),
                  ScoreDisplayWidget(score: _score, streak: _streak),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 24,
                      ),
                      child: Column(
                        children: [
                          QuestionDisplayWidget(
                            question: currentQuestion["question"] as String,
                            questionNumber: _currentQuestionIndex + 1,
                          ),
                          const SizedBox(height: 32),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 1.5,
                                ),
                            itemCount:
                                (currentQuestion["answers"] as List).length,
                            itemBuilder: (context, index) {
                              return AnswerButtonWidget(
                                answer:
                                    (currentQuestion["answers"] as List)[index]
                                        as String,
                                onTap: _isAnswering
                                    ? null
                                    : () => _handleAnswer(index),
                                index: index,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (_showCelebration)
                CelebrationWidget(animation: _celebrationController),
            ],
          ),
        ),
      ),
    );
  }
}
