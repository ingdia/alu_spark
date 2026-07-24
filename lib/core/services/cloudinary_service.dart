import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:alu_spark/core/constants/cloudinary_config.dart';

enum CloudinaryFolder { cvs, profileImages, startupLogos }

class CloudinaryService {
  final String cloudName;
  final String uploadPreset;

  CloudinaryService({
    required this.cloudName,
    required this.uploadPreset,
  });

  /// Shared factory for CV uploads.
  factory CloudinaryService.forCv() => CloudinaryService(
        cloudName: CloudinaryConfig.cloudName,
        uploadPreset: CloudinaryConfig.cvUploadPreset,
      );

  /// Shared factory for image uploads (profiles, logos).
  factory CloudinaryService.forImages() => CloudinaryService(
        cloudName: CloudinaryConfig.cloudName,
        uploadPreset: CloudinaryConfig.imageUploadPreset,
      );

  static String _folderName(CloudinaryFolder folder) {
    switch (folder) {
      case CloudinaryFolder.cvs:
        return 'cvs';
      case CloudinaryFolder.profileImages:
        return 'profile_images';
      case CloudinaryFolder.startupLogos:
        return 'startup_logos';
    }
  }

  /// Upload an [XFile] (from image_picker) to Cloudinary.
  Future<String> uploadXFile(
    XFile file, {
    required CloudinaryFolder folder,
  }) async {
    final bytes = await file.readAsBytes();
    final url = await uploadFile(
      bytes: bytes,
      fileName: file.name,
      folder: _folderName(folder),
      resourceType: 'image',
    );
    if (url == null) throw Exception('Upload returned no URL');
    return url;
  }

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