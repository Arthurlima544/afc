import 'dart:convert';

enum OperationType { create, update, delete }

/// A write operation queued locally while the device is offline.
///
/// Stored as JSON in SharedPreferences under the key managed by SyncQueue.
class PendingOperationEntity {
  const PendingOperationEntity({
    required this.uuid,
    required this.userId,
    required this.type,
    required this.collection,
    required this.payload,
    required this.createdAt,
    this.retries = 0,
    this.docId,
  });

  factory PendingOperationEntity.fromJson(Map<String, dynamic> json) =>
      PendingOperationEntity(
        uuid: json['uuid'] as String,
        userId: json['userId'] as String,
        type: OperationType.values.byName(json['type'] as String),
        collection: json['collection'] as String,
        payload: Map<String, dynamic>.from(json['payload'] as Map<dynamic, dynamic>),
        createdAt: DateTime.parse(json['createdAt'] as String),
        retries: json['retries'] as int? ?? 0,
        docId: json['docId'] as String?,
      );

  final String uuid;
  final String userId;
  final OperationType type;

  /// Firestore collection name (e.g. 'transaction', 'goal').
  final String collection;

  /// Full document payload (the entity's toJson() output).
  final Map<String, dynamic> payload;

  final DateTime createdAt;
  final int retries;

  /// Firestore document ID — required for update and delete replays.
  final String? docId;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'uuid': uuid,
    'userId': userId,
    'type': type.name,
    'collection': collection,
    'payload': payload,
    'createdAt': createdAt.toIso8601String(),
    'retries': retries,
    if (docId != null) 'docId': docId,
  };

  String toJsonString() => jsonEncode(toJson());

  PendingOperationEntity copyWith({int? retries}) => PendingOperationEntity(
    uuid: uuid,
    userId: userId,
    type: type,
    collection: collection,
    payload: payload,
    createdAt: createdAt,
    retries: retries ?? this.retries,
    docId: docId,
  );
}
