// ignore_for_file: use_build_context_synchronously
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:muiraquita_braille/materials/constants.dart';
import 'package:muiraquita_braille/utils/util.dart';
import 'package:opencv_4/factory/pathfrom.dart';
import 'package:opencv_4/opencv_4.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? file;
  final ImagePicker picker = ImagePicker();
  Image? image;
  // List<Offset> _gridLines = [];

  addFromGallery() async {
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    var tempFile = File(pickedFile!.path);
    setState(() {
      file = tempFile;
      image = Image.file(tempFile);
    });
  }

  addFromCamera() async {
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.camera);
    var tempFile = File(pickedFile!.path);
    setState(() {
      file = tempFile;
      image = Image.file(tempFile);
    });
  }

  clearSelection() {
    setState(() {
      image = null;
      file = null;
    });
  }

  translate() async {
    try {
      var imageFile = file!.path;

      //Aplica tons de cinza na imagem
      Uint8List? grayImage = await Cv2.cvtColor(
        pathFrom: CVPathFrom.GALLERY_CAMERA,
        pathString: imageFile,
        outputType: Cv2.COLOR_BGR2GRAY,
      );

      File grayImageFile = await creatFileImage(grayImage!, "gray_image");

      // Aplica o desfoque à imagem em tons de cinza
      Uint8List? blurredImage = await Cv2.dilate(
        pathFrom: CVPathFrom.GALLERY_CAMERA,
        pathString: grayImageFile.path,
        kernelSize: [3, 3],
      );

      File bluredImageFile =
          await creatFileImage(blurredImage!, "blured_image");

      Uint8List byte = await Cv2.threshold(
        pathFrom: CVPathFrom.GALLERY_CAMERA,
        pathString: bluredImageFile.path,
        thresholdValue: 150,
        maxThresholdValue: 200,
        thresholdType: Cv2.THRESH_BINARY,
      );

      setState(() {
        image = Image.memory(byte);
        // file = grayImageFile;
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) =>
            const AlertDialog(title: Text("ERRO ao traduzir")),
      );
    }
  }

  makeGride() {
    // _gridLines.clear();

    // if (file != null) {
    //   final imgSize = ImageSizeGetter.getSize(File(file!.path));
    //   if (imgSize != null) {
    //     final cellWidth = imgSize.width / 10;
    //     final cellHeight = imgSize.height / 10;

    //     for (int i = 1; i < 10; i++) {
    //       _gridLines.add(Offset(cellWidth * i, 0));
    //       _gridLines.add(Offset(cellWidth * i, imgSize.height));
    //       _gridLines.add(Offset(0, cellHeight * i));
    //       _gridLines.add(Offset(imgSize.width, cellHeight * i));
    //     }
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backGroundColor,
      appBar: AppBar(
        title: const Text("Adicionar De"),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.green,
            width: double.infinity,
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: addFromCamera,
                  icon: const Icon(
                    Icons.add_a_photo,
                    color: Colors.black,
                  ),
                  label: const Text(
                    "Camera",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: addFromGallery,
                  icon: const Icon(
                    Icons.add_photo_alternate_rounded,
                    color: Colors.black,
                  ),
                  label: const Text(
                    "Galeria",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: clearSelection,
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.black,
                  ),
                  label: const Text(
                    "Limpar seleção",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              color: Colors.red,
              width: double.infinity,
              child: image != null
                  ? Padding(
                      padding: const EdgeInsets.all(20),
                      child: image!,
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported,
                          size: 50,
                        ),
                        Text("Nenhuma imagem\n selecionada",
                            style: TextStyle(fontSize: 20),
                            textAlign: TextAlign.center),
                      ],
                    ),
            ),
          ),
          Container(
            color: Colors.blue,
            width: double.infinity,
            height: 100,
            child: TextButton.icon(
              onPressed: translate,
              icon: const Icon(
                Icons.translate,
                color: Colors.black87,
              ),
              label: const Text(
                "Cores",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Container(
            color: Colors.blue,
            width: double.infinity,
            height: 100,
            child: TextButton.icon(
              onPressed: translate,
              icon: const Icon(
                Icons.translate,
                color: Colors.black87,
              ),
              label: const Text(
                "Grade",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
