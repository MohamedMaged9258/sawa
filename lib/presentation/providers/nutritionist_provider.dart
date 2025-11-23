// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sawa/presentation/models/nutritionist_models.dart'; // Assume this path

/// A static service class for all Nutritionist Firebase operations.
class NutritionistProvider {
  NutritionistProvider._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final CollectionReference _clientsCollection = _firestore.collection(
    'nutritionist_clients',
  );
  static final CollectionReference _plansCollection = _firestore.collection(
    'meal_plans',
  );
  static final CollectionReference _consultationsCollection = _firestore
      .collection('consultations');

  // =======================================================================
  // --- CLIENTS (C)RUD ---
  // =======================================================================

  static Future<List<Client>> fetchClientsByNutritionId(
    String nutritionistId,
  ) async {
    if (nutritionistId.isEmpty) return [];
    try {
      final snapshot = await _clientsCollection
          .where('nutritionistId', isEqualTo: nutritionistId)
          .orderBy('joinDate', descending: true)
          .get();
      return snapshot.docs.map((doc) => Client.fromFirestore(doc)).toList();
    } catch (e) {
      print("Error fetching clients: $e");
      throw Exception('Failed to fetch clients.');
    }
  }

  static Future<void> addClient(Client client) async {
    if (client.nutritionistId.isEmpty) {
      throw Exception('Nutritionist ID missing');
    }
    try {
      await _clientsCollection.doc(client.cid).set(client.toFirestore());
    } catch (e) {
      print("Error adding client: $e");
      throw Exception('Failed to add client.');
    }
  }

  static Future<void> deleteClient(String clientId) async {
    try {
      await _clientsCollection.doc(clientId).delete();
      // NOTE: In a real app, you would also delete all associated plans and consultations.
    } catch (e) {
      throw Exception('Failed to delete client.');
    }
  }

  // =======================================================================
  // --- MEAL PLANS (CRUD) ---
  // =======================================================================

  static Future<List<MealPlan>> fetchPlansByNutritionist(
    String nutritionistId,
  ) async {
    if (nutritionistId.isEmpty) return [];
    try {
      final snapshot = await _plansCollection
          .where('nutritionistId', isEqualTo: nutritionistId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => MealPlan.fromFirestore(doc)).toList();
    } catch (e) {
      print("Error fetching plans: $e");
      throw Exception('Failed to fetch meal plans.');
    }
  }

  static Future<void> addPlan(MealPlan mealPlan) async {
    if (mealPlan.nutritionistId.isEmpty || mealPlan.clientId.isEmpty) {
      throw Exception('Owner/Client ID missing');
    }
    try {
      await _plansCollection.doc(mealPlan.mid).set(mealPlan.toFirestore());
    } catch (e) {
      throw Exception('Failed to add meal plan.');
    }
  }

  static Future<void> updatePlan(MealPlan mealPlan) async {
    if (mealPlan.nutritionistId.isEmpty || mealPlan.clientId.isEmpty) {
      throw Exception('Owner/Client ID missing');
    }
    try {
      // Only update fields that can change
      Map<String, dynamic> updateData = {
        'name': mealPlan.name,
        'duration': mealPlan.duration,
        'description': mealPlan.description,
        'dailyMeals': mealPlan.dailyMeals,
      };
      await _plansCollection.doc(mealPlan.mid).update(updateData);
    } catch (e) {
      throw Exception('Failed to update meal plan.');
    }
  }

  static Future<void> deletePlan(String planId) async {
    try {
      await _plansCollection.doc(planId).delete();
    } catch (e) {
      throw Exception('Failed to delete meal plan.');
    }
  }

  // =======================================================================
  // --- CONSULTATIONS (RUD) ---
  // =======================================================================

  static Future<List<Consultation>> fetchConsultationsByNutritionist(
    String nutritionistId,
  ) async {
    if (nutritionistId.isEmpty) return [];
    try {
      final snapshot = await _consultationsCollection
          .where('nutritionistId', isEqualTo: nutritionistId)
          .orderBy('date', descending: false)
          .get();
      return snapshot.docs
          .map((doc) => Consultation.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("Error fetching consultations: $e");
      throw Exception('Failed to fetch consultations.');
    }
  }

  static Future<void> addConsultation(Consultation consultation) async {
    if (consultation.nutritionistId.isEmpty || consultation.clientId.isEmpty) {
      throw Exception('Owner/Client ID missing');
    }
    try {
      await _consultationsCollection
          .doc(consultation.cid)
          .set(consultation.toFirestore());
    } catch (e) {
      throw Exception('Failed to add consultation.');
    }
  }

  static Future<void> updateConsultationStatus(
    String consultationId,
    String newStatus,
  ) async {
    try {
      await _consultationsCollection.doc(consultationId).update({
        'status': newStatus,
      });
    } catch (e) {
      throw Exception('Failed to update consultation status.');
    }
  }

  static Future<void> deleteConsultation(String consultationId) async {
  try {
    await _consultationsCollection.doc(consultationId).delete();
  } catch (e) {
    throw Exception('Failed to delete consultation.');
  }
}

  // =======================================================================
  // --- STATISTICS ---
  // =======================================================================

  static Future<Map<String, dynamic>> getStatistics(
    String nutritionistId,
  ) async {
    try {
      final clients = await fetchClientsByNutritionId(nutritionistId);
      final plans = await fetchPlansByNutritionist(nutritionistId);
      final consultations = await fetchConsultationsByNutritionist(
        nutritionistId,
      );

      int pendingConsultations = consultations
          .where((c) => c.status == 'Scheduled')
          .length;

      return {
        'totalClients': clients.length,
        'activePlans': plans.length, // Assuming all plans are active
        'pendingConsultations': pendingConsultations,
        // Revenue is demo data until a payments model is added
        'monthlyRevenue': '1,240',
      };
    } catch (e) {
      print("Error getting stats: $e");
      throw Exception('Failed to load statistics.');
    }
  }
}
