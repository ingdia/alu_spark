class CloudinaryConfig {
  static const String cloudName = 'alu_spark';
  static const String apiKey = String.fromEnvironment('CLOUDINARY_API_KEY');
  static const String apiSecret = String.fromEnvironment('CLOUDINARY_API_SECRET');

  // Upload presets (create these in Cloudinary dashboard)
  static const String imageUploadPreset = 'alu_spark_preset';
  static const String cvUploadPreset = 'alu_spark_cv_preset';
}