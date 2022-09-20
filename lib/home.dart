// ignore_for_file: prefer_const_constructors
import 'dart:io';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/services.dart';
import 'package:animated_snack_bar/animated_snack_bar.dart';

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool textScanning = false;

  XFile? imageFile;

  String scannedText = "";
  void getImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null) {
        textScanning = true;
        imageFile = pickedImage;
        setState(() {});
        getRecognisedText(pickedImage);
      }
    } catch (e) {
      textScanning = false;
      imageFile = null;
      scannedText = "Error occured while scanning";
      setState(() {});
    }
  }

  void getRecognisedText(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    // final textDetector = GoogleMlKit.vision.textDetector();
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    // var recognisedText = await textDetector.processImage(inputImage);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);
    await textRecognizer.close();
    scannedText = "";
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        scannedText = scannedText + line.text + "\n";
      }
    }
    textScanning = false;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Text Recognition App"),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () {
          setState(() {
            textScanning = false;
            imageFile = null;
            scannedText = "";
          });
        },
        child: Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [
            if (!textScanning && imageFile == null)
              Container(
                height: 300,
                color: Colors.grey[300],
              ),
            if (imageFile != null) Image.file(File(imageFile!.path)),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      getImage(ImageSource.gallery);
                    },
                    child: Container(
                        padding: EdgeInsets.symmetric(vertical: 2),
                        color: Colors.green,
                        child: Column(
                          // ignore: prefer_const_literals_to_create_immutables
                          children: [
                            Icon(
                              Icons.image,
                              color: Colors.white,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              "Gallery",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      getImage(ImageSource.camera);
                    },
                    child: Container(
                        padding: EdgeInsets.symmetric(vertical: 2),
                        color: Colors.green,
                        child: Column(
                          // ignore: prefer_const_literals_to_create_immutables
                          children: [
                            Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              "Camera",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            if (textScanning)
              // EasyLoading.showProgress(0.3, status: 'downloading...');
              Center(
                child: Container(
                    margin: EdgeInsets.all(15),
                    width: 80,
                    height: 80,
                    child: const CircularProgressIndicator(
                      backgroundColor: Color.fromARGB(255, 201, 220, 236),
                      strokeWidth: 8,
                      color: Colors.green,
                    )),
              )
            else
              Container(
                child: Text(
                  scannedText,
                  style: TextStyle(fontSize: 20),
                ),
              ),
            if (scannedText != "")
              Container(
                width: double.infinity,
                child: RaisedButton(
                  onPressed: () {
                    AnimatedSnackBar.material(
                      'Text copied',
                      mobileSnackBarPosition: MobileSnackBarPosition.bottom,
                      type: AnimatedSnackBarType.success,
                    ).show(context);
                    Clipboard.setData(ClipboardData(text: scannedText));
                  },
                  color: Colors.grey[400],
                  child: Text(
                    "Copy",
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
