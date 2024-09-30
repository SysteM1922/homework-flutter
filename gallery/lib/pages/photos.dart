import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class PhotosPage extends StatefulWidget {
  const PhotosPage({super.key});

  @override
  State<PhotosPage> createState() => _PhotosPageState();
}

class _PhotosPageState extends State<PhotosPage> {
  int _axisCount = 3;
  int _axisIndex = 2;
  double _expandedHeight = 300.0;
  double _scale = 1.0;
  double _margin = 2.0;
  int range = 0;

  double _borderWidth = 0.5;
  Color _fillColor = Color.fromRGBO(128, 128, 128, 0.2);
  Color _borderColor = Color.fromRGBO(128, 128, 128, 0.61);

  List<int> states = [1, 2, 3, 4, 7, 15];
  List<double> margins = [3.0, 3.0, 3.0, 2.0, 1.0, 0.0];
  List<int> pageSize = [10, 20, 42, 80, 119, 210];

  bool _pinned = true;

  int totalMedia = 0;

  List<AssetEntityImage> media = [];
  List<AssetEntityImage> newMedia = [];

  List<AssetEntity> mediaList = [];

  AssetPathEntity? recent = AssetPathEntity(id: "none", name: "none");

  bool _getMediaLock = false;

  void _getTotalAssets() async {
    totalMedia = await recent!.assetCountAsync;

    log('Total media: $totalMedia');
  }

  void _getMedia() async {
    if (_getMediaLock) {
      return;
    } else {
      _getMediaLock = true;
    }

    log('Getting media from $range to ${range + pageSize[_axisIndex]}');

    if (range == 0) {
      mediaList = await recent!.getAssetListRange(
          start: range, end: range + pageSize[_axisIndex] + 50);
      range = range + pageSize[_axisIndex] * 2;
    } else {
      mediaList = await recent!
          .getAssetListRange(start: range, end: range + pageSize[_axisIndex]);
    }

    for (var asset in mediaList) {
      newMedia.add(AssetEntityImage(
        asset,
        fit: BoxFit.cover,
        isOriginal: false,
      ));
    }

    setState(() {
      media.addAll(newMedia);
      newMedia.clear();
      mediaList.clear();
      range = range + pageSize[_axisIndex];
      _getMediaLock = false;
    });
  }

  void _getAlbums() async {
    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      hasAll: true,
      onlyAll: true,
    );

    setState(() {
      recent = albums.first;
    });

    _getTotalAssets();

    _getMedia();
  }

  final ScrollController _scrollController = ScrollController(
    keepScrollOffset: true,
  );

  @override
  void initState() {
    super.initState();

    _getAlbums();

    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        setState(() {
          _pinned = false;
        });
        _getMedia();
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        setState(() {
          _pinned = true;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      // horizontal
      setState(() {
        _expandedHeight = 0.0;
        _axisCount = states[_axisIndex] + 2;
      });
    } else {
      // vertical
      setState(() {
        _expandedHeight = MediaQuery.of(context).size.height / 3;
        _axisCount = states[_axisIndex];
      });
    }

    if (_axisIndex == 5) {
      _borderWidth = 0.0;
      _fillColor = Colors.transparent;
      _borderColor = Colors.transparent;
    } else {
      _borderWidth = 0.5;
      _fillColor = Color.fromRGBO(128, 128, 128, 0.2);
      _borderColor = Color.fromRGBO(128, 128, 128, 0.61);
    }
  }

  void _updateAxisCount(double scale) {
    if (scale < 1.0) {
      // zoom out
      log('Zoom out');
      setState(() {
        if (_axisIndex < states.length - 1) {
          _axisIndex = _axisIndex + 1;
          _margin = margins[_axisIndex];
          didChangeDependencies();
        }
      });
    } else if (scale > 1.0) {
      // zoom in
      log('Zoom in');
      setState(() {
        if (_axisIndex > 0) {
          _axisIndex = _axisIndex - 1;
          _margin = margins[_axisIndex];
          didChangeDependencies();
        }
      });
    }
    _getMedia();
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
                          Text("Photos", style: TextStyle(color: Colors.white)),
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
                          return Container(
                            margin: EdgeInsets.all(_margin),
                            decoration: BoxDecoration(
                              color: _fillColor,
                              border: Border.all(
                                color:_borderColor,
                                width: _borderWidth,
                              ),
                            ),
                            child: (index < media.length) ? media[index] : null
                          );
                        },
                        childCount: media.length,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _axisCount,
                        crossAxisSpacing: 0.0,
                        mainAxisSpacing: 0.0,
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
