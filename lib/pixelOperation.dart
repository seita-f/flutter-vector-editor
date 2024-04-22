import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'dart:async';

class ImageData {
  Uint8List pixels = Uint8List(0);  // Initialize pixels
  // Uint8List pixels;
  late ui.Image image;
  int width;
  int height;

  ImageData(this.width, this.height) {
    // 画像データの初期化（RGBA形式なのでピクセルあたり4バイト必要）
    pixels = Uint8List(width * height * 4);
    _updateImage();
  }

  // Uint8Listからui.Imageオブジェクトを生成する
  Future<void> _updateImage() async {
    image = await _decodeImageFromPixels(pixels, width, height);
  }

  // Uint8Listからui.Imageを生成するヘルパーメソッド
  Future<ui.Image> _decodeImageFromPixels(Uint8List pixels, int width, int height) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromPixels(
      pixels,
      width,
      height,
      ui.PixelFormat.rgba8888,
      (img) {
        completer.complete(img);
      }
    );
    return completer.future;
  }

  // ピクセルデータをクリア（白で塗りつぶし）
  void clear(ui.Color color) {
    for (int i = 0; i < pixels.length; i += 4) {
      pixels[i] = color.red;
      pixels[i + 1] = color.green;
      pixels[i + 2] = color.blue;
      pixels[i + 3] = color.alpha;
    }
    _updateImage();
  }

  // 特定のピクセルに色を設定するメソッド
  void setPixelColor(int x, int y, ui.Color color) {
    if (x < 0 || y < 0 || x >= width || y >= height) return;
    int index = (y * width + x) * 4;
    pixels[index] = color.red;
    pixels[index + 1] = color.green;
    pixels[index + 2] = color.blue;
    pixels[index + 3] = color.alpha;
    _updateImage();
  }

  // 特定のピクセルの色を取得するメソッド
  ui.Color getPixelColor(int x, int y) {
    if (x < 0 || y < 0 || x >= width || y >= height) return ui.Color(0x00000000); // Transparent color
    int index = (y * width + x) * 4;
    return ui.Color.fromARGB(pixels[index + 3], pixels[index], pixels[index + 1], pixels[index + 2]);
  }

  // ブラシ機能を使ってピクセルに色を適用する
  void applyBrush(int x, int y, int thickness, ui.Color color) {
    for (int i = 1 - thickness; i < thickness; i++) {
      for (int j = 1 - thickness; j < thickness; j++) {
        if (math.sqrt(i * i + j * j) <= thickness) {
          setPixelColor(x + i, y + j, color);
        }
      }
    }
  }
}
