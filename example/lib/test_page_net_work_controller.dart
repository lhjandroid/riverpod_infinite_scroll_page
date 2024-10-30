import 'package:example/test_item.dart';
import 'package:riverpod_infinite_scroll_page/core/paging_data_controller.dart';
import 'package:riverpod_infinite_scroll_page/model/paging_state.dart';

class TestPageNetWorkController extends PagingDataController<String, TestItem> {
  bool isFirst = true;

  TestPageNetWorkController(super.pageKey);

  @override
  Future<PagingState> requestData(pageKey) async {
    print('requestData $pageKey');
    await Future.delayed(const Duration(seconds: 3));
    final newItems = List.generate(
      10,
      (index) => TestItem('Item ${0 * 10 + index + 1}'),
    );
    if (pageKey == '0 1' && isFirst) {
      // isFirst = false;
      return PagingState(
          itemList: newItems, nextPageKey: pageKey, error: '111');
    }
    return PagingState(itemList: newItems, nextPageKey: '0 1');
  }
}
