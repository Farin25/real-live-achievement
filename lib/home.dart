import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NewsFeedPage1 extends StatelessWidget {
  const NewsFeedPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: ListView.separated(
            itemCount: _feedItems.length,
            separatorBuilder: (BuildContext context, int index) {
              return const Divider();
            },
            itemBuilder: (BuildContext context, int index) {
              final item = _feedItems[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AvatarImage(item.user.imageUrl),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: RichText(
                                  overflow: TextOverflow.ellipsis,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: item.user.fullName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text: " @${item.user.userName}",
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Text(
                                '· 5m',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Icon(Icons.more_horiz),
                              ),
                            ],
                          ),
                          if (item.content != null) Text(item.content!),
                          if (item.imageUrl != null)
                            Container(
                              height: 200,
                              margin: const EdgeInsets.only(top: 8.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(item.imageUrl!),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AvatarImage extends StatelessWidget {
  final String url;
  const _AvatarImage(this.url);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(image: NetworkImage(url)),
      ),
    );
  }
}

class _ActionsRow extends StatelessWidget {
  final FeedItem item;
  const _ActionsRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        iconTheme: const IconThemeData(color: Colors.grey, size: 18),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.all(Colors.grey),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.mode_comment_outlined),
            label: Text(
              item.commentsCount == 0 ? '' : item.commentsCount.toString(),
            ),
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.repeat_rounded),
            label: Text(
              item.retweetsCount == 0 ? '' : item.retweetsCount.toString(),
            ),
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.favorite_border),
            label: Text(item.likesCount == 0 ? '' : item.likesCount.toString()),
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.share_up),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class FeedItem {
  final String? content;
  final String? imageUrl;
  final User user;
  final int commentsCount;
  final int likesCount;
  final int retweetsCount;

  FeedItem({
    this.content,
    this.imageUrl,
    required this.user,
    this.commentsCount = 0,
    this.likesCount = 0,
    this.retweetsCount = 0,
  });
}

class User {
  final String fullName;
  final String imageUrl;
  final String userName;

  User(this.fullName, this.userName, this.imageUrl);
}

final List<User> _users = [
  User("John Doe", "john_doe", "https://picsum.photos/id/1062/80/80"),
  User("Jane Doe", "jane_doe", "https://picsum.photos/id/1066/80/80"),
  User("Jack Doe", "jack_doe", "https://picsum.photos/id/1072/80/80"),
  User("Jill Doe", "jill_doe", "https://picsum.photos/id/133/80/80"),
];

final List<FeedItem> _feedItems = [
  
  FeedItem(
    content:
        "New Achievment unlockt Travler II",
    user: _users[0],

  ),
  FeedItem(
    user: _users[1],
    content: 
    "New Achievfgment Unlocked Tutorial finisht",
  ),
  FeedItem(
    user: _users[0],
    content:
        "Freundschaftsanfrage von TheH3nriG",

  ),
  FeedItem(
    user: _users[1],
    content:
        "Du hast Maker I Freigeschaltet",

  ),
  FeedItem(
    user: _users[2],
    content: "Freunschaftsanfrage von GamingBalha",
  ),
];
