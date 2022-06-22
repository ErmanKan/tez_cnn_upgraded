import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:tez_cnn_upgraded/classifierFloat.dart';
import  'package:tez_cnn_upgraded/classifierQuant.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

import 'classifier.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blood Picker Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker _picker = ImagePicker();
  late File imagefile;
  bool hasPicked = false;
  late Classifier classifier;
  late Category category;
  bool hasProcessed = false;
  String? message = "";

  Future getImageGallery() async {
    final XFile? _image =
    await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      imagefile = File(_image!.path);
      hasPicked = true;
      hasProcessed = false;
    });
  }

  @override
  void initState() {
    super.initState();
    classifier = ClassifierQuant();

  }

  Future getImageCamera() async {
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        imagefile = File(pickedFile.path);
        hasProcessed = false;
        hasPicked = true;
      });
    }
  }

  void predict() async {
    img.Image imageInput = img.decodeImage(imagefile.readAsBytesSync())!;
    var pred = classifier.predict(imageInput);

    setState(() {
      category = pred;
      hasProcessed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Blood Picker Demo'),
        ),
        body: Center(
          child:
          Column(
              children: [
                hasPicked == false
                    ? const Text('No image loaded')
                    : Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Align(
                              alignment: Alignment.topCenter,
                              child: Container(
                                alignment: Alignment.topCenter,
                                child:
                                Image.file(imagefile, height: 350, width: 350),
                              )
                          )
                        ],
                      ),
                      ElevatedButton(
                          onPressed: () {
                            predict();
                          },
                          child: const Text('Process')),
                      Text(
                        hasProcessed != false? category.label : '',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        hasProcessed != false
                            ? 'Confidence: ${category.score.toStringAsFixed(3)}'
                            : 'Waiting for Processing',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                )

              ]),
        ),
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          children: [
            SpeedDialChild(
              child: const Icon(Icons.camera),
              label: 'Capture from camera',
              onTap: () => getImageCamera(),
            ),
            SpeedDialChild(
              child: const Icon(Icons.image),
              label: 'Upload from gallery',
              onTap: () => getImageGallery(),
            )
          ],
        ));
  }
}
