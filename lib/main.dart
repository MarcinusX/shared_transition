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
  bool isPageViewVisible = false;
  PageController _pageController = PageController();
  ScrollController _scrollController = ScrollController();
  AnimationController _animationController;
  Animation<Rect> rectAnimation;
  OverlayEntry transitionOverlayEntry;

  int get currentIndex => _pageController.page.round();

  @override
  void initState() {
    super.initState();
    transitionOverlayEntry = _createOverlayEntry();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        transitionOverlayEntry.remove();
      }
      if (status == AnimationStatus.completed) {
        _setPageViewVisible(true);
      } else if (status == AnimationStatus.reverse) {
        _setPageViewVisible(false);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  OverlayEntry _createOverlayEntry() {
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isPageViewVisible) {
          _hidePageView(currentIndex);
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Grid to Pager')),
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

  Widget _buildGridView() {
    return GridView.count(
      crossAxisCount: 2,
      controller: _scrollController,
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

  Widget _buildPageView() {
    PageView pageView = PageView.builder(
      controller: _pageController,
      itemCount: images.length,
      itemBuilder: (context, index) {
        return Center(
          child: RectGetter(
            key: pageKeys[index],
            child: Image.asset("assets/${images[index]}"),
          ),
        );
      },
    );

    return Opacity(
      opacity: isPageViewVisible ? 1 : 0,
      child: IgnorePointer(
        ignoring: !isPageViewVisible,
        child: pageView,
      ),
    );
  }

  void _showPageView(int index) async {
    _pageController.jumpToPage(index);
    await Future.delayed(Duration(milliseconds: 100));
    _startTransition(true);
  }

  void _hidePageView(int index) async {
    _scrollToIndex(index);
    await Future.delayed(Duration(milliseconds: 100));
    _startTransition(false);
  }

  void _startTransition(bool toPageView) {
    Rect gridRect = RectGetter.getRectFromKey(gridKeys[currentIndex]);
    Rect pageRect = RectGetter.getRectFromKey(pageKeys[currentIndex]);

    rectAnimation = RectTween(
      begin: gridRect,
      end: pageRect,
    ).animate(_animationController);

    Overlay.of(context).insert(transitionOverlayEntry);

    if (toPageView) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _setPageViewVisible(bool visible) {
    setState(() => isPageViewVisible = visible);
  }

  void _scrollToIndex(int index) {
    //find card height
    double deviceWidth = MediaQuery.of(context).size.width;
    double cardHeight = deviceWidth / 2;
    //find row we are looking for
    int row = index ~/ 2;
    row -= 1; // subtract 1 to have target row in the center of screen
    //calculate target offset
    double target = row * cardHeight;
    //normalize target
    target = math.max(
      _scrollController.position.minScrollExtent,
      math.min(
        target,
        _scrollController.position.maxScrollExtent,
      ),
    );
    //jump to target
    _scrollController.jumpTo(target);
  }
}
