// import 'package:flutter/material.dart';
// import 'package:lobbytalk/components/my_button.dart';
// import 'package:lobbytalk/components/my_textfields.dart';
//
// import '../services/auth/auth_service.dart';
//
// class LoginPage extends StatelessWidget {
//   //email password controller
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _pwController = TextEditingController();
//   final void Function()? ontap;
//   LoginPage({
//     super.key,
//     required this.ontap,
//   });
//
//   //login method
//   void login(BuildContext context) async {
//     // get service
//     final authService = AuthService();
//
//     try {
//       await authService.signInWithEmailPassword(
//           _emailController.text, _pwController.text);
//     } catch (e) {
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text(e.toString()),
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.background,
//       body: Center(
//         child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//           //logo
//           Icon(
//             Icons.message,
//             size: 60.0,
//             color: Theme.of(context).colorScheme.primary,
//           ),
//           const SizedBox(height: 30),
//           //welcome message
//           Text(
//             "Welcome Back",
//             style: TextStyle(
//                 color: Theme.of(context).colorScheme.primary, fontSize: 16.0),
//           ),
//           const SizedBox(height: 25),
//           //email textfield
//           MyTextfields(
//             hintText: "Email",
//             obscureText: false,
//             controller: _emailController,
//             keyboardType: TextInputType.emailAddress,
//           ),
//           const SizedBox(height: 10),
//           //password textfield
//           MyTextfields(
//             hintText: "Password",
//             obscureText: true,
//             controller: _pwController,
//           ),
//           const SizedBox(height: 25),
//           //login button
//           MyButton(
//             text: "Login",
//             ontap: () => login(context),
//           ),
//           const SizedBox(height: 50),
//           //register now
//           Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//             Text(
//               "Don`t have an account?   ",
//               style: TextStyle(color: Theme.of(context).colorScheme.primary),
//             ),
//             GestureDetector(
//               onTap: ontap,
//               child: Text("Register NOW!",
//                   style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Theme.of(context).colorScheme.primary)),
//             ),
//           ])
//         ]),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:lobbytalk/components/my_button.dart';
import 'package:lobbytalk/components/my_textfields.dart';

import '../services/auth/auth_service.dart';

class LoginPage extends StatelessWidget {
  //email password controller
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final void Function()? ontap;
  LoginPage({
    super.key,
    required this.ontap,
  });

  //login method
  void login(BuildContext context) async {
    // get service
    final authService = AuthService();

    try {
      await authService.signInWithEmailPassword(
          _emailController.text, _pwController.text);
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
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
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
                color: Theme.of(context).colorScheme.primary, fontSize: 16.0),
          ),
          const SizedBox(height: 25),
          //email textfield
          MyTextfields(
            hintText: "Email",
            obscureText: false,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 10),
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
          const SizedBox(height: 50),
          //register now
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              "Don`t have an account?   ",
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
            GestureDetector(
              onTap: ontap,
              child: Text("Register NOW!",
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