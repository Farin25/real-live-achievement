//home.dart
import 'package:flutter/material.dart';

class NewsFeedPage1 extends StatelessWidget {
  const NewsFeedPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Activity Feed"), centerTitle: false),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _feedItems.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final item = _feedItems[index];
              return _FeedCard(item: item);
            },
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

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TypeIconBubble(type: item.type),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            item.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          _FeedTypeChip(type: item.type),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.time,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_horiz),
                ),
              ],
            ),

            if (item.content != null) ...[
              const SizedBox(height: 12),
              Text(
                item.content!,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TypeIconBubble extends StatelessWidget {
  final FeedType type;

  const _TypeIconBubble({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _backgroundColor(context, type),
      ),
      child: Icon(
        _iconForType(type),
        size: 26,
        color: _iconColor(context, type),
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

  Color _backgroundColor(BuildContext context, FeedType type) {
    final scheme = Theme.of(context).colorScheme;
    switch (type) {
      case FeedType.achievement:
        return scheme.primaryContainer;
      case FeedType.friend:
        return scheme.secondaryContainer;
      case FeedType.unlock:
        return scheme.tertiaryContainer;
      case FeedType.promo:
        return scheme.surfaceVariant;
    }
  }

  Color _iconColor(BuildContext context, FeedType type) {
    final scheme = Theme.of(context).colorScheme;
    switch (type) {
      case FeedType.achievement:
        return scheme.onPrimaryContainer;
      case FeedType.friend:
        return scheme.onSecondaryContainer;
      case FeedType.unlock:
        return scheme.onTertiaryContainer;
      case FeedType.promo:
        return scheme.onSurfaceVariant;
    }
  }
}

class _FeedTypeChip extends StatelessWidget {
  final FeedType type;

  const _FeedTypeChip({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Text(_label(type), style: Theme.of(context).textTheme.labelMedium),
    );
  }

  String _label(FeedType type) {
    switch (type) {
      case FeedType.achievement:
        return "Achievement";
      case FeedType.friend:
        return "Friend";
      case FeedType.unlock:
        return "Unlock";
      case FeedType.promo:
        return "Promo";
    }
  }
}

enum FeedType { achievement, friend, unlock, promo }

class FeedItem {
  final String title;
  final String? content;
  final String time;
  final FeedType type;

  FeedItem({
    required this.title,
    this.content,
    required this.time,
    required this.type,
  });
}

final List<FeedItem> _feedItems = [
  FeedItem(
    title: "Traveler II unlocked",
    content: "You visited a new place and earned 250 XP.",
    time: "5 min ago",
    type: FeedType.achievement,
  ),
  FeedItem(
    title: "Tutorial completed",
    content:
        "Nice — your onboarding is finished. More achievements are now available.",
    time: "12 min ago",
    type: FeedType.unlock,
  ),
  FeedItem(
    title: "Friend request",
    content: "TheH3nriG sent you a friend request.",
    time: "24 min ago",
    type: FeedType.friend,
  ),
  FeedItem(
    title: "Maker I unlocked",
    content: "Your first maker-related achievement is now active.",
    time: "38 min ago",
    type: FeedType.achievement,
  ),
  FeedItem(
    title: "Spring Challenge",
    content: "Join the limited community event and unlock exclusive rewards.",
    time: "1 h ago",
    type: FeedType.promo,
  ),
];
