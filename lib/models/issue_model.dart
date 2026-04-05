import 'package:cloud_firestore/cloud_firestore.dart';

class Issue {
  final String id;
  final String userId;
  final String category;
  final String title;
  final String description;
  final String location;
  final String status; // 'reported', 'in_progress', 'resolved', 'closed'
  final List<String> imageUrls;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int upvotes;
  final List<String> upvotedBy;
  final double? latitude;
  final double? longitude;
  final String? priority; // 'low', 'medium', 'high'

  Issue({
    required this.id,
    required this.userId,
    required this.category,
    required this.title,
    required this.description,
    required this.location,
    required this.status,
    required this.imageUrls,
    required this.createdAt,
    this.updatedAt,
    this.upvotes = 0,
    this.upvotedBy = const [],
    this.latitude,
    this.longitude,
    this.priority = 'medium',
  });

  /// Convert Issue to JSON for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'category': category,
      'title': title,
      'description': description,
      'location': location,
      'status': status,
      'imageUrls': imageUrls,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'upvotes': upvotes,
      'upvotedBy': upvotedBy,
      'latitude': latitude,
      'longitude': longitude,
      'priority': priority,
    };
  }

  /// Create Issue from Firestore document
  factory Issue.fromMap(Map<String, dynamic> map, String docId) {
    return Issue(
      id: docId,
      userId: map['userId'] ?? '',
      category: map['category'] ?? 'Other',
      title: map['title'] ?? 'Untitled',
      description: map['description'] ?? '',
      location: map['location'] ?? 'Unknown',
      status: map['status'] ?? 'reported',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      upvotes: map['upvotes'] ?? 0,
      upvotedBy: List<String>.from(map['upvotedBy'] ?? []),
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      priority: map['priority'] ?? 'medium',
    );
  }

  /// Create Issue from Firestore DocumentSnapshot
  factory Issue.fromSnapshot(DocumentSnapshot snapshot) {
    return Issue.fromMap(snapshot.data() as Map<String, dynamic>, snapshot.id);
  }

  /// Copy with method for immutability
  Issue copyWith({
    String? id,
    String? userId,
    String? category,
    String? title,
    String? description,
    String? location,
    String? status,
    List<String>? imageUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? upvotes,
    List<String>? upvotedBy,
    double? latitude,
    double? longitude,
    String? priority,
  }) {
    return Issue(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      status: status ?? this.status,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      upvotes: upvotes ?? this.upvotes,
      upvotedBy: upvotedBy ?? this.upvotedBy,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      priority: priority ?? this.priority,
    );
  }
}
