import 'package:flutter/material.dart';
import 'api_function.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';

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
  final player = AudioPlayer();
  String token = '';

  List getSeasonalAnime(List seasonAnime) {
    seasonAnime.sort(
      (a, b) {
        a['node']['mean'] ??= 0;
        b['node']['mean'] ??= 0;
        return (b['node']['mean'] as double)
            .compareTo(a['node']['mean'] as double);
      },
    );

    int limit = 0;
    List seasonalTVAnime = [];
    for (var element in seasonAnime) {
      if (element['node']['media_type'] == 'tv') {
        seasonalTVAnime.add({
          'id': element['node']['id'],
          'title': element['node']['title'],
          'picture': element['node']['main_picture'],
          'score': element['node']['mean'],
          'start_season': element['node']['start_season']
        });
        limit++;
        if (limit == 5) return seasonalTVAnime;
      }
    }
    return seasonalTVAnime;
  }

  Future<List> getTopFiveAnime(seasonalTVAnime) async {
    List topFiveAnime = [];
    for (int i = 0; i < 5; i++) {
      Map ad =
          await APIFunctions.getAnimeDetail(seasonalTVAnime[i]['id'].toString())
              as Map;
      topFiveAnime.add({
        'id': ad['id'],
        'title': ad['title'],
        'ja_title': ad['alternative_titles']['ja'],
        'picture': ad['main_picture'],
        'score': ad['mean'],
        'song': ad['opening_themes'][0]['text'],
      });
    }
    return topFiveAnime;
  }

  // var anime = {
  //   'id':,

  // };

  @override
  void initState() {
    super.initState();
    APIFunctions.getSpotifyToken().then((value) => token = value);
  }

  Future<List> getTopFiveData(String year, String season) async {
    List seasonAnime =
        await APIFunctions.getSeasonalAnimeLits(year, season) as List;
    List seasonalTVAnime = getSeasonalAnime(seasonAnime);
    // print(seasonalTVAnime);
    List topFiveAnime = await getTopFiveAnime(seasonalTVAnime);
    return topFiveAnime;
  }

  int _index = 0;
  List season = ['winter', 'fall', 'summer', 'spring'];

  Widget cardAnimeListItem(int index, List topFive) {
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(8),
            child: InkWell(
              onTap: () async {
                Map track = await APIFunctions.getTrackPreview(
                    topFive[index]['song'], token) as Map;
                await player
                    .setSourceUrl(track['tracks']['items'][0]['preview_url']);
                await player.resume();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 3,
                    child: Image.network(topFive[index]['picture']['large']),
                  ),
                  const SizedBox(height: 30, child: VerticalDivider()),
                  Flexible(
                    flex: 8,
                    child: Column(
                      children: [
                        Text(
                          topFive[index]['title'],
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Divider(),
                        Text(
                          topFive[index]['ja_title'],
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Divider(),
                        Text(topFive[index]['song'])
                      ],
                    ),
                  ),
                  const SizedBox(height: 30, child: VerticalDivider()),
                  Flexible(
                      flex: 1,
                      child: Column(
                        children: [
                          const Icon(Icons.star),
                          Text(topFive[index]['score'].toString())
                        ],
                      ))
                ],
              ),
            )));
  }

  Widget animatedAnimeListItem(int index, List topFive) {
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: cardAnimeListItem(index, topFive),
        ),
      ),
    );
  }

  Widget topFiveView(int index) {
    return FutureBuilder<List>(
      future: getTopFiveData(
          (2023 - (index / 4)).truncate().toString(), season[index % 4]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
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
        itemCount: 80,
        controller: PageController(viewportFraction: 0.7),
        onPageChanged: (int index) => setState(() => _index = index),
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
                      image: AssetImage('images/${season[i % 4]}.jpg'),
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                  child: Center(
                      child: Stack(
                    children: <Widget>[
                      Text(
                        "${season[i % 4]} ${(2023 - (i / 4)).truncate()}",
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
                        "${season[i % 4]} ${(2023 - (i / 4)).truncate()}",
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
            child: Container(
              width: 200,
              child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'About the app',
                  style: TextStyle(fontSize: 22),
                ),
                const Divider(height: 20,),
                const Text(
                  'This app use automatic functions using APIs. Some information or songs may not be correct',
                  style: TextStyle(fontSize: 16),
                ),
                const Divider(height: 16,),
                const SizedBox(
                    width: double.infinity,
                    child: Text('Developer: Raul Felipe Almeida',
                        textAlign: TextAlign.left)),
                        Container(height: 14,),
                const SizedBox(
                    width: double.infinity,
                    child: Text('Anime info: Myanimelist API')),
                    Container(height: 14,),
                const SizedBox(
                    width: double.infinity, child: Text('Songs: Spotify API')),
                    Container(height: 14,),
                const SizedBox(
                    width: double.infinity,
                    child: Text(
                        'Season backgroud images: Designed by pikisuperstar / Freepik'))
              ],
            ),
            )
          ),
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
