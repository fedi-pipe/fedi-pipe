import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:fedi_pipe/pages/favourite_page.dart';
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
  ],
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
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        textTheme:
            TextTheme(headlineLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold, color: Colors.black)),
        useMaterial3: true,
      ),
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
      NotificationPage(),
      FavouritePage(),
      BookmarkPage(),
    ];
  }
}
