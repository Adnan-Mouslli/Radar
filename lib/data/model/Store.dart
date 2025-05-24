class Store {
  final String id;
  final String name;
  final String phone;
  final String city;
  final String address;
  final String image;
  final bool? isActive;
  final double longitude;
  final double latitude;
  final DateTime createdAt;
  final DateTime updatedAt;
  final StoreCount count;

  Store({
    required this.id,
    required this.name,
    required this.phone,
    required this.city,
    required this.address,
    required this.image,
    required this.longitude,
    required this.latitude,
     this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.count,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    // تحويل آمن من أي نوع إلى double
    double parseDouble(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    // طباعة تشخيصية لمساعدة في تحديد المشكلة
    print('Processing store: ${json['name']}');
    print('Count object: ${json['_count']}');

    return Store(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      longitude: parseDouble(json['longitude']),
      latitude: parseDouble(json['latitude']),
      isActive: json["isActive"],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : DateTime.now(),
      count: json['_count'] is Map
          ? StoreCount.fromJson(json['_count'])
          : StoreCount(offers: 0, contents: 0),
    );
  }
}

class StoreCount {
  final int offers;
  final int contents;

  StoreCount({
    required this.offers,
    required this.contents,
  });

  factory StoreCount.fromJson(Map<String, dynamic> json) {
    // تحويل آمن إلى int
    int parseInteger(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is double) return value.toInt();
      return 0;
    }

    return StoreCount(
      offers: parseInteger(json['offers'] ?? 0),
      contents: parseInteger(json['contents'] ?? 0),
    );
  }
}
