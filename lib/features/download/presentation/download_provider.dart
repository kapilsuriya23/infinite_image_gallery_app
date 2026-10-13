import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_exception.dart';
import '../../gallery/data/models/pixabay_image.dart';
import '../data/download_service.dart';

enum DownloadStatus { idle, downloading, success, failure }

class DownloadState {
  const DownloadState({
    this.status = DownloadStatus.idle,
    this.progress = 0,
    this.message,
  });
  final DownloadStatus status;
  final double progress;
  final String? message;

  bool get isDownloading => status == DownloadStatus.downloading;
}

class DownloadNotifier extends FamilyNotifier<DownloadState, PixabayImage> {
  @override
  DownloadState build(PixabayImage arg) => const DownloadState();

  Future<void> start() async {
    if (state.isDownloading) return;
    state = const DownloadState(status: DownloadStatus.downloading);
    try {
      await ref.read(downloadServiceProvider).saveToGallery(
            url: arg.largeImageUrl,
            fileName: 'pixabay_${arg.id}',
            onProgress: (p) => state =
                DownloadState(status: DownloadStatus.downloading, progress: p),
          );
      state = const DownloadState(
          status: DownloadStatus.success, progress: 1, message: 'Saved to your gallery');
    } catch (e) {
      state = DownloadState(status: DownloadStatus.failure, message: errorMessage(e));
    }
  }
}

final downloadProvider =
    NotifierProvider.family<DownloadNotifier, DownloadState, PixabayImage>(
        DownloadNotifier.new);