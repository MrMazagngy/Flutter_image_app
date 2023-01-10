import 'package:flutter/material.dart';
import 'camera_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:typed_data';
import 'model.dart';
import 'package:flutter/services.dart';

final List<String> imageList = [
  "https://images.unsplash.com/photo-1520342868574-5fa3804e551c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=6ff92caffcdd63681a35134a6770ed3b&auto=format&fit=crop&w=1951&q=80",
  'https://images.unsplash.com/photo-1523205771623-e0faa4d2813d?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=89719a0d55dd05e2deae4120227e6efc&auto=format&fit=crop&w=1953&q=80',
  'https://images.unsplash.com/photo-1508704019882-f9cf40e475b4?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=8c6e5e3aba713b17aa1fe71ab4f0ae5b&auto=format&fit=crop&w=1352&q=80',
  'https://images.unsplash.com/photo-1519985176271-adb1088fa94c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=a0c8d632e977f94e5d312d9893258f59&auto=format&fit=crop&w=1355&q=80'
];

Future ff(String styleImagePath, String originalImagePath) async {
  ImageTransferFacade showtime = ImageTransferFacade();
  showtime.loadModel();
  var style_image = await showtime.loadStyleImage(styleImagePath);
  File imageFile = File(originalImagePath);
  var original_image = await showtime.loadoriginalImage(imageFile);

  var output_image = await showtime.transfer(original_image, style_image);
  output_image = Image.memory(output_image);
  return output_image;
}

Image? finalsd = null;

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
  late XFile _image;

  initState() {
    _image = widget.image;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: SingleChildScrollView(
          child: Container(
              padding: EdgeInsets.all(16),
              child: Card(
                  child: (finalsd == null)
                      ? Image.file(File(_image.path))
                      : finalsd))), // this is the original image which i'd like to replace once user taps on the style image
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: CarouselSlider.builder(
          itemCount: imageList.length,
          options: CarouselOptions(
            autoPlay: true,
            aspectRatio: 2.0,
            enlargeCenterPage: true,
          ),
          itemBuilder: (context, index, realIdx) {
            return Container(
                child: Center(
              child: GestureDetector(
                  onTap: () {
                    ff(imageList[index], widget.image.path).then((value) {
                      setState(() {
                        finalsd = value;
                      });
                    });
                  },
                  child: Image.network(imageList[index],
                      fit: BoxFit.cover, width: 1000)),
            ));
          },
        ),
      ),
      floatingActionButton: const FloatingActionButton(onPressed: null),
    );
  }
}
