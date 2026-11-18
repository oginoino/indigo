import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:indigo/service/persistence/avatar_image_service.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AvatarImageService', () {
    late Directory temporaryDirectory;
    late Directory storageDirectory;
    late SharedPreferences preferences;
    late AvatarImageService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      preferences = await SharedPreferences.getInstance();
      temporaryDirectory = await Directory.systemTemp.createTemp(
        'avatar-image-service-test-',
      );
      storageDirectory = Directory(
        path.join(temporaryDirectory.path, 'app-support'),
      );
      service = AvatarImageService(
        preferences: preferences,
        storageDirectory: storageDirectory,
      );
    });

    tearDown(() async {
      await temporaryDirectory.delete(recursive: true);
    });

    test('saves an image locally and removes it when cleared', () async {
      final source = File(path.join(temporaryDirectory.path, 'source.png'));
      await source.writeAsBytes([1, 2, 3]);

      final savedImage = await service.saveImage(source);

      expect(savedImage.parent.path, storageDirectory.path);
      expect(await savedImage.readAsBytes(), [1, 2, 3]);
      expect((await service.loadImage())?.path, savedImage.path);

      await service.clearImage();

      expect(await savedImage.exists(), isFalse);
      expect(await service.loadImage(), isNull);
    });

    test('clears a stale image path from preferences', () async {
      SharedPreferences.setMockInitialValues({
        'profileAvatarImagePath': path.join(temporaryDirectory.path, 'missing'),
      });
      preferences = await SharedPreferences.getInstance();
      service = AvatarImageService(
        preferences: preferences,
        storageDirectory: storageDirectory,
      );

      expect(await service.loadImage(), isNull);
      expect(preferences.getString('profileAvatarImagePath'), isNull);
    });
  });
}
