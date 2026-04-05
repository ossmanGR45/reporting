import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/issue_model.dart';
import '../models/user_model.dart';
import '../models/notification_model.dart';

// FirebaseService: helper class wrapping Firestore and Firebase Auth operations.
// `Future<T>`: represents a single asynchronous result (use `await` to retrieve the value).
// `Stream<T>`: represents a continuous asynchronous sequence of values over time (listen to it for updates).
class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collections references
  static const String usersCollection = 'users';
  static const String issuesCollection = 'issues';
  static const String notificationsCollection = 'notifications';

  // ============ User Methods ============

  /// Create or update user 
  Future<void> createOrUpdateUser(AppUser user) async {
    try {
      await _firestore
          .collection(usersCollection)
          .doc(user.id)
          .set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Error creating/updating user: $e');
    }
  }

  /// Get current user 
  Future<AppUser?> getCurrentUser() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      final doc = await _firestore
          .collection(usersCollection)
          .doc(currentUser.uid)
          .get();

      if (doc.exists) {
        return AppUser.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error getting current user: $e');
    }
  }

  /// Get user by ID
  Future<AppUser?> getUserById(String userId) async {
    try {
      final doc = await _firestore
          .collection(usersCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        return AppUser.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error getting user: $e');
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    required String displayName,
    String? phoneNumber,
    String? address,
    String? city,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      await _firestore.collection(usersCollection).doc(currentUser.uid).update({
        'displayName': displayName,
        'phoneNumber': phoneNumber,
        'address': address,
        'city': city,
        'lastLoginAt': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Error updating user profile: $e');
    }
  }

  /// Get all users (admin)
  Future<List<AppUser>> getAllUsers() async {
    try {
      final snapshot = await _firestore
          .collection(usersCollection)
          .orderBy('createdAt', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => AppUser.fromSnapshot(doc))
          .toList();
    } catch (e) {
      throw Exception('Error getting all users: $e');
    }
  }

  /// Update a user's type/role (e.g. 'admin' or 'citizen')
  Future<void> updateUserType(String userId, String newType) async {
    try {
      await _firestore.collection(usersCollection).doc(userId).update({
        'userType': newType,
      });
    } catch (e) {
      throw Exception('Error updating user type: $e');
    }
  }

  /// Delete user document (note: does not delete Firebase Auth account)
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection(usersCollection).doc(userId).delete();
    } catch (e) {
      throw Exception('Error deleting user: $e');
    }
  }

  // ============ Issue Methods ============

  /// Create a new issue
  Future<String> createIssue({
    required String category,
    required String title,
    required String description,
    required String location,
    List<String> imageUrls = const [],
    double? latitude,
    double? longitude,
    String priority = 'medium',
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      final newIssue = Issue(
        id: '', // Will be set by Firestore
        userId: currentUser.uid,
        category: category,
        title: title,
        description: description,
        location: location,
        status: 'reported',
        imageUrls: imageUrls,
        createdAt: DateTime.now(),
        latitude: latitude,
        longitude: longitude,
        priority: priority,
      );

      final docRef = await _firestore
          .collection(issuesCollection)
          .add(newIssue.toMap());

      return docRef.id;
    } catch (e) {
      throw Exception('Error creating issue: $e');
    }
  }

  /// Get all issues for current user
  Future<List<Issue>> getUserIssues() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      final snapshot = await _firestore
          .collection(issuesCollection)
          .where('userId', isEqualTo: currentUser.uid)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Issue.fromSnapshot(doc))
          .toList();
    } catch (e) {
      throw Exception('Error getting user issues: $e');
    }
  }

  /// Get all issues (for admin or public view)
  Future<List<Issue>> getAllIssues() async {
    try {
      final snapshot = await _firestore
          .collection(issuesCollection)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Issue.fromSnapshot(doc))
          .toList();
    } catch (e) {
      throw Exception('Error getting all issues: $e');
    }
  }

  /// Get issue by ID
  Future<Issue?> getIssueById(String issueId) async {
    try {
      final doc = await _firestore
          .collection(issuesCollection)
          .doc(issueId)
          .get();

      if (doc.exists) {
        return Issue.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error getting issue: $e');
    }
  }

  /// Get issues by category
  Future<List<Issue>> getIssuesByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection(issuesCollection)
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Issue.fromSnapshot(doc))
          .toList();
    } catch (e) {
      throw Exception('Error getting issues by category: $e');
    }
  }

  /// Update issue status
  Future<void> updateIssueStatus(String issueId, String newStatus) async {
    try {
      await _firestore
          .collection(issuesCollection)
          .doc(issueId)
          .update({
        'status': newStatus,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Error updating issue status: $e');
    }
  }

  /// Upvote an issue
  Future<void> upvoteIssue(String issueId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      final issueDoc = await _firestore
          .collection(issuesCollection)
          .doc(issueId)
          .get();

      if (!issueDoc.exists) throw Exception('Issue not found');

      final issue = Issue.fromSnapshot(issueDoc);
      
      if (!issue.upvotedBy.contains(currentUser.uid)) {
        await _firestore
            .collection(issuesCollection)
            .doc(issueId)
            .update({
          'upvotedBy': FieldValue.arrayUnion([currentUser.uid]),
          'upvotes': issue.upvotes + 1,
        });
      }
    } catch (e) {
      throw Exception('Error upvoting issue: $e');
    }
  }

  /// Remove upvote from issue
  Future<void> removeUpvoteFromIssue(String issueId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      final issueDoc = await _firestore
          .collection(issuesCollection)
          .doc(issueId)
          .get();

      if (!issueDoc.exists) throw Exception('Issue not found');

      final issue = Issue.fromSnapshot(issueDoc);
      
      if (issue.upvotedBy.contains(currentUser.uid)) {
        await _firestore
            .collection(issuesCollection)
            .doc(issueId)
            .update({
          'upvotedBy': FieldValue.arrayRemove([currentUser.uid]),
          'upvotes': issue.upvotes - 1,
        });
      }
    } catch (e) {
      throw Exception('Error removing upvote: $e');
    }
  }

  /// Delete an issue
  Future<void> deleteIssue(String issueId) async {
    try {
      await _firestore
          .collection(issuesCollection)
          .doc(issueId)
          .delete();
    } catch (e) {
      throw Exception('Error deleting issue: $e');
    }
  }

  // ============ Notification Methods ============

  /// Create a notification
  Future<String> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? relatedIssueId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final notification = AppNotification(
        id: '', // Will be set by Firestore
        userId: userId,
        title: title,
        message: message,
        type: type,
        relatedIssueId: relatedIssueId,
        createdAt: DateTime.now(),
        metadata: metadata,
      );

      final docRef = await _firestore
          .collection(notificationsCollection)
          .add(notification.toMap());

      return docRef.id;
    } catch (e) {
      throw Exception('Error creating notification: $e');
    }
  }

  /// Get notifications for current user
  Future<List<AppNotification>> getUserNotifications() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      final snapshot = await _firestore
          .collection(notificationsCollection)
          .where('userId', isEqualTo: currentUser.uid)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => AppNotification.fromSnapshot(doc))
          .toList();
    } catch (e) {
      throw Exception('Error getting notifications: $e');
    }
  }

  /// Get unread notifications count
  Future<int> getUnreadNotificationsCount() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      final snapshot = await _firestore
          .collection(notificationsCollection)
          .where('userId', isEqualTo: currentUser.uid)
          .where('isRead', isEqualTo: false)
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      throw Exception('Error getting unread count: $e');
    }
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection(notificationsCollection)
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      throw Exception('Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      final snapshot = await _firestore
          .collection(notificationsCollection)
          .where('userId', isEqualTo: currentUser.uid)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.update({'isRead': true});
      }
    } catch (e) {
      throw Exception('Error marking all as read: $e');
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore
          .collection(notificationsCollection)
          .doc(notificationId)
          .delete();
    } catch (e) {
      throw Exception('Error deleting notification: $e');
    }
  }

  /// Stream user issues in real-time
  // Returns a Stream<List<Issue>> — subscribe to this to receive real-time updates.
  Stream<List<Issue>> streamUserIssues() {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      return _firestore
          .collection(issuesCollection)
          .where('userId', isEqualTo: currentUser.uid)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Issue.fromSnapshot(doc))
              .toList());
    } catch (e) {
      throw Exception('Error streaming user issues: $e');
    }
  }

  /// Stream all issues in real-time
  Stream<List<Issue>> streamAllIssues() {
    try {
      return _firestore
          .collection(issuesCollection)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => Issue.fromSnapshot(doc)).toList());
    } catch (e) {
      throw Exception('Error streaming all issues: $e');
    }
  }

  /// Stream user notifications in real-time
  Stream<List<AppNotification>> streamUserNotifications() {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      return _firestore
          .collection(notificationsCollection)
          .where('userId', isEqualTo: currentUser.uid)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => AppNotification.fromSnapshot(doc))
              .toList());
    } catch (e) {
      throw Exception('Error streaming notifications: $e');
    }
  }
}
