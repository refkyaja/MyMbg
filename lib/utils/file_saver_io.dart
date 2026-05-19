import 'dart:io';
import 'package:file_picker/file_picker.dart';

Future<void> saveAndLaunchFile(List<int> bytes, String fileName) async {
  final String? outputPath = await FilePicker.platform.saveFile(
    dialogTitle: 'Simpan Laporan',
    fileName: fileName,
  );

  if (outputPath != null) {
    final File file = File(outputPath);
    await file.writeAsBytes(bytes);
  }
}
