import 'dart:developer';
import 'dart:convert' as convert;
import 'constants.dart';
import 'package:http/http.dart' as http;

class APIFunctions {
    static Future<String>  getSpotifyToken() async {
    try{
      var url = Uri.parse('https://accounts.spotify.com/api/token');
      var encoded = convert.base64.encode(convert.utf8.encode('${SpotifyApiConstants.clientId}:${SpotifyApiConstants.clientSecret}'));
      var headers = {'Authorization': 'Basic $encoded'};
      var response = await http.post(url,headers: headers,body: {'grant_type': 'client_credentials'});
      var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
      return jsonResponse['access_token'];
    } catch(e){
      log(e.toString());
    }
    return '---';
  }

  static Future<Object> getTrackPreview(String themeName, String token) async {
    try{
      var url = Uri.https(SpotifyApiConstants.baseUrl,'${SpotifyApiConstants.trackEndPoint}',{'q':themeName.replaceAll('"', '').replaceAll('(', '').replaceAll(')', '').replaceAll('#1', ''),'type':'track','limit':'20','market':'JP', 'genre':['anime']});
      var headers = {'Authorization': 'Bearer $token'};
      var response = await http.get(url,headers: headers);
      var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
      return jsonResponse;
    } catch(e){
      log(e.toString());
    }
    return '---';
  }

  static Future<Object> getSeasonalAnimeLits(String year,String season) async {
    try{
      var url = Uri.https(MALApiConstants.baseUrl,'${MALApiConstants.seasonAnimeEndPoint}$year/$season',{'sort':'anime_score','limit':'200','fields':
        'alternative_titles,mean,rank,media_type,start_season'});
      var headers = {'X-MAL-CLIENT-ID': MALApiConstants.clientAuth};
      var response = await http.get(url,headers: headers);
      var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;

      List seasonList = jsonResponse['data'];

      seasonList = seasonList.where((element) => (element['node']['start_season']['year'].toString()==year && element['node']['start_season']['season']==season)).toList();

      return seasonList;
    } catch(e){
      log(e.toString());
    }
    return '---';
  }

  static Future<Object> getAnimeDetail(String id) async{
    try{
      var url = Uri.https(MALApiConstants.baseUrl,'${MALApiConstants.animeSearchEndPoint}$id',{'fields':
        'alternative_titles,mean,rank,opening_themes,ending_themes'
      });
      var headers = {'X-MAL-CLIENT-ID': MALApiConstants.clientAuth};
      var response = await http.get(url,headers: headers);
      var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
      return jsonResponse;
    }catch(e){
      log(e.toString());
    }
    return '';
  }
}