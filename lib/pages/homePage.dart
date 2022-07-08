import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

import 'package:http/http.dart' as http;
import 'package:wallpaperflutter/pages/cardView.dart';
import 'package:wallpaperflutter/pages/detailPage.dart';
import 'package:wallpaperflutter/pages/searchPage.dart';
import 'package:wallpaperflutter/utils/cardImages.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List images = [];
  int? data;
  int page = 1;
  bool isLoading = false;

  @override
  void initState() {
    isLoaded = false;
    fetchApi();
    isLoaded = true;
    super.initState();
  }

  fetchApi() async {
    await http.get(Uri.parse("https://api.pexels.com/v1/curated?per_page=80"),
        headers: {
          'Authorization':
              '563492ad6f91700001000001abb5e548124b489eb9c74b6d44a7076e'
        }).then((value) {
      Map result = jsonDecode(value.body);

      setState(() {
        images = result['photos'];
      });

      print('fetching data');
    });
  }

  loadMore() async {
    print("using load more");
    setState(() {
      page = page + 1;
    });
    isLoading = true;

    String url =
        "https://api.pexels.com/v1/curated?per_page=80&page=" + page.toString();
    await http.get(Uri.parse(url), headers: {
      'Authorization':
          '563492ad6f91700001000001abb5e548124b489eb9c74b6d44a7076e'
    }).then((value) {
      Map result = jsonDecode(value.body);
      setState(() {
        images.addAll(result['photos']);
        isLoading = false;
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
                onEndOfPage: () => loadMore(),
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 110,
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
                                      borderRadius: BorderRadius.circular(15),
                                      image: DecorationImage(
                                          image: AssetImage(
                                              "${cardImages[index]['url']}"),
                                          fit: BoxFit.cover),
                                    ),
                                    child: Center(
                                        child: Container(
                                      child: Text(
                                        name,
                                        style: TextStyle(
                                          fontSize: 28,
                                          letterSpacing: 1.4,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    )),
                                  ),
                                ),
                              );
                            }),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      images.isEmpty
                          ? Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : Flexible(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 4, right: 4),
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
                                        borderRadius: BorderRadius.circular(15),
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
                      SizedBox(
                        height: 55,
                        child: isLoading
                            ? Container(
                                child: Center(
                                    child: CircularProgressIndicator(
                                color: Colors.white,
                              ),),)
                            : Container(
                                child: Center(child: Text("No More Data!"),),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const SearchPage();
                  }));
                },
                child: Padding(
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
                        enabled: false,
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
                            onPressed: () {},
                            icon: Icon(Icons.search),
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
