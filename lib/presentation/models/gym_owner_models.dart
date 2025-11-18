import 'package:cloud_firestore/cloud_firestore.dart';

// --- Gym Class (Unchanged from your file) ---
class Gym {
  String gid;
  String gymOwnerId;
  String name;
  String location;
  double pricePerMonth;
  String photo;
  DateTime createdAt;
  double? latitude;
  double? longitude;

  Gym({
    required this.gid,
    required this.gymOwnerId,
    required this.name,
    required this.location,
    required this.pricePerMonth,
    required this.photo,
    required this.createdAt,
    this.latitude,
    this.longitude,
  });

  Gym copyWith({
    String? gid,
    String? gymOwnerId,
    String? name,
    String? location,
    double? pricePerMonth,
    String? photo,
    DateTime? createdAt,
    double? latitude,
    double? longitude,
  }) {
    return Gym(
      gid: gid ?? this.gid,
      gymOwnerId: gymOwnerId ?? this.gymOwnerId,
      name: name ?? this.name,
      location: location ?? this.location,
      pricePerMonth: pricePerMonth ?? this.pricePerMonth,
      photo: photo ?? this.photo,
      createdAt: createdAt ?? this.createdAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  factory Gym.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Gym(
      gid: doc.id,
      gymOwnerId: data['gymOwnerId'] ?? '',
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      pricePerMonth: (data['pricePerMonth'] ?? 0.0).toDouble(),
      photo: data['photo'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      latitude: data['latitude'] as double?,
      longitude: data['longitude'] as double?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'gid': gid,
      'gymOwnerId': gymOwnerId,
      'name': name,
      'location': location,
      'pricePerMonth': pricePerMonth,
      'photo': photo,
      'createdAt': createdAt,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

// --- Coach Class (UPDATED) ---
class Coach {
  String cid;
  String gymId; // The specific gym
  String ownerId; // NEW: The user who owns the gym/coach
  String name;
  String experience;
  String photo;
  String specialization;
  DateTime joinedDate;

  Coach({
    required this.cid,
    required this.gymId,
    required this.ownerId, // NEW
    required this.name,
    required this.experience,
    required this.photo,
    required this.specialization,
    required this.joinedDate,
  });

  Coach copyWith({
    String? cid,
    String? gymId,
    String? ownerId, // NEW
    String? name,
    String? experience,
    String? photo,
    String? specialization,
    DateTime? joinedDate,
  }) {
    return Coach(
      cid: cid ?? this.cid,
      gymId: gymId ?? this.gymId,
      ownerId: ownerId ?? this.ownerId, // NEW
      name: name ?? this.name,
      experience: experience ?? this.experience,
      photo: photo ?? this.photo,
      specialization: specialization ?? this.specialization,
      joinedDate: joinedDate ?? this.joinedDate,
    );
  }

  /// Converts a Firestore DocumentSnapshot into a Coach object
  factory Coach.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Coach(
      cid: doc.id,
      gymId: data['gymId'] ?? '',
      ownerId: data['ownerId'] ?? '', // NEW
      name: data['name'] ?? '',
      experience: data['experience'] ?? '',
      photo: data['photo'] ?? '',
      specialization: data['specialization'] ?? '',
      joinedDate: (data['joinedDate'] as Timestamp).toDate(),
    );
  }

  /// Converts a Coach object into a Map for uploading to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'gymId': gymId,
      'ownerId': ownerId, // NEW
      'name': name,
      'experience': experience,
      'photo': photo,
      'specialization': specialization,
      'joinedDate': joinedDate,
    };
  }
}