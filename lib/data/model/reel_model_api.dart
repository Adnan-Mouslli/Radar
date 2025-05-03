import 'dart:convert';

class Interest {
  String id;
  String name;

  Interest({
    required this.id,
    required this.name,
  });

  factory Interest.fromJson(Map<String, dynamic> json) {
    return Interest(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class ReelMedia {
  String url;
  String type;
  String? poster;

  ReelMedia({
    required this.url,
    required this.type,
    this.poster,
  });

  factory ReelMedia.fromJson(Map<String, dynamic> json) {
    return ReelMedia(
      url: json['url'] ?? '',
      type: json['type'] ?? 'IMAGE',
      poster: json['poster'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'type': type,
      if (poster != null) 'poster': poster,
    };
  }
}

class Store {
  final String id;
  final String name;
  final String phone;
  final String? image;
  final String? city;
  final String? address;

  Store({
    required this.id,
    required this.name,
    required this.phone,
    this.image,
    this.city,
    this.address,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      image: json['image'],
      city: json['city'],
      address: json['address'],
    );
  }
}

class Reel {
  String title;
  String id;
  String description;
  String ownerName;
  String ownerNumber;
  String type;
  String ownerType;
  Store? store;
  int intervalHours;
  DateTime endValidationDate;
  List<ReelMedia> mediaUrls;
  DateTime createdAt;
  DateTime updatedAt;
  List<Interest> interests;

  // جعل counts غير final أيضاً لتسمح بتعديل محتوياتها
  ReelCounts counts;

  // متغيرات للتتبع المحلي - قابلة للتعديل أصلاً
  bool isLiked;
  bool isWatched;
  bool isWhatsapped;
  bool hasOffers;
  Reel({
    required this.id,
    required this.title,
    required this.description,
    required this.ownerName,
    required this.ownerNumber,
    required this.type,
    required this.ownerType, // Add this
    this.store, // Add this
    required this.intervalHours,
    required this.endValidationDate,
    required this.mediaUrls,
    required this.createdAt,
    required this.updatedAt,
    required this.interests,
    required this.counts,
    this.isLiked = false,
    this.isWatched = false,
    this.isWhatsapped = false,
    this.hasOffers = false,
  });

  // إضافة طريقة copyWith للسماح بتحديث خصائص محددة فقط
  Reel copyWith({
    String? id,
    String? title,
    String? description,
    String? ownerName,
    String? ownerNumber,
    String? type,
    int? intervalHours,
    DateTime? endValidationDate,
    List<ReelMedia>? mediaUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Interest>? interests,
    ReelCounts? counts,
    bool? isLiked,
    bool? isWatched,
    bool? isWhatsapped,
  }) {
    return Reel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      ownerName: ownerName ?? this.ownerName,
      ownerNumber: ownerNumber ?? this.ownerNumber,
      type: type ?? this.type,
      store: store ?? this.store,
      intervalHours: intervalHours ?? this.intervalHours,
      endValidationDate: endValidationDate ?? this.endValidationDate,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      interests: interests ?? this.interests,
      counts: counts ?? this.counts,
      isLiked: isLiked ?? this.isLiked,
      isWatched: isWatched ?? this.isWatched,
      isWhatsapped: isWhatsapped ?? this.isWhatsapped,
      ownerType:  this.ownerType,
      hasOffers:  this.hasOffers,
    );
  }

  // Factory constructor لإنشاء كائن من JSON
  factory Reel.fromJson(Map<String, dynamic> json) {
    // تحويل mediaUrls من JSON إلى قائمة من كائنات ReelMedia
    List<ReelMedia> mediaList = [];
    if (json['mediaUrls'] != null) {
      mediaList = List<ReelMedia>.from(
          json['mediaUrls'].map((media) => ReelMedia.fromJson(media)));
    }

    List<Interest> interestsList = [];
    if (json['interests'] != null && json['interests'] is List) {
      // استخدم try/catch لالتقاط أي أخطاء في التحويل
      try {
        interestsList = List<Interest>.from(
          (json['interests'] as List).map((item) {
            // تحويل كل عنصر حسب نوعه
            if (item is Map<String, dynamic>) {
              return Interest.fromJson(item);
            } else if (item is Interest) {
              return item;
            } else {
              // طباعة نوع العنصر غير المتوقع للتشخيص
              print("Unexpected interest item type: ${item.runtimeType}");
              print("Interest item content: $item");

              // محاولة تحويل العنصر إلى Map إذا كان ممكناً
              if (item is String) {
                try {
                  // إذا كان العنصر عبارة عن JSON مشفر كنص
                  Map<String, dynamic> parsedItem = jsonDecode(item);
                  return Interest.fromJson(parsedItem);
                } catch (e) {
                  print("Error parsing interest string: $e");
                }
              }

              // إذا كل المحاولات فشلت، إرجاع اهتمام فارغ
              return Interest(id: '', name: item.toString());
            }
          }),
        );
      } catch (e) {
        print("Error converting interests: $e");
        print("Raw interests data: ${json['interests']}");

        // بدلاً من إثارة استثناء، نستخدم قائمة فارغة
        interestsList = [];
      }
    }

    Store? storeData;
    if (json['store'] != null) {
      storeData = Store.fromJson(json['store']);
    }

    return Reel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      ownerName: json['ownerName'] ?? '',
      ownerNumber: json['ownerNumber'] ?? '',
      type: json['type'] ?? 'REEL',
      ownerType: json['ownerType'] ?? 'INDIVIDUAL',
      store: storeData,
      intervalHours: json['intervalHours'] ?? 0,
      endValidationDate: json['endValidationDate'] != null
          ? DateTime.parse(json['endValidationDate'])
          : DateTime.now().add(const Duration(days: 30)),
      mediaUrls: mediaList,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      interests: interestsList,
      counts: ReelCounts.fromJson(json['_count'] ?? {}),
      isLiked: json['isLiked'] ?? false,
      isWatched: json['isWatched'] ?? false,
      isWhatsapped: json['isWhatsapped'] ?? false,
      hasOffers: json['hasOffers'] ?? false,
    );
  }

  // تحويل الكائن إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'ownerName': ownerName,
      'ownerNumber': ownerNumber,
      'type': type,
      'intervalHours': intervalHours,
      'ownerType': ownerType,
      'store': store != null
          ? {
              'id': store!.id,
              'name': store!.name,
              'phone': store!.phone,
              'image': store!.image,
              'city': store!.city,
              'address': store!.address,
            }
          : null,
      'endValidationDate': endValidationDate.toIso8601String(),
      'mediaUrls': mediaUrls.map((media) => media.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'interests': interests,
      '_count': counts.toJson(),
      'isLiked': isLiked,
      'isWatched': isWatched,
      'isWhatsapped': isWhatsapped,
      'hasOffers': hasOffers,
    };
  }

  // إضافة طريقة للحصول على قائمة عناوين URL فقط (للتوافق مع الكود القديم)
  List<String> get mediaUrlStrings {
    return mediaUrls.map((media) => media.url).toList();
  }

  // إضافة طريقة للحصول على الصور المصغرة
  List<String?> get posterUrls {
    return mediaUrls.map((media) => media.poster).toList();
  }

  // إضافة طريقة للتحقق من نوع الوسائط
  List<String> get mediaTypes {
    return mediaUrls.map((media) => media.type).toList();
  }

  // طريقة للتحقق ما إذا كانت الوسائط عبارة عن فيديو
  bool isVideoMedia(int index) {
    if (index >= 0 && index < mediaUrls.length) {
      return mediaUrls[index].type == 'VIDEO';
    }
    return false;
  }
}

// فئة لإحصائيات الريل - تعديل المتغيرات لتكون غير final لتسمح بالتعديل المباشر
class ReelCounts {
  int likedBy;
  int viewedBy;
  int whatsappedBy;

  ReelCounts({
    required this.likedBy,
    required this.viewedBy,
    required this.whatsappedBy,
  });

  factory ReelCounts.fromJson(Map<String, dynamic> json) {
    return ReelCounts(
      likedBy: json['likedBy'] ?? 0,
      viewedBy: json['viewedBy'] ?? 0,
      whatsappedBy: json['whatsappedBy'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'likedBy': likedBy,
      'viewedBy': viewedBy,
      'whatsappedBy': whatsappedBy,
    };
  }
}
