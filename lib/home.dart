// ignore_for_file: use_build_context_synchronously
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:muiraquita_braille/materials/constants.dart';
import 'package:opencv_4/factory/pathfrom.dart';
import 'package:opencv_4/opencv_4.dart';
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? file;
  final ImagePicker picker = ImagePicker();
  Image? image;

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
    });
  }

  translate() async {
    try {
      var imageFile = file!.path;

      Uint8List? grayImage = await Cv2.cvtColor(
        pathFrom: CVPathFrom.GALLERY_CAMERA,
        pathString: imageFile,
        outputType: Cv2.COLOR_BGR2GRAY,
      );

      // Salve a imagem em tons de cinza temporariamente em um arquivo
      Directory tempDir = await getTemporaryDirectory();
      File grayImageFile = File('${tempDir.path}/gray_image.jpg');
      await grayImageFile.writeAsBytes(grayImage!);

      // Aplique o desfoque à imagem em tons de cinza
      Uint8List? blurredImage = await Cv2.dilate(
        pathFrom: CVPathFrom.GALLERY_CAMERA,
        pathString: grayImageFile.path,
        kernelSize: [3, 3],
      );

      setState(() {
        image = Image.memory(blurredImage!);
      });

    } catch (e) {
      showDialog(
        context: context,
        builder: (context) =>
            const AlertDialog(title: Text("ERRO ao traduzir")),
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
                "Traduzir",
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
