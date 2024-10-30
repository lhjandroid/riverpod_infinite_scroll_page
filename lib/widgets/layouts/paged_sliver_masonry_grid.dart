import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:riverpod_infinite_scroll_page/core/paged_child_builder_delegate.dart';
import 'package:riverpod_infinite_scroll_page/core/paging_data_controller.dart';
import 'package:riverpod_infinite_scroll_page/model/paging_item.dart';
import 'package:riverpod_infinite_scroll_page/utils/appended_sliver_grid.dart';
import 'package:riverpod_infinite_scroll_page/widgets/helpers/paged_layout_builder.dart';
import 'package:riverpod_infinite_scroll_page/widgets/helpers/paging_status_widget.dart';

typedef SliverSimpleGridDelegateBuilder = SliverSimpleGridDelegate Function(
  int childCount,
);

/// A [SliverMasonryGrid] with pagination capabilities.
///
/// You can also see this as a [PagedSliverGrid] that supports rows of varying
/// sizes.
///
/// This is a wrapper around the [SliverMasonryGrid]
/// from the [flutter_staggered_grid_view](https://pub.dev/packages/flutter_staggered_grid_view) package.
/// For more info on how to build staggered grids, check out the
/// referred package's documentation and examples.
class PagedSliverMasonryGrid<PageKeyType, ItemType> extends StatelessWidget {
  const PagedSliverMasonryGrid({
    required this.builderDelegate,
    required this.gridDelegateBuilder,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.showNewPageProgressIndicatorAsGridChild = true,
    this.showNewPageErrorIndicatorAsGridChild = true,
    this.showNoMoreItemsIndicatorAsGridChild = true,
    this.shrinkWrapFirstPageIndicators = false,
    required this.pagingBuilderController,
    this.statusBuilderDelegate,
    super.key,
    this.persistent,
  });

  /// Equivalent to [SliverMasonryGrid.count].
  PagedSliverMasonryGrid.count({
    required this.builderDelegate,
    required int crossAxisCount,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.showNewPageProgressIndicatorAsGridChild = true,
    this.showNewPageErrorIndicatorAsGridChild = true,
    this.showNoMoreItemsIndicatorAsGridChild = true,
    this.shrinkWrapFirstPageIndicators = false,
    required this.pagingBuilderController,
    this.statusBuilderDelegate,
    super.key,
    this.persistent,
  }) : gridDelegateBuilder =
            ((childCount) => SliverSimpleGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                ));

  /// Equivalent to [SliverMasonryGrid.extent].
  PagedSliverMasonryGrid.extent({
    required this.builderDelegate,
    required double maxCrossAxisExtent,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.showNewPageProgressIndicatorAsGridChild = true,
    this.showNewPageErrorIndicatorAsGridChild = true,
    this.showNoMoreItemsIndicatorAsGridChild = true,
    this.shrinkWrapFirstPageIndicators = false,
    required this.pagingBuilderController,
    this.statusBuilderDelegate,
    super.key,
    this.persistent,
  }) : gridDelegateBuilder =
            ((childCount) => SliverSimpleGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: maxCrossAxisExtent,
                ));

  /// Matches [PagedLayoutBuilder.builderDelegate].
  final PagedChildBuilderDelegate<PagingItem> builderDelegate;

  /// Provides the adjusted child count (based on the pagination status) so
  /// that a [SliverSimpleGridDelegate] can be returned.
  final SliverSimpleGridDelegateBuilder gridDelegateBuilder;

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

  /// Matches [PagedLayoutBuilder.shrinkWrapFirstPageIndicators].
  final bool shrinkWrapFirstPageIndicators;

  /// Matches [SliverMasonryGrid.mainAxisSpacing].
  final double mainAxisSpacing;

  /// Matches [SliverMasonryGrid.mainAxisSpacing].
  final double crossAxisSpacing;

  // 加载下一页失败时的重试回调
  final PagingDataController pagingBuilderController;

  final PagedChildStatusBuilderDelegate? statusBuilderDelegate;

  final bool? persistent;

  @override
  Widget build(BuildContext context) =>
      PagedLayoutBuilder<PageKeyType, PagingItem>(
        layoutProtocol: PagedLayoutProtocol.sliver,
        builderDelegate: builderDelegate,
        shrinkWrapFirstPageIndicators: shrinkWrapFirstPageIndicators,
        pagingDataController: pagingBuilderController,
        isPersistent: persistent ?? false,
        itemListingBuilder: (BuildContext context,
            Widget Function(BuildContext, int) itemWidgetBuilder,
            int itemCount,
            PagedLayoutProtocol layoutProtocol) {
          return AppendedSliverGrid(
            sliverGridBuilder: (childCount, delegate) => SliverMasonryGrid(
              delegate: delegate,
              gridDelegate: gridDelegateBuilder(childCount),
              mainAxisSpacing: mainAxisSpacing,
              crossAxisSpacing: crossAxisSpacing,
            ),
            itemBuilder: itemWidgetBuilder,
            itemCount: itemCount,
            appendixBuilder: (context) {
              return PagingStatusWidget(
                builderDelegate: statusBuilderDelegate,
                pagingDataController: pagingBuilderController,
                layoutProtocol: layoutProtocol,
                shrinkWrapFirstPageIndicators: shrinkWrapFirstPageIndicators,
                isPersistent: persistent ?? false,
              );
            },
            showAppendixAsGridChild: showNewPageErrorIndicatorAsGridChild,
            addAutomaticKeepAlives: addAutomaticKeepAlives,
            addSemanticIndexes: addSemanticIndexes,
            addRepaintBoundaries: addRepaintBoundaries,
          );
        },
      );
}
