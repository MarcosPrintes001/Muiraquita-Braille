import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:muiraquita_braille/materials/constants.dart';
import 'package:opencv/core/core.dart';
import 'package:opencv/opencv.dart';

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
    var result;
    var bytes = await file!.readAsBytes();

    var colored = await ImgProc.cvtColor(bytes, 6);

    var bluredImage =
        await ImgProc.blur(colored, [45, 45], [20, 30], Core.borderReflect);

    result = bluredImage;

    setState(() {
      image = Image.memory(result);
    });
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
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
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
