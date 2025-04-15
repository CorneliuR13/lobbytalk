import 'package:flutter/material.dart';
import 'package:lobbytalk/pages/client_booking_page.dart';
import 'package:lobbytalk/pages/search_page.dart';
import 'package:lobbytalk/pages/settigns_page.dart';
import 'package:lobbytalk/services/auth/auth_service.dart';

class MyDrawer extends StatelessWidget {
  MyDrawer({super.key});

  final AuthService _authService = AuthService();

  // Sign out
  void logout() async {
    await _authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final bool isReceptionist = _authService.isReceptionist();

    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              DrawerHeader(
                child: Icon(
                  Icons.message,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              if (!isReceptionist) ...[
                ListTile(
                  title: const Text("My Bookings"),
                  leading: const Icon(Icons.history),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClientBookingsPage(),
                      ),
                    );
                  },
                ),

                ListTile(
                  title: const Text("Find Hotels"),
                  leading: const Icon(Icons.search),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchPage(),
                      ),
                    );
                  },
                ),
              ],

              ListTile(
                title: const Text("Settings"),
                leading: const Icon(Icons.settings),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettignsPage(),
                    ),
                  );
                },
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 25),
            child: ListTile(
              title: const Text("Logout"),
              leading: const Icon(Icons.logout),
              onTap: () {
                Navigator.pop(context);

                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Logout"),
                    content: Text("Are you sure you want to logout?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                          logout(); // Call logout function
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: Text("Logout"),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}