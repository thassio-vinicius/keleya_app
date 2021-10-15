import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:keleya_app/UI/onboarding/onboarding_screen.dart';
import 'package:keleya_app/services/authentication_provider.dart';
import 'package:keleya_app/services/firestore_provider.dart';
import 'package:keleya_app/utils/adapt.dart';
import 'package:keleya_app/utils/hexcolor.dart';
import 'package:keleya_app/utils/localizations.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(Keleya());
}

class Keleya extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthenticationProvider>(
          create: (_) => AuthenticationProvider(
            firebaseAuth: FirebaseAuth.instance,
            firestore: FirebaseFirestore.instance,
          ),
        ),
        Provider<FirestoreProvider>(
          create: (_) => FirestoreProvider(
            FirebaseFirestore.instance,
            FirebaseAuth.instance,
          ),
        ),
      ],
      child: MaterialApp(
        home: OnboardingScreen(),
        supportedLocales: [
          Locale('en', 'US'),
          Locale('de', ''),
        ],
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          textTheme: TextTheme(
            headline1: GoogleFonts.nunitoSans(
              color: Colors.white,
              fontSize: Adapt.px(34),
              fontWeight: FontWeight.w600,
            ),
            headline2: GoogleFonts.nunitoSans(
              color: Colors.white,
              fontSize: Adapt.px(18),
              fontWeight: FontWeight.w600,
            ),
            headline3: GoogleFonts.nunitoSans(
              color: HexColor('5a4fd9'),
              fontSize: Adapt.px(18),
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: HexColor('5a4fd9'), //dark purple
          secondaryHeaderColor: HexColor('f3ecff'), //light purple
          hintColor: HexColor('#cdd4d9'),
        ),
      ),
    );
  }
}
