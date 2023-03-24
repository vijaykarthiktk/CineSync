import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class TMDBApi{
  static const API_KEY = '02754a872297fbaf4d6c39dc040eb2f2';
  static const Instagram = "https://www.instagram.com/vijaykaarthiktk/";
  static const Linkedin = 'https://www.linkedin.com/in/vijaykarthiktk';
  static const Twitter = 'https://www.twitter.com/vijaykarthiktk';
  static const Github = 'https://www.github.com/vijaykarthiktk';

  int page = 1;

  Future<Map> _makeGetRequest(String url) async {
    HttpClient client = HttpClient();client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
    final request = IOClient(client);
    var response = await request.get(Uri.parse(url));
    Map responseMap = json.decode(response.body);
    return responseMap;
  }

  Future<Map> getTrending(int page){
    String url = 'https://api.themoviedb.org/3/discover/movie?api_key=$API_KEY&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=$page&with_watch_monetization_types=flatrate';
    return _makeGetRequest(url);
  }

  Future<List<dynamic>> reserveTrendingMovies() async {
    final String url = 'https://api.themoviedb.org/3/discover/movie?api_key=$API_KEY&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=$page&with_watch_monetization_types=flatrate';

    final response = await http.get(Uri.parse(url));

    page++;
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return jsonData['results'];
    } else {
      throw Exception('Failed to reserve trending movies');
    }
  }

  Future<Map> getDetails(int id){
    String url = 'https://api.themoviedb.org/3/movie/$id?api_key=$API_KEY&language=en-US';
    return _makeGetRequest(url);
  }

  Future<Map> getTrailer(int id){
    String url = 'https://api.themoviedb.org/3/movie/$id/videos?api_key=$API_KEY&language=en-US';
    return _makeGetRequest(url);
  }

  Future<List<dynamic>> getMovieSearch(String query) async {
    String url = 'https://api.themoviedb.org/3/search/movie?api_key=$API_KEY&language=en-US&query=$query&page=1&include_adult=false';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return jsonData['results'];
    } else {
      throw Exception('Failed to reserve trending movies');
    }
  }

}