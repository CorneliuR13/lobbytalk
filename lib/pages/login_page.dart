import 'package:flutter/material.dart';
import 'package:lobbytalk/components/my_button.dart';
import 'package:lobbytalk/components/my_textfields.dart';
import '../components/google_button.dart';
import '../services/auth/auth_service.dart';
import 'home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/notification_service.dart';

class LoginPage extends StatelessWidget {
  //email password controller
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final void Function()? ontap;
  LoginPage({
    super.key,
    required this.ontap,
  });

  // Helper to save FCM token to Firestore
  Future<void> saveFcmTokenToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final token = await NotificationService.getFcmToken();
      if (token != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
          {'fcmToken': token},
          SetOptions(merge: true),
        );
      }
    }
  }

  //login method
  void login(BuildContext context) async {
    // get service
    final authService = AuthService();

    try {
      await authService.signInWithEmailPassword(
          _emailController.text, _pwController.text);
      await saveFcmTokenToFirestore(); // Save FCM token after login
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //logo
                  Icon(
                    Icons.message,
                    size: 60.0,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 30),

                  //welcome message
                  Text(
                    "Welcome Back",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 25),

                  //email textfield
                  MyTextfields(
                    hintText: "Email",
                    obscureText: false,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 15),

                  //password textfield
                  MyTextfields(
                    hintText: "Password",
                    obscureText: true,
                    controller: _pwController,
                  ),
                  const SizedBox(height: 25),

                  //login button
                  MyButton(
                    text: "Login",
                    ontap: () => login(context),
                  ),
                  const SizedBox(height: 15),

                  // Google button
                  GoogleButton(
                    onTap: () => signInWithGoogle(context),
                    isLoading: false,
                  ),

                  const SizedBox(height: 25),

                  //register now
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(
                      "Don't have an account?   ",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    GestureDetector(
                      onTap: ontap,
                      child: Text(
                        "Register NOW!",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  ]),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void signInWithGoogle(BuildContext context) async {
    // get service
    final authService = AuthService();

    try {
      final userCredential = await authService.signInWithGoogle();
      if (userCredential == null) {
        // User cancelled the sign-in flow
        print("Google sign-in was cancelled by user");
      } else {
        await saveFcmTokenToFirestore(); // Save FCM token after Google login
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }
}
