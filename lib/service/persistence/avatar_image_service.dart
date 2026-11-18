import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

import '../../util/const/app/app_strings.dart';

class AvatarImageService {
  AvatarImageService({
    required SharedPreferences preferences,
    required Directory storageDirectory,
  }) : _preferences = preferences,
       _storageDirectory = storageDirectory;

  static const _imagePathKey = 'profileAvatarImagePath';
  static const _fileName = 'profile_avatar';
  static const _supportedExtensions = {
    '.gif',
    '.jpg',
    '.jpeg',
    '.png',
    '.webp',
  };

  final SharedPreferences _preferences;
  final Directory _storageDirectory;

  Future<File?> loadImage() async {
    final imagePath = _preferences.getString(_imagePathKey);
    if (imagePath == null) return null;

    final image = File(imagePath);
    if (await image.exists()) return image;

    final removed = await _preferences.remove(_imagePathKey);
    if (!removed) {
      throw StateError(AppStrings.missingAvatarPathClearFailed);
    }
    return null;
  }

  Future<File> saveImage(File source) async {
    if (!await source.exists()) {
      throw FileSystemException(AppStrings.avatarImageMissing, source.path);
    }

    await _storageDirectory.create(recursive: true);
    final extension = path.extension(source.path).toLowerCase();
    final supportedExtension = _supportedExtensions.contains(extension)
        ? extension
        : '';
    final destination = File(
      path.join(_storageDirectory.path, '$_fileName$supportedExtension'),
    );

    if (path.normalize(source.absolute.path) !=
        path.normalize(destination.absolute.path)) {
      await source.copy(destination.path);
    }

    final saved = await _preferences.setString(_imagePathKey, destination.path);
    if (!saved) {
      throw StateError(AppStrings.avatarPathSaveFailed);
    }

    return destination;
  }

  Future<void> clearImage() async {
    final imagePath = _preferences.getString(_imagePathKey);
    if (imagePath != null) {
      final image = File(imagePath);
      if (await image.exists()) {
        await image.delete();
      }

      final removed = await _preferences.remove(_imagePathKey);
      if (!removed) {
        throw StateError(AppStrings.avatarPathRemoveFailed);
      }
    }
  }
}
