import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_processing_contouring/Image/ImageContouring.dart';
import 'package:image_processing_contouring/Image/ImageOperation.dart';
import 'package:image_processing_contouring/Image/ImageManipulation.dart';
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

      File grayImageFile = await creatFileImage(grayImage!, "gray");

      //Criar filtro binario

      Uint8List? treshdImage = await Cv2.threshold(
        pathFrom: CVPathFrom.GALLERY_CAMERA,
        pathString: grayImageFile.path,
        thresholdValue: 240,
        thresholdType: Cv2.THRESH_BINARY,
        maxThresholdValue: 255,
      );

      File treshedImageFile = await creatFileImage(treshdImage!, "tresh");

      Uint8List? blured = await Cv2.medianBlur(
        pathFrom: CVPathFrom.GALLERY_CAMERA,
        pathString: treshedImageFile.path,
        kernelSize: 3,
      );

      File bluredImageFile = await creatFileImage(blured!, "blur");

      Uint8List? erodedImage = await Cv2.erode(
        pathFrom: CVPathFrom.GALLERY_CAMERA,
        pathString: bluredImageFile.path,
        kernelSize: [1, 2],
      );

      File erodeImageFile = await creatFileImage(erodedImage!, "erode");

      Uint8List? dilatedImage = await Cv2.dilate(
        pathFrom: CVPathFrom.GALLERY_CAMERA,
        pathString: erodeImageFile.path,
        kernelSize: [1, 2],
      );

      File dilated1ImageFile = await creatFileImage(dilatedImage!, "dilated1");

      var ima = LoadImageFromPath(dilated1ImageFile.path);

      var contours = ima?.threshold(100).detectContours();

      // Imprimir os contornos
      for (var contour in contours!) {
        // ignore: avoid_print
        print('Contour:');
        for (var point in contour.Points) {
          // ignore: avoid_print
          print('  (${point.x}, ${point.y})');
        }
      }

      setState(() {
        image = Image.memory(dilatedImage);
        // file = grayImageFile;
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) => AlertDialog(title: Text("ERRO ao traduzir: $e ")),
      );
    }
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
        ],
      ),
    );
  }
}
