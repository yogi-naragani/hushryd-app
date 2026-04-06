import 'dart:math';
import 'package:hushryd_backend/config/database.dart';

/// Offer/promotion model with MySQL queries.
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
  final String? validFrom;
  final String? validUntil;
  final bool isActive;
  final String applicableTo;
  final String? createdBy;
  final String? createdAt;
  final String? updatedAt;

  Offer({
    required this.id, this.code, this.title, this.description,
    this.discountType = 'percentage', this.discountValue, this.minAmount,
    this.maxDiscount, this.maxUses, this.usedCount = 0,
    this.validFrom, this.validUntil, this.isActive = true,
    this.applicableTo = 'all', this.createdBy, this.createdAt, this.updatedAt,
  });

  factory Offer.fromRow(Map<String, String?> row) => Offer(
    id: row['id'] ?? '', code: row['code'], title: row['title'],
    description: row['description'],
    discountType: row['discount_type'] ?? 'percentage',
    discountValue: double.tryParse(row['discount_value'] ?? ''),
    minAmount: double.tryParse(row['min_amount'] ?? ''),
    maxDiscount: double.tryParse(row['max_discount'] ?? ''),
    maxUses: int.tryParse(row['max_uses'] ?? ''),
    usedCount: int.tryParse(row['used_count'] ?? '') ?? 0,
    validFrom: row['valid_from'], validUntil: row['valid_until'],
    isActive: row['is_active'] == '1', applicableTo: row['applicable_to'] ?? 'all',
    createdBy: row['created_by'], createdAt: row['created_at'], updatedAt: row['updated_at'],
  );

  bool get isValid => isActive && (maxUses == null || usedCount < maxUses!);

  double calculateDiscount(double amount) {
    double discount = 0;
    if (discountType == 'percentage' && discountValue != null) {
      discount = (amount * discountValue!) / 100;
      if (maxDiscount != null) discount = min(discount, maxDiscount!);
    } else if (discountValue != null) {
      discount = discountValue!;
    }
    return max(0, discount);
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'code': code, 'title': title, 'description': description,
    'discountType': discountType, 'discountValue': discountValue,
    'minAmount': minAmount, 'maxDiscount': maxDiscount,
    'maxUses': maxUses, 'usedCount': usedCount,
    'validFrom': validFrom, 'validUntil': validUntil,
    'isActive': isActive, 'applicableTo': applicableTo,
    'createdBy': createdBy, 'createdAt': createdAt, 'updatedAt': updatedAt,
    'isValid': isValid,
  };

  static Future<Offer?> findById(String id) async {
    final result = await Database.query('SELECT * FROM offers WHERE id = :id', {'id': id});
    final rows = result.rows.toList();
    if (rows.isEmpty) return null;
    return Offer.fromRow(rows.first.assoc());
  }

  static Future<Offer?> findByCode(String code) async {
    final result = await Database.query('SELECT * FROM offers WHERE code = :code', {'code': code});
    final rows = result.rows.toList();
    if (rows.isEmpty) return null;
    return Offer.fromRow(rows.first.assoc());
  }

  static Future<Offer> create(Map<String, dynamic> data) async {
    await Database.query(
      '''INSERT INTO offers (id, code, title, description, discount_type, discount_value,
         min_amount, max_discount, max_uses, valid_from, valid_until, is_active, applicable_to, created_by)
         VALUES (:id, :code, :title, :description, :discountType, :discountValue,
         :minAmount, :maxDiscount, :maxUses, :validFrom, :validUntil, :isActive, :applicableTo, :createdBy)''',
      {
        'id': data['id'], 'code': data['code'], 'title': data['title'],
        'description': data['description'],
        'discountType': data['discountType'] ?? 'percentage',
        'discountValue': data['discountValue']?.toString(),
        'minAmount': (data['minAmount'] ?? 0).toString(),
        'maxDiscount': data['maxDiscount']?.toString(),
        'maxUses': data['maxUses']?.toString(),
        'validFrom': data['validFrom'], 'validUntil': data['validUntil'],
        'isActive': data['isActive'] != false ? '1' : '0',
        'applicableTo': data['applicableTo'] ?? 'all',
        'createdBy': data['createdBy'],
      },
    );
    return (await findById(data['id'] as String))!;
  }

  static Future<List<Offer>> findAll({int page = 1, int limit = 10,
      bool? isActive, String? applicableTo}) async {
    var sql = 'SELECT * FROM offers WHERE 1=1';
    final params = <String, dynamic>{};
    if (isActive != null) { sql += ' AND is_active = :isActive'; params['isActive'] = isActive ? '1' : '0'; }
    if (applicableTo != null) { sql += ' AND applicable_to = :applicableTo'; params['applicableTo'] = applicableTo; }
    sql += ' ORDER BY created_at DESC LIMIT :lim OFFSET :off';
    params['lim'] = limit.toString();
    params['off'] = ((page - 1) * limit).toString();
    final result = await Database.query(sql, params);
    return result.rows.map((r) => Offer.fromRow(r.assoc())).toList();
  }

  static Future<List<Offer>> findActive() async {
    final result = await Database.query('''
      SELECT * FROM offers WHERE is_active = 1
        AND valid_from <= NOW() AND valid_until >= NOW()
        AND (max_uses IS NULL OR used_count < max_uses)
      ORDER BY created_at DESC
    ''');
    return result.rows.map((r) => Offer.fromRow(r.assoc())).toList();
  }

  Future<Offer> update(Map<String, dynamic> data) async {
    final mapping = {
      'title': 'title', 'description': 'description',
      'discountType': 'discount_type', 'discountValue': 'discount_value',
      'minAmount': 'min_amount', 'maxDiscount': 'max_discount',
      'maxUses': 'max_uses', 'validFrom': 'valid_from', 'validUntil': 'valid_until',
      'isActive': 'is_active', 'applicableTo': 'applicable_to',
    };
    final sets = <String>[]; final params = <String, dynamic>{};
    for (final e in data.entries) {
      if (mapping.containsKey(e.key) && e.value != null) {
        sets.add('${mapping[e.key]} = :${e.key}');
        params[e.key] = e.value.toString();
      }
    }
    if (sets.isEmpty) throw Exception('No valid fields to update');
    sets.add('updated_at = CURRENT_TIMESTAMP');
    params['id'] = id;
    await Database.query('UPDATE offers SET ${sets.join(', ')} WHERE id = :id', params);
    return (await findById(id))!;
  }

  Future<void> delete() async =>
      Database.query('DELETE FROM offers WHERE id = :id', {'id': id});
}
