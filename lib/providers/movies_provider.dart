import 'dart:async';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:movies/helpers/debouncer.dart';
import 'package:movies/models/models.dart';

class MoviesProvider extends ChangeNotifier {
  final _baseUrl = 'api.themoviedb.org';
  final _apiKey = 'fa864d292fa6babe16b9e8a8b811cfd5';
  final _language = 'en-US';

  Future<String> _getJsonData(String endpoint, [int page = 1]) async{
    final url = Uri.https(_baseUrl, endpoint, {
      'q': '{http}',
      'api_key': _apiKey,
      'language': _language,
      'page': '$page'
      }
    );

    final response = await http.get(url);
    return response.body;
  }

  List<Movie> onDisplayMovies = [];
  List<Movie> popularMovies = [];
  Map<int, List<Cast>> moviesCast = {};
  int _popularPage = 0;

  final debouncer = Debouncer(
    duration: const Duration(milliseconds: 500)
  );

  final StreamController<List<Movie>> _suggestionStreamController = StreamController.broadcast();
  Stream<List<Movie>> get suggestionStream => _suggestionStreamController.stream;
 
  MoviesProvider() {
    getOnDisplayMovies();
    getPopularMovies();
  }

  getOnDisplayMovies() async {
    final jsonData = await _getJsonData('3/movie/now_playing');

    final nowPlayingResponse = NowPlayingResponse.fromRawJson( jsonData );
    onDisplayMovies = nowPlayingResponse.results;
    notifyListeners(); // This will notify all the listeners
  }

  getPopularMovies() async {
    _popularPage ++;
    final jsonData = await _getJsonData('3/movie/popular', _popularPage);

    final popularResponse = PopularResponse.fromRawJson( jsonData );
    popularMovies = [...popularMovies, ...popularResponse.results];
    notifyListeners(); // This will notify all the listeners
  }

  Future <List<Cast>>getMovieCast(int movieId) async {
    if(moviesCast.containsKey(movieId)) return moviesCast[movieId]!;

    final jsonData = await _getJsonData('3/movie/$movieId/credits');
    final creditsResponse = CreditsResponse.fromRawJson( jsonData );
    moviesCast[movieId] = creditsResponse.cast;

    return creditsResponse.cast;
  }

  Future <List<Movie>>searchMovies(String query) async {
    final url = Uri.https(_baseUrl, '3/search/movie', {
      'api_key': _apiKey,
      'language': _language,
      'query': query
    });

    final response = await http.get(url);
    final searchResponse = SearchResponse.fromRawJson( response.body );

    return searchResponse.results;
  }

  void getSuggestionsByQuery(String searchTerm) {
    debouncer.value = '';
    debouncer.onValue = (value) async {
      final results = await searchMovies(searchTerm);
      _suggestionStreamController.add(results);
    };

    final timer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      debouncer.value = searchTerm;
    });

    Future.delayed(const Duration(milliseconds: 301), () => timer.cancel());
  }
}