
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sawa/presentation/models/member_models.dart';
import 'package:sawa/presentation/models/gym_owner_models.dart';
import 'package:sawa/presentation/models/restaurant_owner_models.dart';

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

  /// Place a Food Order
  /// UPDATED: Saves 'ownerId' so the restaurant owner can query it.
  static Future<void> orderFood({
    required String memberId,
    required Restaurant restaurant,
    required Meal meal,
  }) async {
    try {
      // 1. Structure the item data so it looks like a list of items
      final orderItem = {
        'name': meal.name,
        'quantity': 1,
        'price': meal.price,
      };

      // 2. Build the Order Data with ALL necessary linking IDs
      final orderData = {
        'memberId': memberId, // Link to Member
        'customerId': memberId, // Alternate name for Member ID
        'restaurantId': restaurant.rid, // Link to Restaurant
        'restaurantName': restaurant.name,
        
        // CRITICAL FIX: This allows the Restaurant Owner to find the order!
        'ownerId': restaurant.ownerId, 
        
        'mealName': meal.name, 
        'items': [orderItem], // Save as a list
        
        'price': meal.price,
        'totalAmount': meal.price,
        
        'date': Timestamp.now(), 
        'orderDate': Timestamp.now(), 
        'status': 'pending',
      };

      // 3. Save to Firestore
      String orderId = DateTime.now().millisecondsSinceEpoch.toString();
      await _ordersCollection.doc(orderId).set(orderData);
      
    } catch (e) {
      print("Order Error: $e");
      throw Exception('Failed to place order.');
    }
  }

  // --- DASHBOARD STATS ---

  static Future<Map<String, dynamic>> getMemberStats(String memberId) async {
    try {
      final bookingsSnapshot = await _bookingsCollection
          .where('memberId', isEqualTo: memberId)
          .get();

      final bookings = bookingsSnapshot.docs
          .map((doc) => Booking.fromFirestore(doc))
          .toList();

      final ordersSnapshot = await _ordersCollection
          .where('memberId', isEqualTo: memberId)
          .get();

      final orders = ordersSnapshot.docs
          .map((doc) => FoodOrder.fromFirestore(doc))
          .toList();

      int gymVisits = bookings.where((b) => b.type == 'Gym').length;
      int nutritionistSessions = bookings
          .where((b) => b.type == 'Nutritionist')
          .length;

      final upcoming = bookings
          .where((b) => b.date.isAfter(DateTime.now()))
          .toList();
      upcoming.sort((a, b) => a.date.compareTo(b.date));
      Booking? nextAppt = upcoming.isNotEmpty ? upcoming.first : null;

      final pastOrders = orders;
      pastOrders.sort((a, b) => b.date.compareTo(a.date));
      FoodOrder? lastOrder = pastOrders.isNotEmpty ? pastOrders.first : null;

      return {
        'gymVisits': gymVisits,
        'mealsOrdered': orders.length,
        'nutritionistSessions': nutritionistSessions,
        'activePlans': 0, 
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

  static Future<void> bookConsultation({
    required String memberId,
    required String memberName,
    required String nutritionistId,
    required DateTime date,
  }) async {
    try {
      final consultationData = {
        'nutritionistId': nutritionistId,
        'clientId': memberId,
        'clientName': memberName,
        'date': Timestamp.fromDate(date),
        'status': 'Scheduled',
        'type': 'Initial Consultation',
      };

      await _firestore.collection('consultations').add(consultationData);

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