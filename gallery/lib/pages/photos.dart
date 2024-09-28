import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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

  List states = [1, 2, 3, 4, 7, 15];
  List margins = [3.0, 3.0, 3.0, 2.0, 1.0, 0.0];

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
                        (BuildContext context, int index) {
                          return Container(
                            margin: EdgeInsets.all(_margin),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                              ),
                            ),
                          );
                        },
                        childCount: 200,
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
