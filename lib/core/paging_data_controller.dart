import 'package:riverpod_infinite_scroll_page/model/paging_state.dart';
import 'package:riverpod_infinite_scroll_page/riverpod_infinite_scroll_page.dart';

abstract class PagingDataController<T, K extends PagingItem> {
  int get invisibleItemsThreshold => 3;

  Future<PagingState> requestData(T pageKey);

  Future<PagingState> retryLastFailedRequest(T pageKey) {
    return requestData(pageKey);
  }
}