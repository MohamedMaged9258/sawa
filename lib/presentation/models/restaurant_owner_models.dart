import 'package:cloud_firestore/cloud_firestore.dart';

class Restaurant {
  final String rid; // Was 'rid'
  final String ownerId; // NEW: Links to the user
  final String name;
  final String location;
  final String cuisineType;
  final double priceRange;
  final String photo;
  final DateTime createdAt;
  final double? latitude;
  final double? longitude;

  Restaurant({
    required this.rid,
    required this.ownerId,
    required this.name,
    required this.location,
    required this.cuisineType,
    required this.priceRange,
    required this.photo,
    required this.createdAt,
    this.latitude,
    this.longitude,
  });

  Restaurant copyWith({
    String? rid,
    String? ownerId,
    String? name,
    String? location,
    String? cuisineType,
    double? priceRange,
    String? photo,
    DateTime? createdAt,
    double? latitude,
    double? longitude,
  }) {
    return Restaurant(
      rid: rid ?? this.rid,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      location: location ?? this.location,
      cuisineType: cuisineType ?? this.cuisineType,
      priceRange: priceRange ?? this.priceRange,
      photo: photo ?? this.photo,
      createdAt: createdAt ?? this.createdAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  factory Restaurant.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Restaurant(
      rid: doc.id,
      ownerId: data['ownerId'] ?? '',
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      cuisineType: data['cuisineType'] ?? '',
      priceRange: (data['priceRange'] ?? 0.0).toDouble(),
      photo: data['photo'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      latitude: data['latitude'] as double?,
      longitude: data['longitude'] as double?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ownerId': ownerId,
      'name': name,
      'location': location,
      'cuisineType': cuisineType,
      'priceRange': priceRange,
      'photo': photo,
      'createdAt': createdAt,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class Meal {
  final String mid; // Was 'mid'
  final String restaurantId; // NEW: Links to specific restaurant
  final String ownerId; // NEW: Links to owner for easy fetching
  final String name;
  final String description;
  final double price;
  final String category;
  final String photo;
  final bool isAvailable;
  final DateTime createdAt;

  Meal({
    required this.mid,
    required this.restaurantId,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.photo,
    required this.isAvailable,
    required this.createdAt,
  });

  Meal copyWith({
    String? mid,
    String? restaurantId,
    String? ownerId,
    String? name,
    String? description,
    double? price,
    String? category,
    String? photo,
    bool? isAvailable,
    DateTime? createdAt,
  }) {
    return Meal(
      mid: mid ?? this.mid,
      restaurantId: restaurantId ?? this.restaurantId,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      photo: photo ?? this.photo,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Meal.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Meal(
      mid: doc.id,
      restaurantId: data['restaurantId'] ?? '',
      ownerId: data['ownerId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      category: data['category'] ?? '',
      photo: data['photo'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'restaurantId': restaurantId,
      'ownerId': ownerId,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'photo': photo,
      'isAvailable': isAvailable,
      'createdAt': createdAt,
    };
  }
}

class Order {
  final String oid; // Was 'oid'
  final String ownerId; // To show to the restaurant owner
  final String customerId;
  final List<Map<String, dynamic>> items; // Simplified for Firestore
  final double totalAmount;
  final String status;
  final DateTime orderDate;

  Order({
    required this.oid,
    required this.ownerId,
    required this.customerId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.orderDate,
  });

  factory Order.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Order(
      oid: doc.id,
      ownerId: data['ownerId'] ?? '',
      customerId: data['customerId'] ?? '',
      items: List<Map<String, dynamic>>.from(data['items'] ?? []),
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'pending',
      orderDate: (data['orderDate'] as Timestamp).toDate(),
    );
  }

  // copyWith added for status updates
  Order copyWith({
    String? oid,
    String? ownerId,
    String? customerId,
    List<Map<String, dynamic>>? items,
    double? totalAmount,
    String? status,
    DateTime? orderDate,
  }) {
    return Order(
      oid: oid ?? this.oid,
      ownerId: ownerId ?? this.ownerId,
      customerId: customerId ?? this.customerId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
    );
  }
}
