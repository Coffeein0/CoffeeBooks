import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:coffeebooks/generated/codegen_loader.g.dart';
import 'package:coffeebooks/ui/welcome_screen/widgets/widgets.dart';

class WelcomePageChoices extends StatelessWidget {
  const WelcomePageChoices({
    super.key,
    required this.skipImportingBooks,
  });

  final VoidCallback skipImportingBooks;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Верхний текст
          Text(
            LocaleKeys.help_to_get_started.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          WelcomeOpenAppButton(
            description: LocaleKeys.start_adding_books.tr(),
            onPressed: skipImportingBooks,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
