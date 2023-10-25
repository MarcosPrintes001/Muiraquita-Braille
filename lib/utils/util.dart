import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

creatFileImage(Uint8List image, String name) async {
  // Salva a imagem em tons de cinza temporariamente em um arquivo
  Directory tempDir = await getTemporaryDirectory();
  File grayImageFile = File('${tempDir.path}/$name.jpg');
  await grayImageFile.writeAsBytes(image);

  return grayImageFile;
}
