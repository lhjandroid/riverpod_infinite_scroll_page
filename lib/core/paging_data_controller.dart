import 'package:riverpod_infinite_scroll_page/riverpod_infinite_scroll_page.dart';

abstract class PagingDataController<T, K extends PagingItem> {
  PagingDataController(this.providerKey);

  int get invisibleItemsThreshold => 3;

  final String providerKey;

  Future<PagingState> requestData(T pageKey);

  Future<PagingState> retryLastFailedRequest(T pageKey) {
    return requestData(pageKey);
  }

  String getProviderKey() {
    return providerKey;
  }

  List<K>? getInitData(WidgetRef ref) {
    return null;
  }

  T? getFirstDataPageKey() {
    return null;
  }
}
