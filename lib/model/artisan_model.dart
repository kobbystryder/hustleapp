class Artisan {
  final String category;
  final String dob;
  final String email;
  final String firstname;
  final String ghanaCard;
  final String id;
  final String lastname;
  final String phone;
  final String uid;

  Artisan({
    required this.category,
    required this.dob,
    required this.email,
    required this.firstname,
    required this.ghanaCard,
    required this.id,
    required this.lastname,
    required this.phone,
    required this.uid,
  });

  // Factory constructor to map Firestore data to Artisan model
  factory Artisan.fromFirestore(Map<String, dynamic> data, String uid) {
    return Artisan(
      category: data['category'] ?? '',
      dob: data['dob'] ?? '',
      email: data['email'] ?? '',
      firstname: data['firstname'] ?? '',
      ghanaCard: data['ghanaCard'] ?? '',
      id: data['id'] ?? '',
      lastname: data['lastname'] ?? '',
      phone: data['phone'] ?? '',
      uid: uid, // Use uid passed from FirebaseAuth
    );
  }
}
