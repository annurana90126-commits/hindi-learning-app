import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/progress_model.dart';
import '../../../services/progress_service.dart';
import 'weekly_chart.dart';
import 'stat_card.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  ProgressStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    setState(() => _isLoading = true);
    final data = await ProgressService.getProgress();
    if (mounted && data['success'] == true) {
      setState(() {
        _stats = ProgressStats.fromJson(data['stats']);
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadProgress,
          color: AppColors.primary,
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : _stats == null
                  ? _buildError()
                  : _buildContent(),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('😕', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          const Text('Could not load progress', style: AppTextStyles.heading3),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadProgress,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final stats = _stats!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        // Header
        const Text('Your Progress', style: AppTextStyles.heading1),
        const SizedBox(height: 4),
        const Text(
          'Keep going — you\'re doing great!',
          style: AppTextStyles.bodyMedium,
        ),

        const SizedBox(height: 24),

        // Level + XP card
        _buildLevelCard(stats),

        const SizedBox(height: 16),

        // Daily goal card
        _buildDailyGoalCard(stats),

        const SizedBox(height: 20),

        // Stats grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.95,
          children: [
            StatCard(
              icon: '🔥',
              value: '${stats.streak}',
              label: 'Day Streak',
              color: AppColors.streakOrange,
            ),
            StatCard(
              icon: '📚',
              value: '${stats.wordsLearned}',
              label: 'Words Learned',
              color: AppColors.secondary,
            ),
            StatCard(
              icon: '✅',
              value: '${stats.lessonsCompleted}',
              label: 'Lessons Done',
              color: AppColors.success,
            ),
            StatCard(
              icon: '🎯',
              value: '${stats.accuracy}%',
              label: 'Avg Accuracy',
              color: AppColors.primary,
            ),
            StatCard(
              icon: '🔁',
              value: '${stats.wordsDueToday}',
              label: 'Due Today',
              color: AppColors.warning,
            ),
            StatCard(
              icon: '⚡',
              value: '${stats.xp}',
              label: 'Total XP',
              color: AppColors.accent,
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Weekly XP chart
        WeeklyXpChart(weeklyXp: stats.weeklyXp),

        const SizedBox(height: 20),

        // Review words banner
        if (stats.wordsDueToday > 0) _buildReviewBanner(stats),

        const SizedBox(height: 20),

        // Achievements section
        _buildAchievements(stats),
      ],
    );
  }

  Widget _buildLevelCard(ProgressStats stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.secondary, AppColors.secondaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Level ${stats.level}',
                    style: AppTextStyles.heading1.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _getLevelTitle(stats.level),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _getLevelEmoji(stats.level),
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${stats.xp % 200} / ${stats.xpForNextLevel} XP',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              Text(
                'Level ${stats.level + 1} →',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: stats.xpProgress,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.accent),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyGoalCard(ProgressStats stats) {
    final isComplete = stats.dailyXp >= stats.dailyGoalXp;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: stats.dailyGoalProgress,
                  backgroundColor: AppColors.cardBg,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isComplete ? AppColors.success : AppColors.primary,
                  ),
                  strokeWidth: 5,
                ),
                Center(
                  child: Text(
                    isComplete
                        ? '✓'
                        : '${(stats.dailyGoalProgress * 100).toInt()}%',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isComplete
                          ? AppColors.success
                          : AppColors.primary,
                      fontSize: isComplete ? 18 : 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isComplete ? 'Daily goal achieved! 🎉' : 'Daily Goal',
                  style: AppTextStyles.bodyLarge
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '${stats.dailyXp} / ${stats.dailyGoalXp} XP earned today',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewBanner(ProgressStats stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          const Text('🔁', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${stats.wordsDueToday} words due for review!',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.warning,
                  ),
                ),
                const Text(
                  'Practice them now to boost your memory',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements(ProgressStats stats) {
    final achievements = [
      _Achievement(
        icon: '🌱',
        title: 'First Steps',
        desc: 'Complete your first lesson',
        unlocked: stats.lessonsCompleted >= 1,
      ),
      _Achievement(
        icon: '🔥',
        title: 'On Fire',
        desc: '3-day streak',
        unlocked: stats.streak >= 3,
      ),
      _Achievement(
        icon: '📚',
        title: 'Word Collector',
        desc: 'Learn 20 words',
        unlocked: stats.wordsLearned >= 20,
      ),
      _Achievement(
        icon: '⭐',
        title: 'Rising Star',
        desc: 'Reach Level 2',
        unlocked: stats.level >= 2,
      ),
      _Achievement(
        icon: '🎯',
        title: 'Sharp Shooter',
        desc: '80%+ average accuracy',
        unlocked: stats.accuracy >= 80,
      ),
      _Achievement(
        icon: '🏆',
        title: 'Champion',
        desc: 'Complete all 6 lessons',
        unlocked: stats.lessonsCompleted >= 6,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Achievements', style: AppTextStyles.heading2),
        const SizedBox(height: 14),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: achievements
              .map((a) => _buildAchievementBadge(a))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildAchievementBadge(_Achievement a) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: a.unlocked ? AppColors.surface : AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: a.unlocked
              ? AppColors.accent.withValues(alpha: 0.5)
              : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: a.unlocked
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            a.unlocked ? a.icon : '🔒',
            style: TextStyle(
              fontSize: 28,
              color: a.unlocked ? null : AppColors.textHint,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            a.title,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: a.unlocked
                  ? AppColors.textPrimary
                  : AppColors.textHint,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            a.desc,
            style: AppTextStyles.caption.copyWith(
              fontSize: 9,
              color: AppColors.textHint,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _getLevelTitle(int level) {
    if (level <= 1) return 'Beginner';
    if (level <= 3) return 'Learner';
    if (level <= 5) return 'Intermediate';
    if (level <= 8) return 'Advanced';
    return 'Expert';
  }

  String _getLevelEmoji(int level) {
    if (level <= 1) return '🌱';
    if (level <= 3) return '📖';
    if (level <= 5) return '⭐';
    if (level <= 8) return '🏅';
    return '🏆';
  }
}

class _Achievement {
  final String icon;
  final String title;
  final String desc;
  final bool unlocked;

  _Achievement({
    required this.icon,
    required this.title,
    required this.desc,
    required this.unlocked,
  });
}