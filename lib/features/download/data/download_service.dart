import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/network/dio_provider.dart';

class DownloadService {
  DownloadService(this._dio);
  final Dio _dio;

  Future<void> saveToGallery({
    required String url,
    required String fileName,
    required void Function(double progress) onProgress,
  }) async {
    try {
      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess && !await Gal.requestAccess(toAlbum: true)) {
        throw const PermissionException(
            'Permission denied. Enable photo access in Settings to save images.');
      }
    } on GalException catch (e) {
      throw PermissionException('Could not get permission: ${e.type.message}');
    }

    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/$fileName.jpg';
    try {
      await _dio.download(url, path, onReceiveProgress: (received, total) {
        if (total > 0) onProgress(received / total);
      });
      await Gal.putImage(path, album: 'Infinite Gallery');
    } on DioException {
      throw const DownloadException(
          'Download failed. Check your connection and try again.');
    } on GalException catch (e) {
      throw DownloadException('Could not save image: ${e.type.message}');
    } finally {
      final f = File(path);
      if (await f.exists()) await f.delete();
    }
  }
}

final downloadServiceProvider =
    Provider((ref) => DownloadService(ref.watch(dioProvider)));