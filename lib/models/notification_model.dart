import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type; // 'issue_update', 'system', 'alert'
  final String? relatedIssueId;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? metadata;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.relatedIssueId,
    required this.createdAt,
    this.isRead = false,
    this.metadata,
  });

  /// Convert AppNotification to JSON for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'relatedIssueId': relatedIssueId,
      'createdAt': createdAt,
      'isRead': isRead,
      'metadata': metadata,
    };
  }

  /// Create AppNotification from Firestore document
  factory AppNotification.fromMap(Map<String, dynamic> map, String docId) {
    return AppNotification(
      id: docId,
      userId: map['userId'] ?? '',
      title: map['title'] ?? 'Notification',
      message: map['message'] ?? '',
      type: map['type'] ?? 'system',
      relatedIssueId: map['relatedIssueId'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: map['isRead'] ?? false,
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Create AppNotification from Firestore DocumentSnapshot
  factory AppNotification.fromSnapshot(DocumentSnapshot snapshot) {
    return AppNotification.fromMap(snapshot.data() as Map<String, dynamic>, snapshot.id);
  }

  /// Copy with method for immutability
  AppNotification copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    String? type,
    String? relatedIssueId,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? metadata,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      relatedIssueId: relatedIssueId ?? this.relatedIssueId,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      metadata: metadata ?? this.metadata,
    );
  }
}
