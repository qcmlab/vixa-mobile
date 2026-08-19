import 'dart:convert';
import '../storage/storage_service.dart';

class QueuedReview {
  final String cardId;
  final int rating;
  final int responseTimeMs;
  final DateTime createdAt;

  QueuedReview({
    required this.cardId,
    required this.rating,
    required this.responseTimeMs,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'card_id': cardId,
        'rating': rating,
        'response_time_ms': responseTimeMs,
        'created_at': createdAt.toIso8601String(),
      };

  factory QueuedReview.fromJson(Map<String, dynamic> json) => QueuedReview(
        cardId: json['card_id'],
        rating: json['rating'],
        responseTimeMs: json['response_time_ms'] ?? 2500,
        createdAt: DateTime.parse(json['created_at']),
      );
}

class OfflineSyncService {
  final IStorageService _storage;
  static const String _queueKey = 'hafedh_offline_review_queue';

  OfflineSyncService(this._storage);

  List<QueuedReview> getPendingReviews() {
    final raw = _storage.getString(_queueKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((item) => QueuedReview.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> enqueueReview(String cardId, int rating, {int responseTimeMs = 2500}) async {
    final reviews = getPendingReviews();
    reviews.add(
      QueuedReview(
        cardId: cardId,
        rating: rating,
        responseTimeMs: responseTimeMs,
        createdAt: DateTime.now(),
      ),
    );
    final raw = jsonEncode(reviews.map((r) => r.toJson()).toList());
    await _storage.setString(_queueKey, raw);
  }

  Future<void> clearQueue() async {
    await _storage.remove(_queueKey);
  }
}
