import 'package:example/test_item.dart';
import 'package:example/test_page_net_work_controller.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_infinite_scroll_page/riverpod_infinite_scroll_page.dart';

class TestGridPage extends ConsumerWidget {
  final String pageKey = 'TestGridPage';
  const TestGridPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: PagedGridView<String, PagingItem>(
        pagingControllerProvider: pagingControllerProvider(pageKey),
        builderDelegate: itemRegister(),
        pagingDataController: TestPageNetWorkController(),
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        final pagingController =
            ref.read(pagingControllerProvider(pageKey).notifier);
        pagingController.updateItemAt(8, TestItem('11111'));
      }),
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
    return Center(child: Text('item $index name${testItem.name}'));
  }
}
