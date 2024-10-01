import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gallery/pages/album_page.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class AlbumsPage extends StatefulWidget {
  const AlbumsPage({super.key});

  @override
  State<AlbumsPage> createState() => _AlbumsPageState();
}

class _AlbumsPageState extends State<AlbumsPage> {
  bool _firstLoad = true;
  int _axisIndex = 0;
  int _maxAxisCount = 4;
  int _minAxisCount = 2;
  int _axisCount = 2;
  double _expandedHeight = 300.0;
  double _scale = 1.0;
  double _childAspectRatio = 0.8;

  bool _pinned = true;

  List<AssetPathEntity> albums = [];
  List<AssetEntityImage> albumCovers = [];
  List<int> albumSizes = [];

  Future<void> _requestAssets() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();

    if (!ps.isAuth) {
      log('Permission is not granted');
      exit(0);
    }

    _getMedia();
  }

  final ScrollController _scrollController = ScrollController(
    keepScrollOffset: true,
  );

  void _getAlbumSize(int index) async {
    int size = await albums[index].assetCountAsync;

    if (!mounted) {
      return;
    }
    setState(() {
      albumSizes[index] = size;
    });
  }

  void _getMedia() async {
    albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      hasAll: false,
      onlyAll: false,
    );

    albums.sort((a, b) => a.name.compareTo(b.name.toUpperCase()));

    for (final AssetPathEntity album in albums) {
      List<AssetEntity> media = await album.getAssetListRange(
        start: 0,
        end: 1,
      );

      if (!mounted) {
        return;
      }
      setState(() {
        albumCovers.add(AssetEntityImage(
          media[0],
          fit: BoxFit.cover,
          isOriginal: true,
        ));
        albumSizes.add(0);
      });

      _getAlbumSize(albums.indexOf(album));
    }
  }

  @override
  void initState() {
    super.initState();

    _requestAssets();

    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_pinned) {
          setState(() {
            _pinned = false;
          });
        }
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!_pinned) {
          setState(() {
            _pinned = true;
          });
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      // horizontal
      setState(() {
        _maxAxisCount = 6;
        _minAxisCount = 4;
        _expandedHeight = 0.0;

        if (_firstLoad) {
          _axisCount = _axisIndex + _minAxisCount;
          _firstLoad = false;
        } else {
          if (_axisCount != 1) {
            _axisCount = _minAxisCount + _axisIndex;
            _childAspectRatio = 0.8;
          } else {
            _childAspectRatio = (1 / .1);
          }
        }
      });
    } else {
      // vertical
      setState(() {
        _maxAxisCount = 4;
        _minAxisCount = 2;
        _expandedHeight = MediaQuery.of(context).size.height / 3;

        if (_firstLoad) {
          _axisCount = _minAxisCount + _axisIndex;
          _firstLoad = false;
        } else {
          if (_axisCount != 1) {
            _axisCount = _minAxisCount + _axisIndex;
            _childAspectRatio = 0.8;
          } else {
            _childAspectRatio = (1 / .2);
          }
        }
      });
    }
  }

  void _updateAxisCount(double scale) {
    if (scale < 1.0) {
      // zoom out
      log('Zoom out');
      setState(() {
        if (_axisCount != 1 && _axisCount < _maxAxisCount) {
          _axisIndex = _axisIndex + 1;
          _axisCount = _minAxisCount + _axisIndex;
        }
        if (_axisCount == _maxAxisCount || _axisCount == 1) {
          _axisCount = 1;
          if (MediaQuery.of(context).orientation == Orientation.portrait) {
            _childAspectRatio = (1 / .2);
          } else {
            _childAspectRatio = (1 / .1);
          }
        }
      });
    } else if (scale > 1.0) {
      // zoom in
      log('Zoom in');
      setState(() {
        _childAspectRatio = 0.8;
        if (_axisCount == 1) {
          _axisIndex = _axisIndex - 1;
          _axisCount = _minAxisCount + _axisIndex;
        } else if (_axisCount > _minAxisCount) {
          _axisIndex = _axisIndex - 1;
          _axisCount = _minAxisCount + _axisIndex;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onScaleUpdate: (details) {
          setState(() {
            _scale = details.scale;
          });
        },
        onScaleEnd: (details) {
          _updateAxisCount(_scale);
        },
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                cacheExtent: 10000.0,
                physics: const BouncingScrollPhysics(),
                controller: _scrollController,
                slivers: <Widget>[
                  SliverAppBar(
                    backgroundColor: Colors.black,
                    floating: false,
                    pinned: _pinned,
                    snap: false,
                    expandedHeight: _expandedHeight,
                    flexibleSpace: FlexibleSpaceBar(
                      title:
                          Text("Albums", style: TextStyle(color: Colors.white)),
                      titlePadding: const EdgeInsets.only(bottom: 100.0),
                      centerTitle: true,
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(10.0),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        addRepaintBoundaries: false,
                        (BuildContext context, int index) {
                          if (_axisCount == 1) {
                            return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AlbumPage(
                                                album: albums[index],
                                              )));
                                },
                                child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Row(children: [
                                      Flex(
                                        direction: Axis.horizontal,
                                        children: [
                                          AspectRatio(
                                            aspectRatio: 1.0,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color.fromRGBO(
                                                      128, 128, 128, 0.61),
                                                  width: 1.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                                child:
                                                    index < albumCovers.length
                                                        ? albumCovers[index]
                                                        : null,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        margin:
                                            const EdgeInsets.only(left: 20.0),
                                        child: Flex(
                                          direction: Axis.vertical,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              albums[index].name,
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            Text(
                                              '${index < albumSizes.length ? albumSizes[index] : 0}',
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                color: Color.fromRGBO(
                                                    128, 128, 128, 1),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ])));
                          } else {
                            return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              AlbumPage(album: albums[index])));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Flex(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    direction: Axis.vertical,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AspectRatio(
                                        aspectRatio: 1,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Color.fromRGBO(
                                                  128, 128, 128, 0.61),
                                              width: 1.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                            child: index < albumCovers.length
                                                ? albumCovers[index]
                                                : null,
                                          ),
                                        ),
                                      ),
                                      Flex(
                                        direction: Axis.vertical,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            albums[index].name,
                                            textAlign: TextAlign.left,
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          Text(
                                            '${index < albumSizes.length ? albumSizes[index] : 0}',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              color: Color.fromRGBO(
                                                  128, 128, 128, 1),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ));
                          }
                        },
                        childCount: albums.length,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _axisCount,
                        crossAxisSpacing: 0.0,
                        mainAxisSpacing: 0.0,
                        childAspectRatio: _childAspectRatio,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
