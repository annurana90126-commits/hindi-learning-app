import '../../../shared/widgets/offline_banner.dart';
import '../../profile/screens/progress_screen.dart';
import '../../lesson/screens/lesson_screen.dart';
import '../../../services/lesson_service.dart';
import 'package:go_router/go_router.dart';
import '../../pronunciation/screens/pronunciation_screen.dart';
import '../../../models/word_model.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/user_model.dart';
import '../../../models/lesson_model.dart';
import '../../../services/auth_service.dart';
import '../widgets/streak_card.dart';
import '../widgets/lesson_card.dart';
import '../widgets/daily_goal_card.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

UserModel _user = UserModel.dummy();
List<LessonModel> _lessons = [];

bool _isLoadingUser = true;
bool _isLoadingLessons = true;
@override
void initState() {
  super.initState();
  _loadData();
}

Future<void> _loadData() async {
  await Future.wait([
    _loadUser(),
    _loadLessons(),
  ]);
}

Future<void> _loadUser() async {
  final user = await AuthService.getProfile();

  if (mounted && user != null) {
    setState(() {
      _user = user;
      _isLoadingUser = false;
    });
  } else {
    setState(() {
      _isLoadingUser = false;
    });
  }
}
Future<void> _refreshData() async {
  setState(() {
    _isLoadingLessons = true;
  });

  await _loadData();
}
Future<void> _loadLessons() async {
  final lessons = await LessonService.getLessons();

  if (mounted) {
    setState(() {
      _lessons = lessons;
      _isLoadingLessons = false;
    });
  }
}

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.background,
    body: Column(
      children: [
        const OfflineBanner(),
        Expanded(
          child: IndexedStack(
            index: _currentIndex,
            children: [
              _HomeTab(
                user: _user,
                lessons: _lessons,
                isLoadingLessons: _isLoadingLessons,
                onRefresh: _refreshData,
              ),
              _PracticeTab(),
              const _ProgressTab(),
              _ProfileTab(user: _user),
            ],
          ),
        ),
      ],
    ),
    bottomNavigationBar: _buildBottomNav(),
  );
}

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
                index: 0,
                currentIndex: _currentIndex,
                onTap: (i) => setState(() => _currentIndex = i),
              ),
              _NavItem(
                icon: Icons.fitness_center_outlined,
                activeIcon: Icons.fitness_center,
                label: 'Practice',
                index: 1,
                currentIndex: _currentIndex,
                onTap: (i) => setState(() => _currentIndex = i),
              ),
              _NavItem(
                icon: Icons.bar_chart_outlined,
                activeIcon: Icons.bar_chart,
                label: 'Progress',
                index: 2,
                currentIndex: _currentIndex,
                onTap: (i) => setState(() => _currentIndex = i),
              ),
              _NavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
                index: 3,
                currentIndex: _currentIndex,
                onTap: (i) => setState(() => _currentIndex = i),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── HOME TAB ───────────────────────────────────────────────────────────────

class _HomeTab extends StatelessWidget {
  final UserModel user;
  final List<LessonModel> lessons;
  final bool isLoadingLessons;
  final VoidCallback onRefresh;

