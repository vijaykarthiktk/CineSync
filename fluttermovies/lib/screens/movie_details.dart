import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../API/const.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


class MovieDetails extends StatefulWidget {
  int id;
  MovieDetails({
    Key? key,
    required this.id
  }) : super(key: key);

  @override
  State<MovieDetails> createState() => _MovieDetailsState();
}

class _MovieDetailsState extends State<MovieDetails> {
  final tmdb = TMDBApi();
  List<String> watched = [];
  List<String> watchList = [];

  int watchedRuntime = 0;
  int watchListRuntime = 0;

  double sigma = 0;
  
  late SharedPreferences prefs; 
  
  launchYT(String key) async {
    String toLaunch = 'https://www.youtube.com/watch?v=$key';
    launch(toLaunch);
  }

  getData(var data, String key){
    try{
      if(key == 'release_date'){
        return DateFormat('MMMM d, y').format(DateTime.parse(data[key]));
      } else{
        return data[key];
      }
    } catch (e) {
      return "";
    }
  }

  saveWatched(String id, var data){
    watched = prefs.getStringList('watched') ?? [];
    watchedRuntime = prefs.getInt('runtime_watched')??0;
    if(watched.contains(id)){
      watched.remove(id);
      prefs.setStringList('watched', watched);
      prefs.setInt('runtime_watched', int.parse((watchedRuntime-data['runtime']).toString()));
      prefs.remove(id);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Removed From Watched")));
    }
    else{
      watched.add(id);
      prefs.setStringList('watched', watched);
      prefs.setStringList("${id}_watched", [data['title'], data['poster_path']]);
      prefs.setInt('runtime_watched', data['runtime']);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Saved To Watched")));
    }
  }

  saveWatchList(String id, var data){

    watchList = prefs.getStringList('watchlist') ?? [];
    watchListRuntime = prefs.getInt('runtime_watchlist')??0;
    if(watchList.contains(id)){
      watchList.remove(id);
      prefs.setStringList('watchlist', watchList);
      prefs.setInt('runtime_watchlist', int.parse((watchListRuntime-data['runtime']).toString()));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Removed From Watchlist")));

    } else{
      watchList.add(id);
      prefs.setStringList('watchlist', watchList);
      prefs.setStringList("${id}_watchlist", [data['title'], data['poster_path']]);
      prefs.setInt('runtime_watchlist', data['runtime']);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Saved To Watchlist")));
    }
  }

