import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

import 'package:http/http.dart' as http;
import 'package:wallpaperflutter/pages/cardView.dart';
import 'package:wallpaperflutter/pages/detailPage.dart';
import 'package:wallpaperflutter/utils/cardImages.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List images = [];
  int? data;
  int page = 1;

  TextEditingController _searchField = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  fetchSearchApi(String searchText) async {
    await http.get(
        Uri.parse(
            "https://api.pexels.com/v1/search?query=$searchText&per_page=80"),
        headers: {
          'Authorization':
              '563492ad6f91700001000001abb5e548124b489eb9c74b6d44a7076e'
        }).then((value) {
      print(value.body);
      Map result = jsonDecode(value.body);

      setState(() {
        images = result['photos'];
        data = result['total_results'];
      });

      print('fetching data');
    });
  }

  loadMore(String searchText) async {
    print("using load more");
    setState(() {
      page = page + 1;
    });

    String url =
        "https://api.pexels.com/v1/search?query=$searchText&per_page=80&page=" +
            page.toString();
    await http.get(Uri.parse(url), headers: {
      'Authorization':
          '563492ad6f91700001000001abb5e548124b489eb9c74b6d44a7076e'
    }).then((value) {
      Map result = jsonDecode(value.body);
      setState(() {
        images.addAll(result['photos']);
      });
    });
  }

  bool isLoaded = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: SafeArea(
          child: Stack(
            children: [
              LazyLoadScrollView(
                onEndOfPage: () => loadMore(_searchField.text.trim()),
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 130,
                      ),
                      SizedBox(
                        height: 130,
                        child: ListView.builder(
                            physics: BouncingScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: cardImages.length,
                            itemBuilder: (context, index) {
                              String name = "${cardImages[index]['name']}";
                              return Padding(
                                padding:
                                    const EdgeInsets.only(right: 4, left: 4),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return CardView(cardText: name);
                                    }));
                                  },
                                  child: Container(
                                    height: 140,
                                    width: 180,
                                    decoration: BoxDecoration(
                                      color: Colors.blueGrey.shade400,
                                      borderRadius: BorderRadius.circular(15),
                                      image: DecorationImage(
                                          image: AssetImage(
                                              "${cardImages[index]['url']}"),
                                          fit: BoxFit.cover),
                                    ),
                                    child: Center(
                                        child: Container(
                                      child: Text(name,
                                          style: TextStyle(
                                              fontSize: 28,
                                              letterSpacing: 1.4,
                                              fontWeight: FontWeight.w500)),
                                    )),
                                  ),
                                ),
                              );
                            }),
                      ),
                      SizedBox(
                        height: 14,
                      ),
                      images.isEmpty
                          ? data != null
                              ? Container(
                                  height: 150,
                                  width: double.infinity,
                                  child: Center(
                                    child: Text(
                                      " \"$data\" Results Found",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                )
                              : Container(
                                  height: 150,
                                  width: double.infinity,
                                  child: Center(
                                    child: Text(
                                      'Search Results will show here!',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "   \"$data\" Results Found",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 4, right: 4),
                                    child: MasonryGridView.count(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: images.length,
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 4,
                                      crossAxisSpacing: 4,
                                      itemBuilder: (context, index) {
                                        return InkWell(
                                          onTap: () {
                                            Navigator.push(context,
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return DetailView(
                                                imageUrl: images[index]['src']
                                                    ['large2x'],
                                                photographer: images[index]
                                                    ['photographer'],
                                                originalImageUrl: images[index]
                                                    ['src']['original'],
                                              );
                                            }));
                                          },
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey,
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              child: Image.network(
                                                images[index]['src']['medium'],
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 12, top: 25),
                child: Container(
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: TextField(
                      autofocus: true,
                      controller: _searchField,
                      cursorColor: Colors.grey.shade700,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Find Wallpapers...',
                        hintStyle: TextStyle(
                            fontSize: 16, color: Colors.grey.shade500),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(
                            top: 15, bottom: 15, left: 20, right: 20),
                        suffixIcon: IconButton(
                          onPressed: () {
                            if (_searchField.text.isNotEmpty &&
                                _searchField.text[0] != " ") {
                              fetchSearchApi(_searchField.text.trim());
                            }
                          },
                          icon: Icon(Icons.search),
                          color: Colors.grey.shade700,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.arrow_back_ios,
                              size: 18,
                            ),
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
