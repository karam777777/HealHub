import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;

class CloudinaryService {
  static const String _cloudName = 'doxtfxp3r';
  static const String _apiKey = '145292875868488';
  static const String _apiSecret = 'tVqXz1yjzlYfE2j5AQ1MgBNand0';
  
  static const String _baseUrl = 'https://api.cloudinary.com/v1_1';

  // رفع صورة إلى Cloudinary
  static Future<String?> uploadImage(File imageFile, {String? folder}) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final publicId = '${folder ?? 'medical_app'}/${timestamp}_${path.basenameWithoutExtension(imageFile.path)}';
      
      // إنشاء التوقيع
      final signature = _generateSignature(publicId, timestamp);
      
      // إعداد طلب الرفع
      final uri = Uri.parse('$_baseUrl/$_cloudName/image/upload');
      final request = http.MultipartRequest('POST', uri);
      
      // إضافة البيانات
      request.fields.addAll({
        'public_id': publicId,
        'timestamp': timestamp,
        'api_key': _apiKey,
        'signature': signature,
        'folder': folder ?? 'medical_app',
        'resource_type': 'image',
        'quality': 'auto:good', // ضغط تلقائي للحفاظ على الجودة
        'format': 'auto', // تحويل تلقائي للصيغة الأمثل
      });
      
      // إضافة الملف
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      
      // إرسال الطلب
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseBody);
        return jsonResponse['secure_url'] as String;
      } else {
        print('Cloudinary upload error: ${response.statusCode}');
        print('Response: $responseBody');
        return null;
      }
    } catch (e) {
      print('Error uploading image to Cloudinary: $e');
      return null;
    }
  }

  // رفع فيديو إلى Cloudinary
  static Future<String?> uploadVideo(File videoFile, {String? folder}) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final publicId = '${folder ?? 'medical_app'}/videos/${timestamp}_${path.basenameWithoutExtension(videoFile.path)}';
      
      // إنشاء التوقيع
      final signature = _generateSignature(publicId, timestamp);
      
      // إعداد طلب الرفع
      final uri = Uri.parse('$_baseUrl/$_cloudName/video/upload');
      final request = http.MultipartRequest('POST', uri);
      
      // إضافة البيانات
      request.fields.addAll({
        'public_id': publicId,
        'timestamp': timestamp,
        'api_key': _apiKey,
        'signature': signature,
        'folder': folder ?? 'medical_app',
        'resource_type': 'video',
        'quality': 'auto:good', // ضغط تلقائي للفيديو
        'format': 'auto', // تحويل تلقائي للصيغة الأمثل
      });
      
      // إضافة الملف
      request.files.add(await http.MultipartFile.fromPath('file', videoFile.path));
      
      // إرسال الطلب
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseBody);
        return jsonResponse['secure_url'] as String;
      } else {
        print('Cloudinary upload error: ${response.statusCode}');
        print('Response: $responseBody');
        return null;
      }
    } catch (e) {
      print('Error uploading video to Cloudinary: $e');
      return null;
    }
  }

  // رفع ملفات متعددة (صور)
  static Future<List<String>> uploadMultipleImages(List<File> imageFiles, {String? folder}) async {
    final List<String> uploadedUrls = [];
    
    for (final imageFile in imageFiles) {
      final url = await uploadImage(imageFile, folder: folder);
      if (url != null) {
        uploadedUrls.add(url);
      }
    }
    
    return uploadedUrls;
  }

  // حذف ملف من Cloudinary
  static Future<bool> deleteFile(String publicId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final signature = _generateDeleteSignature(publicId, timestamp);
      
      final uri = Uri.parse('$_baseUrl/$_cloudName/image/destroy');
      final response = await http.post(
        uri,
        body: {
          'public_id': publicId,
          'timestamp': timestamp,
          'api_key': _apiKey,
          'signature': signature,
        },
      );
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['result'] == 'ok';
      }
      
      return false;
    } catch (e) {
      print('Error deleting file from Cloudinary: $e');
      return false;
    }
  }

  // إنشاء التوقيع للرفع
  static String _generateSignature(String publicId, String timestamp) {
    final params = 'public_id=$publicId&timestamp=$timestamp$_apiSecret';
    final bytes = utf8.encode(params);
    final digest = sha1.convert(bytes);
    return digest.toString();
  }

  // إنشاء التوقيع للحذف
  static String _generateDeleteSignature(String publicId, String timestamp) {
    final params = 'public_id=$publicId&timestamp=$timestamp$_apiSecret';
    final bytes = utf8.encode(params);
    final digest = sha1.convert(bytes);
    return digest.toString();
  }

  // الحصول على رابط محسن للصورة
  static String getOptimizedImageUrl(String originalUrl, {
    int? width,
    int? height,
    String quality = 'auto:good',
    String format = 'auto',
  }) {
    if (!originalUrl.contains('cloudinary.com')) {
      return originalUrl;
    }

    // استخراج public_id من الرابط
    final uri = Uri.parse(originalUrl);
    final pathSegments = uri.pathSegments;
    
    if (pathSegments.length < 3) {
      return originalUrl;
    }

    final versionIndex = pathSegments.indexWhere((segment) => segment.startsWith('v'));
    if (versionIndex == -1) {
      return originalUrl;
    }

    final publicIdParts = pathSegments.sublist(versionIndex + 1);
    final publicId = publicIdParts.join('/').replaceAll(RegExp(r'\.[^.]+$'), '');

    // بناء رابط محسن
    final transformations = <String>[];
    
    if (width != null || height != null) {
      final crop = 'c_fill';
      final dimensions = [
        if (width != null) 'w_$width',
        if (height != null) 'h_$height',
      ].join(',');
      transformations.add('$crop,$dimensions');
    }
    
    transformations.addAll([
      'q_$quality',
      'f_$format',
    ]);

    final transformationString = transformations.join(',');
    return 'https://res.cloudinary.com/$_cloudName/image/upload/$transformationString/$publicId';
  }

  // الحصول على رابط مصغر للصورة
  static String getThumbnailUrl(String originalUrl, {int size = 150}) {
    return getOptimizedImageUrl(
      originalUrl,
      width: size,
      height: size,
      quality: 'auto:low',
    );
  }

  // التحقق من صحة إعدادات Cloudinary
  static bool isConfigured() {
    return _cloudName != 'YOUR_CLOUD_NAME' &&
           _apiKey != 'YOUR_API_KEY' &&
           _apiSecret != 'YOUR_API_SECRET';
  }

  // اختبار الاتصال مع Cloudinary
  static Future<bool> testConnection() async {
    if (!isConfigured()) {
      return false;
    }

    try {
      final uri = Uri.parse('$_baseUrl/$_cloudName/image/upload');
      final response = await http.get(uri);
      return response.statusCode == 400; // 400 يعني أن API يعمل لكن الطلب غير صحيح
    } catch (e) {
      return false;
    }
  }
}

