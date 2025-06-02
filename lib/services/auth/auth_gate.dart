import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../pages/home_page.dart';
import '../../pages/reception_page.dart';
import '../../pages/hotel_onboarding_page.dart';
import '../../services/auth/auth_service.dart';
import 'login_or_register.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasData && snapshot.data != null) {
              final AuthService authService = AuthService();

              if (authService.isReceptionist()) {
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection("receptions")
                      .doc(authService.getCurrentUser()!.uid)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final data = snapshot.data?.data() as Map<String, dynamic>?;
                    final bool onboardingCompleted = data?['onboardingCompleted'] ?? true ;

                    if (onboardingCompleted) {
                      return ReceptionPage();
                    } else {
                      return HotelOnboardingPage();
                    }
                  },
                );
              } else {
                return HomePage();
              }
            }
            else {
              return const LoginOrRegister();
            }
          }
      ),
    );
  }
}