import 'package:flutter/material.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import '../API/const.dart';
import 'movie_details.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  final TextEditingController _searchController = TextEditingController();
  List<Widget> result = <Widget>[const SizedBox(height: 10,)];
  final tmdb = TMDBApi();



  showResult(String query){
    if(query.trim().isNotEmpty){
      setState(() {
        result =[
          FutureBuilder(
          future: tmdb.getMovieSearch(query),
          builder: (context, snapshot) {
            if(snapshot.hasData){
              var data = snapshot.data;
              if(data?.length != 0){
                return Column(
                  children: List.generate(data?.length ?? 0, (index) {
                    if(data![index]['poster_path']!=null && data[index]['release_date']!=""){
                      return Column(
                        children: [
                          ListTile(
                            title: Text(data[index]['title']),
                            onTap: (){
                              Navigator.of(context).push(
                                  SwipeablePageRoute(
                                    canOnlySwipeFromEdge: true,
                                    builder: (context) => MovieDetails(id: data[index]['id'],)
                                  )
                              );
                            },
                          ),
                          const FractionallySizedBox(
                            widthFactor: 0.95,
                            child: Divider(
                              height: 1,
                            ),
                          )
                        ],
                      );
                    } else{
                      return Container();
                    }
                  }),
                );
              } else{
                return const Center(
                    child: Text("No Result Found")
                );
              }
            } else{
              return const Center(
                  child: CircularProgressIndicator()
              );}
            },
          )
        ];
      });
    } else{
      setState(() {
        result = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: _searchController,
            focusNode: FocusNode()..requestFocus(),
            keyboardType: TextInputType.name,
            enableSuggestions: true,
            scrollPhysics: const BouncingScrollPhysics(),
            onChanged: (query){
              showResult(query);
            },
            decoration: const InputDecoration(
              hintText: 'Search',
              border: InputBorder.none,
            ),
          ),
        ),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          children: result,
        )
    );
  }
}
