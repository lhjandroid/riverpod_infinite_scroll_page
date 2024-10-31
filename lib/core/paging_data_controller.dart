import 'package:riverpod_infinite_scroll_page/riverpod_infinite_scroll_page.dart';

abstract class PagingDataController<T, K extends PagingItem> {
  PagingDataController(this.pageKey);

  int get invisibleItemsThreshold => 3;

  final String pageKey;

  Future<PagingState> requestData(T pageKey);

  Future<PagingState> retryLastFailedRequest(T pageKey) {
    return requestData(pageKey);
  }

  // list data first page request key
  T? getFirstPageKey() {
    return null;
  }

  String getPageKey() {
    return pageKey;
  }

  List<K>? getInitData(WidgetRef ref) {
    return null;
  }
}
