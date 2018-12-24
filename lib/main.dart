import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rect_getter/rect_getter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

List<String> images = [
  'animal.jpg',
  'beetle.jpg',
  'bug.jpg',
  'butterfly_1.jpg',
  'butterfly_dolls.jpg',
  'dragonfly_1.jpg',
  'dragonfly_2.jpg',
  'dragonfly_3.jpg',
  'grasshopper.jpg',
  'hover_fly.jpg',
  'hoverfly.jpg',
  'insect.jpg',
  'morpho.jpg',
  'nature.jpg'
];

List gridKeys =
    List.generate(images.length, (i) => RectGetter.createGlobalKey());
List pageKeys =
    List.generate(images.length, (i) => RectGetter.createGlobalKey());

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  PageController _pageController = PageController();
  ScrollController _scrollController = ScrollController();
  AnimationController _animationController;
  bool showGriView = true;
  OverlayEntry currentOverlayEntry;

  int get currentIndex => _pageController.page.round();

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        currentOverlayEntry?.remove();
      }
      if (status == AnimationStatus.completed) {
        setState(() => showGriView = false);
      }
      if (status == AnimationStatus.reverse) {
        setState(() => showGriView = true);
      }
    });
  }

  _scrollToIndex(int index) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double cardHeight = deviceWidth / 2;
    double target = index ~/ 2 * cardHeight;
    target = target - cardHeight; //to center it
    _scrollController.jumpTo(math.max(
        _scrollController.position.minScrollExtent,
        math.min(target, _scrollController.position.maxScrollExtent)));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (showGriView) {
          return true;
        } else {
          _showGridView();
          return false;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Grid to Pager'),
        ),
        body: Stack(
          children: <Widget>[
            _buildGridView(),
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) => _animationController.isDismissed
                  ? Container()
                  : Positioned.fill(
                      child: Opacity(
                        opacity: _animationController.value,
                        child: Container(color: Colors.white),
                      ),
                    ),
            ),
            _buildPageView(),
          ],
        ),
      ),
    );
  }

  Widget _buildPageView() {
    return Opacity(
      opacity: showGriView ? 0 : 1,
      child: IgnorePointer(
        ignoring: showGriView,
        child: PageView.builder(
          itemCount: images.length,
          controller: _pageController,
          itemBuilder: (context, index) {
            return Center(
              child: RectGetter(
                key: pageKeys[index],
                child: Image.asset("assets/${images[index]}"),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.count(
      controller: _scrollController,
      crossAxisCount: 2,
      children: images.map((imageName) {
        int index = images.indexOf(imageName);
        return GestureDetector(
          onTap: () => _showPageView(index),
          child: Card(
            child: Center(
              child: RectGetter(
                key: gridKeys[index],
                child: Image.asset("assets/$imageName"),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  _showGridView() async {
    _scrollToIndex(_pageController.page.round());
    await Future.delayed(Duration(milliseconds: 100));
    _startTransition(false);
  }

  void _startTransition(bool toPageView) {
    Rect gridRect = RectGetter.getRectFromKey(gridKeys[currentIndex]);
    Rect pageRect = RectGetter.getRectFromKey(pageKeys[currentIndex]);

    Animation<Rect> animation =
        RectTween(begin: gridRect, end: pageRect).animate(_animationController);

    currentOverlayEntry = OverlayEntry(builder: (context) {
      return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) => Positioned(
              top: animation.value.top,
              left: animation.value.left,
              child: Image.asset(
                "assets/${images[currentIndex]}",
                height: animation.value.height,
                width: animation.value.width,
              ),
            ),
      );
    });

    Overlay.of(context).insert(currentOverlayEntry);

    if (toPageView) {
      _animationController.forward(from: 0.0);
    } else {
      _animationController.reverse(from: 1.0);
    }
  }

  _showPageView(int index) async {
    _pageController.jumpToPage(index);
    await Future.delayed(Duration(milliseconds: 100), () {});
    _startTransition(true);
  }
}