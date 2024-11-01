import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_infinite_scroll_page/core/paged_child_builder_delegate.dart';
import 'package:riverpod_infinite_scroll_page/core/paging_controller.dart';
import 'package:riverpod_infinite_scroll_page/core/paging_data_controller.dart';
import 'package:riverpod_infinite_scroll_page/model/paging_item.dart';
import 'package:riverpod_infinite_scroll_page/model/paging_item_unknow.dart';
import 'package:riverpod_infinite_scroll_page/model/paging_state.dart';
import 'package:riverpod_infinite_scroll_page/model/paging_status.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:tuple/tuple.dart';

final pagingControllerProvider =
    AutoDisposeNotifierProviderFamily<PagingController<dynamic, PagingItem>, PagingState<dynamic, PagingItem>, dynamic>(
  PagingController.new,
);

// Modify the provider to watch the item at a specific data
final itemAtProvider = AutoDisposeProvider.family<PagingItem, Tuple2<dynamic, int>>((ref, data) {
  final pagingState = ref.watch(pagingControllerProvider(data.item1));
  final itemList = pagingState.itemList;

  if (itemList != null && data.item2 < itemList.length) {
    return itemList[data.item2];
  } else {
    return PagingItemUnknown();
  }
});

typedef ItemListingBuilder = Widget Function(
  BuildContext context,
  IndexedWidgetBuilder itemWidgetBuilder,
  int itemCount,
  PagedLayoutProtocol layoutProtocol,
);

/// The Flutter layout protocols supported by [PagedLayoutBuilder].
enum PagedLayoutProtocol { sliver, box }

class PagedLayoutBuilder<PageKeyType, T extends PagingItem> extends ConsumerStatefulWidget {
  const PagedLayoutBuilder({
    required this.builderDelegate,
    required this.itemListingBuilder,
    required this.layoutProtocol,
    this.shrinkWrapFirstPageIndicators = false,
    required this.pagingDataController,
    required this.isPersistent,
    required this.forceUseInitData,
    super.key,
  });

  final PagedChildBuilderDelegate<T> builderDelegate;
  final ItemListingBuilder itemListingBuilder;
  final PagedLayoutProtocol layoutProtocol;
  final bool shrinkWrapFirstPageIndicators;
  final bool isPersistent;
  final PagingDataController pagingDataController;
  // Force the use of the initial values set in PagingDataController, even if the provider has a previous value due to persistence.
  final bool forceUseInitData;

  @override
  PagedLayoutBuilderState<PageKeyType, T> createState() => PagedLayoutBuilderState<PageKeyType, T>();
}

