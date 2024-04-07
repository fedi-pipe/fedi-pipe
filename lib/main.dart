import 'package:fedi_pipe/gale_showcase.dart';
import 'package:flutter/material.dart';
import 'package:gale/gale.dart';

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
        textTheme: TextTheme(headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold, color: Colors.black)),
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

  List<MastodonStatus> statuses = [
    MastodonStatus.fromJson(
      {
        "favourited": false,
        "reblog": null,
        "tags": [],
        "favourites_count": 0,
        "card": {
          "embed_url": "",
          "description": "",
          "html":
              "<iframe width=\"200\" height=\"113\" src=\"https ://www.youtube.com/embed/3ANS2NTNgig?feature=oembed\" frameborder=\"0\" allowfullscreen=\"\" sandbox=\"allow-scripts allow-same-origin allow-popups allow-popups-to-escape-sand box allow-forms\"></iframe>",
          "type": "video",
          "height": 113,
          "url": "https://www.youtube.com/watch?v=3ANS2NTNgig&feature=youtu.be",
          "title": "Clerk: Local-First Notebooks for Clojure by Martin Kavalar at reClojure 2021",
          "published_at": null,
          "width": 200,
          "author_name": "London Clojurians",
          "language": null,
          "provider_name": "YouTube",
          "image_des cription": "",
          "image": null,
          "author_url": "https://www.youtube.com/@LondonClojurians",
          "blurhash": "UzHVC+00f5%Mt7WBofae9F-;WBRjWBofaya|",
          "provider_url": "https://www.youtu be.com/"
        },
        "poll": null,
        "uri": "https://social.silicon.moe/users/kodingwarrior/statuses/109451141394293091",
        "id": "109451141394293091",
        "url": "https://social.silicon.moe/@k odingwarrior/109451141394293091",
        "account": {
          "group": false,
          "locked": false,
          "discoverable": true,
          "uri": "https://social.silicon.moe/users/kodingwarrior",
          "id": "1093093827 73915357",
          "avatar_static":
              "https://mstdn-cdn.e14forest.net/accounts/avatars/109/309/382/773/915/357/original/82c4fc390c12f8f7.jpg",
          "avatar":
              "https://mstdn-cdn.e14forest.ne t/accounts/avatars/109/309/382/773/915/357/original/82c4fc390c12f8f7.jpg",
          "statuses_count": 915,
          "following_count": 341,
          "created_at": "2022-11-08T00:00:00.000Z",
          "last_statu s_at": "2024-04-01",
          "fields": [],
          "url": "https://social.silicon.moe/@kodingwarrior",
          "noindex": false,
          "bot": false,
          "header":
              "https://mstdn-cdn.e14forest.net/accounts/head ers/109/309/382/773/915/357/original/ebb49a10d52ad739.jpg",
          "acct": "kodingwarrior",
          "username": "kodingwarrior",
          "header_static":
              "https://mstdn-cdn.e14forest.net/accounts/he aders/109/309/382/773/915/357/original/ebb49a10d52ad739.jpg",
          "emojis": [
            {
              "url": "https://mstdn-cdn.e14forest.net/custom_emojis/images/000/004/716/original/33efddaa0f52ba3d.pn g",
              "shortcode": "vim",
              "static_url":
                  "https://mstdn-cdn.e14forest.net/custom_emojis/images/000/004/716/static/33efddaa0f52ba3d.png",
              "visible_in_picker": true
            }
          ],
          "followers_c ount": 200,
          "note": "<p>자바가 아닌 백엔드를 하면서 삐딱선을 타는 풀스택개발자</p>",
          "display_name": "kodingwarrior :vim:",
          "roles": []
        },
        "reblogged": false,
        "created_at": "20 22-12-03T18:24:39.185Z",
        "in_reply_to_id": null,
        "bookmarked": true,
        "language": "ko",
        "mentions": [],
        "in_reply_to_account_id": null,
        "visibility": "public",
        "spoiler_text": "",
        "media_attachments": [],
        "muted": false,
        "sensitive": false,
        "emojis": [],
        "application": {"name": "Web", "website": null},
        "edited_at": null,
        "pinned": false,
        "filtered": [],
        "replies_count": 0,
        "reblogs_count": 0,
        "content":
            "<p>YouTube에서 &#39;Clerk: Local-First Notebooks for Clojure by Martin Kavalar at reClojure 2021&#39; 보기 <a href=\"h ttps://youtu.be/3ANS2NTNgig\" target=\"_blank\" rel=\"nofollow noopener noreferrer\" translate=\"no\"><span class=\"invisible\">https://</span><span class=\"\">youtu.be/3ANS2N TNgig</span><span class=\"invisible\"></span></a></p><p>Clojure 환경에서 라인바이 라인으로 해석해서 라이브로 시각화해주는 notebook 환경이라니.. 와... 이거 진짜 제대로 혁신이네..</p>"
      },
    ),
    MastodonStatus.fromJson({
      "favourited": false,
      "reblog": null,
      "tags": [],
      "favourites_count": 0,
      "card": {
        "embed_url": "",
        "description": "Tech support as an LLM Slack bot",
        "html": "",
        "type": "link ",
        "height": 0,
        "url": "https://www.patterns.app//blog/2022/12/21/finetune-llm-tech-support",
        "title": "Prompt engineering davinci-003 on our own docs for automated support (P art I) | Patterns",
        "published_at": null,
        "width": 0,
        "author_name": "",
        "language": "en",
        "provider_name": "",
        "image_description": "",
        "image": null,
        "author_url": "",
        "blur hash": null,
        "provider_url": ""
      },
      "poll": null,
      "uri": "https://social.lansky.name/users/hn50/statuses/109562816522311875",
      "id": "109562816759828736",
      "url": "https://social. lansky.name/@hn50/109562816522311875",
      "account": {
        "group": false,
        "locked": false,
        "discoverable": true,
        "uri": "https://social.lansky.name/users/hn50",
        "id": "10931464875314 5815",
        "avatar_static":
            "https://mstdn-cdn.e14forest.net/cache/accounts/avatars/109/314/648/753/145/815/original/be3def70c55f104a.png",
        "avatar":
            "https://mstdn-cdn.e14forest. net/cache/accounts/avatars/109/314/648/753/145/815/original/be3def70c55f104a.png",
        "statuses_count": 85904,
        "following_count": 1,
        "created_at": "2020-06-09T00:00:00.000Z",
        "la st_status_at": "2024-04-07",
        "fields": [],
        "url": "https://social.lansky.name/@hn50",
        "bot": true,
        "header": "https://social.silicon.moe/headers/original/missing.png",
        "acct": "hn50@social.lansky.name",
        "username": "hn50",
        "header_static": "https://social.silicon.moe/headers/original/missing.png",
        "emojis": [],
        "followers_count": 4110,
        "note":
            "<p> Posts from <a href=\"https://news.ycombinator.com\" rel=\"nofollow noopener noreferrer\" translate=\"no\" target=\"_blank\"><span class=\"invisible\">https://</span><span clas s=\"\">news.ycombinator.com</span><span class=\"invisible\"></span></a> that have over 50 points.</p><p>See also <span class=\"h-card\" translate=\"no\"><a href=\"https://soci al.lansky.name/@hn100\" class=\"u-url mention\" rel=\"nofollow noopener noreferrer\" target=\"_blank\">@<span>hn100</span></a></span>, <span class=\"h-card\" translate=\"no\"> <a href=\"https://social.lansky.name/@hn250\" class=\"u-url mention\" rel=\"nofollow noopener noreferrer\" target=\"_blank\">@<span>hn250</span></a></span> and <span class=\"h -card\" translate=\"no\"><a href=\"https://social.lansky.name/@hn500\" class=\"u-url mention\" rel=\"nofollow noopener noreferrer\" target=\"_blank\">@<span>hn500</span></a></ span></p>",
        "display_name": "Hacker News 50"
      },
      "reblogged": false,
      "created_at": "2022-12-23T11:45:06.000Z",
      "in_reply_to_id": null,
      "bookmarked": true,
      "language": "en",
      "men tions": [],
      "in_reply_to_account_id": null,
      "visibility": "public",
      "spoiler_text": "",
      "media_attachments": [],
      "muted": false,
      "sensitive": false,
      "emojis": [],
      "edited_at": null,
      "filtered": [],
      "replies_count": 0,
      "reblogs_count": 0,
      "content":
          "<p>Prompt engineering DaVinci-003 on our own docs for automated support (Part I)</p><p>Link: <a href =\"https://www.patterns.app/blog/2022/12/21/finetune-llm-tech-support/\" rel=\"nofollow noopener noreferrer\" target=\"_blank\"><span class=\"invisible\">https://www.</span><s pan class=\"ellipsis\">patterns.app/blog/2022/12/21/f</span><span class=\"invisible\">inetune-llm-tech-support/</span></a><br>Discussion: <a href=\"https://news.ycombinator.co m/item?id=34093799\" rel=\"nofollow noopener noreferrer\" target=\"_blank\"><span class=\"invisible\">https://</span><span class=\"ellipsis\">news.ycombinator.com/item?id=3</s pan><span class=\"invisible\">4093799</span></a></p>"
    })
  ];

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
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            GaleContainer(
                predicates: (style) => [style.bg.red200, style.rounded.sm, style.shadow.xl],
                child: GaleTypography.h1(text: 'Hello, Gale!')),
            GaleCircle(
              radius: 80.0,
              predicates: (style) => [style.bg.blue300],
              child: const Icon(Icons.add),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
