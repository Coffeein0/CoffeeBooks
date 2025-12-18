import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:coffeebooks/core/themes/app_theme.dart';
import 'package:coffeebooks/generated/codegen_loader.g.dart';
import 'package:coffeebooks/logic/bloc/theme_bloc/theme_bloc.dart';
import 'package:coffeebooks/logic/bloc/welcome_bloc/welcome_bloc.dart';
import 'package:coffeebooks/ui/home_screen/home_screen.dart';
import 'package:coffeebooks/ui/welcome_screen/widgets/widgets.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _controller = PageController();

  void _setWelcomeState() {
    BlocProvider.of<WelcomeBloc>(context).add(
      const ChangeWelcomeEvent(showWelcome: false),
    );
  }

  void _moveToBooksScreen() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (Route<dynamic> route) => false,
    );
  }

  void _skipImportingBooks() {
    _setWelcomeState();
    _moveToBooksScreen();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        if (state is SetThemeState) {
          AppTheme.init(state, context);

          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Text(
                      LocaleKeys.welcome_1.tr(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: PageView(
                      controller: _controller,
                      children: [
                        WelcomePageText(
                          descriptions: [
                            LocaleKeys.welcome_1_description_1.tr(),
                            LocaleKeys.welcome_1_description_2.tr(),
                          ],
                        ),
                        WelcomePageText(
                          descriptions: [
                            LocaleKeys.welcome_2_description_1.tr(),
                            LocaleKeys.welcome_2_description_2.tr(),
                          ],
                        ),
                        WelcomePageText(
                          descriptions: [
                            LocaleKeys.welcome_3_description_1.tr(),
                            LocaleKeys.welcome_3_description_2.tr(),
                          ],
                        ),
                        WelcomePageChoices(
                          skipImportingBooks: _skipImportingBooks,
                        ),
                      ],
                    ),
                  ),
                  SmoothPageIndicator(
                    controller: _controller,
                    count: 4,
                    effect: ExpandingDotsEffect(
                      activeDotColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      dotColor: Theme.of(context).colorScheme.surfaceContainer,
                      dotHeight: 12,
                      dotWidth: 12,
                    ),
                    onDotClicked: (index) {
                      _controller.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.ease,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          );
        }

        return const SizedBox();
      },
    );
  }
}
