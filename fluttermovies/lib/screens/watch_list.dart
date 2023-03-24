import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import 'movie_details.dart';

class WatchListScreen extends StatefulWidget {
  const WatchListScreen({Key? key}) : super(key: key);

  @override
  State<WatchListScreen> createState() => _WatchListScreenState();
}

class _WatchListScreenState extends State<WatchListScreen> {
  late SharedPreferences prefs;
  List<String> watchList = [];
  init() async {
    prefs = await SharedPreferences.getInstance().then((value) {
      setState(() {
        watchList = value.getStringList('watchlist') ?? [];
      });
      return value;
    });
  }

  @override
  initState() {
    // TODO: implement initState
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Watch Later"),
      ),
      body: Container(
          child: watchList.isNotEmpty
              ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: ResponsiveGridList(
              horizontalGridSpacing: 10,
              verticalGridSpacing: 10,
              horizontalGridMargin: 0,
              verticalGridMargin: 0,
              minItemWidth: 100,
              listViewBuilderOptions:ListViewBuilderOptions(
                  physics: const BouncingScrollPhysics()
              ),
              children: List.generate(
                  (watchList.length),
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
                                      imageUrl:'https://image.tmdb.org/t/p/w400${prefs.getStringList('${watchList[index]}_watchlist')![1]}'
                                  ),
                                ],
                              )
                          ),
                          Text(prefs.getStringList("${watchList[index]}_watchlist")![0], overflow: TextOverflow.ellipsis,)
                        ],
                      ),
                      onTap: (){
                        Navigator.of(context).push(
                            SwipeablePageRoute(
                                builder: (context) => MovieDetails(id: int.parse(watchList[index]),)
                            )
                        );
                      },
                    );
                  }
              ),
            ),
          )
              : const Center(child: Text("No Movie Found", style: TextStyle( fontSize: 20),))
      ),
    );
  }
}
