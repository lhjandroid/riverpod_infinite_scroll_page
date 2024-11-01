## 0.05
Compatible with pull-to-refresh component.
If using a pull-to-refresh component, please set the provider state before refreshing.
```dart
Future<void> refreshPage(WidgetRef ref) async {
    ref.read(pagingControllerProvider(pagingDataController.getProviderKey()).notifier).pullRefresh(); // call this
    var firstPageKey = pagingDataController.getFirstDataPageKey();
    try {
      var data = await pagingDataController.requestData(firstPageKey);
      if (data.error == null) {
        ref
            .read(pagingControllerProvider(pagingDataController.getProviderKey()).notifier)
            .appendRefreshPage(data.itemList ?? [], data.nextPageKey);
      } else {
        ref.read(pagingControllerProvider(pagingDataController.getProviderKey()).notifier).loadError(data.error);
      }
    } on Exception catch (e) {
      ref.read(pagingControllerProvider(pagingDataController.getProviderKey()).notifier).loadError(e);
    }
  }
```

## 0.05
fix bugs

## 0.0.4
code optimize
support setting init data to paging list

## 0.0.3
Optimize the code and add a persistence provider.
Attention! PagedListView must be consistent with MultiItemChildBuilderDelegate persistent persistent

```
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
      persistent: true, //// keep data
    );
  }

  Widget buildTestItem<T extends PagingItem>(
      BuildContext context, T data, int index) {
    print('buildTestItem $index');
    final testItem = data as TestItem; // 假设 TestItem 是具体的类型
    return Text('item $index name${testItem.name}');
  }
}
```

## 0.0.1

* TODO: Describe initial release.
