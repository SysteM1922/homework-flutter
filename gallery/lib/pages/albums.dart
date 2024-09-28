import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gallery/pages/album_page.dart';

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

  final ScrollController _scrollController = ScrollController(
    keepScrollOffset: true,
  );

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        setState(() {
          _pinned = false;
        });
      }
      if (_scrollController.position.userScrollDirection ==
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
                        (BuildContext context, int index) {
                          if (_axisCount == 1) {
                            return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              AlbumPage(name: 'Album $index')));
                                },
                                child: Container(
                                    color: Colors.black,
                                    margin: const EdgeInsets.all(5.0),
                                    child: Row(children: [
                                      Flex(
                                        direction: Axis.horizontal,
                                        children: [
                                          AspectRatio(
                                              aspectRatio: 1.0,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[300],
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                ),
                                              )),
                                        ],
                                      ),
                                      Container(
                                        margin:
                                            const EdgeInsets.only(left: 20.0),
                                        child: Text(
                                            style:
                                                TextStyle(color: Colors.white),
                                            'Album $index'),
                                      ),
                                    ])));
                          } else {
                            return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              AlbumPage(name: 'Album $index')));
                                },
                                child: Container(
                                  color: Colors.black,
                                  margin: const EdgeInsets.all(5.0),
                                  child: Column(
                                    children: [
                                      AspectRatio(
                                        aspectRatio: 1.0,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(top: 5.0),
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Album $index',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ));
                          }
                        },
                        childCount: 9,
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
