import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alu_spark/features/student_profile/domain/entities/student.dart';
import 'package:alu_spark/features/student_profile/domain/repositories/student_repository.dart';

class StudentRepositoryImpl implements StudentRepository {
  final FirebaseFirestore _firestore;
  static const _collection = 'students';

  StudentRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Student?> getStudent(String uid) async {
    final doc = await _firestore.collection(_collection).doc(uid).get();
    if (!doc.exists) return null;
    return Student.fromMap(doc.id, doc.data()!);
  }

  @override
  Future<void> saveStudent(Student student) async {
    await _firestore.collection(_collection).doc(student.id).set(
          student.toMap(),
          SetOptions(merge: true),
        );
  }
}
