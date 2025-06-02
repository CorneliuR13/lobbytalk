import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lobbytalk/services/language_provider.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      right: 16,
      child: PopupMenuButton<Locale>(
        icon: const Icon(Icons.language, size: 28),
        onSelected: (Locale locale) {
          context.read<LanguageProvider>().setLocale(locale);
        },
        itemBuilder: (BuildContext context) => [
          const PopupMenuItem(
            value: Locale('en'),
            child: Text('English'),
          ),
          const PopupMenuItem(
            value: Locale('ro'),
            child: Text('Română'),
          ),
          const PopupMenuItem(
            value: Locale('ru'),
            child: Text('Русский'),
          ),
        ],
      ),
    );
  }
}
