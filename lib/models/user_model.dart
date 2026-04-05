import 'package:cloud_firestore/cloud_firestore.dart';

// AppUser model for Firestore documents.
// `factory` constructors (like `fromSnapshot`) are commonly used to create instances from Firestore's `DocumentSnapshot`.
class AppUser {
  final String id;
  final String email;
  final String displayName;
  final String? profilePhotoUrl;
  final String? phoneNumber;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final String userType; // 'citizen', 'admin'
  final String? address;
  final String? city;
  final double? latitude;
  final double? longitude;

  AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.profilePhotoUrl,
    this.phoneNumber,
    required this.createdAt,
    this.lastLoginAt,
    this.userType = 'citizen',
    this.address,
    this.city,
    this.latitude,
    this.longitude,
  });

  /// Convert AppUser to JSON for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'profilePhotoUrl': profilePhotoUrl,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt,
      'lastLoginAt': lastLoginAt,
      'userType': userType,
      'address': address,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// Create AppUser from Firestore document
  factory AppUser.fromMap(Map<String, dynamic> map, String docId) {
    return AppUser(
      id: docId,
      email: map['email'] ?? '',
      // prefer explicit displayName; default to empty so UI can derive first name from email
      displayName: map['displayName'] ?? '',
      profilePhotoUrl: map['profilePhotoUrl'],
      phoneNumber: map['phoneNumber'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (map['lastLoginAt'] as Timestamp?)?.toDate(),
      userType: map['userType'] ?? 'citizen',
      address: map['address'],
      city: map['city'],
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
    );
  }

  /// Create AppUser from Firestore DocumentSnapshot
  factory AppUser.fromSnapshot(DocumentSnapshot snapshot) {
    return AppUser.fromMap(snapshot.data() as Map<String, dynamic>, snapshot.id);
  }

  /// Copy with method for immutability
  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? profilePhotoUrl,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? userType,
    String? address,
    String? city,
    double? latitude,
    double? longitude,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      userType: userType ?? this.userType,
      address: address ?? this.address,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
