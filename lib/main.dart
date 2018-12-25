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
  Animation<Rect> rectAnimation;
  OverlayEntry currentOverlayEntry;

  int get currentIndex => _pageController.page.round();

  bool get isPageViewVisible => _animationController.isCompleted;

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
    });
    currentOverlayEntry = _initOverlay();
  }

  _scrollToIndex(int index) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double cardHeight = deviceWidth / 2;
    double target = index ~/ 2 * cardHeight;
    target = target - cardHeight; //to center it
    _scrollController.jumpTo(
      math.max(
        _scrollController.position.minScrollExtent,
        math.min(
          target,
          _scrollController.position.maxScrollExtent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isPageViewVisible) {
          _showGridView();
        }
        return !isPageViewVisible;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Grid to Pager'),
        ),
        body: Stack(
          children: <Widget>[
            _buildGridView(),
            _buildWhiteCurtain(),
            _buildPageView(),
          ],
        ),
      ),
    );
  }

  AnimatedBuilder _buildWhiteCurtain() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return _animationController.isDismissed
            ? Container()
            : Positioned.fill(
                child: Opacity(
                  opacity: _animationController.value,
                  child: Container(color: Colors.white),
                ),
              );
      },
    );
  }

  Widget _buildPageView() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: isPageViewVisible ? 1 : 0,
          child: IgnorePointer(
            ignoring: !isPageViewVisible,
            child: child,
          ),
        );
      },
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

  _showPageView(int index) async {
    _pageController.jumpToPage(index);
    await Future.delayed(Duration(milliseconds: 100));
    _startTransition(true);
  }

  void _startTransition(bool toPageView) {
    Rect gridRect = RectGetter.getRectFromKey(gridKeys[currentIndex]);
    Rect pageRect = RectGetter.getRectFromKey(pageKeys[currentIndex]);

    rectAnimation =
        RectTween(begin: gridRect, end: pageRect).animate(_animationController);

    Overlay.of(context).insert(currentOverlayEntry);

    if (toPageView) {
      _animationController.forward(from: 0.0);
    } else {
      _animationController.reverse(from: 1.0);
    }
  }

  OverlayEntry _initOverlay() {
    return OverlayEntry(
      builder: (context) {
        return AnimatedBuilder(
          animation: rectAnimation,
          builder: (context, child) {
            return Positioned(
              top: rectAnimation.value.top,
              left: rectAnimation.value.left,
              child: Image.asset(
                "assets/${images[currentIndex]}",
                height: rectAnimation.value.height,
                width: rectAnimation.value.width,
              ),
            );
          },
        );
      },
    );
  }
}
