import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:http/http.dart' as http;
import 'package:wallpaperflutter/pages/detailPage.dart';

class CardView extends StatefulWidget {
  final String cardText;

  CardView({super.key, required this.cardText});

  @override
  State<CardView> createState() => _CardViewState();
}

class _CardViewState extends State<CardView> {
  List images = [];
  int? data;
  int page = 1;

  fetchSearchApi(String cardText) async {
    await http.get(
        Uri.parse(
            "https://api.pexels.com/v1/search?query=$cardText&per_page=80"),
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

  loadMore(String cardText) async {
    print("using load more");
    setState(() {
      page = page + 1;
    });

    String url =
        "https://api.pexels.com/v1/search?query=$cardText&per_page=80&page=" +
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

  @override
  void initState() {
    fetchSearchApi(widget.cardText);
    super.initState();
  }

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
                onEndOfPage: () => loadMore(widget.cardText),
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 100,
                      ),
                      SizedBox(
                        height: 14,
                      ),
                      images.isEmpty
                          ? Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
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
                padding: const EdgeInsets.only(left: 8, right: 8, top: 30),
                child: Container(
                  height: 60,
                  width: double.infinity,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 8,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.white),
                            borderRadius: BorderRadius.circular(14)),
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.arrow_back_ios_new),
                          iconSize: 35,
                        ),
                      ),
                      SizedBox(
                        width: 18,
                      ),
                      Text(
                        widget.cardText,
                        style: TextStyle(
                          fontSize: 45,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ],
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
