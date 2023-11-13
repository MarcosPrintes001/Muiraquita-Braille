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
  Uint8List binarizedImage = Uint8List.fromList(image);

  for (int i = 0; i < binarizedImage.length; i++) {
    binarizedImage[i] = (binarizedImage[i] > threshold) ? 255 : 0;
  }

  Uint8List binarizedImageFinal = Uint8List.fromList(binarizedImage);

  return binarizedImageFinal;
}
