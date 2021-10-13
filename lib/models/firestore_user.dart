import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreUser {
  final String name, year, email, uid;
  final DateTime babyBirthDate;
  final bool onboardingDone, privacyPolicy, termsNConditions;

  const FirestoreUser({
    required this.name,
    required this.email,
    required this.uid,
    required this.year,
    required this.babyBirthDate,
    required this.onboardingDone,
    required this.privacyPolicy,
    required this.termsNConditions,
  });

  FirestoreUser copyWith({
    String? name,
    String? year,
    String? email,
    String? uid,
    DateTime? babyBirthDate,
    bool? onboarding,
    bool? privacy,
    bool? terms,
  }) {
    return FirestoreUser(
      name: name ?? this.name,
      email: email ?? this.email,
      uid: uid ?? this.uid,
      year: year ?? this.year,
      babyBirthDate: babyBirthDate ?? this.babyBirthDate,
      onboardingDone: onboarding ?? this.onboardingDone,
      privacyPolicy: privacy ?? this.privacyPolicy,
      termsNConditions: terms ?? this.termsNConditions,
    );
  }

  FirestoreUser.fromMap(Map<String, dynamic> map,
      {DocumentReference? reference})
      : name = map['name'],
        uid = map['uid'],
        year = map['year'],
        email = map['email'],
        babyBirthDate = map['babyBirthDate'],
        termsNConditions = map['termsNConditions'],
        onboardingDone = map['onboardingDone'],
        privacyPolicy = map['privacyPolicy'];

  FirestoreUser.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data() as Map<String, dynamic>,
            reference: snapshot.reference);

  Map<String, dynamic> toJson() => {
        'name': this.name,
        'email': this.email,
        'year': this.year,
        'uid': this.uid,
        'privacyPolicy': this.privacyPolicy,
        'onboardingDone': this.onboardingDone,
        'babyBirthDate': this.babyBirthDate,
        'termsNConditions': this.termsNConditions
      };

  @override
  String toString() {
    return 'FirestoreUser{name: $name, year: $year, email: $email, uid: $uid, babyBirthDate: $babyBirthDate, onboardingDone: $onboardingDone, privacyPolicy: $privacyPolicy, termsNConditions: $termsNConditions}';
  }
}
