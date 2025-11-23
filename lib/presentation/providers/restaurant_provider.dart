// ignore_for_file: avoid_print, avoid_types_as_parameter_names

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sawa/presentation/models/restaurant_owner_models.dart';

class RestaurantProvider {
  RestaurantProvider._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static final CollectionReference _restaurantsCollection = _firestore.collection('restaurants');
  static final CollectionReference _mealsCollection = _firestore.collection('meals');
  static final CollectionReference _ordersCollection = _firestore.collection('orders');

  // ================= RESTAURANTS =================

  static Future<List<Restaurant>> fetchRestaurantsByOwner(String ownerId) async {
    if (ownerId.isEmpty) return [];
    try {
      final snapshot = await _restaurantsCollection
          .where('ownerId', isEqualTo: ownerId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => Restaurant.fromFirestore(doc)).toList();
    } catch (e) {
      print("Error fetching restaurants: $e");
      throw Exception('Failed to fetch restaurants.');
    }
  }

  static Future<void> addRestaurant(Restaurant restaurant, XFile? imageFile) async {
    if (restaurant.ownerId.isEmpty) throw Exception('Owner ID missing');
    try {
      String photoUrl = '';
      if (imageFile != null) {
        photoUrl = await _uploadPhoto(imageFile, 'restaurant_photos/${restaurant.rid}');
      }
      Restaurant newRestaurant = restaurant.copyWith(photo: photoUrl);
      await _restaurantsCollection.doc(newRestaurant.rid).set(newRestaurant.toFirestore());
    } catch (e) {
      throw Exception('Failed to add restaurant: $e');
    }
  }

  static Future<void> deleteRestaurant(Restaurant restaurant) async {
    try {
      await _restaurantsCollection.doc(restaurant.rid).delete();
      await _deletePhotoFromUrl(restaurant.photo);
      // Optional: Delete associated meals here if needed
    } catch (e) {
      throw Exception('Failed to delete restaurant.');
    }
  }

  // ================= MEALS =================

  static Future<List<Meal>> fetchMealsByOwner(String ownerId) async {
    if (ownerId.isEmpty) return [];
    try {
      final snapshot = await _mealsCollection
          .where('ownerId', isEqualTo: ownerId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => Meal.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch meals.');
    }
  }

  static Future<void> addMeal(Meal meal, XFile? imageFile) async {
    if (meal.restaurantId.isEmpty || meal.ownerId.isEmpty) {
      throw Exception('Restaurant ID or Owner ID missing');
    }
    try {
      String photoUrl = '';
      if (imageFile != null) {
        photoUrl = await _uploadPhoto(imageFile, 'meal_photos/${meal.mid}');
      }
      Meal newMeal = meal.copyWith(photo: photoUrl);
      await _mealsCollection.doc(newMeal.mid).set(newMeal.toFirestore());
    } catch (e) {
      throw Exception('Failed to add meal: $e');
    }
  }

  static Future<void> deleteMeal(Meal meal) async {
    try {
      await _mealsCollection.doc(meal.mid).delete();
      await _deletePhotoFromUrl(meal.photo);
    } catch (e) {
      throw Exception('Failed to delete meal.');
    }
  }
  
  static Future<void> toggleMealAvailability(Meal meal) async {
    try {
      await _mealsCollection.doc(meal.mid).update({'isAvailable': !meal.isAvailable});
    } catch (e) {
      throw Exception('Failed to update availability.');
    }
  }

  // ================= ORDERS =================

  static Future<List<Order>> fetchOrdersByOwner(String ownerId) async {
    if (ownerId.isEmpty) return [];
    try {
      final snapshot = await _ordersCollection
          .where('ownerId', isEqualTo: ownerId)
          .orderBy('orderDate', descending: true)
          .get();
      return snapshot.docs.map((doc) => Order.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch orders.');
    }
  }

  static Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _ordersCollection.doc(orderId).update({'status': newStatus});
    } catch (e) {
      throw Exception('Failed to update order status.');
    }
  }

  // ================= STATISTICS =================

  static Future<Map<String, dynamic>> getStatistics(String ownerId) async {
    try {
      final restaurants = await fetchRestaurantsByOwner(ownerId);
      final meals = await fetchMealsByOwner(ownerId);
      final orders = await fetchOrdersByOwner(ownerId);

      double totalRevenue = orders
          .where((o) => o.status != 'cancelled')
          .fold(0.0, (sum, o) => sum + o.totalAmount);
      
      int pendingOrders = orders.where((o) => o.status == 'pending').length;

      return {
        'restaurantCount': restaurants.length,
        'mealCount': meals.length,
        'orderCount': orders.length,
        'pendingOrderCount': pendingOrders,
        'totalRevenue': totalRevenue,
      };
    } catch (e) {
      throw Exception('Failed to load statistics.');
    }
  }

  // ================= HELPERS =================

  static Future<String> _uploadPhoto(XFile imageFile, String folderPath) async {
    try {
      File file = File(imageFile.path);
      String fileName = '$folderPath/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = _storage.ref().child(fileName);
      await storageRef.putFile(file);
      return await storageRef.getDownloadURL();
    } catch (e) {
      throw Exception('Photo upload failed.');
    }
  }

  static Future<void> _deletePhotoFromUrl(String photoUrl) async {
    if (photoUrl.isEmpty) return;
    try {
      await _storage.refFromURL(photoUrl).delete();
    } catch (e) {
      print("Info: Could not delete photo: $e");
    }
  }
}