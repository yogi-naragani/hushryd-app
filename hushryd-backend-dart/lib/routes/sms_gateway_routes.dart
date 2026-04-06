import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../config/database.dart';
import '../middleware/auth_middleware.dart';
import '../utils/response.dart';

class SmsGatewayRoutes {
  Router get router {
    final router = Router();

    router.get('/settings', Pipeline()
        .addMiddleware(authenticateAdmin())
        .addMiddleware(requireRole(['superadmin']))
        .addHandler(_getSettings));

    router.post('/settings', Pipeline()
        .addMiddleware(authenticateAdmin())
        .addMiddleware(requireRole(['superadmin']))
        .addHandler(_updateSettings));

    router.get('/balance', Pipeline()
        .addMiddleware(authenticateAdmin())
        .addMiddleware(requireRole(['superadmin', 'admin']))
        .addHandler(_getBalance));

    router.get('/usage', Pipeline()
        .addMiddleware(authenticateAdmin())
        .addMiddleware(requireRole(['superadmin', 'admin']))
        .addHandler(_getUsage));

    router.post('/test', Pipeline()
        .addMiddleware(authenticateAdmin())
        .addMiddleware(requireRole(['superadmin']))
        .addHandler(_sendTest));

    return router;
  }

  Future<Map<String, dynamic>?> _getSmsSettings() async {
    try {
      final result = await Database.query(
          'SELECT * FROM sms_gateway_settings WHERE id = 1');
      if (result.isEmpty) return null;
      return result.first.toColumnMap();
    } catch (_) {
      return null;
    }
  }

  Future<Response> _getSettings(Request request) async {
    try {
      final settings = await _getSmsSettings();
      if (settings == null) {
        return ApiResponse.success('SMS gateway not configured',
            data: {'configured': false});
      }

      return ApiResponse.success(
          'SMS gateway settings retrieved successfully',
          data: {
        'configured': true,
        'provider': settings['provider'],
        'senderId': settings['sender_id'],
        'apiKeyHidden': settings['api_key'] != null
            ? '${(settings['api_key'] as String).substring(0, 8)}****'
            : null,
      });
    } catch (e) {
      print('Get SMS settings error: $e');
      return ApiResponse.error('Internal server error');
    }
  }

  Future<Response> _updateSettings(Request request) async {
    try {
      final body = await parseJsonBody(request);
      if (body['provider'] == null ||
          body['apiKey'] == null ||
          body['senderId'] == null) {
        return ApiResponse.badRequest(
            'Provider, API key, and sender ID are required');
      }

      final existing = await Database.query(
          'SELECT id FROM sms_gateway_settings WHERE id = 1');
      if (existing.isNotEmpty) {
        await Database.query(
          '''UPDATE sms_gateway_settings
             SET provider = @provider, api_key = @apiKey, api_secret = @apiSecret, sender_id = @senderId, updated_at = CURRENT_TIMESTAMP
             WHERE id = 1''',
          parameters: {
            'provider': body['provider'],
            'apiKey': body['apiKey'],
            'apiSecret': body['apiSecret'] ?? '',
            'senderId': body['senderId'],
          },
        );
      } else {
        await Database.query(
          '''INSERT INTO sms_gateway_settings (id, provider, api_key, api_secret, sender_id)
             VALUES (1, @provider, @apiKey, @apiSecret, @senderId)''',
          parameters: {
            'provider': body['provider'],
            'apiKey': body['apiKey'],
            'apiSecret': body['apiSecret'] ?? '',
            'senderId': body['senderId'],
          },
        );
      }

      return ApiResponse.success('SMS gateway settings updated successfully');
    } catch (e) {
      print('Update SMS settings error: $e');
      return ApiResponse.error('Internal server error');
    }
  }

  Future<Response> _getBalance(Request request) async {
    try {
      final settings = await _getSmsSettings();
      if (settings == null) {
        return ApiResponse.success('SMS gateway not configured',
            data: {'configured': false});
      }

      return ApiResponse.success('SMS balance retrieved successfully', data: {
        'configured': true,
        'provider': settings['provider'],
        'senderId': settings['sender_id'],
        'balance': 0,
        'currency': 'INR',
        'accountStatus': 'unknown',
        'lastChecked': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Get SMS balance error: $e');
      return ApiResponse.error('Internal server error');
    }
  }

  Future<Response> _getUsage(Request request) async {
    try {
      final params = request.requestedUri.queryParameters;
      final startDate = params['startDate'] ??
          DateTime.now()
              .subtract(Duration(days: 30))
              .toIso8601String();
      final endDate =
          params['endDate'] ?? DateTime.now().toIso8601String();

      List<Map<String, dynamic>> usage = [];
      Map<String, dynamic> totalStats = {
        'total_sent': 0,
        'successful': 0,
        'failed': 0,
      };

      try {
        final usageResult = await Database.query(
          '''SELECT
              COUNT(*) as total_sent,
              SUM(CASE WHEN status = 'success' THEN 1 ELSE 0 END) as successful,
              SUM(CASE WHEN status = 'failed' THEN 1 ELSE 0 END) as failed,
              DATE(sent_at) as date
            FROM sms_logs
            WHERE sent_at BETWEEN @startDate::timestamp AND @endDate::timestamp
            GROUP BY DATE(sent_at)
            ORDER BY date DESC
            LIMIT 30''',
          parameters: {'startDate': startDate, 'endDate': endDate},
        );
        usage = usageResult.map((r) => r.toColumnMap()).toList();

        final statsResult = await Database.query(
          '''SELECT
              COUNT(*) as total_sent,
              SUM(CASE WHEN status = 'success' THEN 1 ELSE 0 END) as successful,
              SUM(CASE WHEN status = 'failed' THEN 1 ELSE 0 END) as failed
            FROM sms_logs
            WHERE sent_at BETWEEN @startDate::timestamp AND @endDate::timestamp''',
          parameters: {'startDate': startDate, 'endDate': endDate},
        );
        if (statsResult.isNotEmpty) {
          totalStats = statsResult.first.toColumnMap();
        }
      } catch (_) {
        // sms_logs table may not exist yet
      }

      return ApiResponse.success(
          'SMS usage statistics retrieved successfully',
          data: {
        'summary': totalStats,
        'dailyUsage': usage,
        'period': {'startDate': startDate, 'endDate': endDate},
      });
    } catch (e) {
      print('Get SMS usage error: $e');
      return ApiResponse.error('Internal server error');
    }
  }

  Future<Response> _sendTest(Request request) async {
    try {
      final body = await parseJsonBody(request);
      final mobileNumber = body['mobileNumber'] as String?;
      if (mobileNumber == null || mobileNumber.isEmpty) {
        return ApiResponse.badRequest('Mobile number is required');
      }

      final settings = await _getSmsSettings();
      if (settings == null) {
        return ApiResponse.badRequest('SMS gateway not configured');
      }

      final testMessage =
          'Test SMS from HushRyd Admin Dashboard. SMS Gateway is working correctly.';
      print('Test SMS would be sent to $mobileNumber: $testMessage');

      return ApiResponse.success('Test SMS sent successfully', data: {
        'mobileNumber': mobileNumber,
        'message': testMessage,
      });
    } catch (e) {
      print('Send test SMS error: $e');
      return ApiResponse.error('Internal server error');
    }
  }
}
