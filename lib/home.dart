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
    default:
      return Colors.grey;
  }
}

Color _categoryColorLight(String? category) {
  return _categoryColor(category).withValues(alpha: 0.40);
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
      showAppSnackBar(context, '${item.title} Benachrichtigung gelöscht');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          "Activity Feed",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadFeed();
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _feedItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.primaryContainer.withValues(
                        alpha: 0.3,
                      ),
                    ),
                    child: Icon(
                      Icons.emoji_events_rounded,
                      size: 64,
                      color: colorScheme.primary.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Noch keine Achievements freigeschaltet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Geh raus und erleb was! 🚀',
                    style: TextStyle(
                      fontSize: 15,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadFeed,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: _feedItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = _feedItems[index];

                      return Dismissible(
                        key: Key('${item.id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.red.withValues(alpha: 0.0),
                                Colors.red.withValues(alpha: 0.9),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.delete_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        onDismissed: (direction) {
                          _deleteItem(index, item);
                        },
                        child: _FeedCard(item: item),
                      );
                    },
                  ),
                ),
              ),
            ),
    );
  }
}

class _FeedCard extends StatelessWidget {
  final FeedItem item;

  const _FeedCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Farbiger Header-Streifen
            Container(
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _categoryColor(item.category),
                    _categoryColor(item.category).withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TypeIconBubble(type: item.type, category: item.category),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (item.category != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: _categoryColorLight(item.category),
                                  border: Border.all(
                                    color: _categoryColor(
                                      item.category,
                                    ).withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  item.category!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _categoryColor(item.category),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  if (item.content != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      item.content!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        color: colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                  ],

                  const SizedBox(height: 14),

                  // Moderne Zeitanzeige
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: Colors.green[700],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Freigeschaltet ${item.time}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatTimestamp(String timestamp) {
  try {
    final dateTime = DateTime.parse(timestamp);
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inHours < 24) {
      if (difference.inMinutes < 1) return 'gerade eben';
      if (difference.inMinutes < 60) return 'vor ${difference.inMinutes} min';
      return 'vor ${difference.inHours} h';
    } else {
      return 'am ${DateFormat('dd.MM.yyyy').format(dateTime)}';
    }
  } catch (e) {
    return timestamp;
  }
}

class _TypeIconBubble extends StatelessWidget {
  final FeedType type;
  final String? category;

  const _TypeIconBubble({required this.type, this.category});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _categoryColor(category).withValues(alpha: 0.2),
            _categoryColor(category).withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(
          color: _categoryColor(category).withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Icon(
        _iconForType(type),
        size: 28,
        color: _categoryColor(category),
      ),
    );
  }

  IconData _iconForType(FeedType type) {
    switch (type) {
      case FeedType.achievement:
        return Icons.emoji_events_rounded;
      case FeedType.friend:
        return Icons.person_add_alt_1_rounded;
      case FeedType.unlock:
        return Icons.lock_open_rounded;
      case FeedType.promo:
        return Icons.campaign_rounded;
    }
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
