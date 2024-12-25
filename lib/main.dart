import 'package:fedi_pipe/components/mastodon_status_card.dart';
import 'package:fedi_pipe/pages/compose_page.dart';
import 'package:fedi_pipe/models/mastodon_status.dart';
import 'package:fedi_pipe/pages/bookmark_page.dart';
import 'package:fedi_pipe/pages/notification_page.dart';
import 'package:fedi_pipe/repositories/mastodon/status_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
          currentIndex: index,
          onTap: (int index) {
            setState(() {
              this.index = index;
            });
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notification'),
            BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Bookmark'),
          ]),
      body: pages[index],
    );
  }

  List<Widget> get pages {
    return [
      PublicTimelinePage(),
      NotificationPage(),
      BookmarkPage(),
    ];
  }
}

class PublicTimelinePage extends StatefulWidget {
  const PublicTimelinePage({Key? key}) : super(key: key);

  @override
  State<PublicTimelinePage> createState() => _PublicTimelinePageState();
}

class _PublicTimelinePageState extends State<PublicTimelinePage> {
  final ScrollController _scrollController = ScrollController();
  List<MastodonStatusModel> _statuses = [];
  bool _isLoading = false;
  int _page = 1; // For page-based pagination

  @override
  void initState() {
    super.initState();
    _fetchStatuses();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // If scrolled to within 200px of the bottom, fetch more
    if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent - 200) {
      _fetchStatuses();
    }
  }

  Future<void> _fetchStatuses() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Adjust repository fetch call to include page or other pagination param
      final newStatuses = await MastodonStatusRepository.fetchStatuses(/* page: _page */);
      setState(() {
        _page++;
        _statuses.addAll(newStatuses);
      });
    } catch (e) {
      debugPrint('Error fetching statuses: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshStatuses() async {
    setState(() {
      _statuses.clear();
      _page = 1;
    });
    await _fetchStatuses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Public Timeline'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ComposePage()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshStatuses,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _statuses.length + 1,
          itemBuilder: (context, index) {
            if (index < _statuses.length) {
              return MastodonStatusCard(status: _statuses[index]);
            } else {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: _isLoading ? const CircularProgressIndicator() : const SizedBox.shrink(),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
