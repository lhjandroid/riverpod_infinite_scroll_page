import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_infinite_scroll_page/core/paged_child_builder_delegate.dart';
import 'package:riverpod_infinite_scroll_page/core/paging_controller.dart';
import 'package:riverpod_infinite_scroll_page/core/paging_data_controller.dart';
import 'package:riverpod_infinite_scroll_page/model/paging_item.dart';
import 'package:riverpod_infinite_scroll_page/model/paging_state.dart';
import 'package:riverpod_infinite_scroll_page/utils/appended_sliver_grid.dart';
import 'package:riverpod_infinite_scroll_page/widgets/helpers/paged_layout_builder.dart';
import 'package:riverpod_infinite_scroll_page/widgets/helpers/paging_status_widget.dart';

/// Paged [SliverGrid] with progress and error indicators displayed as the last
/// item.
///
/// Similar to [PagedGridView] but needs to be wrapped by a
/// [CustomScrollView] when added to the screen.
/// Useful for combining multiple scrollable pieces in your UI or if you need
/// to add some widgets preceding or following your paged grid.
class PagedSliverGrid<PageKeyType, ItemType> extends StatelessWidget {
  const PagedSliverGrid({
    required this.pagingControllerProvider,
    required this.builderDelegate,
    required this.gridDelegate,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.showNewPageProgressIndicatorAsGridChild = true,
    this.showNewPageErrorIndicatorAsGridChild = true,
    this.showNoMoreItemsIndicatorAsGridChild = true,
    this.shrinkWrapFirstPageIndicators = false,
    super.key,
    required this.pagingBuilderController,
    this.statusBuilderDelegate,
  });

  /// Matches [PagedLayoutBuilder.pagingController].
  final AutoDisposeFamilyNotifierProvider<
      PagingController<PageKeyType, PagingItem>,
      PagingState<PageKeyType, PagingItem>,
      PageKeyType> pagingControllerProvider;

  /// Matches [PagedLayoutBuilder.builderDelegate].
  final PagedChildBuilderDelegate<PagingItem> builderDelegate;

  /// Matches [GridView.gridDelegate].
  final SliverGridDelegate gridDelegate;

  /// Matches [SliverChildBuilderDelegate.addAutomaticKeepAlives].
  final bool addAutomaticKeepAlives;

  /// Matches [SliverChildBuilderDelegate.addRepaintBoundaries].
  final bool addRepaintBoundaries;

  /// Matches [SliverChildBuilderDelegate.addSemanticIndexes].
  final bool addSemanticIndexes;

  /// Whether the new page progress indicator should display as a grid child
  /// or put below the grid.
  ///
  /// Defaults to true.
  final bool showNewPageProgressIndicatorAsGridChild;

  /// Whether the new page error indicator should display as a grid child
  /// or put below the grid.
  ///
  /// Defaults to true.
  final bool showNewPageErrorIndicatorAsGridChild;

  /// Whether the no more items indicator should display as a grid child
  /// or put below the grid.
  ///
  /// Defaults to true.
  final bool showNoMoreItemsIndicatorAsGridChild;

  /// Matches [PagedLayoutBuilder.shrinkWrapFirstPageIndicators].
  final bool shrinkWrapFirstPageIndicators;

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
            sliverGridBuilder: (_, delegate) => SliverGrid(
              delegate: delegate,
              gridDelegate: gridDelegate,
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
            addAutomaticKeepAlives: addAutomaticKeepAlives,
            addSemanticIndexes: addSemanticIndexes,
            addRepaintBoundaries: addRepaintBoundaries,
          );
        },
      );
}