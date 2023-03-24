import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttermovies/screens/comming_soom.dart';
import 'package:fluttermovies/screens/search_screen.dart';
import 'package:fluttermovies/screens/settings.dart';
import 'package:fluttermovies/screens/statistics.dart';
import 'package:fluttermovies/screens/watch_list.dart';
import 'package:fluttermovies/screens/watched.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'API/const.dart';
import 'screens/movie_details.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

void main() {
  CachedNetworkImage.logLevel = CacheManagerLogLevel.debug;
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            ' Error!\n ${details.exception}',
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
          ),
        ),),
    );
  };

  runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
          fontFamily: 'Product Sans'
        ),
        title: 'CineSync',
        initialRoute: '/',
        routes: {
          '/': (context) => MyApp(),
          '/search': (context) => const SearchScreen(),
        },
      )
  );
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final tmdb = TMDBApi();
  int selectedIndex = 0;
  List<dynamic> movies = [];
  late PackageInfo packageInfo ;

  _scrollListener() {
    if (_controller.position.maxScrollExtent==_controller.offset) {
      fetchTrendingMovies();
    }
    if (_controller.offset <= _controller.position.minScrollExtent &&
        !_controller.position.outOfRange) {
    }
  }

  Future<void> fetchTrendingMoviesInitial() async {
    try {
      for (int i = 1; i <= 2; i++) {
        final pageMovies  = await tmdb.reserveTrendingMovies();
        movies.addAll(pageMovies);
      }
      _moviesStreamController.sink.add(movies);
    } catch (e) {
      throw('Error fetching trending movies: $e');
    }
  }

  Future<void> fetchTrendingMovies() async {
    try {
      final pageMovies  = await tmdb.reserveTrendingMovies();
      movies.addAll(pageMovies);
      _moviesStreamController.sink.add(movies);
    } catch (e) {
      throw('Error fetching trending movies: $e');
    }
  }

  launchLink(String link) async {
    launchUrlString(link);
  }
  late ScrollController _controller;

  final _moviesStreamController = StreamController<List<dynamic>>();

  init() async {
    packageInfo = await PackageInfo.fromPlatform();
  }

  @override
  void initState() {
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
    fetchTrendingMoviesInitial();
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        primary: true,
        title: const Text('CineSync'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/search');
              },
              icon: const Icon(Icons.search)),
          const Padding(padding: EdgeInsets.only(right: 10))
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          children: [
            StreamBuilder(
              stream: _moviesStreamController.stream,
              builder: (BuildContext context, snapshot) {
                if(snapshot.hasData){
                  final data = snapshot.data;
                  return Expanded(
                      child: ResponsiveGridList(
                        horizontalGridSpacing: 10,
                        verticalGridSpacing: 10,
                        horizontalGridMargin: 0,
                        verticalGridMargin: 0,
                        minItemWidth: 100,
                        listViewBuilderOptions:ListViewBuilderOptions(
                            controller:_controller,
                            physics: const BouncingScrollPhysics()
                        ),
                        children: List.generate(
                            (data?.length)!,
                                (index) {
                              return GestureDetector(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Stack(
                                          children: [
                                            CachedNetworkImage(
                                              imageUrl:'https://image.tmdb.org/t/p/w400${data![index]['poster_path']}',
                                              cacheKey: data[index]['id'].toString(),
                                            ),
                                          ],
                                        )
                                    ),
                                    Text(data[index]['title'], overflow: TextOverflow.ellipsis,)
                                  ],
                                ),
                                onTap: (){
                                  Navigator.of(context).push(
                                      SwipeablePageRoute(
                                          builder: (context) => MovieDetails(id: data[index]['id'],)
                                      )
                                  );
                                },
                              );
                            }
                        ),
                      )
                  );
                } else{
                  return const Center(child: CircularProgressIndicator(),);
                }
              },
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
                accountName: Text("CineSync"),
                accountEmail: null,
                currentAccountPicture:CircleAvatar(
                  radius: 30,
                  child: ClipRRect(
                    child: Image.asset('assets/icons/icon.png'),
                    borderRadius: BorderRadius.circular(50),
                  ),
                )
            ),
            ListTile(
              title: const Text("Show"),
              leading: const Icon(Icons.tv),
              onTap: (){
                Navigator.of(context).push(SwipeablePageRoute(builder: (context) => ComingSoonScreen(),));
              },
            ),
            ListTile(
              title: const Text("People"),
              leading: const Icon(Icons.people),
              onTap: (){
                Navigator.of(context).push(SwipeablePageRoute(builder: (context) => ComingSoonScreen(),));
              },
            ),
            const Divider(),
            ListTile(
              title: const Text("Watched Movies"),
              leading: const Icon(Icons.check),
              onTap: (){
                Navigator.of(context).push(SwipeablePageRoute(builder: (context) => const WatchedScreen(),));
              },
            ),
            ListTile(
              title: const Text("Watch Later"),
              leading: const Icon(Icons.watch_later),
              onTap: (){
                Navigator.of(context).push(SwipeablePageRoute(builder: (context) => const WatchListScreen(),));
              },
            ),
            const Divider(),
            ListTile(
              title: const Text("Statistics"),
              leading: const Icon(Icons.stacked_line_chart),
              onTap: (){
                Navigator.of(context).push(SwipeablePageRoute(builder: (context) => const StatisticsScreen(),));
              },
            ),
            const Divider(),
            ListTile(
              title: const Text("Settings"),
              leading: const Icon(Icons.settings),
              onTap: (){
                Navigator.of(context).push(SwipeablePageRoute(builder: (context) => SettingsScreen(),));
              },
            ),
            ListTile(
              title: const Text("About"),
              leading: const Icon(Icons.info),
              onTap: (){
                showAboutDialog(
                    context: context,
                  applicationIcon: Center(
                    child: CircleAvatar(
                      radius: 30,
                      child: ClipRRect(
                        child: Image.asset('assets/icons/icon.png'),
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                  applicationVersion: packageInfo.version,
                  children: [
                    const Text("Flutter Movie App Build With TMDB Api \n By VijayKarthik "),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(onPressed: (){
                          launchLink(TMDBApi.Github);
                        }, icon: const FaIcon(FontAwesomeIcons.github)),
                        IconButton(onPressed: (){
                          launchLink(TMDBApi.Linkedin);
                        }, icon: const FaIcon(FontAwesomeIcons.linkedin)),
                        IconButton(onPressed: (){
                          launchLink(TMDBApi.Twitter);
                        }, icon: const FaIcon(FontAwesomeIcons.twitter)),
                        IconButton(onPressed: (){
                          launchLink(TMDBApi.Instagram);
                        }, icon: const FaIcon(FontAwesomeIcons.instagram))
                      ],
                    )
                  ]
                );
              },
            ),
          ],
        ),
      ),
    );
  }

}
