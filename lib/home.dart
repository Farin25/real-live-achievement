//home.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'services.dart';
import 'package:shared_preferences/shared_preferences.dart';

Color _categoryColor(String? category) {
  switch (category) {
    case 'Fun':
      return Colors.red;
    case 'Adventure & Travel':
      return Colors.orange;
    case 'Fitness & Health':
      return Colors.pink;
    case 'App':
      return Colors.blue;
    case 'Nature':
      return Colors.green;
    case 'Events':
      return Colors.yellow;
    case 'Sponsored':
      return Colors.grey;
    default:
      return Colors.black12;
  }
}

class NewsFeedPage1 extends StatefulWidget {
  const NewsFeedPage1({super.key});

  @override
  State<NewsFeedPage1> createState() => _NewsFeedPage1State();
}

class _NewsFeedPage1State extends State<NewsFeedPage1> {
  List<FeedItem> _feedItems = [];
  bool _isLoading = true;
  final supabase = Supabase.instance.client;
  Set<int> _hiddenIds = {};

  @override
  void initState() {
    super.initState();
    _loadHiddenIds();
    _loadFeed();
  }

  Future<void> _loadHiddenIds() async {
    final prefs = await SharedPreferences.getInstance();
    final hidden = prefs.getStringList('hidden_feed_ids') ?? [];
    setState(() {
      _hiddenIds = hidden.map((e) => int.parse(e)).toSet();
    });
  }

  Future<void> _loadFeed() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await supabase
          .from('user_achievements')
          .select('''
            id,
            unlocked_at,
            achievement_id,
            achievements (
              name,
              description,
              category
            )
          ''')
          .eq('user_id', user.id)
          .order('unlocked_at', ascending: false)
          .limit(20);

      final items = <FeedItem>[];

      for (final row in response) {
        final id = row['id'] as int;

        if (_hiddenIds.contains(id)) continue;

        final unlockedAt = row['unlocked_at'] as String;
        final achievement = row['achievements'];

        if (achievement != null) {
          final timestamp = _formatTimestamp(unlockedAt);

          items.add(
            FeedItem(
              id: id,
              achievementId: row['achievement_id'],
              title: achievement['name'] ?? 'Unbekanntes Achievement',
              content: achievement['description'],
              time: timestamp,
              type: FeedType.achievement,
              category: achievement['category'],
            ),
          );
        }
      }

      setState(() {
        _feedItems = items;
        _isLoading = false;
      });
    } catch (e) {
      print('Fehler beim Feed laden: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteItem(int index, FeedItem item) async {
    final prefs = await SharedPreferences.getInstance();

    _hiddenIds.add(item.id);

    await prefs.setStringList(
      'hidden_feed_ids',
      _hiddenIds.map((e) => e.toString()).toList(),
    );

    setState(() {
      _feedItems.removeAt(index);
    });

    if (mounted) {
      showAppSnackBar(context, '${item.title} gelöscht');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0A0A)
          : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _isLoading
                ? const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _feedItems.isEmpty
                ? SliverFillRemaining(child: _buildEmptyState(isDark))
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final item = _feedItems[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == _feedItems.length - 1 ? 20 : 16,
                          ),
                          child: Dismissible(
                            key: Key('${item.id}'),
                            direction: DismissDirection.endToStart,
                            background: _buildDismissBackground(item.category),
                            onDismissed: (direction) =>
                                _deleteItem(index, item),
                            child: _FeedCard(item: item),
                          ),
                        );
                      }, childCount: _feedItems.length),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.amber.withValues(alpha: 0.2),
                  Colors.orange.withValues(alpha: 0.1),
                ],
              ),
            ),
            child: Icon(
              Icons.emoji_events_rounded,
              size: 60,
              color: Colors.amber.shade700,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Noch keine Erfolge',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Geh raus und sammle deine ersten Achievements!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white54 : Colors.black45,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDismissBackground(String? category) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      decoration: BoxDecoration(
        color: Colors.red.shade600,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
    );
  }
}

class _FeedCard extends StatelessWidget {
  final FeedItem item;

  const _FeedCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryColor = _categoryColor(item.category);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            categoryColor.withValues(alpha: isDark ? 0.15 : 0.12),
            categoryColor.withValues(alpha: isDark ? 0.08 : 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: categoryColor.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    Icons.emoji_events_rounded,
                    size: 32,
                    color: categoryColor,
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (item.category != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.15)
                                : Colors.white.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            item.category!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: categoryColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (item.content != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                item.content!,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ),

          const SizedBox(height: 20),

          Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: categoryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  item.time,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white60 : Colors.black45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _formatTimestamp(String timestamp) {
  try {
    final dateTime = DateTime.parse(timestamp).toLocal();
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'Gerade eben';
    if (difference.inMinutes < 60) return 'Vor ${difference.inMinutes} Min';
    if (difference.inHours < 24) return 'Vor ${difference.inHours} Std';
    if (difference.inDays == 1) return 'Vor 1 Tag';
    if (difference.inDays < 7) return 'Vor ${difference.inDays} Tagen';

    return DateFormat('dd.MM.yyyy').format(dateTime);
  } catch (e) {
    print('Fehler beim Timestamp formatieren: $e');
    return 'Kürzlich';
  }
}

enum FeedType { achievement, friend, unlock, promo }

class FeedItem {
  final int id;
  final int achievementId;
  final String title;
  final String? content;
  final String time;
  final FeedType type;
  final String? category;

  FeedItem({
    required this.id,
    required this.achievementId,
    required this.title,
    this.content,
    required this.time,
    required this.type,
    this.category,
  });
}
