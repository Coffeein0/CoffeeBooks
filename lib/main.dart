import 'dart:io' if (dart.library.html) 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
// Импорты без dart:io
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb, TargetPlatform, defaultTargetPlatform;
import 'package:sqflite_common/sqflite.dart' as sqflite;
import 'package:sqflite_common/sqflite.dart' show databaseFactory;


// Импорты sqflite_common
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common/sqflite.dart';

import 'package:coffeebooks/core/constants/constants.dart';
import 'package:coffeebooks/core/constants/locale.dart';
import 'package:coffeebooks/core/helpers/locale_delegates/locale_delegates.dart';
import 'package:coffeebooks/core/helpers/old_android_http_overrides.dart';

import 'package:coffeebooks/logic/bloc/challenge_bloc/challenge_bloc.dart';
import 'package:coffeebooks/logic/bloc/open_library_search_bloc/open_library_search_bloc.dart';
import 'package:coffeebooks/logic/bloc/rating_type_bloc/rating_type_bloc.dart';

import 'package:coffeebooks/logic/bloc/sort_bloc/sort_finished_books_bloc.dart';
import 'package:coffeebooks/logic/bloc/sort_bloc/sort_for_later_books_bloc.dart';
import 'package:coffeebooks/logic/bloc/sort_bloc/sort_in_progress_books_bloc.dart';
import 'package:coffeebooks/logic/bloc/sort_bloc/sort_unfinished_books_bloc.dart';

import 'package:coffeebooks/logic/bloc/theme_bloc/theme_bloc.dart';
import 'package:coffeebooks/logic/bloc/welcome_bloc/welcome_bloc.dart';

import 'package:coffeebooks/logic/cubit/book_cubit.dart';
import 'package:coffeebooks/logic/cubit/book_lists_order_cubit.dart';
import 'package:coffeebooks/logic/cubit/books_tab_index_cubit.dart';
import 'package:coffeebooks/logic/cubit/current_book_cubit.dart';
import 'package:coffeebooks/logic/cubit/default_book_status_cubit.dart';
import 'package:coffeebooks/logic/cubit/default_book_tags_cubit.dart';
import 'package:coffeebooks/logic/cubit/display_cubit.dart';
import 'package:coffeebooks/logic/cubit/edit_book_cubit.dart';
import 'package:coffeebooks/logic/cubit/selected_books_cubit.dart';

import 'package:coffeebooks/resources/connectivity_service.dart';
import 'package:coffeebooks/resources/open_library_service.dart';

import 'package:coffeebooks/ui/home_screen/home_screen.dart';
import 'package:coffeebooks/ui/welcome_screen/welcome_screen.dart';


