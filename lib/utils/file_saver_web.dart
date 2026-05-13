// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

void saveAndLaunchFile(List<int> bytes, String fileName) {
  final html.Blob blob = html.Blob(<List<int>>[bytes]);
  final String url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click();
  html.Url.revokeObjectUrl(url);
}
