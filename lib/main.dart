import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: OcrScreen(),
    );
  }
}

class OcrScreen extends StatefulWidget {
  const OcrScreen({Key? key}) : super(key: key);

  @override
  State<OcrScreen> createState() => _OcrScreenState();
}

class _OcrScreenState extends State<OcrScreen> {
  File? _storedImage;
  String? resultText = '';

  void _scanImage() async {
    String _ocrResult =
        await FlutterTesseractOcr.extractText(_storedImage!.path, args: {
      "psm": "4",
      "preserve_interword_spaces": "1",
    });
    setState(() {
      resultText = _ocrResult;
    });
  }

  Future<void> _takePicture(ImageSource src) async {
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(
      source: src,
      maxWidth: 600,
    );
    try {
      if (imageFile == null) {
        return;
      }
      setState(() {
        _storedImage = File((imageFile).path);
      });
    } catch (e) {
      // TODO
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OCR Scanner')),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 350,
                margin: const EdgeInsets.only(
                    top: 5, right: 10, left: 10, bottom: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Colors.grey,
                  ),
                ),
                child: _storedImage == null
                    ? const Center(
                        child: Text(
                          'No Image Uploaded Yet',
                          textAlign: TextAlign.center,
                        ),
                      )
                    : FittedBox(
                        child: Image.file(
                          _storedImage as File,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
              if (_storedImage != null)
                TextButton(
                  onPressed: _scanImage,
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.cyan, primary: Colors.white),
                  child: const Text('Scan image'),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Result: '),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      color: Colors.grey,
                      onPressed: () =>
                          Clipboard.setData(ClipboardData(text: resultText))
                              .then(
                        (value) {
                          //only if ->
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Text added to clipboard',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ); // -> show a notification
                        },
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: 100,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.all(5),
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.grey)),
                child: SingleChildScrollView(child: Text(resultText ?? '')),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        //padding: EdgeInsets.all(10),
                        constraints: const BoxConstraints(
                          minWidth: 75,
                          minHeight: 75,
                        ),
                        decoration: BoxDecoration(
                            border: Border.all(
                              width: 2,
                              color: Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(100)),
                        child: IconButton(
                          padding: const EdgeInsets.all(0),
                          onPressed: () {
                            _takePicture(ImageSource.camera);
                          },
                          icon: const Icon(
                            Icons.camera_alt,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const Text('Take a picture!'),
                    ],
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        //padding: EdgeInsets.all(10),
                        constraints: const BoxConstraints(
                          minWidth: 75,
                          minHeight: 75,
                        ),
                        decoration: BoxDecoration(
                            border: Border.all(
                              width: 2,
                              color: Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(100)),
                        child: IconButton(
                          padding: const EdgeInsets.all(0),
                          onPressed: () {
                            _takePicture(ImageSource.gallery);
                          },
                          icon: const Icon(
                            Icons.image_outlined,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const Text('Choose from Gallery!'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
