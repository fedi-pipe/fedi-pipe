import 'dart:async';
import 'dart:ui';

import 'package:app_links/app_links.dart';
import 'package:fedi_pipe/pages/status_detail_page.dart';
import 'package:fedi_pipe/models/mastodon_status.dart';
import 'package:fedi_pipe/pages/favourite_page.dart';
import 'package:fedi_pipe/pages/grouped_notification_page.dart';
import 'package:fedi_pipe/pages/home_timeline_page.dart';
import 'package:fedi_pipe/pages/manage_accounts_page.dart';
import 'package:fedi_pipe/pages/add_token_page.dart';
import 'package:fedi_pipe/pages/bookmark_page.dart';
import 'package:fedi_pipe/pages/notification_page.dart';
import 'package:fedi_pipe/pages/oauth_page.dart';
import 'package:fedi_pipe/pages/public_timeline_page.dart';
import 'package:fedi_pipe/repositories/persistent/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appLinks = AppLinks();

  final initialUri = await appLinks.getInitialLink();
  runApp(MyApp(initialUri: initialUri));
}

final _router = GoRouter(
  redirect: (BuildContext context, GoRouterState state) async {
    final authRepository = AuthRepository();
    final auth = await authRepository.getAuth();
    print(auth);

    print("--- State ---");
    print(state);
    print("--- State ---");
    print(state.name);
    print(state.extra);
    print(state.fullPath);
    print(state.path);
    print(state.pathParameters);
    if ((state.fullPath ?? "/").contains('/oauth')) {
      return null;
    }

    if (auth == null) {
      return '/add-token';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => MyHomePage(title: ""),
    ),
    GoRoute(
      path: '/add-token',
      name: 'add-token',
      builder: (context, state) => AddTokenPage(),
    ),
    GoRoute(
      path: '/oauth/:code',
      name: 'oauth',
      builder: (context, state) {
        final pathParameters = state.pathParameters;
        print("-----");
        print(state.fullPath);
        print("-----");
        return OAuthPage(code: pathParameters['code']);
      },
    ),
    GoRoute(
      path: '/manage-accounts',
      name: 'manage-accounts',
      builder: (context, state) => ManageAccountsPage(),
    ),
    GoRoute(
      path: '/status/:id', // Path parameter for statusId
      name: 'statusDetail',
      builder: (context, state) {
        final statusId = state.pathParameters['id']!;
        // Attempt to cast `extra` to MastodonStatusModel, allow null if not provided or wrong type
        final MastodonStatusModel? status =
            state.extra is MastodonStatusModel ? state.extra as MastodonStatusModel : null;
        return StatusDetailPage(statusId: statusId, initialStatus: status);
      },
    ),
  ],
);

class AppDarkPalette {
  static Color primaryBlue = Color(0xFF6495ED);

  static Color accentPurple = Color(0xFFB190F1);

  static Color background = Color(0xFF242526);

  static Color surfaceFaded = Color(0xFF18191A);

  static Color text = Color(0xFFF0F2F5);

  static Color textInsignificant = Color(0x99F0F2F5);

  static Color divider = Color(0x1AFFFFFF);

  static final Color buttonBackground = Color.lerp(background, primaryBlue, 0.8)!;

  static Color buttonText = text;

  static Color error = Color(0xFFCF6679);
  static Color onError = Colors.black;

  static Color accentGreen = Color(0xFF90EE90);

  static Color accentOrange = Color(0xFFFFA500);

  static Color hashtagColor = Color(0xFF20B2AA);
}

