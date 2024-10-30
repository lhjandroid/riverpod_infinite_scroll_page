import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:riverpod_infinite_scroll_page/core/paged_child_builder_delegate.dart';
import 'package:riverpod_infinite_scroll_page/core/paging_data_controller.dart';
import 'package:riverpod_infinite_scroll_page/model/paging_item.dart';
import 'package:riverpod_infinite_scroll_page/widgets/layouts/paged_sliver_aligned_grid.dart';
import 'package:riverpod_infinite_scroll_page/widgets/layouts/paged_sliver_masonry_grid.dart';

/// A [AlignedGridView] with pagination capabilities.
///
/// You can also see this as a [PagedGridView] that ensures that the items
/// in its rows all have the same size.
///
/// This is a wrapper around the [MasonryGridView]
/// from the [flutter_staggered_grid_view](https://pub.dev/packages/flutter_staggered_grid_view) package.
/// For more info on how to build staggered grids, check out the
/// referred package's documentation and examples.
class PagedAlignedGridView<PageKeyType, ItemType> extends BoxScrollView {
  const PagedAlignedGridView({
    required this.builderDelegate,
    required this.gridDelegateBuilder,
    this.statusBuilderDelegate,
    // Matches [ScrollView.scrollDirection].
    super.scrollDirection,
    // Matches [ScrollView.reverse].
    super.reverse,
    // Matches [ScrollView.primary].
    super.primary,
    // Matches [ScrollView.physics].
    super.physics,
    this.scrollController,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    // Matches [ScrollView.cacheExtent].
    super.cacheExtent,
    this.showNewPageProgressIndicatorAsGridChild = true,
    this.showNewPageErrorIndicatorAsGridChild = true,
    this.showNoMoreItemsIndicatorAsGridChild = true,
    // Matches [ScrollView.dragStartBehavior].
    super.dragStartBehavior,
    // Matches [ScrollView.keyboardDismissBehavior].
    super.keyboardDismissBehavior,
    // Matches [ScrollView.restorationId].
    super.restorationId,
    // Matches [ScrollView.clipBehavior].
    super.clipBehavior,
    // Matches [ScrollView.shrinkWrap].
    super.shrinkWrap,
    // Matches [BoxScrollView.padding].
    super.padding,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    required this.pagingBuilderController,
    this.persistent,
    super.key,
  })  : _shrinkWrapFirstPageIndicators = shrinkWrap,
        super(
          controller: scrollController,
        );

