// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sawa/presentation/models/member_models.dart';
// Reuse existing models for fetching Lists
import 'package:sawa/presentation/models/gym_owner_models.dart';
import 'package:sawa/presentation/models/restaurant_owner_models.dart';
// You might need a separate Nutritionist Profile model if not using the Owner one directly

class MemberProvider {
  MemberProvider._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final CollectionReference _bookingsCollection = _firestore.collection(
    'bookings',
  );
  static final CollectionReference _ordersCollection = _firestore.collection(
    'orders',
  );

  // --- PUBLIC DATA FETCHING (Read Only) ---

  /// Fetch ALL gyms for the member to browse
  static Future<List<Gym>> fetchAllGyms() async {
    try {
      final snapshot = await _firestore
          .collection('gyms')
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => Gym.fromFirestore(doc)).toList();
    } catch (e) {
      print("Error fetching gyms: $e");
      throw Exception('Failed to load gyms.');
    }
  }

  /// Fetch ALL restaurants
  static Future<List<Restaurant>> fetchAllRestaurants() async {
    try {
      final snapshot = await _firestore
          .collection('restaurants')
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => Restaurant.fromFirestore(doc)).toList();
    } catch (e) {
      print("Error fetching restaurants: $e");
      throw Exception('Failed to load restaurants.');
    }
  }

  /// Fetch Meals for a specific restaurant
  static Future<List<Meal>> fetchMealsForRestaurant(String restaurantId) async {
    try {
      final snapshot = await _firestore
          .collection('meals')
          .where('restaurantId', isEqualTo: restaurantId)
          .get();
      return snapshot.docs.map((doc) => Meal.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to load menu.');
    }
  }

  // --- MEMBER ACTIONS ---

  /// Create a new Gym Booking
  static Future<void> bookGym({
    required String memberId,
    required Gym gym,
    required DateTime date,
  }) async {
    try {
      final booking = Booking(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        memberId: memberId,
        serviceId: gym.gid, // Using 'gid' from Gym model
        serviceName: gym.name,
        type: 'Gym',
        date: date,
        status: 'Upcoming',
      );
      await _bookingsCollection.doc(booking.id).set(booking.toFirestore());
    } catch (e) {
      throw Exception('Failed to book gym.');
    }
  }

  /// Place a Food Order
  static Future<void> orderFood({
    required String memberId,
    required Restaurant restaurant,
    required Meal meal,
  }) async {
    try {
      final order = FoodOrder(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        memberId: memberId,
        restaurantId: restaurant.rid,
        restaurantName: restaurant.name,
        mealName: meal.name,
        price: meal.price,
        date: DateTime.now(),
        status: 'Pending',
      );
      await _ordersCollection.doc(order.id).set(order.toFirestore());
    } catch (e) {
      throw Exception('Failed to place order.');
    }
  }

  // --- DASHBOARD STATS ---

  static Future<Map<String, dynamic>> getMemberStats(String memberId) async {
    try {
      // 1. Get Gym/Consultation Bookings
      final bookingsSnapshot = await _bookingsCollection
          .where('memberId', isEqualTo: memberId)
          .get();

      final bookings = bookingsSnapshot.docs
          .map((doc) => Booking.fromFirestore(doc))
          .toList();

      // 2. Get Food Orders
      final ordersSnapshot = await _ordersCollection
          .where('memberId', isEqualTo: memberId)
          .get();

      final orders = ordersSnapshot.docs
          .map((doc) => FoodOrder.fromFirestore(doc))
          .toList();

      // Calculate counts
      int gymVisits = bookings.where((b) => b.type == 'Gym').length;
      int nutritionistSessions = bookings
          .where((b) => b.type == 'Nutritionist')
          .length; // Future use

      // Find next appointment
      final upcoming = bookings
          .where((b) => b.date.isAfter(DateTime.now()))
          .toList();
      upcoming.sort((a, b) => a.date.compareTo(b.date));
      Booking? nextAppt = upcoming.isNotEmpty ? upcoming.first : null;

      // Find last meal
      final pastOrders = orders;
      pastOrders.sort((a, b) => b.date.compareTo(a.date)); // Descending
      FoodOrder? lastOrder = pastOrders.isNotEmpty ? pastOrders.first : null;

      return {
        'gymVisits': gymVisits,
        'mealsOrdered': orders.length,
        'nutritionistSessions': nutritionistSessions,
        'activePlans': 0, // Placeholder until Plans logic is connected
        'nextAppointment': nextAppt,
        'lastOrder': lastOrder,
      };
    } catch (e) {
      print("Error stats: $e");
      throw Exception('Failed to load stats.');
    }
  }

  // --- NUTRITIONIST METHODS ---

  /// Fetch all users who are nutritionists
  static Future<List<Map<String, dynamic>>> fetchAllNutritionists() async {
    try {
      // Assuming nutritionists are stored in 'users' collection with role 'nutritionist'
      // Or if you have a 'nutritionist_profiles' collection (recommended)
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'nutritionist')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Unknown',
          'email': data['email'] ?? '',
          // Add other profile fields like 'specialization' if they exist in your user doc
        };
      }).toList();
    } catch (e) {
      print("Error fetching nutritionists: $e");
      throw Exception('Failed to load nutritionists.');
    }
  }

  /// Book a consultation
  static Future<void> bookConsultation({
    required String memberId,
    required String memberName,
    required String nutritionistId,
    required DateTime date,
  }) async {
    try {
      // This writes to the 'consultations' collection that the Nutritionist app reads
      final consultationData = {
        'ownerId': nutritionistId, // The nutritionist owns this record
        'clientId': memberId, // The member who booked
        'clientName': memberName,
        'date': Timestamp.fromDate(date),
        'status': 'Scheduled',
        'type': 'Initial Consultation', // Default type
      };

      await _firestore.collection('consultations').add(consultationData);

      // Also create a booking record for the member's dashboard stats
      final booking = Booking(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        memberId: memberId,
        serviceId: nutritionistId,
        serviceName: 'Nutritionist Consultation',
        type: 'Nutritionist',
        date: date,
        status: 'Upcoming',
      );
      await _bookingsCollection.doc(booking.id).set(booking.toFirestore());
    } catch (e) {
      throw Exception('Failed to book consultation.');
    }
  }
}
