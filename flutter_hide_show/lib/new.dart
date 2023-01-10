import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'ad_helper.dart';
import 'package:flutter_share_me/flutter_share_me.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
/** To connect to Flask API in localhost :
  *
    1.Disable Ubuntu firewall : sudo ufw disable
    2.Run these commands :
        adb kill-server
        sudo cp ~/Android/Sdk/platform-tools/adb /usr/bin/adb
        sudo chmod +x /usr/bin/adb
        adb start-server 
    3. Run : adb reverse tcp:5000 tcp:5000 where 5000 isport number used
    4. use this link in flutter app : http://localhost:5000
     
  */

enum Share { whatsapp, share_instagram }

final List<String> imageList_back = [
  "assets/back_1.jpg",
  'assets/back_2.jpg',
  'assets/back_3.jpg',
  'assets/back_4.jpg',
  'assets/back_5.jpg',
  'assets/back_6.jpg'
];

final List<String> imageList_style = [
  "assets/style_1.jpg",
  'assets/style_2.jpg',
  'assets/style_3.jpg',
  'assets/style_4.jpg',
  'assets/style_5.jpg',
  'assets/style_6.jpg',
];

Future ff(String styleImagePath, String originalImagePath) async {
  ImageTransferFacade showtime = ImageTransferFacade();
  showtime.loadModel();
  var style_image = await showtime.loadStyleImage(styleImagePath);

  File imageFile =
      File(originalImagePath); // change original image to File type
  var original_image = await showtime.loadoriginalImage(imageFile);

  var output_image = await showtime.transfer(original_image, style_image);
  //output_image = Image.memory(output_image);
  //output_image = File.fromRawPath(output_image);
  final tempDir = await getTemporaryDirectory();
  File file = await File('${tempDir.path}/image.png').create();
  file.writeAsBytesSync(output_image);
  return file;
}

class second extends StatefulWidget {
  const second({
    Key? key,
    required this.image,
  }) : super(key: key);

  final XFile image;
  @override
  State<second> createState() => _secondState();
}

class _secondState extends State<second> {
  /** Define 
     * Variables
     */
  Timer? _timer;
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;
  late InterstitialAd _interstitialAd;
  bool _isInterstitialAdReady = false;

  int _selectedIndex = 0;
  File? finalsd;
  bool carosuel_vis = false;
  bool pix_vis = false;
  bool caption_vis = false;
  bool bottom_vis = true;
  bool main_body = true;
  String caption = 'Coming Soon';
  late FocusNode myFocusNode;
  late TextEditingController _controller;
  late XFile _image;
  StreamSubscription? internetconnection;
  bool isoffline = true;

  pix(BackgroundImagePath, originalImagePath) async {
    originalImagePath = (File(originalImagePath));
    final upload =
        http.MultipartRequest('POST', Uri.parse("http://localhost:5000/"));

    upload.files.add(http.MultipartFile.fromBytes('back',
        (await rootBundle.load(BackgroundImagePath)).buffer.asUint8List(),
        filename: 'photo.jpg'));

    upload.files.add(http.MultipartFile(
        'image',
        originalImagePath.readAsBytes().asStream(),
        originalImagePath.lengthSync(),
        filename: originalImagePath.path.split('/').last));

    final response = await upload.send();
    print(response);
    http.Response res = await http.Response.fromStream(response);
    //print(res.bodyBytes);
    //File.fromRawPath(Uint8List.fromList(res.bodyBytes));
    final tempDir = await getTemporaryDirectory();
    File file = await File('${tempDir.path}/image_1.png').create();
    file.writeAsBytesSync(Uint8List.fromList(res.bodyBytes));

    return file;
  }

  Future<void> onButtonTap(Share share) async {
    String msg =
        'Flutter share is great!!\n Check out full example at https://pub.dev/packages/flutter_share_me';
    String url = 'https://pub.dev/packages/flutter_share_me';

    String? response;
    final FlutterShareMe flutterShareMe = FlutterShareMe();
    switch (share) {
      case Share.whatsapp:
        if (finalsd != null) {
          response = await flutterShareMe.shareToWhatsApp(
              imagePath: finalsd!.path, fileType: FileType.image);
        } else {
          response = await flutterShareMe.shareToWhatsApp(msg: msg);
        }
        break;
      case Share.share_instagram:
        if (finalsd != null) {
          response =
              await flutterShareMe.shareToInstagram(imagePath: finalsd!.path);
        }
        break;
    }
    debugPrint(response);
  }

/** initState */

