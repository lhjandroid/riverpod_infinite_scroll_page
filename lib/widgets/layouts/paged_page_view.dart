import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_infinite_scroll_page/core/paged_child_builder_delegate.dart';
import 'package:riverpod_infinite_scroll_page/core/paging_controller.dart';
import 'package:riverpod_infinite_scroll_page/core/paging_data_controller.dart';
import 'package:riverpod_infinite_scroll_page/model/paging_item.dart';
import 'package:riverpod_infinite_scroll_page/model/paging_state.dart';
import 'package:riverpod_infinite_scroll_page/utils/appended_sliver_child_builder_delegate.dart';
import 'package:riverpod_infinite_scroll_page/widgets/helpers/paged_layout_builder.dart';
import 'package:riverpod_infinite_scroll_page/widgets/helpers/paging_status_widget.dart';

/// Paged [PageView] with progress and error indicators displayed as the last
/// item.
///
/// Similar to a [PageView].
/// Useful for combining another paged widget with a page view with details.
class PagedPageView<PageKeyType, T extends PagingItem> extends StatelessWidget {
  const PagedPageView({
    required this.pagingControllerProvider,
    required this.builderDelegate,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.allowImplicitScrolling = false,
    this.restorationId,
    this.pageController,
    this.scrollBehavior,
    this.scrollDirection = Axis.horizontal,
    this.dragStartBehavior = DragStartBehavior.start,
    this.clipBehavior = Clip.hardEdge,
    this.reverse = false,
    this.physics,
    this.onPageChanged,
    this.pageSnapping = true,
    this.padEnds = true,
    this.shrinkWrapFirstPageIndicators = false,
    this.statusBuilderDelegate,
    required this.pagingDataController,
    this.persistent,
    super.key,
  });

  /// Matches [PagedLayoutBuilder.pagingController].
  final AutoDisposeFamilyNotifierProvider<PagingController<PageKeyType, T>,
      PagingState<PageKeyType, T>, PageKeyType> pagingControllerProvider;

  /// Matches [PagedLayoutBuilder.builderDelegate].
  final PagedChildBuilderDelegate<T> builderDelegate;

  /// Matches [SliverChildBuilderDelegate.addAutomaticKeepAlives].
  final bool addAutomaticKeepAlives;

  /// Matches [SliverChildBuilderDelegate.addRepaintBoundaries].
  final bool addRepaintBoundaries;

  /// Matches [SliverChildBuilderDelegate.addSemanticIndexes].
  final bool addSemanticIndexes;

  /// Matches [PageView.allowImplicitScrolling].
  final bool allowImplicitScrolling;

  /// Matches [PageView.restorationId].
  final String? restorationId;

  /// Matches [PageView.controller].
  final PageController? pageController;

  /// Matches [PageView.scrollBehavior].
  final ScrollBehavior? scrollBehavior;

  /// Matches [PageView.scrollDirection].
  final Axis scrollDirection;

  /// Matches [PageView.dragStartBehavior].
  final DragStartBehavior dragStartBehavior;

  /// Matches [PageView.clipBehavior].
  final Clip clipBehavior;

  /// Matches [PageView.reverse].
  final bool reverse;

  /// Matches [PageView.physics].
  final ScrollPhysics? physics;

  /// Matches [PageView.pageSnapping].
  final bool pageSnapping;

  /// Matches [PageView.onPageChanged].
  final void Function(int)? onPageChanged;

  /// Matches [PageView.padEnds].
  final bool padEnds;

  /// Matches [PagedLayoutBuilder.shrinkWrapFirstPageIndicators].
  final bool shrinkWrapFirstPageIndicators;

  // 加载下一页失败时的重试回调
  final PagingDataController pagingDataController;

  final PagedChildStatusBuilderDelegate? statusBuilderDelegate;

  final bool? persistent;

  @override
  Widget build(BuildContext context) => PagedLayoutBuilder<PageKeyType, T>(
        layoutProtocol: PagedLayoutProtocol.box,
        builderDelegate: builderDelegate,
        shrinkWrapFirstPageIndicators: shrinkWrapFirstPageIndicators,
        pagingDataController: pagingDataController,
        itemListingBuilder: (BuildContext context,
            Widget Function(BuildContext, int) itemWidgetBuilder,
            int itemCount,
            PagedLayoutProtocol layoutProtocol) {
          return PageView.custom(
            key: key,
            restorationId: restorationId,
            controller: pageController,
            onPageChanged: onPageChanged,
            scrollBehavior: scrollBehavior,
            scrollDirection: scrollDirection,
            dragStartBehavior: dragStartBehavior,
            clipBehavior: clipBehavior,
            allowImplicitScrolling: allowImplicitScrolling,
            reverse: reverse,
            physics: physics,
            pageSnapping: pageSnapping,
            padEnds: padEnds,
            childrenDelegate: AppendedSliverChildBuilderDelegate(
              builder: itemWidgetBuilder,
              childCount: itemCount,
              appendixBuilder: (context) {
                return PagingStatusWidget(
                  builderDelegate: statusBuilderDelegate,
                  pagingDataController: pagingDataController,
                  layoutProtocol: layoutProtocol,
                  shrinkWrapFirstPageIndicators: shrinkWrapFirstPageIndicators,
                  isPersistent: persistent ?? false,
                );
              },
              addAutomaticKeepAlives: addAutomaticKeepAlives,
              addRepaintBoundaries: addRepaintBoundaries,
              addSemanticIndexes: addSemanticIndexes,
            ),
          );
        },
        isPersistent: persistent ?? false,
      );
}
