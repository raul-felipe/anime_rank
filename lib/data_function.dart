import 'package:audioplayers/audioplayers.dart';
import 'api_function.dart';

class DataRetrieve {
  static final player = AudioPlayer();
  static String token = '';
  static List season = ['winter', 'fall', 'summer', 'spring'];
  static List<double> cardColorStops = [0, 0.01, 0.99, 1];

  static List getSeasonalAnime(List seasonAnime) {
    seasonAnime.sort(
      (a, b) {
        a['node']['mean'] ??= 0;
        b['node']['mean'] ??= 0;
        return (b['node']['mean'].toDouble())
            .compareTo(a['node']['mean'].toDouble());
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

  static Future<List> getTopFiveAnime(seasonalTVAnime) async {
    List topFiveAnime = [];
    for (int i = 0; i < 5; i++) {
      Map ad =
          await APIFunctions.getAnimeDetail(seasonalTVAnime[i]['id'].toString())
              as Map;

      String op = ad['opening_themes'][0]['text'];
      String ed = ad['ending_themes'][0]['text'];
      if (op.contains(ed.substring(6, 12)) &&
          ad['ending_themes'][1]['text'] != null) {
        ed = ad['ending_themes'][1]['text'];
      }

      topFiveAnime.add({
        'id': ad['id'],
        'title': ad['title'],
        'ja_title': ad['alternative_titles']['ja'],
        'picture': ad['main_picture'],
        'score': ad['mean'],
        'op': op,
        'ed': ed,
      });
    }
    return topFiveAnime;
  }

  static Future<List> getTopFiveData(String year, String season) async {
    List seasonAnime =
        await APIFunctions.getSeasonalAnimeLits(year, season) as List;
    List seasonalTVAnime = getSeasonalAnime(seasonAnime);
    List topFiveAnime = await getTopFiveAnime(seasonalTVAnime);
    
    return topFiveAnime;
  }

  static void playSong(String songName) async {
    Map track = await APIFunctions.getTrackPreview(songName, token) as Map;
    await player.setSourceUrl(track['tracks']['items'][0]['preview_url']);
    await player.resume();
  }
}
