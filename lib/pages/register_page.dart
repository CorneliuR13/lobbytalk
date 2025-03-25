import 'package:flutter/material.dart';
import '../components/my_button.dart';
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
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(
            Icons.message,
            size: 60.0,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 30),
          Text(
            "Create an Account for you",
            style: TextStyle(
                color: Theme.of(context).colorScheme.primary, fontSize: 16.0),
          ),
          const SizedBox(height: 25),
          MyTextfields(
            hintText: "Email",
            obscureText: false,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 10),
          MyTextfields(
            hintText: "Password",
            obscureText: true,
            controller: _pwController,
          ),
          const SizedBox(height: 10),
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
          const SizedBox(height: 50),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              "Have an account?   ",
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
            GestureDetector(
              onTap: ontap,
              child: Text("Login now",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary)),
            ),
          ])
        ]),
      ),
    );
  }
}
