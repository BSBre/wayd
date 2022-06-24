import 'dart:math';

class PlaceholderImage {
  static String randomPlaceholderImagePath(int id) {
    var index = Random().nextInt(14) + 1;
    if(id > 0 && id < 15) {
      index = id;
    }
    return 'assets/placeholders/placeholder_image_$index.png';
  }
}
