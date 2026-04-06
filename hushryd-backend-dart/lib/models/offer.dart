import 'dart:math';
import '../config/database.dart';

class Offer {
  final String id;
  final String? code;
  final String? title;
  final String? description;
  final String discountType;
  final double? discountValue;
  final double? minAmount;
  final double? maxDiscount;
  final int? maxUses;
  final int usedCount;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final bool isActive;
  final String applicableTo;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Offer({
    required this.id,
    this.code,
    this.title,
    this.description,
    this.discountType = 'percentage',
    this.discountValue,
    this.minAmount,
    this.maxDiscount,
    this.maxUses,
    this.usedCount = 0,
    this.validFrom,
    this.validUntil,
    this.isActive = true,
    this.applicableTo = 'all',
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory Offer.fromRow(Map<String, dynamic> row) {
    return Offer(
      id: row['id'] as String,
      code: row['code'] as String?,
      title: row['title'] as String?,
      description: row['description'] as String?,
      discountType: row['discount_type'] as String? ?? 'percentage',
      discountValue: _toDouble(row['discount_value']),
      minAmount: _toDouble(row['min_amount']),
      maxDiscount: _toDouble(row['max_discount']),
      maxUses: row['max_uses'] as int?,
      usedCount: row['used_count'] as int? ?? 0,
      validFrom: row['valid_from'] as DateTime?,
      validUntil: row['valid_until'] as DateTime?,
      isActive: row['is_active'] as bool? ?? true,
      applicableTo: row['applicable_to'] as String? ?? 'all',
      createdBy: row['created_by'] as String?,
      createdAt: row['created_at'] as DateTime?,
      updatedAt: row['updated_at'] as DateTime?,
    );
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  bool get isValid {
    final now = DateTime.now();
    return isActive &&
        (validFrom == null || now.isAfter(validFrom!)) &&
        (validUntil == null || now.isBefore(validUntil!)) &&
        (maxUses == null || usedCount < maxUses!);
  }

  double calculateDiscount(double amount) {
    double discount = 0;
    if (discountType == 'percentage' && discountValue != null) {
      discount = (amount * discountValue!) / 100;
      if (maxDiscount != null) {
        discount = min(discount, maxDiscount!);
      }
    } else if (discountValue != null) {
      discount = discountValue!;
    }
    return max(0, discount);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'title': title,
        'description': description,
        'discountType': discountType,
        'discountValue': discountValue,
        'minAmount': minAmount,
        'maxDiscount': maxDiscount,
        'maxUses': maxUses,
        'usedCount': usedCount,
        'validFrom': validFrom?.toIso8601String(),
        'validUntil': validUntil?.toIso8601String(),
        'isActive': isActive,
        'applicableTo': applicableTo,
        'createdBy': createdBy,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'isValid': isValid,
      };

  static Future<Offer?> findById(String id) async {
    final result = await Database.query(
      'SELECT * FROM offers WHERE id = @id',
      parameters: {'id': id},
    );
    if (result.isEmpty) return null;
    return Offer.fromRow(result.first.toColumnMap());
  }

  static Future<Offer?> findByCode(String code) async {
    final result = await Database.query(
      'SELECT * FROM offers WHERE code = @code',
      parameters: {'code': code},
    );
    if (result.isEmpty) return null;
    return Offer.fromRow(result.first.toColumnMap());
  }

  static Future<Offer> create(Map<String, dynamic> data) async {
    await Database.query(
      '''INSERT INTO offers (id, code, title, description, discount_type, discount_value,
           min_amount, max_discount, max_uses, valid_from, valid_until, is_active, applicable_to, created_by)
         VALUES (@id, @code, @title, @description, @discountType, @discountValue,
           @minAmount, @maxDiscount, @maxUses, @validFrom, @validUntil, @isActive, @applicableTo, @createdBy)''',
      parameters: {
        'id': data['id'],
        'code': data['code'],
        'title': data['title'],
        'description': data['description'],
        'discountType': data['discountType'] ?? 'percentage',
        'discountValue': data['discountValue'],
        'minAmount': data['minAmount'] ?? 0,
        'maxDiscount': data['maxDiscount'],
        'maxUses': data['maxUses'],
        'validFrom': data['validFrom'],
        'validUntil': data['validUntil'],
        'isActive': data['isActive'] ?? true,
        'applicableTo': data['applicableTo'] ?? 'all',
        'createdBy': data['createdBy'],
      },
    );
    return (await findById(data['id'] as String))!;
  }

  static Future<List<Offer>> findAll({
    int page = 1,
    int limit = 10,
    bool? isActive,
    String? applicableTo,
  }) async {
    var sql = 'SELECT * FROM offers WHERE 1=1';
    final params = <String, dynamic>{};

    if (isActive != null) {
      sql += ' AND is_active = @isActive';
      params['isActive'] = isActive;
    }
    if (applicableTo != null) {
      sql += ' AND applicable_to = @applicableTo';
      params['applicableTo'] = applicableTo;
    }

    final offset = (page - 1) * limit;
    sql += ' ORDER BY created_at DESC LIMIT @limit OFFSET @offset';
    params['limit'] = limit;
    params['offset'] = offset;

    final result = await Database.query(sql, parameters: params);
    return result.map((r) => Offer.fromRow(r.toColumnMap())).toList();
  }

  static Future<List<Offer>> findActive() async {
    final result = await Database.query('''
      SELECT * FROM offers
      WHERE is_active = true
        AND valid_from <= CURRENT_TIMESTAMP
        AND valid_until >= CURRENT_TIMESTAMP
        AND (max_uses IS NULL OR used_count < max_uses)
      ORDER BY created_at DESC
    ''');
    return result.map((r) => Offer.fromRow(r.toColumnMap())).toList();
  }

  Future<Offer> update(Map<String, dynamic> data) async {
    final fieldMapping = {
      'title': 'title',
      'description': 'description',
      'discountType': 'discount_type',
      'discountValue': 'discount_value',
      'minAmount': 'min_amount',
      'maxDiscount': 'max_discount',
      'maxUses': 'max_uses',
      'validFrom': 'valid_from',
      'validUntil': 'valid_until',
      'isActive': 'is_active',
      'applicableTo': 'applicable_to',
    };

    final sets = <String>[];
    final params = <String, dynamic>{'id': id};

    for (final entry in data.entries) {
      if (fieldMapping.containsKey(entry.key) && entry.value != null) {
        final dbKey = fieldMapping[entry.key]!;
        sets.add('$dbKey = @${entry.key}');
        params[entry.key] = entry.value;
      }
    }

    if (sets.isEmpty) throw Exception('No valid fields to update');

    sets.add('updated_at = CURRENT_TIMESTAMP');
    await Database.query(
      'UPDATE offers SET ${sets.join(', ')} WHERE id = @id',
      parameters: params,
    );
    return (await findById(id))!;
  }

  Future<void> delete() async {
    await Database.query('DELETE FROM offers WHERE id = @id',
        parameters: {'id': id});
  }

  Future<void> incrementUsage() async {
    await Database.query(
      'UPDATE offers SET used_count = used_count + 1 WHERE id = @id',
      parameters: {'id': id},
    );
  }

  Future<Map<String, dynamic>> getUsageStats() async {
    final result = await Database.query('''
      SELECT
        COUNT(*) as total_uses,
        COALESCE(SUM(discount_amount), 0) as total_discount,
        COALESCE(SUM(final_amount), 0) as total_revenue
      FROM offer_usage
      WHERE offer_id = @id
    ''', parameters: {'id': id});
    if (result.isEmpty) {
      return {'total_uses': 0, 'total_discount': 0, 'total_revenue': 0};
    }
    return result.first.toColumnMap();
  }
}
