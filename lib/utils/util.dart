import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

creatFileImage(Uint8List image, String name) async {
  // Salva a imagem em tons de cinza temporariamente em um arquivo
  Directory tempDir = await getTemporaryDirectory();
  File ImageFileSelected = File('${tempDir.path}/$name.jpg');
  await ImageFileSelected.writeAsBytes(image);

  return ImageFileSelected;
}

Uint8List manualBinarization(Uint8List image, int threshold) {
  for (int i = 0; i < image.length; i++) {
    image[i] = (image[i] > threshold) ? 255 : 0;
  }

  return image;
}

