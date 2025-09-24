import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pikachu/app_assets.dart';

//import 'package:word_puzzle/words_helper.dart';
import 'package:pikachu/database_helper.dart';
import 'package:flutter/widgets.dart';
import 'dart:math';
import 'dart:async';

import 'package:pikachu/imagehelper.dart';

import 'ad_manager.dart';
import 'ads/app_lifecircle_factory.dart';
import 'ads/open_app_ads_manage.dart';
import 'dimens.dart';

class Todo {
  final String title;
  final String description;

  Todo(this.title, this.description);
}

void initAds() async{
  await MobileAds.instance.initialize();
}

void main(){
  WidgetsFlutterBinding.ensureInitialized();
  FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
  FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
  initAds();
  runApp(MaterialApp(
    title: 'Word Puzzle',
    home: SelectWidget(),
    debugShowCheckedModeBanner: false,
  ));
}

class SelectWidget extends StatefulWidget {
  SelectWidget({Key? key}) : super(key: key);

  @override
  _SelectWidgetState createState() => _SelectWidgetState();
}

double deviceWidth = 0.0;

class _SelectWidgetState extends State<SelectWidget> {
  List<ACategory>? categories;
  List<List<AWord>> allWords = [];
  List<Color> colorList = [];
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;

  getHeightWidth(context) {
    deviceWidth = MediaQuery.of(context).size.width;
  }

  _navigateAndDisplaySelection(BuildContext context, int index) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => GameWidget(
              category: categories![index].category ?? '',
              words: allWords[index],
              bestTime: categories![index].time ?? '')),
    );
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    initAds();
    _loadInterstitialAd();
    super.initState();
  }

  initAds() {
    BannerAd(
      adUnitId: AdManager.bannerAdUnitId,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          ad.dispose();
        },
      ),
    ).load();
  }


  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdManager.interstitialAdUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              //kakak
            },
          );

          setState(() {
            _interstitialAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
          print('Failed to load an interstitial ad: ${err.message}');
        },
      ),
    );
  }

  @override
  void dispose() {
    // TODO: Dispose a BannerAd object
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Dimens.init(context);
    getHeightWidth(context);
    return FutureBuilder(
      future: _initializeDatabase(), // function where you call your api
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        // AsyncSnapshot<Your object type>
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Scaffold(
              body: Column(children: [
                // if (_bannerAd != null)
                  const SizedBox(height: kToolbarHeight,),
                // if (_bannerAd != null)
                //   Align(
                //     alignment: Alignment.topCenter,
                //     child: SizedBox(
                //       width: _bannerAd!.size.width.toDouble(),
                //       height: _bannerAd!.size.height.toDouble(),
                //       child: AdWidget(ad: _bannerAd!),
                //     ),
                //   ),
                Expanded(child: ListView.builder(
                  itemCount: categories!.length,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    return Container(
                        height: 100,
                        color: Colors.white,
                        child: Card(
                          child: InkWell(
                            onTap: () {
                              // if(_interstitialAd != null){
                              //   _interstitialAd?.show();
                              //   _navigateAndDisplaySelection(context, index);
                              // }else{
                              //   _navigateAndDisplaySelection(context, index);
                              // }
                              _navigateAndDisplaySelection(context, index);
                            },
                            hoverColor: Colors.blue,
                            child: Container(
                              margin:
                              const EdgeInsets.only(left: 3.0, right: 3.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: colorList[index % colorList.length],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Row(children: <Widget>[
                                      Text(categories![index].category ?? '',
                                          style: const TextStyle(
                                            fontSize: 25.0,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ))
                                    ]),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            const Icon(IconData(57746,fontFamily: 'MaterialIcons'),
                                                color: Colors.white),
                                            const Text("   "),
                                            Text(categories![index].time ?? '',
                                                style: const TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.white)),
                                          ],
                                        ),
                                        Row(
                                          children: <Widget>[
                                            const Icon(IconData(58683, fontFamily: 'MaterialIcons'),
                                                color: Colors.white),
                                            Text(
                                                allWords[index].length.toString(),
                                                style: const TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.white)),
                                            const Text("   "),
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ));
                  },
                ))
              ],) ,
            );
          }
        }
      },
    );
  }

  Future _initializeDatabase() async {
    DatabaseHelper helper = DatabaseHelper.instance;
    await helper.initializeDatabase();
    int ccount = await helper.getCategoryCount();
    int wcount = await helper.getAllWordsCount();
    categories = await helper.getAllCategories();

    colorList.add(Colors.deepOrange[400]!);
    colorList.add(Colors.orangeAccent[400]!);
    colorList.add(Colors.purpleAccent[400]!);
    colorList.add(Colors.redAccent[400]!);
    colorList.add(Colors.lightGreen[900]!);
    colorList.add(Colors.indigoAccent);
    colorList.add(Colors.redAccent[400]!);

    for (int i = 0; i < (categories?.length ?? 0); i++) {
      allWords.add(await helper.getWords(categories![i].category ?? ''));
    }
    print("Database Loaded..  CCount : [$ccount]  WCount[$wcount]");
  }
}