late BookCubit bookCubit;
String? appDocumentsPath;
String? appTempPath;
late GlobalKey<ScaffoldMessengerState> snackbarKey;
late DateFormat dateFormat;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Инициализация SQLite для веба
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  // Android-only настройки
  if (!kIsWeb) {
    _setAndroidConfig();
  }

  HydratedStorage? storage;
  if (!kIsWeb) {
    final dir = await getApplicationDocumentsDirectory();
    storage = await HydratedStorage.build(
      storageDirectory: HydratedStorageDirectory(dir.path),
    );
    appDocumentsPath = dir.path; // Сохраняем только путь как строку
    appTempPath = (await getTemporaryDirectory()).path;
  } else {
    storage = await HydratedStorage.build(
      storageDirectory: HydratedStorageDirectory.web,
    );
  }
  HydratedBloc.storage = storage;

  snackbarKey = GlobalKey<ScaffoldMessengerState>();
  bookCubit = BookCubit();

  final localeCodes = supportedLocales.map((e) => e.locale).toList();

  runApp(
    EasyLocalization(
      supportedLocales: localeCodes,
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      startLocale: const Locale('ru', 'RU'),
      useFallbackTranslations: true,
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  _listOfBlocProviders(BuildContext context) {
    final bookProviders = [
      BlocProvider(create: (_) => EditBookCubit()),
      BlocProvider(create: (_) => EditBookCoverCubit()),
      BlocProvider(create: (_) => CurrentBookCubit()),
      BlocProvider(create: (_) => SelectedBooksCubit()),
      BlocProvider(create: (_) => ChallengeBloc()),
      BlocProvider(create: (_) => DefaultBookTagsCubit()),
      BlocProvider(create: (_) => BookListsOrderCubit()),
    ];

    final settingsProviders = [
      BlocProvider(create: (_) => DefaultBooksFormatCubit()),
      BlocProvider(create: (_) => ThemeBloc()),
      BlocProvider(create: (_) => DisplayCubit()),
      BlocProvider(create: (_) => BooksTabIndexCubit()),
      BlocProvider(create: (_) => WelcomeBloc()),
      BlocProvider(create: (_) => RatingTypeBloc()),
    ];

    final sortProviders = [
      BlocProvider(create: (_) => SortFinishedBooksBloc()),
      BlocProvider(create: (_) => SortInProgressBooksBloc()),
      BlocProvider(create: (_) => SortForLaterBooksBloc()),
      BlocProvider(create: (_) => SortUnfinishedBooksBloc()),
    ];

    final openLibraryProviders = [
      BlocProvider(create: (_) => OpenLibrarySearchBloc()),
    ];

    return [
      ...bookProviders,
      ...settingsProviders,
      ...sortProviders,
      ...openLibraryProviders,
    ];
  }

  _listOfRepositoryProviders(BuildContext context) {
    return [
      RepositoryProvider(create: (_) => OpenLibraryService()),
      RepositoryProvider(create: (_) => ConnectivityService()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: _listOfRepositoryProviders(context),
      child: MultiBlocProvider(
        providers: _listOfBlocProviders(context),
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (_, themeState) {
            if (themeState is SetThemeState) {
              return BlocBuilder<WelcomeBloc, WelcomeState>(
                builder: (_, welcomeState) {
                  return CoffeeBooksApp(
                    themeState: themeState,
                    welcomeState: welcomeState,
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
}

class CoffeeBooksApp extends StatefulWidget {
  const CoffeeBooksApp({
    super.key,
    required this.themeState,
    required this.welcomeState,
  });

  final SetThemeState themeState;
  final WelcomeState welcomeState;

  @override
  State<CoffeeBooksApp> createState() => _CoffeeBooksAppState();
}

class _CoffeeBooksAppState extends State<CoffeeBooksApp>
    with WidgetsBindingObserver {
  late bool showWelcomeScreen;

  _decideWelcomeMode(WelcomeState welcomeState) {
    if (welcomeState is ShowWelcomeState) {
      showWelcomeScreen = true;
    } else if (welcomeState is HideWelcomeState) {
      showWelcomeScreen = false;
    } else {
      showWelcomeScreen = true;
    }
  }

  @override
  void initState() {
    super.initState();

    _decideWelcomeMode(widget.welcomeState);
  }

  @override
  Widget build(BuildContext context) {
    _initDateFormat(context);

    final localizationsDelegates = [
      ...context.localizationDelegates,
      const NynorskMaterialLocalizationsDelegate(),
      const NynorskCupertinoLocalizationsDelegate(),
    ];

    return DynamicColorBuilder(builder: (lightScheme, darkScheme) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      final themeMode = widget.themeState.themeMode;

      final lightColorScheme = ColorScheme.fromSeed(
        seedColor: widget.themeState.useMaterialYou && lightScheme != null
            ? lightScheme.primary
            : widget.themeState.primaryColor,
        dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
        brightness: Brightness.light,
      );

      final lightTheme = ThemeData(
        colorScheme: lightColorScheme,
        brightness: Brightness.light,
        fontFamily: widget.themeState.fontFamily,
      ).copyWith(
        scaffoldBackgroundColor: lightColorScheme.surfaceContainerLowest,
        appBarTheme: AppBarTheme(
          backgroundColor: lightColorScheme.surfaceContainerLowest,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: lightColorScheme.surfaceContainerLow,
        ),
      );

      final darkColorScheme = ColorScheme.fromSeed(
        seedColor: widget.themeState.useMaterialYou && darkScheme != null
            ? darkScheme.primary
            : widget.themeState.primaryColor,
        dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
        brightness: Brightness.dark,
        surface: widget.themeState.amoledDark ? Colors.black : null,
        surfaceContainer: widget.themeState.amoledDark ? Colors.black : null,
      );

      final darkTheme = ThemeData(
        colorScheme: darkColorScheme,
        brightness: Brightness.dark,
        fontFamily: widget.themeState.fontFamily,
      ).copyWith(
        scaffoldBackgroundColor: widget.themeState.amoledDark
            ? Colors.black
            : darkColorScheme.surfaceContainerLowest,
        appBarTheme: AppBarTheme(
          backgroundColor: widget.themeState.amoledDark
              ? Colors.black
              : darkColorScheme.surfaceContainerLowest,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: widget.themeState.amoledDark
              ? Colors.black
              : darkColorScheme.surfaceContainerLow,
        ),
      );

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          statusBarBrightness: themeMode == ThemeMode.system
              ? MediaQuery.platformBrightnessOf(context) == Brightness.dark
                  ? Brightness.light
                  : Brightness.dark
              : themeMode == ThemeMode.dark
                  ? Brightness.light
                  : Brightness.dark,
          statusBarIconBrightness: themeMode == ThemeMode.system
              ? MediaQuery.platformBrightnessOf(context) == Brightness.dark
                  ? Brightness.light
                  : Brightness.dark
              : themeMode == ThemeMode.dark
                  ? Brightness.light
                  : Brightness.dark,
          systemNavigationBarIconBrightness: themeMode == ThemeMode.system
              ? MediaQuery.platformBrightnessOf(context) == Brightness.dark
                  ? Brightness.light
                  : Brightness.dark
              : themeMode == ThemeMode.dark
                  ? Brightness.light
                  : Brightness.dark,
        ),
        child: MaterialApp(
          title: Constants.appName,
          scaffoldMessengerKey: snackbarKey,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeMode,
          home: showWelcomeScreen ? const WelcomeScreen() : const HomeScreen(),
          localizationsDelegates: localizationsDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
        ),
      );
    });
  }
}

Future<void> _setAndroidConfig() async {

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    var androidInfo = await DeviceInfoPlugin().androidInfo;
    var sdkInt = androidInfo.version.sdkInt;

    if (sdkInt >= 23) {
      await FlutterDisplayMode.setHighRefreshRate();
    }

    if (sdkInt <= 25) {
      // На старых Android устройствах могут быть проблемы с HTTPS
      // HttpOverrides.global = OldAndroidHttpOverrides(); // ignore: undefined_identifier
    }
  }
}



Future _initDateFormat(BuildContext context) async {
  await initializeDateFormatting();

  String locale = context.locale.toString();

  if (locale == const Locale('nn').toString()) {
    locale = const Locale('no', 'NO').toString();
  }

  dateFormat = DateFormat.yMMMMd(locale);
}
