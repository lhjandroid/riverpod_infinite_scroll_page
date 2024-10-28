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

//The paging controller provider using AutoDisposeNotifierProviderFamily
final pagingControllerProvider = AutoDisposeNotifierProviderFamily<
    PagingController<String, PagingItem>,
    PagingState<String, PagingItem>,
    String>(
  PagingController.new,
);

// Modify the provider to watch the item at a specific data
final itemAtProvider =
    AutoDisposeProvider.family<PagingItem, Tuple2<String, int>>((ref, data) {
  // Ensure that the correct family argument (page key) is passed
  final pagingState = ref.watch(
      pagingControllerProvider(data.item1)); // Assuming 0 is the page key

  // Access the item list directly from the pagingState and return the item at the specified data
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

/// Facilitates creating infinitely scrolled paged layouts.
///
/// Combines a [PagingController] with a
/// [PagedChildBuilderDelegate] and calls the supplied
/// [loadingListingBuilder], [errorListingBuilder] or
/// [completedListingBuilder] for filling in the gaps.
///
/// For ordinary cases, this widget shouldn't be used directly. Instead, take a
/// look at [PagedSliverList], [PagedSliverGrid], [PagedListView],
/// [PagedGridView], [PagedMasonryGridView], or [PagedPageView].
class PagedLayoutBuilder<PageKeyType, T extends PagingItem>
    extends ConsumerStatefulWidget {
  const PagedLayoutBuilder({
    required this.pagingControllerProvider,
    required this.builderDelegate,
    required this.itemListingBuilder,
    required this.layoutProtocol,
    this.shrinkWrapFirstPageIndicators = false,
    required this.pagingBuilderController,
    super.key,
  });

  final AutoDisposeFamilyNotifierProvider<PagingController<PageKeyType, T>,
      PagingState<PageKeyType, T>, PageKeyType> pagingControllerProvider;
  final PagedChildBuilderDelegate<T> builderDelegate;
  final ItemListingBuilder itemListingBuilder;
  final PagedLayoutProtocol layoutProtocol;
  final bool shrinkWrapFirstPageIndicators;
  // 加载下一页失败时的重试回调
  final PagingDataController pagingBuilderController;

  @override
  PagedLayoutBuilderState<PageKeyType, T> createState() =>
      PagedLayoutBuilderState<PageKeyType, T>();
}

class PagedLayoutBuilderState<PageKeyType, T extends PagingItem>
    extends ConsumerState<PagedLayoutBuilder<PageKeyType, T>> {
  PagedChildBuilderDelegate<T> get _builderDelegate => widget.builderDelegate;

  PagedLayoutProtocol get _layoutProtocol => widget.layoutProtocol;

  /// Retry the last failed request.
  /// This method updates the state of the PagingController to indicate that a new request is in progress,
  /// then attempts to retrieve the data for the next page.
  /// If the data retrieval is successful, it appends the new data to the current paging data list
  /// and updates the next page key.
  /// If the data retrieval fails, it updates the state of the PagingController to indicate an error.
  ///
  /// @throws Exception If an exception occurs during the retry process, it is caught and passed
  /// to the loadError method of the PagingController.
  Future<void> retryLastFailedRequest() async {
    // Update the state of the PagingController to indicate that a new request is in progress
    ref.read(widget.pagingControllerProvider.notifier).onGoing();
    // Retrieve the next page key from the PagingController
    var nextPageKey = ref.read(widget.pagingControllerProvider).nextPageKey;
    try {
      // Retry retrieving the data for the next page
      var data = await widget.pagingBuilderController
          .retryLastFailedRequest(nextPageKey);
      // If the data retrieval is successful, append the new data and update the next page key
      if (data.error == null) {
        ref
            .read(widget.pagingControllerProvider.notifier)
            .appendPage(data.itemList as List<T>, data.nextPageKey);
      }
      // If the data retrieval fails, update the state of the PagingController to indicate an error
      else {
        ref
            .read(widget.pagingControllerProvider.notifier)
            .loadError(data.error);
      }
    } catch (e) {
      // If an exception occurs during the retry process, pass it to the loadError method of the PagingController
      ref.read(widget.pagingControllerProvider.notifier).loadError(e);
    }
  }

  /// Avoids duplicate requests on rebuilds.
  bool _hasRequestedNextPage = false;

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    try {
      var firstKey = ref.read(widget.pagingControllerProvider).nextPageKey;
      var firstPageData =
          await widget.pagingBuilderController.requestData(firstKey);
      if (firstPageData.error != null) {
        ref.read(widget.pagingControllerProvider.notifier).loadError(e);
      } else {
        ref
            .read(widget.pagingControllerProvider.notifier)
            .appendPage(firstPageData.itemList as List<T>, firstKey);
      }
    } on Exception catch (e) {
      ref.read(widget.pagingControllerProvider.notifier).loadError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the AsyncValue from the pagingControllerProvider
    final itemCount = ref.watch(widget.pagingControllerProvider
            .select((value) => value.itemList?.length)) ??
        0;

    Widget child = widget.itemListingBuilder(
      context,
      (context, index) => _itemBuilder(
        context,
        index,
      ),
      itemCount,
      widget.layoutProtocol,
    );

    if (_builderDelegate.animateTransitions) {
      if (_layoutProtocol == PagedLayoutProtocol.sliver) {
        return SliverAnimatedSwitcher(
          duration: _builderDelegate.transitionDuration,
          child: child,
        );
      } else {
        return AnimatedSwitcher(
          duration: _builderDelegate.transitionDuration,
          child: child,
        );
      }
    } else {
      return child;
    }
  }

  Widget _itemBuilder(BuildContext context, int index) {
    final asyncPagingState = ref.read(widget.pagingControllerProvider);
    final itemCount = asyncPagingState.itemList?.length ?? 0;
    if (!_hasRequestedNextPage) {
      final newPageRequestTriggerIndex = max(0,
          itemCount - widget.pagingBuilderController.invisibleItemsThreshold);

      final isBuildingTriggerIndexItem = index == newPageRequestTriggerIndex;

      if (asyncPagingState.nextPageKey != null && isBuildingTriggerIndexItem) {
        _hasRequestedNextPage = true;
        // Schedules the request for the end of this frame.
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          try {
            var data = await widget.pagingBuilderController
                .requestData(asyncPagingState.nextPageKey);
            if (data.error != null) {
              ref.read(widget.pagingControllerProvider.notifier).loadError(e);
            } else if ((asyncPagingState.itemList?.length ?? 0) > 0 &&
                data.nextPageKey == null) {
              ref
                  .read(widget.pagingControllerProvider.notifier)
                  .appendLastPage((data.itemList ?? []) as List<T>);
            } else {
              ref.read(widget.pagingControllerProvider.notifier).appendPage(
                  (data.itemList ?? []) as List<T>, data.nextPageKey);
            }
          } on Exception catch (e) {
            ref.read(widget.pagingControllerProvider.notifier).loadError(e);
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
