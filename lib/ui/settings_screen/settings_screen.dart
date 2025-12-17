import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:coffeebooks/core/constants/enums/enums.dart';
import 'package:coffeebooks/core/constants/locale.dart';
import 'package:coffeebooks/core/themes/app_theme.dart';
import 'package:coffeebooks/generated/codegen_loader.g.dart';
import 'package:coffeebooks/logic/bloc/theme_bloc/theme_bloc.dart';
import 'package:coffeebooks/logic/cubit/default_book_status_cubit.dart';
import 'package:coffeebooks/ui/settings_screen/set_book_lists_order_screen.dart';
import 'package:coffeebooks/ui/settings_screen/set_default_book_tags_screen.dart';
import 'package:coffeebooks/ui/settings_screen/settings_apperance_screen.dart';
import 'package:coffeebooks/ui/settings_screen/widgets/widgets.dart';
import 'package:coffeebooks/ui/trash_screen/trash_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const licence = 'Licence v1.0';
  static const repoUrl = 'https://github.com/Coffeein0/coffeebookscoffeebooks';
  static const releasesUrl = '$repoUrl/releases';
  static const licenceUrl = '$repoUrl/blob/master/LICENSE';

  _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cornerRadius),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, state) {
                if (state is SetThemeState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          LocaleKeys.select_language.tr(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: _buildLanguageButtons(context, state),
                        ),
                      ),
                    ],
                  );
                } else {
                  return const SizedBox();
                }
              },
            ),
          ),
        );
      },
    );
  }

  _showDefaultBooksFormatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cornerRadius),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    LocaleKeys.default_books_format.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                SettingsDialogButton(
                  text: LocaleKeys.book_format_paperback.tr(),
                  onPressed: () => _setDefaultBooksFormat(
                    context,
                    BookFormat.paperback,
                  ),
                ),
                const SizedBox(height: 5),
                SettingsDialogButton(
                  text: LocaleKeys.book_format_hardcover.tr(),
                  onPressed: () => _setDefaultBooksFormat(
                    context,
                    BookFormat.hardcover,
                  ),
                ),
                const SizedBox(height: 5),
                SettingsDialogButton(
                  text: LocaleKeys.book_format_ebook.tr(),
                  onPressed: () => _setDefaultBooksFormat(
                    context,
                    BookFormat.ebook,
                  ),
                ),
                const SizedBox(height: 5),
                SettingsDialogButton(
                  text: LocaleKeys.book_format_audiobook.tr(),
                  onPressed: () => _setDefaultBooksFormat(
                    context,
                    BookFormat.audiobook,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _setDefaultBooksFormat(BuildContext context, BookFormat bookFormat) {
    BlocProvider.of<DefaultBooksFormatCubit>(context).setBookFormat(bookFormat);

    Navigator.of(context).pop();
  }

  List<Widget> _buildLanguageButtons(
    BuildContext context,
    SetThemeState state,
  ) {
    final widgets = List<Widget>.empty(growable: true);

    widgets.add(
      LanguageButton(
        language: LocaleKeys.default_locale.tr(),
        onPressed: () => _setLanguage(context, state, null),
      ),
    );

    for (var language in supportedLocales) {
      widgets.add(
        LanguageButton(
          language: language.fullName,
          onPressed: () => _setLanguage(context, state, language.locale),
        ),
      );
    }

    return widgets;
  }

  _setLanguage(BuildContext context, SetThemeState state, Locale? locale) {
    if (locale == null) {
      if (context.supportedLocales.contains(context.deviceLocale)) {
        context.resetLocale();
      } else {
        context.setLocale(context.fallbackLocale!);
      }
    } else {
      context.setLocale(locale);
    }

    BlocProvider.of<ThemeBloc>(context).add(ChangeThemeEvent(
      themeMode: state.themeMode,
      primaryColor: state.primaryColor,
      fontFamily: state.fontFamily,
      useMaterialYou: state.useMaterialYou,
      amoledDark: state.amoledDark,
    ));

    Navigator.of(context).pop();
  }

  SettingsTile _buildURLSetting({
    required String title,
    String? description,
    String? url,
    IconData? iconData,
    required BuildContext context,
  }) {
    return SettingsTile.navigation(
      title: Text(title, style: const TextStyle(fontSize: 16)),
      leading: (iconData == null) ? null : Icon(iconData),
      description: (description != null)
          ? Text(description, style: const TextStyle())
          : null,
      onPressed: (_) {
        if (url == null) return;

        launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      },
    );
  }

  SettingsTile _buildBasicSetting({
    required String title,
    String? description,
    IconData? iconData,
    required BuildContext context,
  }) {
    return SettingsTile(
      title: Text(title, style: const TextStyle(fontSize: 16)),
      leading: (iconData == null) ? null : Icon(iconData),
      description: (description != null)
          ? Text(description, style: const TextStyle())
          : null,
    );
  }

  SettingsTile _buildTrashSetting(BuildContext context) {
    return SettingsTile.navigation(
      title: Text(
        LocaleKeys.deleted_books.tr(),
        style: const TextStyle(fontSize: 16),
      ),
      leading: const Icon(Icons.delete),
      onPressed: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TrashScreen()),
        );
      },
    );
  }

  SettingsTile _buildTabOrderSetting(BuildContext context) {
    return SettingsTile.navigation(
      title: Text(
        LocaleKeys.tabs_order.tr(),
        style: const TextStyle(fontSize: 16),
      ),
      leading: const FaIcon(FontAwesomeIcons.tableColumns),
      onPressed: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SetBookListsOrderScreen(),
          ),
        );
      },
    );
  }

  SettingsTile _buildDefaultTags(BuildContext context) {
    return SettingsTile.navigation(
      title: Text(
        LocaleKeys.set_default_tags.tr(),
        style: const TextStyle(fontSize: 16),
      ),
      leading: const FaIcon(
        FontAwesomeIcons.tags,
        size: 20,
      ),
      onPressed: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SetDefaultBookTagsScreen(),
          ),
        );
      },
    );
  }

  SettingsTile _buildDefaultBooksFormat(BuildContext context) {
    return SettingsTile(
      title: Text(
        LocaleKeys.default_books_format.tr(),
        style: const TextStyle(fontSize: 16),
      ),
      leading: const Icon(Icons.book_rounded),
      description: BlocBuilder<DefaultBooksFormatCubit, BookFormat>(
        builder: (_, state) {
          if (state == BookFormat.paperback) {
            return Text(
              LocaleKeys.book_format_paperback.tr(),
              style: const TextStyle(),
            );
          } else if (state == BookFormat.hardcover) {
            return Text(
              LocaleKeys.book_format_hardcover.tr(),
              style: const TextStyle(),
            );
          } else if (state == BookFormat.ebook) {
            return Text(
              LocaleKeys.book_format_ebook.tr(),
              style: const TextStyle(),
            );
          } else if (state == BookFormat.audiobook) {
            return Text(
              LocaleKeys.book_format_audiobook.tr(),
              style: const TextStyle(),
            );
          } else {
            return const SizedBox();
          }
        },
      ),
      onPressed: (context) => _showDefaultBooksFormatDialog(context),
    );
  }

  SettingsTile _buildAppearanceSetting(BuildContext context) {
    return SettingsTile.navigation(
      title: Text(
        LocaleKeys.apperance.tr(),
        style: const TextStyle(fontSize: 16),
      ),
      leading: const Icon(Icons.color_lens),
      onPressed: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SettingsApperanceScreen(),
          ),
        );
      },
    );
  }

  SettingsTile _buildLanguageSetting(BuildContext context) {
    return SettingsTile(
      title: Text(
        LocaleKeys.language.tr(),
        style: const TextStyle(fontSize: 16),
      ),
      leading: const Icon(Icons.public),
      description: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (_, themeState) {
          if (themeState is SetThemeState) {
            final locale = context.locale;

            for (var language in supportedLocales) {
              if (language.locale == locale) {
                return Text(language.fullName, style: const TextStyle());
              }
            }

            return Text(
              LocaleKeys.default_locale.tr(),
              style: const TextStyle(),
            );
          } else {
            return const SizedBox();
          }
        },
      ),
      onPressed: (context) => _showLanguageDialog(context),
    );
  }

  Future<String> _getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    return packageInfo.version;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocaleKeys.settings.tr(),
          style: const TextStyle(fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<String>(
          future: _getAppVersion(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final version = snapshot.data;

              return BlocBuilder<ThemeBloc, ThemeState>(
                builder: (context, state) {
                  late final bool amoledDark;

                  if (state is SetThemeState) {
                    amoledDark = state.amoledDark;
                  } else {
                    amoledDark = false;
                  }

                  return SettingsList(
                    contentPadding: const EdgeInsets.only(top: 10),
                    darkTheme: SettingsThemeData(
                      settingsListBackground: amoledDark
                          ? Colors.black
                          : Theme.of(context)
                              .colorScheme
                              .surfaceContainerLowest,
                    ),
                    lightTheme: SettingsThemeData(
                      settingsListBackground:
                          Theme.of(context).colorScheme.surfaceContainerLowest,
                    ),
                    sections: [
                      SettingsSection(
                        tiles: _buildGeneralSettingsTiles(context),
                      ),
                      SettingsSection(
                        title: Text(
                          LocaleKeys.books_settings.tr(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        tiles: <SettingsTile>[
                          _buildTrashSetting(context),
                          _buildDefaultBooksFormat(context),
                          _buildTabOrderSetting(context),
                          _buildDefaultTags(context),
                        ],
                      ),
                      SettingsSection(
                        title: Text(
                          LocaleKeys.app.tr(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        tiles: <SettingsTile>[
                          _buildAppearanceSetting(context),
                          _buildLanguageSetting(context),
                        ],
                      ),
                      SettingsSection(
                        title: Text(
                          LocaleKeys.about.tr(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        tiles: <SettingsTile>[
                          _buildBasicSetting(
                            title: LocaleKeys.version.tr(),
                            description: version,
                            iconData: Icons.rocket_launch,
                            context: context,
                          ),
                          _buildURLSetting(
                            title: LocaleKeys.source_code.tr(),
                            description:
                                LocaleKeys.source_code_description.tr(),
                            url: repoUrl,
                            iconData: Icons.code,
                            context: context,
                          ),
                          _buildURLSetting(
                            title: LocaleKeys.licence.tr(),
                            description: licence,
                            url: licenceUrl,
                            iconData: Icons.copyright_rounded,
                            context: context,
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }

  List<SettingsTile> _buildGeneralSettingsTiles(BuildContext context) {
    final tiles = List<SettingsTile>.empty(growable: true);
    return tiles;
  }
}
