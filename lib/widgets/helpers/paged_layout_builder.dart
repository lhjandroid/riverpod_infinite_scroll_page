import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_infinite_scroll_page/core/paged_child_builder_delegate.dart';
import 'package:riverpod_infinite_scroll_page/core/paging_controller.dart';
import 'package:riverpod_infinite_scroll_page/core/paging_data_controller.dart';
import 'package:riverpod_infinite_scroll_page/model/paging_item.dart';
import 'package:riverpod_infinite_scroll_page/model/paging_item_unknow.dart';
import 'package:riverpod_infinite_scroll_page/model/paging_state.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:tuple/tuple.dart';

final pagingControllerProvider = AutoDisposeNotifierProviderFamily<
    PagingController<dynamic, PagingItem>,
    PagingState<dynamic, PagingItem>,
    dynamic>(
  PagingController.new,
);

final persistentPagingControllerProvider = NotifierProviderFamily<
    PersistentPagingController<dynamic, PagingItem>,
    PagingState<dynamic, PagingItem>,
    dynamic>(
  PersistentPagingController.new,
);

// Utility function to select the appropriate provider based on persistence
ProviderBase<PagingState<dynamic, PagingItem>> getPagingControllerProvider(
  bool isPersistent,
  String pageKey,
) {
  return isPersistent
      ? persistentPagingControllerProvider(pageKey)
      : pagingControllerProvider(pageKey);
}

// Modify the provider to watch the item at a specific data
final itemAtProvider =
    AutoDisposeProvider.family<PagingItem, Tuple3<dynamic, int, bool>>(
        (ref, data) {
  final pagingState = ref.watch(data.item3
      ? persistentPagingControllerProvider(data.item1)
      : pagingControllerProvider(data.item1));
  final itemList = pagingState.itemList;

  if (itemList != null && data.item2 < itemList.length) {
    return itemList[data.item2];
  } else {
    return PagingItemUnknown();
  }
});

PagingDataControllerInterface getPagingDataControllerInterface(
    WidgetRef ref, bool isPersistent, dynamic pageKey) {
  if (isPersistent) {
    return ref.read(persistentPagingControllerProvider(pageKey).notifier);
  }
  return ref.read(pagingControllerProvider(pageKey).notifier);
}

typedef ItemListingBuilder = Widget Function(
  BuildContext context,
  IndexedWidgetBuilder itemWidgetBuilder,
  int itemCount,
  PagedLayoutProtocol layoutProtocol,
);

/// The Flutter layout protocols supported by [PagedLayoutBuilder].
enum PagedLayoutProtocol { sliver, box }

class PagedLayoutBuilder<PageKeyType, T extends PagingItem>
    extends ConsumerStatefulWidget {
  const PagedLayoutBuilder({
    required this.builderDelegate,
    required this.itemListingBuilder,
    required this.layoutProtocol,
    this.shrinkWrapFirstPageIndicators = false,
    required this.pagingDataController,
    required this.isPersistent,
    super.key,
  });

  final PagedChildBuilderDelegate<T> builderDelegate;
  final ItemListingBuilder itemListingBuilder;
  final PagedLayoutProtocol layoutProtocol;
  final bool shrinkWrapFirstPageIndicators;
  final bool isPersistent;
  final PagingDataController pagingDataController;

  @override
  PagedLayoutBuilderState<PageKeyType, T> createState() =>
      PagedLayoutBuilderState<PageKeyType, T>();
}

