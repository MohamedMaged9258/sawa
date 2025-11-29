import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sawa/presentation/models/gym_owner_models.dart';
import 'package:sawa/presentation/models/member_models.dart'; // To use Booking model

class GymProvider {
  GymProvider._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final CollectionReference _gymsCollection =
      _firestore.collection('gyms');
  static final CollectionReference _coachesCollection =
      _firestore.collection('coaches');
  static final CollectionReference _bookingsCollection =
      _firestore.collection('bookings');

  // --- GYM METHODS (UNCHANGED) ---
  static Future<List<Gym>> fetchGymsByOwner(String ownerId) async {
    if (ownerId.isEmpty) return [];
    try {
      final snapshot = await _gymsCollection
          .where('gymOwnerId', isEqualTo: ownerId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => Gym.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch gyms.');
    }
  }

  static Future<void> addGym(Gym newGym, XFile? imageFile) async {
    if (newGym.gymOwnerId.isEmpty) throw Exception('Owner missing');
    try {
      String photoUrl = '';
      if (imageFile != null) {
        photoUrl = await _uploadPhoto(imageFile, 'gym_photos/${newGym.gid}');
      }
      Gym gymToSave = newGym.copyWith(photo: photoUrl);
      await _gymsCollection.doc(gymToSave.gid).set(gymToSave.toFirestore());
    } catch (e) {
      throw Exception('Failed to add gym: $e');
    }
  }

  static Future<void> updateGym(Gym updatedGym) async {
    try {
      Map<String, dynamic> updateData = {
        'name': updatedGym.name,
        'location': updatedGym.location,
        'pricePerMonth': updatedGym.pricePerMonth,
      };
      await _gymsCollection.doc(updatedGym.gid).update(updateData);
    } catch (e) {
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
      throw Exception('Failed to delete gym.');
    }
  }

  // --- STATISTICS (REAL DATA IMPLEMENTATION) ---

  static Future<Map<String, dynamic>> getStatistics(String ownerId) async {
    try {
      // 1. Fetch Owner's Gyms & Coaches
      final gyms = await fetchGymsByOwner(ownerId);
      final coaches = await fetchCoachesByOwner(ownerId);

      // Create lookup map for Gym Price
      Map<String, double> gymPrices = {
        for (var gym in gyms) gym.gid: gym.pricePerMonth
      };
      List<String> myGymIds = gyms.map((e) => e.gid).toList();

      if (myGymIds.isEmpty) {
        return {
          'gymCount': 0, 'coachCount': coaches.length,
          'totalMonthlyRevenue': 0.0, 'activeMembers': 0,
          'yearlyRevenue': 0.0, 'weeklyRevenue': 0.0,
        };
      }

      // 2. Fetch Bookings 
      // Note: In production with many gyms, batch this query.
      final bookingSnapshot = await _bookingsCollection
          .where('type', isEqualTo: 'Gym')
          .get();

      final allBookings = bookingSnapshot.docs
          .map((doc) => Booking.fromFirestore(doc))
          .toList();

      // Filter bookings for this owner's gyms
      final myBookings = allBookings
          .where((b) => myGymIds.contains(b.serviceId))
          .toList();

      // 3. Count Unique Members
      final uniqueMembers = myBookings.map((b) => b.memberId).toSet().length;

      // 4. Calculate Revenue (Active bookings only)
      double totalRevenue = 0.0;
      for (var booking in myBookings) {
        if (booking.status != 'Cancelled') {
          totalRevenue += (gymPrices[booking.serviceId] ?? 0.0);
        }
      }

      return {
        'gymCount': gyms.length,
        'coachCount': coaches.length,
        'totalMonthlyRevenue': totalRevenue,
        'activeMembers': uniqueMembers, // REAL count
        'yearlyRevenue': totalRevenue * 12,
        'weeklyRevenue': totalRevenue / 4,
      };
    } catch (e) {
      print("Stats Error: $e");
      throw Exception('Failed to load statistics.');
    }
  }

  // --- COACH METHODS (UNCHANGED) ---
  static Future<List<Coach>> fetchCoachesByOwner(String ownerId) async {
    if (ownerId.isEmpty) return [];
    try {
      final snapshot = await _coachesCollection
          .where('ownerId', isEqualTo: ownerId)
          .orderBy('joinedDate', descending: true)
          .get();
      return snapshot.docs.map((doc) => Coach.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch coaches.');
    }
  }

  static Future<void> addCoach(Coach newCoach, XFile? imageFile) async {
    if (newCoach.gymId.isEmpty || newCoach.ownerId.isEmpty) throw Exception('Data missing');
    try {
      String photoUrl = '';
      if (imageFile != null) {
        photoUrl = await _uploadPhoto(imageFile, 'coach_photos/${newCoach.cid}');
      }
      Coach coachToSave = newCoach.copyWith(photo: photoUrl);
      await _coachesCollection.doc(coachToSave.cid).set(coachToSave.toFirestore());
    } catch (e) {
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
      throw Exception('Failed to delete coach.');
    }
  }

  // --- HELPERS ---
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
      print("Delete error: $e");
    }
  }
}