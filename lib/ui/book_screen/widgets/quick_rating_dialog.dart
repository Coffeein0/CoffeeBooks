
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:coffeebooks/core/themes/app_theme.dart';
import 'package:coffeebooks/generated/codegen_loader.g.dart';
import 'package:coffeebooks/ui/book_screen/widgets/widgets.dart';

class QuickRatingDialog extends StatefulWidget {
  const QuickRatingDialog({super.key});

  @override
  State<QuickRatingDialog> createState() => _QuickRatingDialogState();
}

class _QuickRatingDialogState extends State<QuickRatingDialog> {
  int? quickRating;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cornerRadius),
      ),
      title: Text(
        LocaleKeys.rate_book.tr(),
        style: const TextStyle(fontSize: 18),
      ),
      content: QuickRating(
        onRatingUpdate: (double newRating) {
          setState(() {
            quickRating = (newRating * 10).toInt();
          });
        },
      ),
      actions: [
        FilledButton.tonal(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(cornerRadius),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop(null);
          },
          child: Text(LocaleKeys.skip.tr()),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(cornerRadius),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop(quickRating);
          },
          child: Text(LocaleKeys.save.tr()),
        ),
      ],
    );
  }
}
