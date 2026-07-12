import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  final String cloudName;
  final String uploadPreset;

  CloudinaryService({
    required this.cloudName,
    required this.uploadPreset,
  });

  // Upload image to Cloudinary
  Future<String?> uploadImage(File imageFile, {String folder = 'alu_spark'}) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload'),
      );

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
      ));

      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = folder;

      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var jsonResponse = json.decode(String.fromCharCodes(responseData));

      if (response.statusCode == 200) {
        return jsonResponse['secure_url'];
      } else {
        throw Exception('Failed to upload: ${jsonResponse['error']['message']}');
      }
    } catch (e) {
      print('Cloudinary upload error: $e');
      return null;
    }
  }

  // Get transformed image URL
  String getTransformedImageUrl(String publicId, {
    int? width,
    int? height,
    String crop = 'fill',
  }) {
    String transformations = '';
    
    if (width != null || height != null) {
      transformations = 'w_${width ?? 'auto'},h_${height ?? 'auto'},c_$crop/';
    }

    return 'https://res.cloudinary.com/$cloudName/image/upload/$transformations$publicId';
  }
}