  const _HomeTab({
    required this.user,
    required this.lessons,
    required this.isLoadingLessons,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    // Group lessons by unit
    final units = <int, List<LessonModel>>{};
    for (final l in lessons) {
      units.putIfAbsent(l.unitNumber, () => []).add(l);
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: AppColors.primary,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.background,
            elevation: 0,
            title: Text(
              'हिंदी सीखो',
              style: AppTextStyles.hindiMedium.copyWith(
                color: AppColors.primary,
                fontSize: 20,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: AppColors.textPrimary),
                onPressed: () {},
              ),
              const SizedBox(width: 4),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Streak card
                StreakCard(user: user),
                const SizedBox(height: 20),

                // Daily goal
                DailyGoalCard(
                  currentXp: 30,
                  goalXp: user.dailyGoalXp,
                ),
                const SizedBox(height: 28),

                // Lessons section
                if (isLoadingLessons)
                  _buildLessonsShimmer()
                else if (lessons.isEmpty)
                  _buildEmptyLessons()
                else
                  ...units.entries.map((entry) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Unit header
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Unit ${entry.key}',
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                entry.key == 1
                                    ? 'Basics'
                                    : 'Everyday Life',
                                style: AppTextStyles.heading3,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Lesson cards
                          ...entry.value.map((lesson) => LessonCard(
                                lesson: lesson,
                                onTap: () async {
                                  // Load real words from API
                                  final words = await LessonService
                                      .getLessonWords(lesson.id);
                                  if (context.mounted) {
                                    await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => LessonScreen(
                                          lessonId: lesson.id,
                                          lessonTitle: lesson.title,
                                          lessonTitleHindi: lesson.titleHindi,
                                          xpReward: lesson.xpReward,
                                          words: words,
                                        ),
                                      ),
                                    );
                                    // Refresh after lesson completes
                                    onRefresh();
                                  }
                                },
                              )),

                          const SizedBox(height: 24),
                        ],
                      )),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonsShimmer() {
    return Column(
      children: List.generate(
        3,
        (i) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyLessons() {
    return const Center(
      child: Column(
        children: [
          SizedBox(height: 32),
          Text('📚', style: TextStyle(fontSize: 48)),
          SizedBox(height: 16),
          Text('No lessons found', style: AppTextStyles.heading3),
          SizedBox(height: 8),
          Text('Pull down to refresh', style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}

// ─── PLACEHOLDER TABS ────────────────────────────────────────────────────────

class _PracticeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text('Practice', style: AppTextStyles.heading1),
          const SizedBox(height: 8),
          const Text(
            'Sharpen your Hindi skills',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 32),

          // Pronunciation card
          _PracticeCard(
            icon: '🎙️',
            title: 'Pronunciation',
            titleHindi: 'उच्चारण',
            description: 'Speak Hindi words and get instant feedback on your pronunciation',
            color: AppColors.primary,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PronunciationScreen(
                  words: WordModel.dummyWords(),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Coming soon cards
          _PracticeCard(
            icon: '🔁',
            title: 'Word Review',
            titleHindi: 'शब्द दोहराएं',
            description: 'Review words due today based on your learning schedule',
            color: AppColors.secondary,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Word Review — coming soon!'),
                backgroundColor: AppColors.secondary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),

          const SizedBox(height: 16),

          _PracticeCard(
            icon: '📝',
            title: 'Quick Quiz',
            titleHindi: 'त्वरित प्रश्नोत्तरी',
            description: 'Test yourself on everything you\'ve learned so far',
            color: AppColors.levelPurple,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Quick Quiz — coming soon!'),
                backgroundColor: AppColors.levelPurple,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PracticeCard extends StatelessWidget {
  final String icon;
  final String title;
  final String titleHindi;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _PracticeCard({
    required this.icon,
    required this.title,
    required this.titleHindi,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        titleHindi,
                        style: AppTextStyles.hindiSmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(description, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 16, color: color),
          ],
        ),
      ),
    );
  }
}

class _ProgressTab extends StatelessWidget {
  const _ProgressTab();

  @override
  Widget build(BuildContext context) {
    return const ProgressScreen();
  }
}
class _ProfileTab extends StatelessWidget {
  final UserModel user;
  const _ProfileTab({required this.user});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Avatar
          CircleAvatar(
            radius: 48,
            backgroundColor: AppColors.primary,
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
              style: const TextStyle(
                fontSize: 42,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 16),
          Text(user.name, style: AppTextStyles.heading2),
          const SizedBox(height: 4),
          Text(user.email, style: AppTextStyles.bodyMedium),

          const SizedBox(height: 24),

          // Stats grid
          Row(
            children: [
              _ProfileStat(icon: '🔥', value: '${user.streak}', label: 'Streak'),
              const SizedBox(width: 12),
              _ProfileStat(icon: '⚡', value: '${user.xp}', label: 'Total XP'),
              const SizedBox(width: 12),
              _ProfileStat(icon: '📚', value: '${user.wordsLearned}', label: 'Words'),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              _ProfileStat(icon: '⭐', value: 'Lv ${user.level}', label: 'Level'),
              const SizedBox(width: 12),
              _ProfileStat(
                icon: '✅',
                value: '${user.lessonsCompleted}',
                label: 'Lessons',
              ),
              const SizedBox(width: 12),
              _ProfileStat(icon: '🎯', value: '${user.dailyGoalXp}', label: 'Daily XP Goal'),
            ],
          ),

          const SizedBox(height: 32),

          // Settings options
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Daily reminders to keep your streak',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.flag_outlined,
            title: 'Daily Goal',
            subtitle: '${user.dailyGoalXp} XP per day',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'हिंदी सीखो v1.0.0',
            onTap: () {},
          ),

          const SizedBox(height: 20),

          // Logout button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () async {
                await AuthService.logout();
                if (context.mounted) context.go('/login');
              },
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: Text(
                'Logout',
                style: AppTextStyles.button.copyWith(color: AppColors.error),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String icon;
  final String value;
  final String label;

  const _ProfileStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.bodyLarge
                          .copyWith(fontWeight: FontWeight.w500)),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 14, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

// ─── NAV ITEM ────────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int currentIndex;
  final Function(int) onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.primary : AppColors.textHint,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isActive ? AppColors.primary : AppColors.textHint,
                fontWeight:
                    isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 