final ThemeData appDarkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme(
    brightness: Brightness.dark,
    primary: AppDarkPalette.primaryBlue,
    onPrimary: AppDarkPalette.buttonText,
    secondary: AppDarkPalette.accentPurple,
    onSecondary: Colors.black,
    error: AppDarkPalette.error,
    onError: AppDarkPalette.onError,
    surface: AppDarkPalette.background,
    onSurface: AppDarkPalette.text,
    background: AppDarkPalette.background,
    onBackground: AppDarkPalette.text,
    surfaceContainerHighest: AppDarkPalette.background,
    surfaceContainerHigh: Color.lerp(AppDarkPalette.background, Colors.white, 0.03),
    surfaceContainer: Color.lerp(AppDarkPalette.background, Colors.white, 0.06)!,
    surfaceContainerLow: Color.lerp(AppDarkPalette.background, Colors.white, 0.09)!,
    surfaceContainerLowest: AppDarkPalette.surfaceFaded,
    surfaceBright: Color.lerp(AppDarkPalette.background, Colors.white, 0.12)!,
    surfaceDim: AppDarkPalette.surfaceFaded,
    outline: AppDarkPalette.divider,
    outlineVariant: Color.lerp(AppDarkPalette.divider, AppDarkPalette.text, 0.15),
  ),
  scaffoldBackgroundColor: AppDarkPalette.background,
  appBarTheme: AppBarTheme(
    backgroundColor: AppDarkPalette.surfaceFaded,
    foregroundColor: AppDarkPalette.text,
    elevation: 0,
  ),
  cardTheme: CardTheme(
    color: AppDarkPalette.surfaceFaded,
    elevation: 1,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppDarkPalette.buttonBackground,
      foregroundColor: AppDarkPalette.buttonText,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
    foregroundColor: AppDarkPalette.primaryBlue,
  )),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppDarkPalette.surfaceFaded,
    hintStyle: TextStyle(color: AppDarkPalette.textInsignificant),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4.0),
      borderSide: BorderSide(color: AppDarkPalette.divider, width: 1.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4.0),
      borderSide: BorderSide(color: AppDarkPalette.divider, width: 1.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4.0),
      borderSide: BorderSide(color: AppDarkPalette.primaryBlue, width: 2.0),
    ),
  ),
  dividerTheme: DividerThemeData(
    color: AppDarkPalette.divider,
    thickness: 1,
  ),
  textTheme: Typography.whiteMountainView
      .apply(
        bodyColor: AppDarkPalette.text,
        displayColor: AppDarkPalette.text,
      )
      .copyWith(
        titleMedium: TextStyle(color: AppDarkPalette.text.withOpacity(0.9)),
        bodySmall: TextStyle(color: AppDarkPalette.textInsignificant),
      ),
  iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
    foregroundColor: AppDarkPalette.textInsignificant,
  )),
  iconTheme: IconThemeData(
    color: AppDarkPalette.textInsignificant,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: AppDarkPalette.surfaceFaded,
    selectedItemColor: AppDarkPalette.primaryBlue,
    unselectedItemColor: AppDarkPalette.textInsignificant,
    type: BottomNavigationBarType.fixed,
  ),
  useMaterial3: true,
);

class MyApp extends StatefulWidget {
  final Uri? initialUri;
  const MyApp({super.key, required this.initialUri});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppLinks _appLinks;

  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    initDeepLinks();
  }

  // Step 8: Method to initialize deep link handling.
  Future<void> initDeepLinks() async {
    _appLinks = AppLinks(); // Initialize the AppLinks instance.

    if (widget.initialUri != null) {
      _handleDeepLink(widget.initialUri!);
    }

    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri); // Handle the deep link when received.
    });
  }

  void _handleDeepLink(Uri uri) {
    print("========");
    print(uri);
    print(uri.path);
    print(uri.queryParameters);
    print(uri.query);
    print(uri.queryParametersAll);
    print("========");
    if (uri.path == '/oauth') {
      _router.goNamed('oauth', pathParameters: {
        'code': uri.queryParameters['code'] ?? "",
      });
    }
  }

  void dispose() {
    super.dispose();
    _linkSubscription?.cancel();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    print("asdasdas");
    return MaterialApp.router(
      title: 'Flutter Demo',
      themeMode: ThemeMode.dark, // Force dark mode initially
      darkTheme: appDarkTheme,
      routerConfig: _router,
      //home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int index = 0;

  @override
  void initState() {
    super.initState();
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: null,
      bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).colorScheme.onSurface,
          currentIndex: index,
          onTap: (int index) {
            setState(() {
              this.index = index;
            });
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.public), label: 'public'),
            BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notification'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favourite'),
            BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Bookmark'),
          ]),
      body: pages[index],
    );
  }

  List<Widget> get pages {
    return [
      HomeTimelinePage(),
      PublicTimelinePage(),
      GroupedNotificationPage(),
      FavouritePage(),
      BookmarkPage(),
    ];
  }
}
