import 'package:fitpanion/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class UserService {
  final _db = FirebaseFirestore.instance;
  final _collection = 'users';

  Future<void> createUser(UserModel user) async {
    await _db.collection(_collection).doc(user.id).set(user.toMap());
  }

  Future<UserModel?> getUser(String userId) async {
    final doc = await _db.collection(_collection).doc(userId).get();
    return doc.exists ? UserModel.fromDoc(doc) : null;
  }

  Future<void> updateUser(String userId, Map<String, dynamic> fields) async {
    await _db.collection(_collection).doc(userId).update(fields);
  }

  Future<void> deleteUser(String userId) async {
    await _db.collection(_collection).doc(userId).delete();
  }

  Future<void> addDailyInputs(String userId, String dailyInputs) async {
    await _db.collection(_collection).doc(userId).update({
      'dailyInputs': FieldValue.arrayUnion([dailyInputs]),
    });
  }

  Future<void> removeDailyInputs(String userId, String dailyInputs) async {
    await _db.collection(_collection).doc(userId).update({
      'dailyInputs': FieldValue.arrayRemove([dailyInputs]),
    });
  }

  Future<void> addWeeklyInputs(String userId, String weeklyInputs) async {
    await _db.collection(_collection).doc(userId).update({
      'dailyInputs': FieldValue.arrayUnion([weeklyInputs]),
    });
  }

  Future<void> removeWeeklyInputs(String userId, String weeklyInputs) async {
    await _db.collection(_collection).doc(userId).update({
      'weeklyInputs': FieldValue.arrayRemove([weeklyInputs]),
    });
  }
}