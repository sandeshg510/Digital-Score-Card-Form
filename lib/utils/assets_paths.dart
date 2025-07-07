const String _images = "assets/images"; // * Path to the images folder
const String _svgs = "assets/svgs"; // * Path to the svgs folder
// const String _videos = "assets/videos"; // * Path to the videos folder
const String _anims = "assets/anims"; // * Path to the animations folder

class ImagePaths {
  static ImagePaths instance =
      ImagePaths(); // * A singleton instance of the class to be used all over the project codebase

  final String brandNameLogoPath = "$_images/brandLogo.png";
}