List<List<String>> gridMap = [];
double gridSize = 20.0;
List<Point> touchItems = [];

List<List<Point>> foundMap = [];
List<Color> foundColor = [];
List<String> foundWords = [];

class GameWidget extends StatefulWidget {
  final String? category;
  final List<AWord>? words;
  final String? bestTime;

  GameWidget(
      {Key? key,
      @required this.category,
      @required this.words,
      @required this.bestTime})
      : super(key: key);

  @override
  _GameWidgetState createState() => _GameWidgetState();
}

class _GameWidgetState extends State<GameWidget> {

  int? gridW;
  int? gridH;
  List<String> wordsList = [];

  Size? panSize;

  double x = 0.0;
  double y = 0.0;
  int timeElapsed = 10;

  GlobalKey _keyRed = GlobalKey();
  bool? validTouchFlag;

  static const duration = const Duration(seconds: 1);
  int secondsPassed = 0;
  bool isActive = false;
  Timer? timer;


  void handleTick() {
    setState(() {
      secondsPassed = secondsPassed + 1;
    });
  }

  void finishGame() {
    DatabaseHelper helper = DatabaseHelper.instance;
    helper.updateBestTime(widget.category ?? '', secondsPassed);
    timer?.cancel();

    // _interstitialAd?.show();
    Navigator.pop(
        context, ACategory.withTime(widget.category, secondsPassed.toString()));
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Congratulations!"),
          content: Text(
              "Your Score is ${secondsPassed ~/ 60} m ${secondsPassed % 60} s"),
        ));
  }

  void _incrementDown(PointerEvent details) {
    _updateLocation(details);
//    finishGame();
    setState(() {
      touchItems.clear();
      validTouchFlag = true;
    });
  }

  void _incrementUp(PointerEvent details) {
    _updateLocation(details);
    String selectedStr = "";
    touchItems.forEach((element) {
      selectedStr = selectedStr + gridMap[element.y.toInt()][element.x.toInt()];
    });
    if (wordsList.contains(selectedStr) && !foundWords.contains(selectedStr)) {
      foundMap.add(List<Point>.generate(
          touchItems.length, (index) => touchItems[index]));
      foundColor.add(Color.fromARGB(100, Random().nextInt(255),
          Random().nextInt(255), Random().nextInt(255)));
      foundWords.add(selectedStr);

      if (foundWords.length == wordsList.length) finishGame();
    }
    touchItems.clear();
  }

  void _updateLocation(PointerEvent details) {
    if (validTouchFlag == true) {
      setState(() {
        x = details.position.dx - _getPositions().dx;
        y = details.position.dy - _getPositions().dy;

        int itemX = x ~/ gridSize;
        int itemY = y ~/ gridSize;
        if (!touchItems.contains(Point(itemX, itemY)) &&
            itemX >= 0 &&
            itemX < (gridW ?? 0) &&
            itemY >= 0 &&
            itemY < (gridH ?? 0)) {
          Offset itemPos = Offset(
              itemX * gridSize + gridSize / 2, itemY * gridSize + gridSize / 2);
          Offset touchPos = Offset(x, y);
          if ((itemPos - touchPos).distance <
              gridSize / 2.5) if (touchItems.length < 2) {
            touchItems.add(Point(itemX, itemY));
          } else {
            if (itemX + touchItems[touchItems.length - 2].x ==
                    touchItems[touchItems.length - 1].x * 2 &&
                itemY + touchItems[touchItems.length - 2].y ==
                    touchItems[touchItems.length - 1].y * 2) {
              touchItems.add(Point(itemX, itemY));
            }
          }
        }
      });
    }
  }

  Offset _getPositions() {
    final RenderBox renderBox =
        _keyRed.currentContext!.findRenderObject() as RenderBox;
    Offset position = renderBox.localToGlobal(Offset.zero);
    return position;
  }
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    foundMap.clear();
    foundColor.clear();
    foundWords.clear();
    touchItems.clear();
    _loadInterstitialAd();
    AppOpenAdManager appOpenAdManager = AppOpenAdManager()..loadAd();
    AppLifecycleReactor(appOpenAdManager: appOpenAdManager)
        .listenToAppStateChanges();
    _initializeGame();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdManager.interstitialAdUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              //kakak
            },
          );

          setState(() {
            _interstitialAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
          print('Failed to load an interstitial ad: ${err.message}');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    timer ??= Timer.periodic(duration, (Timer t) {
      handleTick();
    });

    int seconds = secondsPassed % 60;
    int minutes = secondsPassed ~/ 60;
    return Scaffold(
      body: Stack(
        children: [
          ImageHelper.loadFromAsset(AppAssets.imgBacground,
              fit: BoxFit.cover,
              width: Dimens.screenWidth,
              height: Dimens.screenHeight),
          Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Center(
                  child: Container(
                      alignment: Alignment.topRight,
                      margin: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              width: 100,
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.cyan[800]),
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    const Text('Time',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 5,),
                                    Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Colors.yellow[700]),
                                        child: Text(
                                          //'$timeElapsed',
                                          "${minutes < 10 ? '0$minutes' : minutes}:${seconds < 10 ? '0$seconds' : seconds}",
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        )),
                                  ])),
                          Container(
                              width: 100,
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.cyan[800]),
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    const Text('Best Time',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(height: 5,),
                                    Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Colors.yellow[700]),
                                        child: Text(
                                          '${widget.bestTime}',
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        )),
                                  ])),
                        ],
                      )),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Listener(
                      onPointerDown: _incrementDown,
                      onPointerMove: _updateLocation,
                      onPointerUp: _incrementUp,
                      child: Column(children: <Widget>[
                        Container(
                          width: panSize?.width,
                          height: panSize?.height,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.cyan[200]),
                          //color: Colors.white,
                          child: CustomPaint(
                              painter: CharacterMapPainter(), key: _keyRed),
                        ),
                      ])),
                ),
                Container(
                    decoration: BoxDecoration(
                        color: const Color(0XFF672C19).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16)),
                    width: deviceWidth * 0.9,
                    height: (wordsList.length * 11).toDouble(),
                    child: GridView.count(
                      primary: false,
                      padding: const EdgeInsets.all(5),
                      crossAxisCount: 3,
                      childAspectRatio: 3.8,
                      children: wordsList
                          .map((data) => Container(
                              decoration: BoxDecoration(
                                  color: foundWords.contains(data)
                                      ? const Color(0XFFCFA56F)
                                      : const Color(0XFF35120F)
                                          .withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(16)),
                              margin: const EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 5),
                              child: Center(
                                  child: Text(data,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: foundWords.contains(data)
                                            ? const Color(0XFF4E230C)
                                            : const Color(0XFFE9C292),
                                      ),
                                      textAlign: TextAlign.center))))
                          .toList(),
                    )),
              ])
        ],
      ),
      // Inner yellow container
      /*child: */
    );
  }

  void _initializeGame() {
    gridH = 15;
    gridW = 15;
    gridSize = (deviceWidth - 20) / (gridW?.toInt() ?? 1);
    //print(wi;

    gridMap = List<List<String>>.generate(
        gridH ?? 0, (i) => List<String>.generate(gridW ?? 0, (j) => ""));
    panSize = Size((gridW?.toDouble() ?? 0) * gridSize,
        (gridH?.toDouble() ?? 0) * gridSize);
    wordsList = List<String>.generate(
        widget.words!.length, (index) => widget.words![index].word ?? '');
    wordsList.sort((b, a) => a.length.compareTo(b.length));
    var random = Random();
    if (wordsList.length == 0) return;
    var first = generate(random.nextInt(8), wordsList[0]);
    Point pt = Point(random.nextInt((gridW ?? 0) - first.first.length + 1),
        random.nextInt((gridH ?? 0) - first.length + 1));
    putOnGrid(first, pt);
    for (int wi = 1; wi < wordsList.length; wi++) {
      int dir;
      checkFound:
      for (dir = 0; dir < 8; dir++) {
        //find if words match exist
        var piece = generate(dir, wordsList[wi]);
        for (int i = 0; i < (gridH ?? 0) - piece.length; i++)
          for (int j = 0; j < (gridW ?? 0) - piece.first.length; j++) {
            int matchCharCount = 0, dismatchCharCount = 0;
            for (int ii = 0; ii < piece.length; ii++)
              for (int jj = 0; jj < piece.first.length; jj++) {
                if (piece[ii][jj] == gridMap[i + ii][j + jj] &&
                    piece[ii][jj] != "") {
                  matchCharCount++;
                } else if (piece[ii][jj] != gridMap[i + ii][j + jj] &&
                    gridMap[i + ii][j + jj] != "") {
                  dismatchCharCount++;
                }
              }
            if (matchCharCount > 0 && dismatchCharCount == 0) {
              putOnGrid(piece, Point(j, i));
              break checkFound;
            }
          }
      }
      if (dir == 8) {
        putAsAnother:
        while (true) {
          var piece = generate(random.nextInt(8), wordsList[wi]);
          int i = random.nextInt((gridH ?? 0) - piece.length);
          int j = random.nextInt((gridW ?? 0) - piece.first.length);
          int matchCharCount = 0;
          for (int ii = 0; ii < piece.length; ii++)
            for (int jj = 0; jj < piece.first.length; jj++) {
              if (gridMap[i + ii][j + jj] != "") matchCharCount++;
            }
          if (matchCharCount == 0) {
            putOnGrid(piece, Point(j, i));
            break putAsAnother;
          }
        }
      }
    }

    String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    for (int i = 0; i < gridMap.length; i++)
      for (int j = 0; j < gridMap[i].length; j++) {
        if (gridMap[i][j] == "") gridMap[i][j] = chars[random.nextInt(26)];
      }
  }

  void putOnGrid(List<List<String>> piece, Point pt) {
    for (int i = 0; i < piece.length; i++)
      for (int j = 0; j < piece[i].length; j++) {
        gridMap[pt.y.toInt() + i][pt.x.toInt() + j] = piece[i][j];
      }
  }

  List<List<String>> generate(int direction, String aword) {
    List<List<String>> grid = [[]];
    if (direction == 0) {
      grid = List<List<String>>.generate(
          1, (i) => List<String>.generate(aword.length, (j) => aword[j]));
    } else if (direction == 1) {
      grid = List<List<String>>.generate(
          aword.length,
          (i) => List<String>.generate(
              aword.length, (j) => i == j ? aword[i] : ""));
    } else if (direction == 2) {
      grid = List<List<String>>.generate(
          aword.length, (i) => List<String>.generate(1, (j) => aword[i]));
    } else if (direction == 3) {
      grid = List<List<String>>.generate(
          aword.length,
          (i) => List<String>.generate(
              aword.length, (j) => i + j + 1 == aword.length ? aword[i] : ""));
    } else if (direction == 4) {
      grid = List<List<String>>.generate(
          1,
          (i) => List<String>.generate(
              aword.length, (j) => aword[aword.length - 1 - j]));
    } else if (direction == 5) {
      grid = List<List<String>>.generate(
          aword.length,
          (i) => List<String>.generate(
              aword.length, (j) => i == j ? aword[aword.length - i - 1] : ""));
    } else if (direction == 6) {
      grid = List<List<String>>.generate(aword.length,
          (i) => List<String>.generate(1, (j) => aword[aword.length - i - 1]));
    } else if (direction == 7) {
      grid = List<List<String>>.generate(
          aword.length,
          (i) => List<String>.generate(
              aword.length, (j) => i + j + 1 == aword.length ? aword[j] : ""));
    }
    return grid;
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    if (timer != null) timer?.cancel();
    super.dispose();
  }
}

class CharacterMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Define a paint object
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.cyan[200]!;
    // Left eye
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height),
            const Radius.circular(10)),
        paint);
    for (int i = 0; i < gridMap.length; i++)
      for (int j = 0; j < gridMap[i].length; j++) {
        final textStyle = TextStyle(
            color: Colors.cyan[900], fontSize: 16, fontWeight: FontWeight.bold);
        final textSpan = TextSpan(text: gridMap[i][j], style: textStyle);
        final textPainter =
            TextPainter(text: textSpan, textDirection: TextDirection.ltr);
        textPainter.layout();
        final offset = Offset(j * gridSize + (gridSize - textPainter.width) / 2,
            i * gridSize + (gridSize - textPainter.height) / 2);
        textPainter.paint(canvas, offset);
      }
    //----- Found Words history
    List<Offset> offset = [];
    Path path = Path();
    paint.strokeWidth = gridSize;
    paint.strokeCap = StrokeCap.round;
    paint.strokeJoin = StrokeJoin.round;
    for (int i = 0; i < foundWords.length; i++) {
      offset.clear();
      path.reset();
      paint.color = foundColor[i];
      for (int j = 0; j < foundMap[i].length; j++) {
        offset.add(Offset(foundMap[i][j].x * gridSize + gridSize / 2,
            foundMap[i][j].y * gridSize + gridSize / 2));
      }
      path.addPolygon(offset, false);
      canvas.drawPath(path, paint);
    }

    //----- Current drawing
    List<Offset> offsets = [];
    for (int i = 0; i < touchItems.length; i++) {
      offsets.add(Offset(touchItems[i].x * gridSize + gridSize / 2,
          touchItems[i].y * gridSize + gridSize / 2));
    }
    path.reset();
    path.addPolygon(offsets, false);
    paint.color = const Color.fromRGBO(255, 0, 0, 80);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CharacterMapPainter oldDelegate) => true;

  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