class PagedLayoutBuilderState<PageKeyType, T extends PagingItem>
    extends ConsumerState<PagedLayoutBuilder<PageKeyType, T>> {
  PagedChildBuilderDelegate<T> get _builderDelegate => widget.builderDelegate;

  PagedLayoutProtocol get _layoutProtocol => widget.layoutProtocol;

  PagingDataController get _pagingBuilderController => widget.pagingDataController;

  Future<void> retryLastFailedRequest() async {
    String pageProviderKey = _pagingBuilderController.getProviderKey();
    ref.read(pagingControllerProvider(pageProviderKey).notifier).onGoing();

    final provider = pagingControllerProvider(pageProviderKey);
    var nextPageKey = ref.read(provider).nextPageKey;

    try {
      var data = await widget.pagingDataController.retryLastFailedRequest(nextPageKey);
      if (data.error == null) {
        ref
            .read(pagingControllerProvider(pageProviderKey).notifier)
            .appendPage(data.itemList as List<T>, data.nextPageKey);
      } else {
        ref.read(pagingControllerProvider(pageProviderKey).notifier).loadError(data.error);
      }
    } catch (e) {
      ref.read(pagingControllerProvider(pageProviderKey).notifier).loadError(e);
    }
  }

  bool _hasRequestedNextPage = false;
  bool needDropNextPageRequest = false;
  bool lastIsRefresh = false;
  // 最后一次build布局的index 在下拉刷新时会用到
  int lastBuildIndex = -1;

  @override
  void initState() {
    super.initState();
    ref.listenManual(
      pagingControllerProvider(_pagingBuilderController.getProviderKey()),
      (pre, next) {
        if (pre != next) {
          // 如果下拉刷新时正在请求下一页，则需要丢弃下一页的标识
          if ((next.isRefreshing ?? false) && _hasRequestedNextPage) {
            needDropNextPageRequest = true;
            lastIsRefresh = true;
          } else {
            _hasRequestedNextPage = false;
            needDropNextPageRequest = false;
            // 如果由下拉刷新变成了onGoing状态，如果列表数据项没有变化，且在列表中显示的最后一个数据项的index大于等于列表item数-invisibleItemsThreshold，则重新请求下一页数据
            if (lastIsRefresh &&
                next.status == PagingStatus.ongoing &&
                pre?.itemList?.length == next.itemList?.length &&
                lastBuildIndex >= (next.itemList?.length ?? 0) - widget.pagingDataController.invisibleItemsThreshold) {
              lastIsRefresh = false;
              requestNextPageData();
            }
          }
        }
      },
      fireImmediately: false,
    );
    initData();
  }

  void initData() async {
    final pageProviderKey = _pagingBuilderController.getProviderKey();
    if (widget.isPersistent) {
      ref.read(pagingControllerProvider(pageProviderKey).notifier).keepAlive();
    }
    try {
      var cacheData = widget.pagingDataController.getInitData(ref);
      if (cacheData != null && cacheData.isNotEmpty && widget.forceUseInitData) {
        ref.read(pagingControllerProvider(pageProviderKey).notifier).appendRefreshPage(
              cacheData,
              ref.read(pagingControllerProvider(pageProviderKey).notifier).arg,
            );
      }
      var firstPageData =
          await widget.pagingDataController.requestData(widget.pagingDataController.getFirstDataPageKey());

      if (!mounted) return;

      if (firstPageData.error != null) {
        ref.read(pagingControllerProvider(pageProviderKey).notifier).loadError(firstPageData.error);
      } else {
        ref
            .read(pagingControllerProvider(pageProviderKey).notifier)
            .appendRefreshPage(firstPageData.itemList as List<T>, firstPageData.nextPageKey);
      }
    } catch (e) {
      ref.read(pagingControllerProvider(pageProviderKey).notifier).loadError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = pagingControllerProvider(_pagingBuilderController.getProviderKey());
    final itemCount = ref.watch(provider.select((value) => value.itemList?.length)) ?? 0;

    Widget child = widget.itemListingBuilder(
      context,
      (context, index) => _itemBuilder(context, index),
      itemCount,
      widget.layoutProtocol,
    );

    if (_builderDelegate.animateTransitions) {
      return _layoutProtocol == PagedLayoutProtocol.sliver
          ? SliverAnimatedSwitcher(duration: _builderDelegate.transitionDuration, child: child)
          : AnimatedSwitcher(duration: _builderDelegate.transitionDuration, child: child);
    } else {
      return child;
    }
  }

  Widget _itemBuilder(BuildContext context, int index) {
    if (!mounted) {
      return const SizedBox.shrink();
    }
    lastBuildIndex = index;
    final providerPageKey = _pagingBuilderController.getProviderKey();
    final provider = pagingControllerProvider(providerPageKey);
    final asyncPagingState = ref.read(provider);
    final itemCount = asyncPagingState.itemList?.length ?? 0;

    if (!_hasRequestedNextPage) {
      final newPageRequestTriggerIndex = max(0, itemCount - widget.pagingDataController.invisibleItemsThreshold);
      final isBuildingTriggerIndexItem = index == newPageRequestTriggerIndex;

      if (asyncPagingState.nextPageKey != null && isBuildingTriggerIndexItem) {
        _hasRequestedNextPage = true;
        requestNextPageData();
      }
    }
    return widget.builderDelegate.itemBuilder(context, index);
  }

  // 加载下一页数据
  void requestNextPageData() {
    final providerPageKey = _pagingBuilderController.getProviderKey();
    final provider = pagingControllerProvider(providerPageKey);
    final asyncPagingState = ref.read(provider);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        var data = await widget.pagingDataController.requestData(asyncPagingState.nextPageKey);
        if (!mounted) return;
        if (needDropNextPageRequest) {
          needDropNextPageRequest = false;
          return;
        }

        if (data.error != null) {
          ref.read(pagingControllerProvider(providerPageKey).notifier).loadError(data.error);
        } else if ((asyncPagingState.itemList?.length ?? 0) > 0 && data.nextPageKey == null) {
          ref.read(pagingControllerProvider(providerPageKey).notifier).appendLastPage((data.itemList ?? []) as List<T>);
        } else {
          ref
              .read(pagingControllerProvider(providerPageKey).notifier)
              .appendPage((data.itemList ?? []) as List<T>, data.nextPageKey);
        }
      } catch (e) {
        ref.read(pagingControllerProvider(providerPageKey).notifier).loadError(e);
      }
      _hasRequestedNextPage = false;
    });
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
    // if (layoutProtocol == PagedLayoutProtocol.sliver) {
    //   if (shrinkWrap) {
    //     return SliverToBoxAdapter(
    //       child: builder(context),
    //     );
    //   } else {
    //     return SliverFillRemaining(
    //       hasScrollBody: false,
    //       child: builder(context),
    //     );
    //   }
    // } else {
    //   if (shrinkWrap) {
    //     return builder(context);
    //   } else {
    //     return Center(
    //       child: builder(context),
    //     );
    //   }
    // }

    if (shrinkWrap) {
      return builder(context);
    } else {
      return Center(
        child: builder(context),
      );
    }
  }
}
