import 'package:cloud_firestore/cloud_firestore.dart';

// --- Client Model ---
class Client {
  final String cid;
  final String nutritionistId; // Links to the Nutritionist
  final String name;
  final String email;
  final String phone;
  final DateTime joinDate;
  final String status;
  final String goals;

  Client({
    required this.cid,
    required this.nutritionistId,
    required this.name,
    required this.email,
    required this.phone,
    required this.joinDate,
    required this.status,
    required this.goals,
  });

  Client copyWith({
    String? cid,
    String? nutritionistId,
    String? name,
    String? email,
    String? phone,
    DateTime? joinDate,
    String? status,
    String? goals,
  }) {
    return Client(
      cid: cid ?? this.cid,
      nutritionistId: nutritionistId ?? this.nutritionistId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      joinDate: joinDate ?? this.joinDate,
      status: status ?? this.status,
      goals: goals ?? this.goals,
    );
  }

  factory Client.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Client(
      cid: doc.id,
      nutritionistId: data['nutritionistId'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      joinDate: (data['joinDate'] as Timestamp).toDate(),
      status: data['status'] ?? 'Pending',
      goals: data['goals'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nutritionistId': nutritionistId,
      'name': name,
      'email': email,
      'phone': phone,
      'joinDate': joinDate,
      'status': status,
      'goals': goals,
    };
  }
}

// --- MealPlan Model ---
class MealPlan {
  final String mid;
  final String nutritionistId; // Links to the Nutritionist
  final String clientId; // Links to the specific client
  final String name;
  final String clientName; // Stored for display convenience
  final String duration;
  final String description;
  final DateTime createdAt;
  // Placeholder fields for daily meals (to be implemented fully later)
  final Map<String, String> dailyMeals; 

  MealPlan({
    required this.mid,
    required this.nutritionistId,
    required this.clientId,
    required this.name,
    required this.clientName,
    required this.duration,
    required this.description,
    required this.createdAt,
    this.dailyMeals = const {},
  });

  MealPlan copyWith({
    String? mid,
    String? nutritionistId,
    String? clientId,
    String? name,
    String? clientName,
    String? duration,
    String? description,
    DateTime? createdAt,
    Map<String, String>? dailyMeals,
  }) {
    return MealPlan(
      mid: mid ?? this.mid,
      nutritionistId: nutritionistId ?? this.nutritionistId,
      clientId: clientId ?? this.clientId,
      name: name ?? this.name,
      clientName: clientName ?? this.clientName,
      duration: duration ?? this.duration,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      dailyMeals: dailyMeals ?? this.dailyMeals,
    );
  }

  factory MealPlan.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MealPlan(
      mid: doc.id,
      nutritionistId: data['nutritionistId'] ?? '',
      clientId: data['clientId'] ?? '',
      name: data['name'] ?? '',
      clientName: data['clientName'] ?? '',
      duration: data['duration'] ?? '',
      description: data['description'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      dailyMeals: Map<String, String>.from(data['dailyMeals'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nutritionistId': nutritionistId,
      'clientId': clientId,
      'name': name,
      'clientName': clientName,
      'duration': duration,
      'description': description,
      'createdAt': createdAt,
      'dailyMeals': dailyMeals,
    };
  }
}

// --- Consultation Model ---
class Consultation {
  final String cid;
  final String nutritionistId; // Links to the Nutritionist
  final String clientId; // Links to the specific client
  final String clientName;
  final DateTime date;
  final String status;
  final String type;

  Consultation({
    required this.cid,
    required this.nutritionistId,
    required this.clientId,
    required this.clientName,
    required this.date,
    required this.status,
    required this.type,
  });

  Consultation copyWith({
    String? cid,
    String? nutritionistId,
    String? clientId,
    String? clientName,
    DateTime? date,
    String? status,
    String? type,
  }) {
    return Consultation(
      cid: cid ?? this.cid,
      nutritionistId: nutritionistId ?? this.nutritionistId,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      date: date ?? this.date,
      status: status ?? this.status,
      type: type ?? this.type,
    );
  }

  factory Consultation.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Consultation(
      cid: doc.id,
      nutritionistId: data['nutritionistId'] ?? '',
      clientId: data['clientId'] ?? '',
      clientName: data['clientName'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      status: data['status'] ?? 'Scheduled',
      type: data['type'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nutritionistId': nutritionistId,
      'clientId': clientId,
      'clientName': clientName,
      'date': date,
      'status': status,
      'type': type,
    };
  }
}