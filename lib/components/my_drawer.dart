import 'package:flutter/material.dart';
import 'package:lobbytalk/pages/client_booking_page.dart';
import 'package:lobbytalk/pages/search_page.dart';
import 'package:lobbytalk/pages/settigns_page.dart';
import 'package:lobbytalk/services/auth/auth_service.dart';
import 'package:lobbytalk/services/translations.dart';

import '../pages/client_service_request_page.dart';

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
    final t = Translations.of(context);

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
                  title: Text(t.myRequest),
                  leading: const Icon(Icons.room_service),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClientActiveRequestsPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: Text(t.findHotels),
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
                title: Text(t.settings),
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
              title: Text(t.logout),
              leading: const Icon(Icons.logout),
              onTap: () {
                Navigator.pop(context);

                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(t.logout),
                    content: Text(t.logoutConfirm),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(t.cancel),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                          logout(); // Call logout function
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: Text(t.logout),
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
