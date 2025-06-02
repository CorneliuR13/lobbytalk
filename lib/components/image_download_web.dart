import 'dart:html' as html;

void downloadImage(String url) {
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', 'image.jpg')
    ..click();
}