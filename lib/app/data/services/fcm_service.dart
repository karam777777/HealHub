import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';

class FCMService {
  static const String _fcmUrl =
      'https://fcm.googleapis.com/v1/projects/YOUR_PROJECT_ID/messages:send';

  // Service account credentials (should be stored securely)
  static const Map<String, dynamic> _serviceAccountCredentials = {
    "type": "service_account",
    "project_id": "my-pro-fcc67",
    "private_key_id": "a005dfc6bd5b79c24f4db40def64e78da7a0e915",
    "private_key":
        "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCvdgYT6qpmd7NO\nSFPwt8lQ8TYBxx6OmjEu1d2QW8IJQ7MXc/7jJ7RiKgm+0duHQodcFmMEFMXk1WEv\noqLMSBAguKArJREFaqRsLpzXD3czXhrfx0TE2TlwIRwovPezJLQShopKX7sPxwJU\nufpoDiHEPDRoxvvaXRhMMsK0JMHYKIa+UMRG+qkm55xtRvdZ+7X7Hc4G3H/10jyY\nAo3JmO18qURFUZc/kiQk7DE4GfKzp/QvF4QpK9fqkF4ZTM/eI3Y2EpPI20ZzxFOY\n3ZoUwjLsp3etYlIwb3kNcxeaWUHweMcYhXRoYSMGCbwn/wyFTyMgiYuTwdinTpu2\nCn4xAOhxAgMBAAECggEASEoO/Pus0uS0OidwdfeyeKe4gYkBHO2IH+y7CTPUwK5k\nxd/jfsEn/12kgDrEAHk3fYg3qUHJuprzHIYcHp/+DQ0j6EKwPZQPRAb8VVqo2MAH\nwHS/734zvO/XQy1/vA3+JrfJmBTS5BAw9Kle8qoH3WqUiSqaLwA194beUwvl1WFE\ngLk9kDv/mhLVZVCnxbWn1pj+JnBjlP25VRc43kqqy1O1Hd7M5MIFePvLIQDl1Qcz\n63/S6AJr3vLovm6XsIs2jkbkTEtw3R2td3q1Icco8HWmArHtfbUTEOQJeAxDGAWH\nB8Xc4lC+BRHv1zFgHf5DZsGLwxBhfmBJ6tFyvrhvhQKBgQD1ln+k2FQ3Xmv0rGrK\n+3QHdn8JUOn6LGgzOpAQkVloT6+jI8wN9QXAYU3SN3f9TfILMDB3odINVy3zcRlC\n7NDehaqhdIS+gQ3xHNRWbTGNP+Xcx5zW5yXB66LrZzlNmc7zdFpBctqqH3wPChm2\nZuOiepVy86/Co96uv1dVR/dtJwKBgQC25mZG9ss7mQkK/a5XOHMhgySKQWZyvE7y\nKC+7nqE48owxqlDv7bqbp8Ug/3ASB/Eey2JuufLMhnuSruHjcA7NL7u+rxgHqcJu\nAKqDd6nhDwqkq1lp9U7nWA3COAUG1WHdTLms3aLpmFgPsNxdQ5xdUkYG9zNtA7uy\nMGrhOzospwKBgAqLgcOUPll6RmxlEtjQXzUK032U6dcCHR9F/nWXqB0gfswkd1iK\nEssl4m+KTi6kMCZm1U3tttU3zxNK4ejLvlQvrRntpN2BMRYPRNbJLX2BJt+J+qQH\nnMls0rwE3KMGXap6bn2s7tKrM2p55oy8cj3BwbUD3aIf4ynhsWBKDMe1AoGBALKE\nualkM0PNgE0RBHyvZXh9R0oGwZcVg7zKSqTHFTe/TeUgBvXYRL6vBzLI/7sps0hK\nXZ4Tsw+755tpRKO4eUn+4DIjNsIsCNFTpxrAzrgT9WB6usA4JjaZ9HvwL7/WwDm/\nLK+0eNGl17Yg+0Wwu0s/BYjA+Zna/fXTWk7Sf1qbAoGAE3Ijkz1wcRy4KAWQ/PH5\n29Of5Ih4aGLabfkCUyo7tIHdZjIUlJkb6gEzukki00Zqt5WIGv/3UqC5CfMkmm4E\nwKcg2odvSRHpWUEh84DHknk5hgV9Lo3nmBx6Na/DtDx54LHppQrGDRR82lSY6/f/\n7OG2EQtDzN9c1TkkNQAo76c=\n-----END PRIVATE KEY-----\n",
    "client_email":
        "firebase-adminsdk-fbsvc@my-pro-fcc67.iam.gserviceaccount.com",
    "client_id": "117893840134077854472",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url":
        "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40my-pro-fcc67.iam.gserviceaccount.com",
    "universe_domain": "googleapis.com",
  };

  // Get OAuth 2.0 access token
  static Future<String> _getAccessToken() async {
    final accountCredentials = ServiceAccountCredentials.fromJson(
      _serviceAccountCredentials,
    );
    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    final client = await clientViaServiceAccount(accountCredentials, scopes);
    final accessToken = client.credentials.accessToken.data;
    client.close();

    return accessToken;
  }

  // Send notification using FCM V1 API
  static Future<bool> sendNotification({
    required String token,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    try {
      final accessToken = await _getAccessToken();

      final message = {
        'message': {
          'token': token,
          'notification': {'title': title, 'body': body},
          'data': data ?? {},
          'webpush': {
            'headers': {
              'TTL': '86400', // 24 hours
            },
            'notification': {
              'title': title,
              'body': body,
              'icon': '/icons/Icon-192.png',
              'badge': '/icons/Icon-192.png',
              'requireInteraction': true,
              'actions': [
                {'action': 'open', 'title': 'فتح التطبيق'},
              ],
            },
          },
        },
      };

      final response = await http.post(
        Uri.parse(_fcmUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully');
        return true;
      } else {
        print('Failed to send notification: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending notification: $e');
      return false;
    }
  }

  // Send notification to multiple tokens
  static Future<bool> sendNotificationToMultiple({
    required List<String> tokens,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    try {
      final accessToken = await _getAccessToken();

      final message = {
        'message': {
          'registration_ids': tokens,
          'notification': {'title': title, 'body': body},
          'data': data ?? {},
          'webpush': {
            'headers': {
              'TTL': '86400', // 24 hours
            },
            'notification': {
              'title': title,
              'body': body,
              'icon': '/icons/Icon-192.png',
              'badge': '/icons/Icon-192.png',
              'requireInteraction': true,
            },
          },
        },
      };

      final response = await http.post(
        Uri.parse(_fcmUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        print('Notifications sent successfully to ${tokens.length} devices');
        return true;
      } else {
        print('Failed to send notifications: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending notifications: $e');
      return false;
    }
  }
}
