class OfferModel {
  final String id;
  final String title;
  final String description;
  final List<String> images;
  final double price;
  final int discount;
  final String? contentId;
  final String categoryId;
  final String storeId;
  final bool isActive;
  final DateTime startDate;
  final DateTime? endDate;
  final CategoryModel category;
  final StoreModel store;
  final ContentModel? content;
   double? distance;

  OfferModel({
    required this.id,
    required this.title,
    required this.description,
    required this.images,
    required this.price,
    required this.discount,
    this.contentId,
    required this.categoryId,
    required this.storeId,
    required this.isActive,
    required this.startDate,
    this.endDate,
    required this.category,
    required this.store,
    this.content,
     this.distance,
  });

  // Getter for main image URL
  String get mainImage => images.isNotEmpty ? images.first : '';

  // Getter for store location
  double get latitude => store.latitude;
  double get longitude => store.longitude;

  // Getter for formatted price
  String get formattedPrice => '$price';

  // Getter for discount amount
  double get discountAmount => price * (discount / 100);

  // Getter for price after discount
  double get priceAfterDiscount => price - discountAmount;

  // Getter for formatted price after discount
  String get formattedPriceAfterDiscount =>
      '${priceAfterDiscount.toStringAsFixed(0)}';

  // Factory method to create OfferModel from JSON
  factory OfferModel.fromJson(Map<String, dynamic> json, {double? distance}) {
    return OfferModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      images: List<String>.from(json['images'] ?? []),
      price: json['price'].toDouble(),
      discount: json['discount'],
      contentId: json['contentId'],
      categoryId: json['categoryId'],
      storeId: json['storeId'],
      isActive: json['isActive'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      category: CategoryModel.fromJson(json['category']),
      store: StoreModel.fromJson(json['store']),
      content: json['content'] != null
          ? ContentModel.fromJson(json['content'])
          : null,
      distance: distance ?? 0.0,
    );
  }
}

class CategoryModel {
  final String id;
  final String name;

  CategoryModel({
    required this.id,
    required this.name,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
    );
  }
}

class StoreModel {
  final String id;
  final String name;
  final String city;
  final String address;
  final double longitude;
  final double latitude;
  final String image;
  final String phone;

  StoreModel({
    required this.id,
    required this.name,
    required this.city,
    required this.address,
    required this.longitude,
    required this.latitude,
    required this.image,
    required this.phone,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'],
      name: json['name'],
      city: json['city'],
      address: json['address'],
      longitude: json['longitude'].toDouble(),
      latitude: json['latitude'].toDouble(),
      image: json['image'],
      phone: json['phone'],
    );
  }
}

class ContentModel {
  final String id;
  final String title;
  final String ownerType;

  ContentModel({
    required this.id,
    required this.title,
    required this.ownerType,
  });

  factory ContentModel.fromJson(Map<String, dynamic> json) {
    return ContentModel(
      id: json['id'],
      title: json['title'],
      ownerType: json['ownerType'],
    );
  }
}
