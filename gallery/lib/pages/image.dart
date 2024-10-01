import 'dart:math' show min;
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gallery/pages/map.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImagePage extends StatefulWidget {
  final int imageIndex;
  final AssetPathEntity album;
  final int albumSize;
  final List<AssetEntity> images;

  const ImagePage(
      {super.key,
      required this.images,
      required this.imageIndex,
      required this.albumSize,
      required this.album});

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  List<AssetEntity> images = [];
  List<AssetEntity> mediaList = [];
  AssetPathEntity album = AssetPathEntity(id: "none", name: "none");
  int albumSize = 0;

  bool _getMediaLock = false;

  bool _isAppBarVisible = true;

  bool _isHalfScreen = false;

  final latlong2.LatLng _center = latlong2.LatLng(39.8239, -7.49189);

  final PhotoViewController _photoViewController = PhotoViewController();

  void _getMedia(index) async {
    if (_getMediaLock) {
      return;
    } else {
      _getMediaLock = true;
    }

    log("Trying to get media from ${index + 3} to ${min<int>(index + 4, albumSize)}");

    if (index + 3 < images.length || index > albumSize - 2) {
      _getMediaLock = false;
      return;
    }

    mediaList = await album.getAssetListRange(
        start: min(index + 3, images.length), end: min(index + 4, albumSize));

    if (!mounted) {
      return;
    }

    setState(() {
      ++index;
      images.addAll(mediaList);
    });

    _getMediaLock = false;
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      album = widget.album;
      images = widget.images;
      albumSize = widget.albumSize;
    });

    _getMedia(widget.imageIndex);
  }

  @override
  Widget build(BuildContext context) {
    double halfHeight = MediaQuery.of(context).size.height / 2;

    return GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.primaryDelta! < -10) {
            setState(() {
              _isHalfScreen = true;
            });
          } else if (details.primaryDelta! > 10) {
            setState(() {
              _isHalfScreen = false;
            });
          }
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Column(
            children: [
              Stack(children: [
                Container(
                  color: Colors.black,
                  height: _isHalfScreen ? halfHeight : halfHeight * 2,
                  child: PhotoViewGallery.builder(
                      loadingBuilder: (context, event) => const Center(
                            child:
                                CircularProgressIndicator(color: Colors.white),
                          ),
                      itemCount: images.length,
                      pageController:
                          PageController(initialPage: widget.imageIndex),
                      builder: (context, index) {
                        return PhotoViewGalleryPageOptions(
                          imageProvider:
                              AssetEntityImageProvider(images[index]),
                          initialScale: PhotoViewComputedScale.contained,
                          basePosition: Alignment.center,
                          minScale: PhotoViewComputedScale.contained,
                          controller: _photoViewController,
                          onTapDown: (context, details, controllerValue) {
                            if (_isAppBarVisible) {
                              SystemChrome.setEnabledSystemUIMode(
                                  SystemUiMode.manual,
                                  overlays: [SystemUiOverlay.top]);
                            } else {
                              SystemChrome.setEnabledSystemUIMode(
                                  SystemUiMode.edgeToEdge);
                            }
                            setState(() {
                              _isAppBarVisible = !_isAppBarVisible;
                            });
                          },
                        );
                      },
                      scrollPhysics: const BouncingScrollPhysics(),
                      onPageChanged: (index) {
                        setState(() {});
                        _getMedia(index);
                      }),
                ),
                if (_isAppBarVisible)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: AppBar(
                      iconTheme: const IconThemeData(color: Colors.white),
                      backgroundColor: Colors.black.withOpacity(0.2),
                    ),
                  ),
              ]),
              if (_isHalfScreen)
                Container(
                  height: halfHeight,
                  alignment: Alignment.topCenter,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                  ),
                  child: FractionallySizedBox(
                    heightFactor: 0.5,
                    child: Container(
                      padding: const EdgeInsets.all(40.0),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.all(
                          Radius.circular(20.0),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          log("Opening map");
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MapPage(marker: _center),
                              ));
                        },
                        child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20.0)),
                            child: FlutterMap(
                              options: MapOptions(
                                initialZoom: 14.0,
                                interactionOptions: const InteractionOptions(
                                  flags: InteractiveFlag.none, 
                                ),
                                onTap: (tapPosition, point) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MapPage(marker: _center),
                                      ));
                                },
                                initialCenter: _center,
                              ),
                              children: <Widget>[
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  maxZoom: 19,
                                  minZoom: 2,
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      width: 80.0,
                                      point: _center,
                                      child: const Icon(
                                        Icons.location_on,
                                        color: Colors.red,
                                        size: 50.0,
                                      ),
                                      alignment: Alignment(0.0, -2.0)
                                    ),
                                  ],
                                ),
                              ],
                            )),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ));
  }
}
