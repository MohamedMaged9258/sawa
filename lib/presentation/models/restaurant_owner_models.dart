// lib/presentation/screens/restaurant_owner/restaurant_owner_models.dart
class Restaurant {
  String id;
  String name;
  String location;
  String cuisineType;
  double priceRange;
  String photo;
  DateTime createdAt;
  double? latitude;
  double? longitude;

  Restaurant({
    required this.id,
    required this.name,
    required this.location,
    required this.cuisineType,
    required this.priceRange,
    required this.photo,
    required this.createdAt,
    this.latitude,
    this.longitude,
  });
}

class Meal {
  String id;
  String name;
  String description;
  double price;
  String category;
  String photo;
  bool isAvailable;
  DateTime createdAt;

  Meal({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.photo,
    required this.isAvailable,
    required this.createdAt,
  });
}

class Order {
  String id;
  String customerName;
  List<Meal> meals;
  double totalAmount;
  String status;
  DateTime orderDate;

  Order({
    required this.id,
    required this.customerName,
    required this.meals,
    required this.totalAmount,
    required this.status,
    required this.orderDate,
  });
}