  initState() {
    super.initState();

    _controller = TextEditingController(text: caption); // text field
    myFocusNode = FocusNode();

    /** Check For 
     * Device Connectivity
     */
    internetconnection = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        setState(() {
          isoffline = true;
        });
      } else if (result == ConnectivityResult.mobile) {
        setState(() {
          isoffline = false;
        });
      } else if (result == ConnectivityResult.wifi) {
        setState(() {
          isoffline = false;
        });
      }
    });

    /** Check For 
     * Loading Bar
     */
    EasyLoading.addStatusCallback((status) {
      print('EasyLoading Status $status');
      if (status == EasyLoadingStatus.dismiss) {
        _timer?.cancel();
      }
    });

    /** Check For 
     * Google AdMob
     */
    _bannerAd = BannerAd(
        // Change Banner Size According to Ur Need
        size: AdSize.mediumRectangle,
        adUnitId: AdHelper.bannerAdUnitId,
        listener: BannerAdListener(onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        }, onAdFailedToLoad: (ad, LoadAdError error) {
          print("Failed to Load A Banner Ad${error.message}");
          _isBannerAdReady = false;
          ad.dispose();
        }),
        request: AdRequest())
      ..load();
    //Interstitial Ads
    InterstitialAd.load(
        adUnitId: AdHelper.interstitialAdUnitId,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(onAdLoaded: (ad) {
          this._interstitialAd = ad;
          _isInterstitialAdReady = true;
        }, onAdFailedToLoad: (LoadAdError error) {
          print("failed to Load Interstitial Ad ${error.message}");
        }));
  }

  /** Dispose Ads */
  @override
  void dispose() {
    _controller.dispose();
    myFocusNode.dispose(); // text field
    super.dispose();
    _bannerAd.dispose();
    _interstitialAd.dispose();
    internetconnection!.cancel();
  }

  /** Function For 
     * BottomBar
     */
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 0) {
        bottom_vis = !bottom_vis;
        carosuel_vis = !carosuel_vis;
      } else if (_selectedIndex == 1) {
        pix_vis = !pix_vis;
        bottom_vis = !bottom_vis;
      } else if (_selectedIndex == 2) {
        caption_vis = !caption_vis;
        main_body = !main_body;
        _isInterstitialAdReady ? _interstitialAd.show() : null;
      }
    });
  }
  /** Function For 
     * Return Botton
     */

  Future<bool?> showwarning(BuildContext context) async {
    if ((carosuel_vis == true) & (pix_vis == false) & (bottom_vis == false)) {
      carosuel_vis = false;
      bottom_vis = true;
    }
    if ((carosuel_vis == false) & (pix_vis == false) & (bottom_vis == true)) {
      return showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
                backgroundColor: Colors.black,
                title: new Text("Whoa!!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withOpacity(0.6))),
                content: new Text("Return To Main Page ?",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.white)),
                actions: [
                  TextButton(
                    child: Text("Yes"),
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                  ),
                  TextButton(
                    child: Text("Nope"),
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                  )
                ],
              ));
    }
    ;
  }

  /** Function For 
     * connectivity
     */
  Future connectivity(BuildContext context) async {
    return showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                backgroundColor: Colors.black,
                title: new Text("Whoa!!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withOpacity(0.6))),
                content: new Text("Please Connect To Internet",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.white)),
                actions: [
                  TextButton(
                    child: Text("Ok"),
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {});
                    },
                  ),
                ]));
  }

  Offset position = Offset(100, 100);
  void updatePosition(Offset newPosition) =>
      setState(() => position += newPosition);

  /** Main Widget */

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    if (isoffline == true) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        connectivity(context);
      });
    }
    _image = widget.image;
    return WillPopScope(
        onWillPop: () async {
          if ((carosuel_vis == true) &
              (pix_vis == false) &
              (bottom_vis == false)) {
            setState(() => {carosuel_vis = false, bottom_vis = true});
            return false;
          } else if ((carosuel_vis == false) &
              (pix_vis == true) &
              (bottom_vis == false)) {
            setState(() => {pix_vis = false, bottom_vis = true});
            return false;
          } else {
            final user_decision = await showwarning(context);
            return user_decision ?? false;
          }
        },
        child: Scaffold(
          appBar: AppBar(
              backgroundColor: Colors.black,
              title: Text("Playground"),
              automaticallyImplyLeading: false,
              leading: BackButton(),
              actions: [
                IconButton(
                  icon: Icon(Icons.file_download_outlined),
                  onPressed: () {
                    /** Do something */
                    (finalsd == null)
                        ? Text('make a change first')
                        : [
                            GallerySaver.saveImage(finalsd!.path),
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('Image Saved Sucessfully')))
                          ];
                  },
                ),
                IconButton(
                  /** Share Icons */
                  icon: FaIcon(FontAwesomeIcons.share),
                  onPressed: () {
                    /** Do something */
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                          title: Center(child: Text('Share Your Pic')),
                          actions: [
                            SizedBox(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: FaIcon(FontAwesomeIcons.instagram),
                                  onPressed: () {
                                    /** instagram share */
                                    (finalsd == null)
                                        ? Text('make a change first')
                                        : onButtonTap(Share.share_instagram);
                                  },
                                ),
                                IconButton(
                                  icon: FaIcon(FontAwesomeIcons.whatsapp),
                                  onPressed: () {
                                    /** whatsapp share */
                                    (finalsd == null)
                                        ? Text('make a change first')
                                        : onButtonTap(Share.whatsapp);
                                  },
                                ),
                              ],
                            ))
                          ]),
                    );
                  },
                )
              ]),
          body: Stack(children: [
            Visibility(
              visible: main_body,
              child: SingleChildScrollView(
                  child: Container(
                      padding: EdgeInsets.all(16),
                      child: Card(
                          child: (finalsd == null)
                              ? Image.file(File(_image.path))
                              : Image.file(File(finalsd!.path))))),
            ),
            Visibility(
              visible: caption_vis,
              child: GestureDetector(
                child: Stack(children: [
                  SingleChildScrollView(
                      child: Container(
                          padding: EdgeInsets.all(16),
                          child: Card(
                              child: (finalsd == null)
                                  ? Image.file(File(_image.path))
                                  : Image.file(File(finalsd!.path))))),
                  Positioned(
                    left: position.dx,
                    top: position.dy,
                    child: Draggable(
                        child: SizedBox(
                          height: 200,
                          width: 200,
                          child: TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                            ),
                            onSubmitted: (String value) async {
                              //Your Code
                            },
                          ),
                        ),
                        feedback: SizedBox(
                          height: 200,
                          width: 200,
                          child: TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                            ),
                            onSubmitted: (String value) async {
                              //Your Code
                            },
                          ),
                        ),
                        onDragEnd: (details) {
                          final RenderBox box =
                              context.findRenderObject() as RenderBox;
                          updatePosition(box.globalToLocal(details.offset));
                        } //updatePosition(details.offset),
                        ),
                  ),
                ]),
              ),
            )
          ]),

          // this is the original image which i'd like to replace once user taps on the style image
          bottomNavigationBar: Stack(children: [
            Visibility(
              visible: bottom_vis,
              child: BottomNavigationBar(
                backgroundColor: Colors.black, // <-- This works for fixed
                selectedItemColor: Colors.greenAccent,
                unselectedItemColor: Colors.grey,

                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                      icon: Icon(Icons.vrpano_rounded),
                      label: 'Stylish',
                      backgroundColor: Colors.pink),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.assignment_ind_outlined),
                      label: 'Background Sub',
                      backgroundColor: Colors.red),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.art_track_rounded),
                      label: 'Caption',
                      tooltip: 'Coming Soon'),
                ],
                onTap: _onItemTapped,
              ),
            ),
            BottomAppBar(
              //style transfer part
              color: Colors.white,
              child: Visibility(
                  visible: carosuel_vis,
                  child: CarouselSlider.builder(
                    itemCount: imageList_style.length,
                    options: CarouselOptions(
                      autoPlay: true,
                      aspectRatio: 3.0,
                      enlargeCenterPage: true,
                    ),
                    itemBuilder: (context, index, realIdx) {
                      return Container(
                          child: Center(
                        child: GestureDetector(
                            onTap: () async {
                              _isInterstitialAdReady
                                  ? _interstitialAd.show()
                                  : null;
                              //Load the ad
                              //update the image
                              ff(imageList_style[index], widget.image.path)
                                  .then((value) {
                                setState(() {
                                  finalsd = value;
                                });
                              });
                              //Loading Bar
                              _timer?.cancel();
                              await EasyLoading.show(
                                status: 'loading...',
                                maskType: EasyLoadingMaskType.black,
                              );
                              EasyLoading.dismiss();
                            },
                            child: Image.asset(imageList_style[index],
                                fit: BoxFit.cover, width: 1000)),
                      ));
                    },
                  )),
            ),
            BottomAppBar(
              // pix background part
              color: Colors.white,
              child: Visibility(
                  visible: pix_vis,
                  child: CarouselSlider.builder(
                    itemCount: imageList_back.length,
                    options: CarouselOptions(
                      autoPlay: true,
                      aspectRatio: 3.0,
                      enlargeCenterPage: true,
                    ),
                    itemBuilder: (context, index, realIdx) {
                      return Container(
                          child: Center(
                        child: GestureDetector(
                            onTap: () async {
                              _isInterstitialAdReady
                                  ? _interstitialAd.show()
                                  : null;
                              pix(imageList_back[index], widget.image.path)
                                  .then((value) {
                                setState(() {
                                  finalsd = value; //update the image
                                });
                              });

                              //Loading Bar
                              _timer?.cancel();
                              await EasyLoading.show(
                                status: 'loading...',
                                maskType: EasyLoadingMaskType.black,
                              );
                              EasyLoading.dismiss();
                            },
                            child: Image.asset(imageList_back[index],
                                fit: BoxFit.cover, width: 1000)),
                      ));
                    },
                  )),
            ),
          ]),
        ));
  }
}
