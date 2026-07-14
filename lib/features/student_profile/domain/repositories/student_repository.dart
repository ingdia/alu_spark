import 'package:alu_spark/features/student_profile/domain/entities/student.dart';

abstract class StudentRepository {
  Future<Student?> getStudent(String uid);
  Future<void> saveStudent(Student student);
}
