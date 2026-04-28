import 'package:get/get.dart';
import 'package:piliotto/ottohub/api/models/video.dart';
import 'package:piliotto/repositories/i_video_repository.dart';
import 'package:piliotto/services/loggeer.dart';

final _logger = getLogger();

class FavDetailController extends GetxController {
  final IVideoRepository _videoRepo = Get.find<IVideoRepository>();
  RxString title = ''.obs;
  RxList<Video> favList = <Video>[].obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;
  RxBool hasMore = true.obs;
  RxString loadingText = '加载中...'.obs;

  int _currentPage = 0;
  final int _pageSize = 20;

  @override
  void onInit() {
    super.onInit();
    title.value = Get.parameters['title'] ?? '我的收藏';
    queryFavorites();
  }

  Future<void> queryFavorites({bool isLoadMore = false}) async {
    if (isLoading.value || isLoadingMore.value) return;

    if (!isLoadMore) {
      isLoading.value = true;
      _currentPage = 0;
    } else {
      if (!hasMore.value) return;
      isLoadingMore.value = true;
    }

    try {
      final response = await _videoRepo.getFavoriteVideos(
        offset: _currentPage,
        num: _pageSize,
      );

      final List<Video> videos = response.videoList;

      if (isLoadMore) {
        favList.addAll(videos);
      } else {
        favList.value = videos;
      }

      hasMore.value = videos.length >= _pageSize;
      if (!hasMore.value && favList.isNotEmpty) {
        loadingText.value = '没有更多了';
      }
      _currentPage++;
    } catch (e) {
      _logger.e('获取收藏列表失败: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> onLoad() async {
    await queryFavorites(isLoadMore: true);
  }

  Future<void> onRefresh() async {
    await queryFavorites();
  }

  Future<void> removeFavorite(int vid) async {
    try {
      await _videoRepo.toggleFavorite(vid: vid);
      favList.removeWhere((v) => v.vid == vid);
    } catch (e) {
      _logger.e('取消收藏失败: $e');
    }
  }
}
