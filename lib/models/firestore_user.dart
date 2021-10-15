import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreUser {
  String name, email, uid;
  DateTime babyBirthDate;
  bool onboardingDone, privacyPolicy, termsNConditions;

  FirestoreUser({
    this.name = '',
    this.onboardingDone = false,
    required this.email,
    required this.uid,
    required this.babyBirthDate,
    required this.privacyPolicy,
    required this.termsNConditions,
  });

  FirestoreUser copyWith({
    String? name,
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
      babyBirthDate: babyBirthDate ?? this.babyBirthDate,
      onboardingDone: onboarding ?? this.onboardingDone,
      privacyPolicy: privacy ?? this.privacyPolicy,
      termsNConditions: terms ?? this.termsNConditions,
    );
  }

  FirestoreUser.fromMap(Map<String, dynamic> map, {DocumentReference? reference})
      : name = map['name'],
        uid = map['uid'],
        email = map['email'],
        babyBirthDate = DateTime.fromMillisecondsSinceEpoch(map['babyBirthDate'].millisecondsSinceEpoch),
        termsNConditions = map['termsNConditions'],
        onboardingDone = map['onboardingDone'],
        privacyPolicy = map['privacyPolicy'];

  FirestoreUser.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data() as Map<String, dynamic>, reference: snapshot.reference);

  Map<String, dynamic> toJson() => {
        'name': this.name,
        'email': this.email,
        'uid': this.uid,
        'privacyPolicy': this.privacyPolicy,
        'onboardingDone': this.onboardingDone,
        'babyBirthDate': this.babyBirthDate,
        'termsNConditions': this.termsNConditions
      };

  @override
  String toString() {
    return 'FirestoreUser{name: $name, email: $email, uid: $uid, babyBirthDate: $babyBirthDate, onboardingDone: $onboardingDone, privacyPolicy: $privacyPolicy, termsNConditions: $termsNConditions}';
  }
}
