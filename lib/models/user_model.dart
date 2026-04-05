import 'package:cloud_firestore/cloud_firestore.dart';


class UserModel {
  final String id;
  final String name;
  final double height;
  final int age;
  final String sex;
  final List<String> dailyInputs;
  final List<String> weeklyInputs;

  UserModel({
    required this.id,
    required this.name,
    required this.height,
    required this.age,
    required this.sex,
    this.dailyInputs = const [],
    this.weeklyInputs = const [],
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'height': height,
    'age': age,
    'sex': sex,
    'dailyInputs': dailyInputs,
    'weeklyInputs': weeklyInputs,
  };

  factory UserModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      height: (data['height'] ?? 0).toDouble(),
      age: data['age'] ?? 0,
      sex: data['sex'] ?? '',
      dailyInputs: List<String>.from(data['dailyInputs'] ?? []),
      weeklyInputs: List<String>.from(data['weeklyInputs'] ?? []),
    );
  }
}