import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'camera_widget.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:introduction_screen/introduction_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(MaterialApp(
    title: "Pick Image Camera",
    home: mainPage(),
    builder: EasyLoading.init(),
  ));
}

class mainPage extends StatefulWidget {
  @override
  _mainPageState createState() => _mainPageState();
}

class _mainPageState extends State<mainPage> {
  void endwelcome(context) {
    Navigator.pop(context);
    Navigator.of(context)
        .push(MaterialPageRoute(builder: ((_) => CameraWidget())));
  }

  List<PageViewModel> getPages() {
    return [
      PageViewModel(
          image: Image.asset("assets/back_1.jpg"),
          title: "Live Demo page 1",
          body: "Welcome to Proto Coders Point",
          footer: Text("Footer Text here "),
          decoration: const PageDecoration(
            pageColor: Colors.blue,
          )),
      PageViewModel(
        image: Image.asset("assets/back_1.jpg"),
        title: "Live Demo page 2 ",
        body: "Live Demo Text",
        footer: Text("Footer Text  here "),
      ),
      PageViewModel(
        image: Image.asset("assets/back_1.jpg"),
        title: "Live Demo page 3",
        body: "Welcome to Proto Coders Point",
        footer: Text("Footer Text  here "),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Introduction Screen"),
      ),
      body: IntroductionScreen(
          globalBackgroundColor: Colors.black,
          pages: getPages(),
          showSkipButton: true,
          next: const Icon(Icons.arrow_forward),
          skip: Text("Skip"),
          done: Text("Got it "),
          onDone: () {
            endwelcome(context);
          },
          onSkip: () {
            endwelcome(context);
          }),
    );
  }
}
