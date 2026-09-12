import 'dart:convert';
import 'dart:typed_data';

abstract final class ImageBase64Utils {
  ///return img bytes as string can saved in firestore 
    static String encode (Uint8List bytes){
      return base64Encode(bytes);
    }
  ///return img can use it directly by image.memory
    static Uint8List decode (String imgString){
      return base64Decode(imgString);
    }
}