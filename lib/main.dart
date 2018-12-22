import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
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

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PageController _pageController = PageController();
  ScrollController _scrollController = ScrollController();
  bool showGriView = true;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      _scrollToIndex(_pageController.page.round());
    });
    _scrollController.addListener(() {
//      print(_scrollController.offset);
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
            title: Text('asd'),
          ),
          body: Stack(
            children: <Widget>[
              _buildGridView(),
              _buildPageView(),
            ],
          )),
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
            return Image.asset("assets/${images[index]}");
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
        return GestureDetector(
          onTap: () => _showPageView(images.indexOf(imageName)),
          child: Card(
            child: Image.asset("assets/$imageName"),
          ),
        );
      }).toList(),
    );
  }

  _showGridView() {
    setState(() {
      showGriView = true;
    });
  }

  _showPageView(int index) {
    _pageController.jumpToPage(index);
    setState(() {
      showGriView = false;
    });
  }
}
