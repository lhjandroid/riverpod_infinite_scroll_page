import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_infinite_scroll_page/core/paged_child_builder_delegate.dart';
import 'package:riverpod_infinite_scroll_page/core/paging_controller.dart';
import 'package:riverpod_infinite_scroll_page/core/paging_data_controller.dart';
import 'package:riverpod_infinite_scroll_page/model/paging_item.dart';
import 'package:riverpod_infinite_scroll_page/model/paging_state.dart';
import 'package:riverpod_infinite_scroll_page/widgets/helpers/paged_layout_builder.dart';
import 'package:riverpod_infinite_scroll_page/widgets/layouts/paged_sliver_list.dart';

/// A [ListView] with pagination capabilities.
///
/// To include separators, use [PagedListView.separated].
///
/// Wraps a [PagedSliverList] in a [BoxScrollView] so that it can be
/// used without the need for a [CustomScrollView]. Similar to a [ListView].
class PagedListView<PageKeyType, T extends PagingItem> extends BoxScrollView {
  const PagedListView({
    required this.pagingControllerProvider,
    required this.builderDelegate,
    // Matches [ScrollView.controller].
    ScrollController? scrollController,
    this.statusBuilderDelegate,
    // Matches [ScrollView.scrollDirection].
    super.scrollDirection,
    // Matches [ScrollView.reverse].
    super.reverse,
    // Matches [ScrollView.primary].
    super.primary,
    // Matches [ScrollView.physics].
    super.physics,
    // Matches [ScrollView.shrinkWrap].
    super.shrinkWrap,
    // Matches [BoxScrollView.padding].
    super.padding,
    this.itemExtent,
    this.prototypeItem,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    required this.pagingDataController,
    // Matches [ScrollView.cacheExtent]
    super.cacheExtent,
    // Matches [ScrollView.dragStartBehavior]
    super.dragStartBehavior,
    // Matches [ScrollView.keyboardDismissBehavior]
    super.keyboardDismissBehavior,
    // Matches [ScrollView.restorationId]
    super.restorationId,
    // Matches [ScrollView.clipBehavior]
    super.clipBehavior,
    super.key,
  })  : assert(
          itemExtent == null || prototypeItem == null,
          'You can only pass itemExtent or prototypeItem, not both',
        ),
        _separatorBuilder = null,
        _shrinkWrapFirstPageIndicators = shrinkWrap,
        super(
          controller: scrollController,
        );

  const PagedListView.separated({
    required this.pagingControllerProvider,
    required this.builderDelegate,
    required IndexedWidgetBuilder separatorBuilder,
    this.statusBuilderDelegate,
    // Matches [ScrollView.controller].
    ScrollController? scrollController,
    // Matches [ScrollView.scrollDirection].
    super.scrollDirection,
    // Matches [ScrollView.reverse].
    super.reverse,
    // Matches [ScrollView.primary].
    super.primary,
    // Matches [ScrollView.physics].
    super.physics,
    // Matches [ScrollView.shrinkWrap].
    super.shrinkWrap,
    // Matches [BoxScrollView.padding].
    super.padding,
    this.itemExtent,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    required this.pagingDataController,
    // Matches [ScrollView.cacheExtent]
    super.cacheExtent,
    // Matches [ScrollView.dragStartBehavior]
    super.dragStartBehavior,
    // Matches [ScrollView.keyboardDismissBehavior]
    super.keyboardDismissBehavior,
    // Matches [ScrollView.restorationId]
    super.restorationId,
    // Matches [ScrollView.clipBehavior]
    super.clipBehavior,
    super.key,
  })  : prototypeItem = null,
        _shrinkWrapFirstPageIndicators = shrinkWrap,
        _separatorBuilder = separatorBuilder,
        super(
          controller: scrollController,
        );

  /// Matches [PagedLayoutBuilder.pagingController].
  final AutoDisposeFamilyNotifierProvider<PagingController<PageKeyType, T>,
      PagingState<PageKeyType, T>, PageKeyType> pagingControllerProvider;

  /// Matches [PagedLayoutBuilder.builderDelegate].
  final PagedChildBuilderDelegate<T> builderDelegate;

  /// The builder for list item separators, just like in [ListView.separated].
  final IndexedWidgetBuilder? _separatorBuilder;

  /// Matches [SliverChildBuilderDelegate.addAutomaticKeepAlives].
  final bool addAutomaticKeepAlives;

  /// Matches [SliverChildBuilderDelegate.addRepaintBoundaries].
  final bool addRepaintBoundaries;

  /// Matches [SliverChildBuilderDelegate.addSemanticIndexes].
  final bool addSemanticIndexes;

  /// Matches [SliverFixedExtentList.itemExtent].
  ///
  /// If this is not null, [prototypeItem] must be null, and vice versa.
  final double? itemExtent;

  /// Matches [SliverPrototypeExtentList.prototypeItem].
  ///
  /// If this is not null, [itemExtent] must be null, and vice versa.
  final Widget? prototypeItem;

  /// Matches [PagedSliverList.shrinkWrapFirstPageIndicators].
  final bool _shrinkWrapFirstPageIndicators;

  // 加载下一页失败时的重试回调
  final PagingDataController pagingDataController;

  final PagedChildStatusBuilderDelegate? statusBuilderDelegate;

  @override
  Widget buildChildLayout(BuildContext context) {
    final separatorBuilder = _separatorBuilder;
    return separatorBuilder != null
        ? PagedSliverList<PageKeyType, T>.separated(
            builderDelegate: builderDelegate,
            pagingControllerProvider: pagingControllerProvider,
            separatorBuilder: separatorBuilder,
            addAutomaticKeepAlives: addAutomaticKeepAlives,
            addRepaintBoundaries: addRepaintBoundaries,
            addSemanticIndexes: addSemanticIndexes,
            itemExtent: itemExtent,
            shrinkWrapFirstPageIndicators: _shrinkWrapFirstPageIndicators,
            pagingBuilderController: pagingDataController,
            statusBuilderDelegate: statusBuilderDelegate,
            layoutProtocol: PagedLayoutProtocol.box,
          )
        : PagedSliverList<PageKeyType, T>(
            builderDelegate: builderDelegate,
            pagingControllerProvider: pagingControllerProvider,
            addAutomaticKeepAlives: addAutomaticKeepAlives,
            addRepaintBoundaries: addRepaintBoundaries,
            addSemanticIndexes: addSemanticIndexes,
            itemExtent: itemExtent,
            shrinkWrapFirstPageIndicators: _shrinkWrapFirstPageIndicators,
            prototypeItem: prototypeItem,
            pagingBuilderController: pagingDataController,
            statusBuilderDelegate: statusBuilderDelegate,
            layoutProtocol: PagedLayoutProtocol.box,
          );
  }
}
