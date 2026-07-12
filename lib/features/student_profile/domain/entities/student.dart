class Student {
  final String id;
  final String fullName;
  final String email;
  final String university;
  final String major;
  final String bio;
  final List<String> skills;
  final List<Map<String, String>> education;
  final List<Map<String, String>> experience;
  final String? profileImageUrl;

  const Student({
    required this.id,
    required this.fullName,
    required this.email,
    required this.university,
    required this.major,
    required this.bio,
    required this.skills,
    required this.education,
    required this.experience,
    this.profileImageUrl,
  });

  factory Student.fromMap(String id, Map<String, dynamic> data) {
    return Student(
      id: id,
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      university: data['university'] ?? '',
      major: data['major'] ?? '',
      bio: data['bio'] ?? '',
      skills: List<String>.from(data['skills'] ?? []),
      education: List<Map<String, String>>.from(
        (data['education'] ?? []).map((e) => Map<String, String>.from(e)),
      ),
      experience: List<Map<String, String>>.from(
        (data['experience'] ?? []).map((e) => Map<String, String>.from(e)),
      ),
      profileImageUrl: data['profileImageUrl'],
    );
  }

  Map<String, dynamic> toMap() => {
        'fullName': fullName,
        'email': email,
        'university': university,
        'major': major,
        'bio': bio,
        'skills': skills,
        'education': education,
        'experience': experience,
        'profileImageUrl': profileImageUrl,
      };
}