class PagedLayoutBuilderState<PageKeyType, T extends PagingItem>
    extends ConsumerState<PagedLayoutBuilder<PageKeyType, T>> {
  PagedChildBuilderDelegate<T> get _builderDelegate => widget.builderDelegate;
  PagedLayoutProtocol get _layoutProtocol => widget.layoutProtocol;

  PagingDataController get _pagingBuilderController =>
      widget.pagingDataController;

  // Helper function to access .notifier based on isPersistent
  void withNotifier(
      Function(PagingDataControllerInterface<dynamic, PagingItem> controller)
          action) {
    if (widget.isPersistent) {
      // Use persistent provider directly
      final notifier = ref.read(persistentPagingControllerProvider(
              _pagingBuilderController.getPageKey())
          .notifier);
      action(notifier);
    } else {
      // Use auto-dispose provider directly
      final notifier = ref.read(
          pagingControllerProvider(_pagingBuilderController.getPageKey())
              .notifier);
      action(notifier);
    }
  }

  Future<void> retryLastFailedRequest() async {
    withNotifier((notifier) => notifier.onGoing());

    final provider = getPagingControllerProvider(
        widget.isPersistent, _pagingBuilderController.getPageKey());
    var nextPageKey = ref.read(provider).nextPageKey;

    try {
      var data =
          await widget.pagingDataController.retryLastFailedRequest(nextPageKey);
      withNotifier((notifier) {
        if (data.error == null) {
          notifier.appendPage(data.itemList as List<T>, data.nextPageKey);
        } else {
          notifier.loadError(data.error);
        }
      });
    } catch (e) {
      withNotifier((notifier) => notifier.loadError(e));
    }
  }

  bool _hasRequestedNextPage = false;

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    final provider = getPagingControllerProvider(
        widget.isPersistent, _pagingBuilderController.getPageKey());
    try {
      var firstKey = ref.read(provider).nextPageKey;
      var firstPageData =
          await widget.pagingDataController.requestData(firstKey);

      withNotifier((notifier) {
        if (firstPageData.error != null) {
          notifier.loadError(firstPageData.error);
        } else {
          notifier.appendPage(
              firstPageData.itemList as List<T>, firstPageData.nextPageKey);
        }
      });
    } catch (e) {
      withNotifier((notifier) => notifier.loadError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = getPagingControllerProvider(
        widget.isPersistent, _pagingBuilderController.getPageKey());
    final itemCount =
        ref.watch(provider.select((value) => value.itemList?.length)) ?? 0;

    Widget child = widget.itemListingBuilder(
      context,
      (context, index) => _itemBuilder(context, index),
      itemCount,
      widget.layoutProtocol,
    );

    if (_builderDelegate.animateTransitions) {
      return _layoutProtocol == PagedLayoutProtocol.sliver
          ? SliverAnimatedSwitcher(
              duration: _builderDelegate.transitionDuration, child: child)
          : AnimatedSwitcher(
              duration: _builderDelegate.transitionDuration, child: child);
    } else {
      return child;
    }
  }

  Widget _itemBuilder(BuildContext context, int index) {
    final provider = getPagingControllerProvider(
        widget.isPersistent, _pagingBuilderController.getPageKey());
    final asyncPagingState = ref.read(provider);
    final itemCount = asyncPagingState.itemList?.length ?? 0;

    if (!_hasRequestedNextPage) {
      final newPageRequestTriggerIndex = max(
          0, itemCount - widget.pagingDataController.invisibleItemsThreshold);
      final isBuildingTriggerIndexItem = index == newPageRequestTriggerIndex;

      if (asyncPagingState.nextPageKey != null && isBuildingTriggerIndexItem) {
        _hasRequestedNextPage = true;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          try {
            var data = await widget.pagingDataController
                .requestData(asyncPagingState.nextPageKey);

            withNotifier((notifier) {
              if (data.error != null) {
                notifier.loadError(data.error);
              } else if ((asyncPagingState.itemList?.length ?? 0) > 0 &&
                  data.nextPageKey == null) {
                notifier.appendLastPage((data.itemList ?? []) as List<T>);
              } else {
                notifier.appendPage(
                    (data.itemList ?? []) as List<T>, data.nextPageKey);
              }
            });
          } catch (e) {
            withNotifier((notifier) => notifier.loadError(e));
          }
          _hasRequestedNextPage = false;
        });
      }
    }
    return widget.builderDelegate.itemBuilder(context, index);
  }
}

class FirstPageStatusIndicatorBuilder extends StatelessWidget {
  const FirstPageStatusIndicatorBuilder({
    super.key,
    required this.builder,
    required this.layoutProtocol,
    this.shrinkWrap = false,
  });

  final WidgetBuilder builder;
  final bool shrinkWrap;
  final PagedLayoutProtocol layoutProtocol;

  @override
  Widget build(BuildContext context) {
    if (layoutProtocol == PagedLayoutProtocol.sliver) {
      if (shrinkWrap) {
        return SliverToBoxAdapter(
          child: builder(context),
        );
      } else {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: builder(context),
        );
      }
    } else {
      if (shrinkWrap) {
        return builder(context);
      } else {
        return Center(
          child: builder(context),
        );
      }
    }
  }
}
