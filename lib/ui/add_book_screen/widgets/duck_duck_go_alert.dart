import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:coffeebooks/core/constants/constants.dart';
import 'package:coffeebooks/core/themes/app_theme.dart';
import 'package:coffeebooks/generated/codegen_loader.g.dart';

class DuckDuckGoAlert extends StatelessWidget {
  const DuckDuckGoAlert({
    super.key,
    required this.openDuckDuckGoSearchScreen,
  });

  final Function(BuildContext) openDuckDuckGoSearchScreen;

  _yesButtonAction(BuildContext context) {
    Navigator.of(context).pop();

    openDuckDuckGoSearchScreen(context);
  }

  _yesAndDontShowButtonAction(BuildContext context) async {
    Navigator.of(context).pop();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SharedPreferencesKeys.duckDuckGoWarning, false);

    openDuckDuckGoSearchScreen(context);
  }

  _noButtonAction(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        LocaleKeys.duckDuckGoWarning.tr(),
        style: const TextStyle(fontSize: 16),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        _buildAndroidNoButton(context),
        _buildAndroidYesButton(context),
        _buildAndroidYesAndDontShowButton(context),
      ],
    );
  }

  Widget _buildAndroidYesButton(BuildContext context) {
    return FilledButton.tonal(
      onPressed: () => _yesButtonAction(context),
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cornerRadius),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          LocaleKeys.warningYes.tr(),
          textAlign: TextAlign.end,
        ),
      ),
    );
  }

  Widget _buildAndroidYesAndDontShowButton(BuildContext context) {
    return FilledButton(
      onPressed: () => _yesAndDontShowButtonAction(context),
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cornerRadius),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          LocaleKeys.warningYesAndDontShow.tr(),
          textAlign: TextAlign.end,
        ),
      ),
    );
  }

  Widget _buildAndroidNoButton(BuildContext context) {
    return FilledButton(
      onPressed: () => _noButtonAction(context),
      style: TextButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cornerRadius),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(LocaleKeys.warningNo.tr()),
      ),
    );
  }

  Widget _buildIOSYesButton(BuildContext context) {
    return CupertinoDialogAction(
      isDefaultAction: false,
      onPressed: () => _yesButtonAction(context),
      child: Text(LocaleKeys.warningYes.tr()),
    );
  }

  Widget _buildIOSYesAndDontShowButton(BuildContext context) {
    return CupertinoDialogAction(
      isDefaultAction: true,
      onPressed: () => _yesAndDontShowButtonAction(context),
      child: Text(LocaleKeys.warningYesAndDontShow.tr()),
    );
  }

  Widget _buildIOSNoButton(BuildContext context) {
    return CupertinoDialogAction(
      isDefaultAction: false,
      onPressed: () => _noButtonAction(context),
      child: Text(LocaleKeys.warningNo.tr()),
    );
  }
}
