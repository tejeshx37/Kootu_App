import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

/// Thin wrapper around Firebase Storage for user-generated media.
class StorageService {
  StorageService(this._storage);
  final FirebaseStorage _storage;

  /// Uploads a profile photo to `profile_photos/{uid}.jpg` and returns the
  /// public download URL. Overwrites any previous photo for the same user.
  Future<String> uploadProfilePhoto(String uid, File file) async {
    final ref = _storage.ref('profile_photos/$uid.jpg');
    await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return ref.getDownloadURL();
  }
}