  init() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  initState() {
    // TODO: implement initState
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  FutureBuilder(
        future: tmdb.getDetails(widget.id),
        builder: (BuildContext context, snapshot) {
          if(snapshot.hasData){
            final data = snapshot.data;
            return Stack(
              children: [
                Scaffold(
                  appBar: AppBar(
                    title: Text((data!['title'])!),
                    actions: [
                      IconButton(
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: widget.id.toString(),));
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copied")));
                        },
                        icon: const Icon(Icons.copy,)
                      ),
                      const Padding(padding: EdgeInsets.fromLTRB(0, 0, 10, 0))
                    ],
                  ),
                  body:SafeArea(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: SizedBox(
                                            width: 120,
                                            height: 180,
                                            child: getData(data, 'poster_path') != null
                                                ? CachedNetworkImage(
                                                  imageUrl: 'https://image.tmdb.org/t/p/w400${data['poster_path']}',
                                                  cacheKey: widget.id.toString(),
                                                  fadeInDuration: const Duration(seconds: 1),
                                                )
                                                : const Icon(Icons.movie, size: 100,)
                                        )
                                    ),
                                    onTap: (){
                                      if(getData(data, 'poster_path') != null){
                                        setState(() {
                                          sigma = 5.0;
                                        });
                                        showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (context){
                                              return Dialog(
                                                insetAnimationCurve: Curves.easeInOut,
                                                child: SizedBox(
                                                    width: MediaQuery.of(context).size.width,
                                                    child: CachedNetworkImage(
                                                      imageUrl: 'https://image.tmdb.org/t/p/w400${data['poster_path']}',
                                                      fadeInDuration: const Duration(seconds: 1),
                                                    )
                                                ),
                                              );
                                            }
                                        );
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 10,),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          LimitedBox(
                                            maxWidth: MediaQuery.of(context).size.width - 150,
                                            child: Tooltip(
                                              message: "Copied",
                                              onTriggered: () async {
                                                await Clipboard.setData(ClipboardData(text: data['title'],));
                                              },
                                              child: Text(getData(data,'title'),
                                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold,),
                                                maxLines: 3,
                                                softWrap: true,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 3,),
                                          Text('${getData(data, 'release_date')} | ${data['runtime']} minutes', style: const TextStyle(fontSize: 12),),
                                          const SizedBox(height: 10,),
                                          FutureBuilder(
                                            future: tmdb.getTrailer(widget.id),
                                            builder: (context, snapshot) {
                                              if(snapshot.hasData ){
                                                var trailerData = snapshot.data!['results'];
                                                return Column(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    FilledButton(
                                                        onPressed: (){
                                                          launchYT(trailerData[trailerData.length-1]['key']);
                                                        },
                                                        child: Row(
                                                          children: const [
                                                            Icon(Icons.movie_creation_outlined),
                                                            Text("  Trailer")],
                                                        )
                                                    ),
                                                  ],
                                                );
                                              }else{
                                                return const CircularProgressIndicator();
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            const Divider(),
                            const SizedBox(height: 3,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                OutlinedButton(
                                  onPressed: (){
                                    saveWatched(widget.id.toString(), data);
                                },
                                  child: Column(
                                  children: const [
                                    SizedBox(height: 5,),
                                    Icon(Icons.check),
                                    Text("Set Watched"),
                                    SizedBox(height: 5,),
                                  ],
                                )),
                                const SizedBox(width: 10,),
                                OutlinedButton(
                                    onPressed: (){
                                  saveWatchList(widget.id.toString(), data);
                                },
                                    child: Column(
                                      children: const [
                                        SizedBox(height: 5,),
                                        Icon(Icons.watch_later_outlined),
                                        Text("On Watchlist"),
                                        SizedBox(height: 5,),
                                      ],
                                    )),
                                const SizedBox(width: 10,),
                                OutlinedButton(onPressed: (){}, child: Column(
                                  children: const [
                                    SizedBox(height: 5,),
                                    Icon(Icons.download),
                                    Text("Download"),
                                    SizedBox(height: 5,),

                                  ],
                                )),
                              ],
                            ),
                            const SizedBox(height: 3,),
                            const Divider(),
                            Text('${getData(data,'overview')}\n\nSource:TMDB'),
                            const Divider(),
                            Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(getData(data,'vote_average').toStringAsFixed(1),
                                            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900,),
                                          ),
                                          Text("(${getData(data, 'vote_count')})", style: const TextStyle(fontSize: 10),)
                                        ],
                                      ),
                                      const Text('TMDB')
                                    ],
                                  ),
                                ],
                              ),
                            const Divider(),
                            const Text('Genres', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                            Row(
                                children: List.generate(
                                    getData(data,'genres').length,
                                        (index) {
                                      if(index == getData(data, 'genres').length-1){
                                        return Text('${getData(data, 'genres')[index]['name']}');
                                      }else{
                                        return Text(' ${getData(data, 'genres')[index]['name']}, ');
                                      }
                                    }
                                    ),
                              )
                          ],
                        ),
                      )
                  ),
                ),
                Positioned.fill(
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                            sigmaX: sigma,
                            sigmaY: sigma
                        ),
                        child: const Opacity(
                          opacity: 0.01,
                        ),
                      ),
                    )
                )
              ]
            );
          } else {
            return const Scaffold(
                body: Center(
                    child: CircularProgressIndicator()
                )
            );
          }
        }
    );
  }
}
