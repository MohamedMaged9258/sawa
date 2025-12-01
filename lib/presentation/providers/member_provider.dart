// lib/presentation/providers/member_provider.dart
// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sawa/presentation/models/member_models.dart';
import 'package:sawa/presentation/models/gym_owner_models.dart';
import 'package:sawa/presentation/models/restaurant_owner_models.dart';
import 'package:sawa/presentation/models/nutritionist_models.dart';

class MemberProvider {
  MemberProvider._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final CollectionReference _bookingsCollection = _firestore.collection(
    'bookings',
  );
  static final CollectionReference _consultationsCollection = _firestore
      .collection('consultations');
  static final CollectionReference _ordersCollection = _firestore.collection(
    'orders',
  );

  // --- PUBLIC DATA FETCHING (Read Only) ---

  static Future<List<Gym>> fetchAllGyms() async {
    try {
      final snapshot = await _firestore
          .collection('gyms')
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => Gym.fromFirestore(doc)).toList();
    } catch (e) {
      print("Error fetching gyms: $e");
      try {
        final snapshot = await _firestore.collection('gyms').get();
        return snapshot.docs.map((doc) => Gym.fromFirestore(doc)).toList();
      } catch (e2) {
        throw Exception('Failed to load gyms.');
      }
    }
  }

  static Future<List<Restaurant>> fetchAllRestaurants() async {
    try {
      final snapshot = await _firestore
          .collection('restaurants')
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => Restaurant.fromFirestore(doc)).toList();
    } catch (e) {
      print("Error fetching restaurants: $e");
      try {
        final snapshot = await _firestore.collection('restaurants').get();
        return snapshot.docs
            .map((doc) => Restaurant.fromFirestore(doc))
            .toList();
      } catch (e2) {
        throw Exception('Failed to load restaurants.');
      }
    }
  }

  static Future<List<Meal>> fetchMealsForRestaurant(String restaurantId) async {
    try {
      final snapshot = await _firestore
          .collection('meals')
          .where('restaurantId', isEqualTo: restaurantId)
          .where('isAvailable', isEqualTo: true)
          .get();
      return snapshot.docs.map((doc) => Meal.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to load menu.');
    }
  }

  static Future<List<MealPlan>> fetchMealPlansForMember(String memberId) async {
    try {
      final snapshot = await _firestore
          .collection('meal_plans')
          .where('clientId', isEqualTo: memberId)
          .get();

      final plans = snapshot.docs
          .map((doc) => MealPlan.fromFirestore(doc))
          .toList();

      plans.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return plans;
    } catch (e) {
      print("Error fetching meal plans: $e");
      throw Exception('Failed to load meal plans.');
    }
  }

  // --- MEMBER ACTIONS ---

  static Future<void> bookGym({
    required String memberId,
    required Gym gym,
    required DateTime date,
  }) async {
    try {
      final booking = Booking(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        memberId: memberId,
        serviceId: gym.gid,
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

  static Future<void> orderFood({
    required String memberId,
    required Restaurant restaurant,
    required Meal meal,
  }) async {
    try {
      final orderItem = {'name': meal.name, 'quantity': 1, 'price': meal.price};

      final orderData = {
        'memberId': memberId,
        'customerId': memberId,
        'restaurantId': restaurant.rid,
        'restaurantName': restaurant.name,
        'ownerId': restaurant.ownerId,
        'mealName': meal.name,
        'items': [orderItem],
        'price': meal.price,
        'totalAmount': meal.price,
        'date': Timestamp.now(),
        'orderDate': Timestamp.now(),
        'status': 'pending',
      };

      String orderId = DateTime.now().millisecondsSinceEpoch.toString();
      await _ordersCollection.doc(orderId).set(orderData);
    } catch (e) {
      print("Order Error: $e");
      throw Exception('Failed to place order.');
    }
  }

  // --- STATISTICS & DASHBOARD DATA (UPDATED) ---

  static Future<Map<String, dynamic>> getMemberStats(String memberId) async {
    try {
      // 1. Fetch Gym Bookings (from 'bookings')
      final bookingsSnapshot = await _bookingsCollection
          .where('memberId', isEqualTo: memberId)
          .get();

      final gymBookings = bookingsSnapshot.docs
          .map((doc) => Booking.fromFirestore(doc))
          .toList();

      // 2. Fetch Consultations (from 'consultations')
      final consultationsSnapshot = await _consultationsCollection
          .where('clientId', isEqualTo: memberId)
          .get();

      // 3. Manually map Consultations to Booking objects for the Dashboard.
      // We do this manually to extract 'nutritionistName' directly from the doc
      // even if the Consultation model doesn't strictly have it yet.
      final consultationBookings = consultationsSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Booking(
          id: doc.id,
          memberId: data['clientId'] ?? '',
          serviceId: data['nutritionistId'] ?? '',
          // HERE: We read the name we saved in bookConsultation
          serviceName: data['nutritionistName'] ?? 'Nutritionist',
          type: 'Nutritionist',
          date: (data['date'] as Timestamp).toDate(),
          status: data['status'] ?? 'Scheduled',
        );
      }).toList();

      // 4. Merge All Appointments
      final allAppointments = [...gymBookings, ...consultationBookings];

      // 5. Fetch Orders
      final ordersSnapshot = await _ordersCollection
          .where('memberId', isEqualTo: memberId)
          .get();

      final orders = ordersSnapshot.docs
          .map((doc) => FoodOrder.fromFirestore(doc))
          .toList();

      // 6. Fetch Meal Plans (Safe Fetch)
      List<MealPlan> mealPlans = [];
      try {
        mealPlans = await fetchMealPlansForMember(memberId);
      } catch (e) {
        print("Warning: Could not fetch meal plans for stats: $e");
      }

      // --- CALCULATIONS ---

      int gymVisits = gymBookings.length;
      int nutritionistSessions = consultationBookings.length;

      // Find Next Appointment (from merged list)
      final upcoming = allAppointments
          .where((b) => b.date.isAfter(DateTime.now()))
          .toList();
      upcoming.sort((a, b) => a.date.compareTo(b.date));

      Booking? nextAppt = upcoming.isNotEmpty ? upcoming.first : null;

      // Find Last Order
      final pastOrders = orders;
      pastOrders.sort((a, b) => b.date.compareTo(a.date));
      FoodOrder? lastOrder = pastOrders.isNotEmpty ? pastOrders.first : null;

      return {
        'gymVisits': gymVisits,
        'mealsOrdered': orders.length,
        'nutritionistSessions': nutritionistSessions,
        'activePlans': mealPlans.length,
        'nextAppointment': nextAppt,
        'lastOrder': lastOrder,
      };
    } catch (e) {
      print("Error stats: $e");
      throw Exception('Failed to load stats.');
    }
  }

  // --- NUTRITIONIST METHODS ---

  static Future<List<Map<String, dynamic>>> fetchAllNutritionists() async {
    try {
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
          'photo': '',
        };
      }).toList();
    } catch (e) {
      print("Error fetching nutritionists: $e");
      throw Exception('Failed to load nutritionists.');
    }
  }

  // UPDATED: Only writes to 'consultations' collection
  static Future<void> bookConsultation({
    required String memberId,
    required String memberName,
    required String nutritionistId,
    required String nutritionistName,
    required DateTime date,
  }) async {
    try {
      final consultationData = {
        'nutritionistId': nutritionistId,
        'nutritionistName': nutritionistName, // Saving name for display later
        'clientId': memberId,
        'clientName': memberName,
        'date': Timestamp.fromDate(date),
        'status': 'Scheduled',
        'type': 'Initial Consultation',
      };

      // ONLY write to consultations collection
      await _consultationsCollection.add(consultationData);
    } catch (e) {
      throw Exception('Failed to book consultation.');
    }
  }
}