  /// Equivalent to [MasonryGridView.count].
  PagedAlignedGridView.count({
    this.statusBuilderDelegate,
    required this.builderDelegate,
    required int crossAxisCount,
    super.scrollDirection,
    // Matches [ScrollView.reverse].
    super.reverse,
    // Matches [ScrollView.primary].
    super.primary,
    // Matches [ScrollView.physics].
    super.physics,
    this.scrollController,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    // Matches [ScrollView.cacheExtent].
    super.cacheExtent,
    this.showNewPageProgressIndicatorAsGridChild = true,
    this.showNewPageErrorIndicatorAsGridChild = true,
    this.showNoMoreItemsIndicatorAsGridChild = true,
    // Matches [ScrollView.dragStartBehavior].
    super.dragStartBehavior,
    // Matches [ScrollView.keyboardDismissBehavior].
    super.keyboardDismissBehavior,
    // Matches [ScrollView.restorationId].
    super.restorationId,
    // Matches [ScrollView.clipBehavior].
    super.clipBehavior,
    // Matches [ScrollView.shrinkWrap].
    super.shrinkWrap,
    // Matches [BoxScrollView.padding].
    super.padding,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    required this.pagingBuilderController,
    this.persistent,
    super.key,
  })  : _shrinkWrapFirstPageIndicators = shrinkWrap,
        gridDelegateBuilder =
            ((childCount) => SliverSimpleGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                )),
        super(
          controller: scrollController,
        );

  /// Equivalent to [MasonryGridView.extent].
  PagedAlignedGridView.extent({
    this.statusBuilderDelegate,
    required this.builderDelegate,
    required double maxCrossAxisExtent,
    super.scrollDirection,
    // Matches [ScrollView.reverse].
    super.reverse,
    // Matches [ScrollView.primary].
    super.primary,
    // Matches [ScrollView.physics].
    super.physics,
    this.scrollController,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    // Matches [ScrollView.cacheExtent].
    super.cacheExtent,
    this.showNewPageProgressIndicatorAsGridChild = true,
    this.showNewPageErrorIndicatorAsGridChild = true,
    this.showNoMoreItemsIndicatorAsGridChild = true,
    // Matches [ScrollView.dragStartBehavior].
    super.dragStartBehavior,
    // Matches [ScrollView.keyboardDismissBehavior].
    super.keyboardDismissBehavior,
    // Matches [ScrollView.restorationId].
    super.restorationId,
    // Matches [ScrollView.clipBehavior].
    super.clipBehavior,
    // Matches [ScrollView.shrinkWrap].
    super.shrinkWrap,
    // Matches [BoxScrollView.padding].
    super.padding,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.persistent,
    required this.pagingBuilderController,
    super.key,
  })  : _shrinkWrapFirstPageIndicators = shrinkWrap,
        gridDelegateBuilder =
            ((childCount) => SliverSimpleGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: maxCrossAxisExtent,
                )),
        super(
          controller: scrollController,
        );

  /// Matches [PagedLayoutBuilder.builderDelegate].
  final PagedChildBuilderDelegate<PagingItem> builderDelegate;

  /// Provides the adjusted child count (based on the pagination status) so
  /// that a [SliverSimpleGridDelegate] can be returned.
  final SliverSimpleGridDelegateBuilder gridDelegateBuilder;

  /// Matches [ScrollView.controller]
  final ScrollController? scrollController;

  final double mainAxisSpacing;

  final double crossAxisSpacing;

  /// Matches [SliverChildBuilderDelegate.addAutomaticKeepAlives].
  final bool addAutomaticKeepAlives;

  /// Matches [SliverChildBuilderDelegate.addRepaintBoundaries].
  final bool addRepaintBoundaries;

  /// Matches [SliverChildBuilderDelegate.addSemanticIndexes].
  final bool addSemanticIndexes;

  /// Matches [PagedSliverGrid.showNewPageProgressIndicatorAsGridChild].
  final bool showNewPageProgressIndicatorAsGridChild;

  /// Matches [PagedSliverGrid.showNewPageErrorIndicatorAsGridChild].
  final bool showNewPageErrorIndicatorAsGridChild;

  /// Matches [PagedSliverGrid.showNoMoreItemsIndicatorAsGridChild].
  final bool showNoMoreItemsIndicatorAsGridChild;

  /// Matches [PagedSliverGrid.shrinkWrapFirstPageIndicators].
  final bool _shrinkWrapFirstPageIndicators;

  // 加载下一页失败时的重试回调
  final PagingDataController pagingBuilderController;

  final PagedChildStatusBuilderDelegate? statusBuilderDelegate;

  final bool? persistent;

  @override
  Widget buildChildLayout(BuildContext context) =>
      PagedSliverAlignedGrid<PageKeyType, PagingItem>(
        builderDelegate: builderDelegate,
        gridDelegateBuilder: gridDelegateBuilder,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        addAutomaticKeepAlives: addAutomaticKeepAlives,
        addRepaintBoundaries: addRepaintBoundaries,
        addSemanticIndexes: addSemanticIndexes,
        showNewPageProgressIndicatorAsGridChild:
            showNewPageProgressIndicatorAsGridChild,
        showNewPageErrorIndicatorAsGridChild:
            showNewPageErrorIndicatorAsGridChild,
        showNoMoreItemsIndicatorAsGridChild:
            showNoMoreItemsIndicatorAsGridChild,
        shrinkWrapFirstPageIndicators: _shrinkWrapFirstPageIndicators,
        pagingDataController: pagingBuilderController,
        statusBuilderDelegate: statusBuilderDelegate,
        persistent: persistent,
      );
}
