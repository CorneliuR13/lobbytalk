import 'package:flutter/material.dart';
import '../components/my_button.dart';
import '../components/google_button.dart';
import '../components/my_textfields.dart';
import '../services/auth/auth_service.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final void Function()? ontap;
  RegisterPage({
    super.key,
    required this.ontap,
  });

  void register(BuildContext context) {
    final _auth = AuthService();

    if (_pwController.text == _confirmController.text) {
      try {
        _auth.signUpWithEmailPassword(
            _emailController.text, _pwController.text);
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(e.toString()),
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text("Passwords don't match!"),
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
                  SizedBox(height: 20),
                  Icon(
                    Icons.message,
                    size: 60.0,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Create an Account",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 25),
                  MyTextfields(
                    hintText: "Email",
                    obscureText: false,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 15),
                  MyTextfields(
                    hintText: "Password",
                    obscureText: true,
                    controller: _pwController,
                  ),
                  const SizedBox(height: 15),
                  MyTextfields(
                    hintText: "Confirm Password",
                    obscureText: true,
                    controller: _confirmController,
                  ),
                  const SizedBox(height: 25),
                  MyButton(
                    text: "Register",
                    ontap: () => register(context),
                  ),
                  const SizedBox(height: 25),
                  GoogleButton(
                    onTap: () => signInWithGoogle(context),
                    isLoading: false, // You'll need to manage this state
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Have an account?   ",
                        style: TextStyle(color: Theme.of(context).colorScheme.primary),
                      ),
                      GestureDetector(
                        onTap: ontap,
                        child: Text(
                          "Login now",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
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
    final _auth = AuthService();

    try {
      await _auth.signInWithGoogle();
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}