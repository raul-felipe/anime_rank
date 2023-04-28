import 'dart:developer';
import 'dart:convert' as convert;
import 'package:fluttertoast/fluttertoast.dart';

import 'constants.dart';
import 'package:http/http.dart' as http;

class APIFunctions {
  static Future<String> getSpotifyToken() async {
    try {
      var url = Uri.parse('https://accounts.spotify.com/api/token');
      var encoded = convert.base64.encode(convert.utf8.encode(
          '${SpotifyApiConstants.clientId}:${SpotifyApiConstants.clientSecret}'));
      var headers = {'Authorization': 'Basic $encoded'};
      var response = await http.post(url,
          headers: headers, body: {'grant_type': 'client_credentials'});
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      return jsonResponse['access_token'];
    } catch (e) {
      log(e.toString());
    }
    return '---';
  }

  static String getStringBetween(
      String originalString, String start, String end) {
    int startIndex = originalString.indexOf(start);
    int endIndex = originalString.indexOf(end, startIndex + start.length);

    return originalString.substring(startIndex + start.length, endIndex);
  }

  static Future<Object> getTrackPreview(
      String themeName, String token, Map animeInfo) async {
    try {
      String song = themeName
          .replaceAll('.', '')
          .replaceAll('#1: ', '')
          .replaceAll('#2: ', '');
      //print(song);
      String songName = getStringBetween(song, '"', '"');
      //if(songName.contains('(')) songName = getStringBetween(songName, '(', ')');

      String artistName = song.substring(song.indexOf('by ') + 3);
      if (artistName.contains('(ep ')) {
        artistName =
            artistName.replaceRange(artistName.indexOf('(ep '), null, '');
      }
      if (artistName.contains('(eps ')) {
        artistName =
            artistName.replaceRange(artistName.indexOf('(eps '), null, '');
      }
      //if(artistName.contains('(')) artistName = getStringBetween(artistName,'(',')');

      var url = Uri.https(
          SpotifyApiConstants.baseUrl, SpotifyApiConstants.trackEndPoint, {
        'q': '$songName $artistName',
        'type': 'track',
        'limit': '1',
        'market': 'JP'
      });
      var headers = {'Authorization': 'Bearer $token'};
      var response = await http.get(url, headers: headers);
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;

      String spotifyTrackName = jsonResponse['tracks']['items'][0]['name'];
      String spotifyArtistName =
          jsonResponse['tracks']['items'][0]['artists'][0]['name'];
      String jpSongName = songName;
      if (songName.contains('(')) {
        jpSongName = getStringBetween(songName, '(', ')');
      }

      // print(spotifyTrackName);
      // print(songName);
      // print(spotifyArtistName);
      // print(artistName);

      //check if the spotify response has a track name similar to the song name and, if not, redo the request with anime title

      if (!songName.toLowerCase().contains(spotifyTrackName.toLowerCase()) &&
          !artistName.toLowerCase().contains(spotifyArtistName.toLowerCase()) &&
          !spotifyTrackName.toLowerCase().contains(jpSongName.toLowerCase()) &&
          !spotifyTrackName.toLowerCase().contains(songName.toLowerCase())) {
        if (songName.contains('(')) {
          songName = getStringBetween(songName, '(', ')');
        }

        var url = Uri.https(
            SpotifyApiConstants.baseUrl, SpotifyApiConstants.trackEndPoint, {
          'q': '$songName $artistName アニメ}',
          'type': 'track',
          'limit': '1',
          'market': 'NO',
        });
        headers = {'Authorization': 'Bearer $token'};
        response = await http.get(url, headers: headers);
        jsonResponse =
            convert.jsonDecode(response.body) as Map<String, dynamic>;

        // print(spotifyTrackName);
        // print(songName);
        // print(spotifyArtistName);
        // print(artistName);

        if (songName.toLowerCase().contains(spotifyTrackName.toLowerCase()) ||
            artistName
                .toLowerCase()
                .contains(spotifyArtistName.toLowerCase()) ||
            spotifyTrackName.toLowerCase().contains(songName.toLowerCase()) ||
            spotifyArtistName
                .toLowerCase()
                .contains(artistName.toLowerCase())) {
          return jsonResponse;
        }
        //there is no match between spotify response and song title / artist
        Fluttertoast.showToast(
          msg: "This song may not be correct",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
      return jsonResponse;
    } catch (e) {
      log(e.toString());
    }
    return '---';
  }

  static Future<Object> getSeasonalAnimeLits(String year, String season) async {
    try {
      var url = Uri.https(MALApiConstants.baseUrl,
          '${MALApiConstants.seasonAnimeEndPoint}$year/$season', {
        'sort': 'anime_score',
        'limit': '200',
        'fields': 'alternative_titles,mean,rank,media_type,start_season'
      });
      var headers = {'X-MAL-CLIENT-ID': MALApiConstants.clientAuth};
      var response = await http.get(url, headers: headers);
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;

      List seasonList = jsonResponse['data'];

      seasonList = seasonList
          .where((element) =>
              (element['node']['start_season']['year'].toString() == year &&
                  element['node']['start_season']['season'] == season))
          .toList();
      return seasonList;
    } catch (e) {
      log(e.toString());
    }
    return '---';
  }

  static Future<Object> getAnimeDetail(String id) async {
    try {
      var url = Uri.https(MALApiConstants.baseUrl,
          '${MALApiConstants.animeSearchEndPoint}$id', {
        'fields': 'alternative_titles,mean,rank,opening_themes,ending_themes'
      });
      var headers = {'X-MAL-CLIENT-ID': MALApiConstants.clientAuth};
      var response = await http.get(url, headers: headers);
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      return jsonResponse;
    } catch (e) {
      log(e.toString());
    }
    return '';
  }
}
