import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

import '../../models/quiz_result_model.dart';
import '../../services/supabase_service.dart';
import '../../widgets/animated_math_background.dart';
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

  List<Map<String, dynamic>> _filteredQuestions = [];

  final List<Map<String, dynamic>> _allQuestions = [
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get operation type from route arguments
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _operationType = args?['operation'] as String?;

    // Filter questions based on operation type
    _filterQuestions();
  }

  void _filterQuestions() {
    if (_operationType != null && _operationType != 'mixed') {
      // Filter for specific operation
      _filteredQuestions = _allQuestions
          .where((q) => q['operation'] == _operationType)
          .toList();

      // If not enough questions, generate more
      if (_filteredQuestions.length < 10) {
        _filteredQuestions.addAll(
          _generateQuestions(_operationType!, 10 - _filteredQuestions.length),
        );
      }
    } else {
      // Use all questions for mixed mode
      _filteredQuestions = List.from(_allQuestions);
    }

    // Shuffle questions
    _filteredQuestions.shuffle(Random());

    // Take only 10 questions
    _filteredQuestions = _filteredQuestions.take(10).toList();
  }

  List<Map<String, dynamic>> _generateQuestions(String operation, int count) {
    final random = Random();
    final questions = <Map<String, dynamic>>[];

    for (int i = 0; i < count; i++) {
      int num1, num2, answer;
      String question;

      switch (operation) {
        case 'addition':
          num1 = random.nextInt(20) + 1;
          num2 = random.nextInt(20) + 1;
          answer = num1 + num2;
          question = '$num1 + $num2 = ?';
          break;
        case 'subtraction':
          num1 = random.nextInt(30) + 10;
          num2 = random.nextInt(num1);
          answer = num1 - num2;
          question = '$num1 − $num2 = ?';
          break;
        case 'multiplication':
          num1 = random.nextInt(10) + 2;
          num2 = random.nextInt(10) + 2;
          answer = num1 * num2;
          question = '$num1 × $num2 = ?';
          break;
        case 'division':
          num2 = random.nextInt(9) + 2;
          answer = random.nextInt(10) + 2;
          num1 = num2 * answer;
          question = '$num1 ÷ $num2 = ?';
          break;
        default:
          num1 = random.nextInt(20) + 1;
          num2 = random.nextInt(20) + 1;
          answer = num1 + num2;
          question = '$num1 + $num2 = ?';
      }

      // Generate wrong answers
      final answers = <String>[];
      answers.add(answer.toString());

      while (answers.length < 4) {
        final wrongAnswer = answer + random.nextInt(10) - 5;
        if (wrongAnswer > 0 &&
            wrongAnswer != answer &&
            !answers.contains(wrongAnswer.toString())) {
          answers.add(wrongAnswer.toString());
        }
      }

      answers.shuffle(random);
      final correctIndex = answers.indexOf(answer.toString());

      questions.add({
        'question': question,
        'answers': answers,
        'correctIndex': correctIndex,
        'operation': operation,
      });
    }

    return questions;
  }

  void _onTimerComplete(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_isAnswering) {
      _handleTimeout();
    }
  }

  void _handleTimeout() {
    if (_currentQuestionIndex < _filteredQuestions.length - 1) {
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

    final currentQuestion = _filteredQuestions[_currentQuestionIndex];
    final isCorrect = selectedIndex == currentQuestion["correctIndex"];

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

    if (_currentQuestionIndex < _filteredQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _isAnswering = false;
        _showCelebration = false;
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
    await prefs.setInt('last_quiz_total', _filteredQuestions.length);
    await prefs.setInt('last_quiz_time', timeTaken);

    // Save to Supabase
    final userId = await SupabaseService.instance.getCurrentUserId();
    if (userId != null) {
      final quizResult = QuizResultModel(
        userId: userId,
        score: _score,
        totalQuestions: _filteredQuestions.length,
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
        'totalQuestions': _filteredQuestions.length,
        'correctAnswers': _correctAnswers,
        'timeTaken': timeTaken,
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

    if (_filteredQuestions.isEmpty) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: theme.colorScheme.primary),
        ),
      );
    }

    final currentQuestion = _filteredQuestions[_currentQuestionIndex];

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
        body: Stack(
          children: [
            // Animated math background
            Positioned.fill(
              child: AnimatedMathBackground(
                symbolColor: theme.colorScheme.primary,
                opacity: 0.03,
                symbolCount: 15,
                animationSpeed: 0.4,
              ),
            ),

            // Main content
            SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      ProgressBarWidget(
                        currentQuestion: _currentQuestionIndex + 1,
                        totalQuestions: _filteredQuestions.length,
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
                                        (currentQuestion["answers"]
                                                as List)[index]
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
          ],
        ),
      ),
    );
  }
}
