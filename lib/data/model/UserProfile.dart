class UserProfile {
  final String id;
  final String name;
  final String phone;
  final String gender;
  final DateTime dateOfBirth;
  final String providence;
  int points;
  final int adsPerMonth;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Interest> interests;
  final String profilePhoto;
  UserProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.gender,
    required this.dateOfBirth,
    required this.providence,
    required this.points,
    required this.adsPerMonth,
    required this.createdAt,
    required this.updatedAt,
    required this.interests,
    required this.profilePhoto,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? 'غير معروف',
      phone: json['phone'] ?? '',
      gender: json['gender'] ?? 'غير محدد',
      dateOfBirth:
          DateTime.tryParse(json['dateOfBirth'] ?? '') ?? DateTime(2000, 1, 1),
      providence: json['providence'] ?? '',
      points: json['points'] ?? 0,
      adsPerMonth: json['adsPerMonth'] ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      interests: json['interests'] != null
          ? (json['interests'] as List)
              .map((i) => Interest.fromJson(i))
              .toList()
          : [],
          profilePhoto: json['profilePhoto'] ?? '',
    );
  }

  @override
  String toString() {
    return 'UserProfile(name: $name, points: $points, adsPerMonth: $adsPerMonth, createdAt)';
  }
}

class UserStats {
  final int viewedAdsCount;
  final int createdAdsCount;
  final int totalViews;
  final int totalLikes;
  final int totalShares;
  final int spentPoints;
  final int currentPoints;

  UserStats({
    required this.viewedAdsCount,
    required this.createdAdsCount,
    required this.totalViews,
    required this.totalLikes,
    required this.totalShares,
    required this.spentPoints,
    required this.currentPoints,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      viewedAdsCount: json['viewedAdsCount'],
      createdAdsCount: json['createdAdsCount'],
      totalViews: json['totalViews'],
      totalLikes: json['totalLikes'],
      totalShares: json['totalShares'],
      spentPoints: json['spentPoints'],
      currentPoints: json['currentPoints'],
    );
  }
}

class Interest {
  final String id;
  final String name;
  final String? targetedGender;
  final int minAge;
  final int maxAge;
  final DateTime createdAt;
  final DateTime updatedAt;

  Interest({
    required this.id,
    required this.name,
    this.targetedGender,
    required this.minAge,
    required this.maxAge,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Interest.fromJson(Map<String, dynamic> json) {
    return Interest(
      id: json['id'],
      name: json['name'],
      targetedGender: json['targetedGender'],
      minAge: json['minAge'],
      maxAge: json['maxAge'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class MediaUrl {
  final String url;
  final String type;
  final String? poster;

  MediaUrl({
    required this.url,
    required this.type,
    this.poster,
  });

  factory MediaUrl.fromJson(Map<String, dynamic> json) {
    return MediaUrl(
      url: json['url'],
      type: json['type'],
      poster: json['poster'],
    );
  }
}

class Content {
  final String id;
  final String? title;
  final List<MediaUrl> mediaUrls;
  final DateTime? whatsappedAt;

  Content({
    required this.id,
    this.title,
    required this.mediaUrls,
    this.whatsappedAt,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      id: json['id'],
      title: json['title'],
      mediaUrls:
          (json['mediaUrls'] as List).map((i) => MediaUrl.fromJson(i)).toList(),
      whatsappedAt: json['whatsappedAt'] != null
          ? DateTime.parse(json['whatsappedAt'])
          : null,
    );
  }
}

class ProfileResponseModel {
  final UserProfile user;
  final UserStats stats;
  final List<Interest> interests;

  ProfileResponseModel({
    required this.user,
    required this.stats,
    required this.interests,
  });

  factory ProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return ProfileResponseModel(
      user: UserProfile.fromJson(json['user']),
      stats: UserStats.fromJson(json['stats']),
      interests: json['interests'] != null
          ? (json['interests'] as List)
              .map((i) => Interest.fromJson(i))
              .toList()
          : [],
    );
  }
}
