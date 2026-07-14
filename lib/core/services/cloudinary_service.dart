import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  final String cloudName;
  final String uploadPreset;

  CloudinaryService({
    required this.cloudName,
    required this.uploadPreset,
  });

  /// Upload a file to Cloudinary.
  /// Supports both mobile (filePath) and web (bytes).
  /// [resourceType] can be 'image', 'raw', or 'auto'.
  Future<String?> uploadFile({
    String? filePath,
    Uint8List? bytes,
    required String fileName,
    String folder = 'alu_spark',
    String resourceType = 'auto',
  }) async {
    try {
      final uri = Uri.parse(
          'https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload');
      final request = http.MultipartRequest('POST', uri);

      if (bytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName,
        ));
      } else if (filePath != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          filePath,
          filename: fileName,
        ));
      } else {
        throw Exception('No file data provided');
      }

      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = folder;

      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final jsonResponse = json.decode(String.fromCharCodes(responseData));

      if (response.statusCode == 200) {
        return jsonResponse['secure_url'] as String?;
      } else {
        throw Exception('Cloudinary error: ${jsonResponse['error']['message']}');
      }
    } catch (e) {
      debugPrint('Cloudinary upload error: $e');
      rethrow;
    }
  }

  /// Convenience wrapper for image uploads.
  Future<String?> uploadImage(File imageFile, {String folder = 'alu_spark'}) {
    return uploadFile(
      filePath: imageFile.path,
      fileName: imageFile.path.split('/').last,
      folder: folder,
      resourceType: 'image',
    );
  }

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