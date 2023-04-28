import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'api_function.dart';
import 'data_function.dart';
import 'card.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Top Anime',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: const MyHomePage(title: 'Top Anime'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    APIFunctions.getSpotifyToken().then((value) => DataRetrieve.token = value);
  }

  Widget animatedAnimeListItem(int index, List topFive) {
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: CardItemBuild(index: index, topFive: topFive)//cardAnimeListItem(index, topFive),
        ),
      ),
    );
  }

  Widget topFiveView(int index) {
    return FutureBuilder<List>(
      future: DataRetrieve.getTopFiveData(
          (2023 - (index / 4)).truncate().toString(),
          DataRetrieve.season[index % 4]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          
          if (snapshot.data==null) return const Center(child: Text('There was a error while connecting with the API. Please, try again later.'),);

          List? topFive = snapshot.data;
          return AnimationLimiter(
            key: UniqueKey(),
            child: ListView(children: [
              animatedAnimeListItem(0, topFive!),
              animatedAnimeListItem(1, topFive),
              animatedAnimeListItem(2, topFive),
              animatedAnimeListItem(3, topFive),
              animatedAnimeListItem(4, topFive),
            ]),
          );
        } else {
          return const Center(
            child: SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  Widget seasonCardPageView() {
    return SizedBox(
      height: 200, // card height
      child: PageView.builder(
        itemCount: 60,
        controller: PageController(viewportFraction: 0.7),
        onPageChanged: (int index) => setState((){ _index = index;DataRetrieve.cardColorStops = [0, 0.01, 0.99, 1];}),
        itemBuilder: (_, i) {
          return Transform.scale(
            scale: i == _index ? 1 : 0.9,
            child: Card(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              elevation: 6,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          'images/${DataRetrieve.season[i % 4]}.jpg'),
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                  child: Center(
                      child: Stack(
                    children: <Widget>[
                      Text(
                        "${DataRetrieve.season[i % 4]} ${(2023 - (i / 4)).truncate()}",
                        style: GoogleFonts.pacifico(
                            textStyle: TextStyle(
                          fontSize: 32,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 3
                            ..color = Colors.black38,
                        )),
                      ),
                      Text(
                        "${DataRetrieve.season[i % 4]} ${(2023 - (i / 4)).truncate()}",
                        style: GoogleFonts.pacifico(
                            textStyle: const TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                        )),
                      ),
                    ],
                  ))),
            ),
          );
        },
      ),
    );
  }

  void showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: 200,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'About the app',
                      style: TextStyle(fontSize: 22),
                    ),
                    const Divider(
                      height: 20,
                    ),
                    const Text(
                      'This app uses automatic functions from APIs. Some information or songs may not be correct',
                      style: TextStyle(fontSize: 16),
                    ),
                    const Divider(
                      height: 16,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Text.rich(
                          textAlign: TextAlign.left,
                          TextSpan(
                              text: 'Developer: Raul Felipe Almeida',
                              children: [
                                TextSpan(
                                    text: ' - GitHub',
                                    style: const TextStyle(
                                        color: Colors.blueAccent),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        launchUrl(Uri.parse(
                                            'https://github.com/raul-felipe/top_anime'));
                                      })
                              ])),
                    ),
                    Container(
                      height: 14,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Text.rich(
                          textAlign: TextAlign.left,
                          TextSpan(
                              text: 'Anime info: Myanimelist API',
                              children: [
                                TextSpan(
                                    text: ' - MAL Website',
                                    style: const TextStyle(
                                        color: Colors.blueAccent),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        launchUrl(Uri.parse(
                                            'https://myanimelist.net/'));
                                      })
                              ])),
                    ),
                    Container(
                      height: 14,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Text.rich(
                          textAlign: TextAlign.left,
                          TextSpan(text: 'Songs: Spotify API', children: [
                            TextSpan(
                                text: ' - Spotify Website',
                                style:
                                    const TextStyle(color: Colors.blueAccent),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    launchUrl(
                                        Uri.parse('https://open.spotify.com/'));
                                  })
                          ])),
                    ),
                    Container(
                      height: 14,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Text.rich(
                          textAlign: TextAlign.left,
                          TextSpan(
                              text:
                                  'Season backgroud images: Designed by pikisuperstar / Freepik',
                              children: [
                                TextSpan(
                                    text: ' - Source',
                                    style: const TextStyle(
                                        color: Colors.blueAccent),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        launchUrl(Uri.parse(
                                            'https://www.freepik.com/author/pikisuperstar'));
                                      })
                              ])),
                    ),
                  ],
                ),
              )),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade100, width: 2),
            color: Colors.white30),
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.grey[50],
              title: Text(widget.title),
              foregroundColor: Colors.grey[600],
              actions: [
                IconButton(
                    onPressed: () {
                      showInfoDialog();
                    },
                    icon: const Icon(Icons.info_outline))
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: seasonCardPageView(),
            ),
            Expanded(child: topFiveView(_index)),
          ],
        ),
      ),
    ));
  }
}
