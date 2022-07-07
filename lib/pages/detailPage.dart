import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wallpaper_manager_flutter/wallpaper_manager_flutter.dart';

class DetailView extends StatefulWidget {
  final String imageUrl;
  final String photographer;
  final String originalImageUrl;

  DetailView(
      {super.key,
      required this.imageUrl,
      required this.photographer,
      required this.originalImageUrl});

  @override
  State<DetailView> createState() => _DetailViewState();
}

class _DetailViewState extends State<DetailView> {
  Random random = new Random();

  Future<void> _setwallpaper() async {
    var file = await DefaultCacheManager().getSingleFile(widget.imageUrl);
    int location = WallpaperManagerFlutter.HOME_SCREEN;
    try {
      WallpaperManagerFlutter().setwallpaperfromFile(file, location);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Wallpaper updated'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error Setting Wallpaper'),
        ),
      );
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: (size.height),
                  width: (size.width),
                  child: CachedNetworkImage(
                    imageUrl: widget.imageUrl,
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(
                      color: Colors.white,
                    )),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 20,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 55,
                width: 55,
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.white),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back_ios),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            child: Container(
              width: (size.width),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: Colors.white,
                        ),
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(" Photographer"),
                          SizedBox(
                            height: 3,
                          ),
                          Container(
                            width: (size.width) * 0.53,
                            child: Text(
                              "${widget.photographer}",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.white,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.black.withOpacity(0.3)),
                        child: IconButton(
                          onPressed: () async {
                            String url = widget.originalImageUrl;
                            int randomNumber = random.nextInt(100000000);

                            final tempDir = await getTemporaryDirectory();
                            final path =
                                '${tempDir.path}/Wall-E_$randomNumber.jpg';

                            await Dio().download(url, path);
                            await GallerySaver.saveImage(path,
                                albumName: 'Flutter Wallpaper App');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Downloaded to Gallery!')),
                            );
                          },
                          icon: Icon(Icons.file_download),
                          iconSize: 38,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.white,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.black.withOpacity(0.3)),
                        child: IconButton(
                          onPressed: () {
                            _setwallpaper();
                          },
                          icon: Icon(Icons.brush),
                          iconSize: 38,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
