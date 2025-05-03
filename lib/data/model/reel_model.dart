class Reel {
  final String username;
  final String userAvatar;
  final List<MediaItem> mediaItems;
  final String caption;
  final String likes;
  final String comments;
  final String shares;
  final bool isFollowing;
  final String timestamp;
  final List<String> hashtags;
  final String soundName;

  Reel({
    required this.username,
    required this.userAvatar,
    required this.mediaItems,
    required this.caption,
    required this.likes,
    required this.comments,
    required this.shares,
    this.isFollowing = false,
    required this.timestamp,
    required this.hashtags,
    required this.soundName,
  });

}

class MediaItem {
  final String url;
  final MediaType type;
  final String? thumbnail;
  final bool isHLS; // إضافة خاصية جديدة

  MediaItem({
    required this.url,
    required this.type,
    this.thumbnail,
    this.isHLS = false,

  });
}

enum MediaType { image, video }