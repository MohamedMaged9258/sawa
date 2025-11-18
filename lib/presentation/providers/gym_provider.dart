// ignore_for_file: avoid_print

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sawa/presentation/models/gym_owner_models.dart';

class GymProvider {
  GymProvider._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final CollectionReference _gymsCollection =
      _firestore.collection('gyms');
  static final CollectionReference _coachesCollection =
      _firestore.collection('coaches');

  // --- GYM METHODS ---

  static Future<List<Gym>> fetchGymsByOwner(String ownerId) async {
    if (ownerId.isEmpty) {
      print("fetchGymsByOwner called with empty ownerId.");
      return [];
    }
    try {
      final snapshot = await _gymsCollection
          .where('gymOwnerId', isEqualTo: ownerId) // Use your model's field name
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => Gym.fromFirestore(doc)).toList();
    } catch (e) {
      print("Error fetching gyms: $e");
      throw Exception('Failed to fetch gyms. Please try again.');
    }
  }

  static Future<void> addGym(Gym newGym, XFile? imageFile) async {
    if (newGym.gymOwnerId.isEmpty) {
      throw Exception('Cannot add gym: ownerId is missing.');
    }
    try {
      String photoUrl = '';
      if (imageFile != null) {
        // Use the generic helper
        photoUrl = await _uploadPhoto(imageFile, 'gym_photos/${newGym.gid}');
      }
      Gym gymToSave = newGym.copyWith(photo: photoUrl);
      await _gymsCollection.doc(gymToSave.gid).set(gymToSave.toFirestore());
    } catch (e) {
      print("Error adding gym: $e");
      throw Exception('Failed to add gym: $e');
    }
  }

  static Future<void> updateGym(Gym updatedGym) async {
    try {
      Map<String, dynamic> updateData = {
        'name': updatedGym.name,
        'location': updatedGym.location,
        'pricePerMonth': updatedGym.pricePerMonth,
        'latitude': updatedGym.latitude,
        'longitude': updatedGym.longitude,
      };
      await _gymsCollection.doc(updatedGym.gid).update(updateData);
    } catch (e) {
      print("Error updating gym: $e");
      throw Exception('Failed to update gym.');
    }
  }

  static Future<void> deleteGym(Gym gymToDelete) async {
    try {
      await _gymsCollection.doc(gymToDelete.gid).delete();
      if (gymToDelete.photo.isNotEmpty) {
        await _deletePhotoFromUrl(gymToDelete.photo);
      }
    } catch (e) {
      print("Error deleting gym: $e");
      throw Exception('Failed to delete gym.');
    }
  }

  /// Calculates basic statistics for the owner.
  static Future<Map<String, dynamic>> getStatistics(String ownerId) async {
    try {
      final gyms = await fetchGymsByOwner(ownerId);
      // NEW: Fetch coaches
      final coaches = await fetchCoachesByOwner(ownerId);

      double totalMonthlyRevenue = gyms.fold(
        0.0,
        (sum, gym) => sum + gym.pricePerMonth,
      );
      
      return {
        'gymCount': gyms.length,
        'coachCount': coaches.length, // NEW
        'totalMonthlyRevenue': totalMonthlyRevenue,
        'activeMembers': 128, // This is still DEMO data
      };
    } catch (e) {
      print("Error getting statistics: $e");
      throw Exception('Failed to load statistics.');
    }
  }

  // --- COACH METHODS ---

  static Future<List<Coach>> fetchCoachesByOwner(String ownerId) async {
    if (ownerId.isEmpty) {
      print("fetchCoachesByOwner called with empty ownerId.");
      return [];
    }
    try {
      final snapshot = await _coachesCollection
          .where('ownerId', isEqualTo: ownerId) // Now queries the new field
          .orderBy('joinedDate', descending: true)
          .get();
      return snapshot.docs.map((doc) => Coach.fromFirestore(doc)).toList();
    } catch (e) {
      print("Error fetching coaches: $e");
      throw Exception('Failed to fetch coaches. Please try again.');
    }
  }

  static Future<void> addCoach(Coach newCoach, XFile? imageFile) async {
    // UPDATED: Check for both fields
    if (newCoach.gymId.isEmpty || newCoach.ownerId.isEmpty) {
      throw Exception('Cannot add coach: gymId or ownerId is missing.');
    }
    try {
      String photoUrl = '';
      if (imageFile != null) {
        photoUrl = await _uploadPhoto(
          imageFile,
          'coach_photos/${newCoach.cid}',
        );
      }
      Coach coachToSave = newCoach.copyWith(photo: photoUrl);
      await _coachesCollection.doc(coachToSave.cid).set(coachToSave.toFirestore());
    } catch (e) {
      print("Error adding coach: $e");
      throw Exception('Failed to add coach: $e');
    }
  }

  static Future<void> deleteCoach(Coach coachToDelete) async {
    try {
      await _coachesCollection.doc(coachToDelete.cid).delete();
      if (coachToDelete.photo.isNotEmpty) {
        await _deletePhotoFromUrl(coachToDelete.photo);
      }
    } catch (e) {
      print("Error deleting coach: $e");
      throw Exception('Failed to delete coach.');
    }
  }

  // --- PRIVATE HELPER METHODS ---

  /// Generic helper to upload a photo and return its download URL.
  static Future<String> _uploadPhoto(XFile imageFile, String folderPath) async {
    try {
      File file = File(imageFile.path);
      String fileName = '$folderPath/${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      Reference storageRef = _storage.ref().child(fileName);
      UploadTask uploadTask = storageRef.putFile(file);
      
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print("Error uploading photo to $folderPath: $e");
      throw Exception('Photo upload failed.');
    }
  }

  /// Generic helper to delete a photo from Storage using its URL.
  static Future<void> _deletePhotoFromUrl(String photoUrl) async {
    if (photoUrl.isEmpty) return;
    try {
      await _storage.refFromURL(photoUrl).delete();
    } catch (e) {
      print("Info: Could not delete photo from storage: $e");
    }
  }
}