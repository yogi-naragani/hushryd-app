import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:uuid/uuid.dart';
import '../models/offer.dart';
import '../config/database.dart';
import '../middleware/auth_middleware.dart';
import '../utils/response.dart';

class OfferRoutes {
  final _uuid = const Uuid();

  Router get router {
    final router = Router();

    // Public routes
    router.get('/active', _getActive);
    router.post('/verify', _verify);

    // Admin routes
    router.get('/', _withAdminAuth(_getAll));
    router.post('/', _withAdminAuth(_create));

    router.get('/<id>/usage', _paramWithAdminAuth(_getUsage));
    router.get('/<id>', _paramWithAdminAuth(_getById));
    router.put('/<id>', _paramWithAdminAuth(_updateById));
    router.delete('/<id>', _paramWithAdminAuth(_deleteById));

    return router;
  }

  Handler _withAdminAuth(Future<Response> Function(Request) h) =>
      Pipeline()
          .addMiddleware(authenticateAdmin())
          .addMiddleware(requireRole(['superadmin', 'admin']))
          .addHandler(h);

  Function _paramWithAdminAuth(Future<Response> Function(Request, String) h) {
    return (Request request, String id) async {
      return Pipeline()
          .addMiddleware(authenticateAdmin())
          .addMiddleware(requireRole(['superadmin', 'admin']))
          .addHandler((req) => h(req, id))(request);
    };
  }

  Future<Response> _getAll(Request request) async {
    try {
      final params = request.requestedUri.queryParameters;
      final page = int.tryParse(params['page'] ?? '') ?? 1;
      final limit = int.tryParse(params['limit'] ?? '') ?? 10;

      final offers = await Offer.findAll(
        page: page, limit: limit,
        isActive: params['isActive'] != null ? params['isActive'] == 'true' : null,
      );

      return ApiResponse.success('Offers retrieved successfully', data: {
        'offers': offers.map((o) => o.toJson()).toList(),
      });
    } catch (e) {
      print('Get offers error: $e');
      return ApiResponse.error('Internal server error');
    }
  }

  Future<Response> _getActive(Request request) async {
    try {
      final offers = await Offer.findActive();
      return ApiResponse.success('Active offers retrieved successfully', data: {
        'offers': offers.map((o) => o.toJson()).toList(),
      });
    } catch (e) {
      print('Get active offers error: $e');
      return ApiResponse.error('Internal server error');
    }
  }

  Future<Response> _getById(Request request, String id) async {
    try {
      final offer = await Offer.findById(id);
      if (offer == null) return ApiResponse.notFound('Offer not found');
      final stats = await offer.getUsageStats();
      return ApiResponse.success('Offer retrieved successfully',
          data: {'offer': offer.toJson(), 'stats': stats});
    } catch (e) {
      print('Get offer error: $e');
      return ApiResponse.error('Internal server error');
    }
  }

  Future<Response> _create(Request request) async {
    try {
      final body = await parseJsonBody(request);
      for (final f in ['code', 'title', 'discountValue', 'validFrom', 'validUntil']) {
        if (body[f] == null) return ApiResponse.badRequest('$f is required');
      }

      final code = (body['code'] as String).toUpperCase();
      final existing = await Offer.findByCode(code);
      if (existing != null) return ApiResponse.conflict('Offer code already exists');

      final adminId = request.context['adminId'] as String?;
      final offer = await Offer.create({
        'id': _uuid.v4(),
        'code': code,
        'title': body['title'],
        'description': body['description'],
        'discountType': body['discountType'] ?? 'percentage',
        'discountValue': body['discountValue'],
        'minAmount': body['minAmount'] ?? 0,
        'maxDiscount': body['maxDiscount'],
        'maxUses': body['maxUses'],
        'validFrom': body['validFrom'],
        'validUntil': body['validUntil'],
        'isActive': body['isActive'] ?? true,
        'applicableTo': body['applicableTo'] ?? 'all',
        'createdBy': body['createdBy'] ?? adminId,
      });

      return ApiResponse.created('Offer created successfully',
          data: {'offer': offer.toJson()});
    } catch (e) {
      print('Create offer error: $e');
      return ApiResponse.error('Internal server error');
    }
  }

  Future<Response> _updateById(Request request, String id) async {
    try {
      final offer = await Offer.findById(id);
      if (offer == null) return ApiResponse.notFound('Offer not found');
      final body = await parseJsonBody(request);
      final updatedOffer = await offer.update(body);
      return ApiResponse.success('Offer updated successfully',
          data: {'offer': updatedOffer.toJson()});
    } catch (e) {
      print('Update offer error: $e');
      return ApiResponse.error('Internal server error');
    }
  }

  Future<Response> _deleteById(Request request, String id) async {
    try {
      final offer = await Offer.findById(id);
      if (offer == null) return ApiResponse.notFound('Offer not found');
      await offer.delete();
      return ApiResponse.success('Offer deleted successfully');
    } catch (e) {
      print('Delete offer error: $e');
      return ApiResponse.error('Internal server error');
    }
  }

  Future<Response> _getUsage(Request request, String id) async {
    try {
      final offer = await Offer.findById(id);
      if (offer == null) return ApiResponse.notFound('Offer not found');
      final result = await Database.query('''
        SELECT ou.*, u.first_name, u.last_name, u.email, u.phone
        FROM offer_usage ou LEFT JOIN users u ON ou.user_id = u.id
        WHERE ou.offer_id = @id ORDER BY ou.used_at DESC
      ''', parameters: {'id': id});
      return ApiResponse.success('Offer usage retrieved successfully',
          data: {'usage': result.map((r) => r.toColumnMap()).toList()});
    } catch (e) {
      print('Get offer usage error: $e');
      return ApiResponse.error('Internal server error');
    }
  }

  Future<Response> _verify(Request request) async {
    try {
      final body = await parseJsonBody(request);
      final code = body['code'] as String?;
      if (code == null || code.isEmpty) {
        return ApiResponse.badRequest('Offer code is required');
      }

      final offer = await Offer.findByCode(code.toUpperCase());
      if (offer == null) return ApiResponse.notFound('Invalid offer code');
      if (!offer.isValid) return ApiResponse.badRequest('Offer code is not valid or has expired');

      final amount = body['amount'] != null
          ? (body['amount'] is num ? (body['amount'] as num).toDouble() : double.tryParse(body['amount'].toString()))
          : null;

      if (amount != null && offer.minAmount != null && amount < offer.minAmount!) {
        return ApiResponse.badRequest('Minimum amount of ${offer.minAmount} required');
      }

      final discount = amount != null ? offer.calculateDiscount(amount) : null;
      final finalAmount = amount != null && discount != null ? (amount - discount).clamp(0, double.infinity) : null;

      return ApiResponse.success('Offer code is valid', data: {
        'offer': offer.toJson(),
        'discount': discount,
        'finalAmount': finalAmount,
      });
    } catch (e) {
      print('Verify offer error: $e');
      return ApiResponse.error('Internal server error');
    }
  }
}
