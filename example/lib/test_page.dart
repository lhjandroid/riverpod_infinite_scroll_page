import 'package:example/test_item.dart';
import 'package:example/test_page_net_work_controller.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_infinite_scroll_page/riverpod_infinite_scroll_page.dart';

class TestPage extends ConsumerStatefulWidget {
  const TestPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TestPageState();
}

class _TestPageState extends ConsumerState<TestPage> {
  final String pageKey = '0';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PagedListView<String, PagingItem>(
        builderDelegate: itemRegister(),
        pagingDataController: TestPageNetWorkController(pageKey),
        statusBuilderDelegate: statusBuilder(),
        persistent: true, // keep data
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        final pagingController =
            ref.read(pagingControllerProvider(pageKey).notifier);
        pagingController.updateItemAt(8, TestItem('11111'));
      }),
    );
  }

  PagedChildStatusBuilderDelegate<PagingItem> statusBuilder() {
    return PagedChildStatusBuilderDelegate(
      newPageErrorIndicatorBuilder: (context, retryCallback) {
        return GestureDetector(
          onTap: retryCallback,
          child: const SizedBox(
            height: 40,
            child: Center(child: Text('error')),
          ),
        );
      },
    );
  }

  MultiItemChildBuilderDelegate itemRegister() {
    return MultiItemChildBuilderDelegate(
      pageKey,
      pagingItemRegister: PagingItemRegister(
        itemRegister: {
          TestItem: buildTestItem,
        },
      ),
    );
  }

  Widget buildTestItem<T extends PagingItem>(
      BuildContext context, T data, int index) {
    print('buildTestItem $index');
    final testItem = data as TestItem; // 假设 TestItem 是具体的类型
    return Text('item $index name${testItem.name}');
  }
}
