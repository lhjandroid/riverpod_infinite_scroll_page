import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:riverpod_infinite_scroll_page/core/paged_child_builder_delegate.dart';
import 'package:riverpod_infinite_scroll_page/core/paging_controller.dart';
import 'package:riverpod_infinite_scroll_page/core/paging_data_controller.dart';
import 'package:riverpod_infinite_scroll_page/model/paging_item.dart';
import 'package:riverpod_infinite_scroll_page/model/paging_state.dart';
import 'package:riverpod_infinite_scroll_page/utils/appended_sliver_grid.dart';
import 'package:riverpod_infinite_scroll_page/widgets/helpers/paged_layout_builder.dart';
import 'package:riverpod_infinite_scroll_page/widgets/helpers/paging_status_widget.dart';
import 'package:riverpod_infinite_scroll_page/widgets/layouts/paged_sliver_masonry_grid.dart';

/// A [SliverAlignedGrid] with pagination capabilities.
///
/// You can also see this as a [PagedSliverGrid] that ensures that the items
/// in its rows all have the same size.
///
/// This is a wrapper around the [SliverAlignedGrid]
/// from the [flutter_staggered_grid_view](https://pub.dev/packages/flutter_staggered_grid_view) package.
/// For more info on how to build staggered grids, check out the
/// referred package's documentation and examples.
class PagedSliverAlignedGrid<PageKeyType, ItemType> extends StatelessWidget {
  const PagedSliverAlignedGrid({
    required this.pagingControllerProvider,
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
  });

  PagedSliverAlignedGrid.count({
    required this.pagingControllerProvider,
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
    this.statusBuilderDelegate,
    super.key,
    required this.pagingBuilderController,
  }) : gridDelegateBuilder =
            ((childCount) => SliverSimpleGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                ));

  PagedSliverAlignedGrid.extent({
    super.key,
    required this.pagingControllerProvider,
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
    this.statusBuilderDelegate,
    required this.pagingBuilderController,
  }) : gridDelegateBuilder =
            ((childCount) => SliverSimpleGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: maxCrossAxisExtent,
                ));

  /// Matches [PagedLayoutBuilder.pagingController].
  final AutoDisposeFamilyNotifierProvider<
      PagingController<PageKeyType, PagingItem>,
      PagingState<PageKeyType, PagingItem>,
      PageKeyType> pagingControllerProvider;

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

  /// Matches [SliverAlignedGrid.mainAxisSpacing].
  final double mainAxisSpacing;

  /// Matches [SliverAlignedGrid.crossAxisSpacing].
  final double crossAxisSpacing;
  // 加载下一页失败时的重试回调
  final PagingDataController pagingBuilderController;

  final PagedChildStatusBuilderDelegate? statusBuilderDelegate;

  @override
  Widget build(BuildContext context) =>
      PagedLayoutBuilder<PageKeyType, PagingItem>(
        layoutProtocol: PagedLayoutProtocol.sliver,
        pagingControllerProvider: pagingControllerProvider,
        builderDelegate: builderDelegate,
        shrinkWrapFirstPageIndicators: shrinkWrapFirstPageIndicators,
        pagingBuilderController: pagingBuilderController,
        itemListingBuilder: (BuildContext context,
            Widget Function(BuildContext, int) itemWidgetBuilder,
            int itemCount,
            PagedLayoutProtocol layoutProtocol) {
          return AppendedSliverGrid(
            sliverGridBuilder: (childCount, delegate) => SliverAlignedGrid(
              itemBuilder: delegate.build,
              itemCount: childCount,
              gridDelegate: gridDelegateBuilder(childCount),
              mainAxisSpacing: mainAxisSpacing,
              crossAxisSpacing: crossAxisSpacing,
              addAutomaticKeepAlives: addAutomaticKeepAlives,
              addRepaintBoundaries: addRepaintBoundaries,
            ),
            itemBuilder: itemWidgetBuilder,
            itemCount: itemCount,
            appendixBuilder: (context) {
              return PagingStatusWidget(
                pagingControllerProvider: pagingControllerProvider,
                builderDelegate: statusBuilderDelegate,
                pagingBuilderController: pagingBuilderController,
                layoutProtocol: layoutProtocol,
                shrinkWrapFirstPageIndicators: shrinkWrapFirstPageIndicators,
              );
            },
            showAppendixAsGridChild: showNewPageErrorIndicatorAsGridChild,
            addAutomaticKeepAlives: false,
            addSemanticIndexes: false,
            addRepaintBoundaries: false,
          );
        },
      );
}
