import 'package:cloud_firestore/cloud_firestore.dart';

// --- Member Profile ---
class Member {
  final String id;
  final String name;
  final String email;
  final String phone;
  final double? weight;
  final double? height;
  final String goal; // e.g., "Lose Weight", "Gain Muscle"

  Member({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.weight,
    this.height,
    this.goal = '',
  });

  factory Member.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Member(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      weight: (data['weight'] ?? 0.0).toDouble(),
      height: (data['height'] ?? 0.0).toDouble(),
      goal: data['goal'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'weight': weight,
      'height': height,
      'goal': goal,
    };
  }
}

// --- Booking Model (Gym/Consultation) ---
class Booking {
  final String id;
  final String memberId;
  final String serviceId; // Gym ID or Nutritionist ID
  final String serviceName; // For display
  final String type; // 'Gym' or 'Nutritionist'
  final DateTime date;
  final String status; // 'Upcoming', 'Completed', 'Cancelled'

  Booking({
    required this.id,
    required this.memberId,
    required this.serviceId,
    required this.serviceName,
    required this.type,
    required this.date,
    required this.status,
  });

  factory Booking.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Booking(
      id: doc.id,
      memberId: data['memberId'] ?? '',
      serviceId: data['serviceId'] ?? '',
      serviceName: data['serviceName'] ?? '',
      type: data['type'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      status: data['status'] ?? 'Upcoming',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'memberId': memberId,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'type': type,
      'date': date,
      'status': status,
    };
  }
}

// --- Order Model (Food) ---
class FoodOrder {
  final String id;
  final String memberId;
  final String restaurantId;
  final String restaurantName;
  final String mealName;
  final double price;
  final DateTime date;
  final String status; // 'Pending', 'Delivered'

  FoodOrder({
    required this.id,
    required this.memberId,
    required this.restaurantId,
    required this.restaurantName,
    required this.mealName,
    required this.price,
    required this.date,
    required this.status,
  });

  factory FoodOrder.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return FoodOrder(
      id: doc.id,
      memberId: data['memberId'] ?? '',
      restaurantId: data['restaurantId'] ?? '',
      restaurantName: data['restaurantName'] ?? '',
      mealName: data['mealName'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      status: data['status'] ?? 'Pending',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'memberId': memberId,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'mealName': mealName,
      'price': price,
      'date': date,
      'status': status,
    };
  }
}
