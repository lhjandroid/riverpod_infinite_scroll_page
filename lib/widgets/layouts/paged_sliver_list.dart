import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_infinite_scroll_page/core/paged_child_builder_delegate.dart';
import 'package:riverpod_infinite_scroll_page/core/paging_data_controller.dart';
import 'package:riverpod_infinite_scroll_page/model/paging_item.dart';
import 'package:riverpod_infinite_scroll_page/utils/appended_sliver_child_builder_delegate.dart';
import 'package:riverpod_infinite_scroll_page/widgets/helpers/paged_layout_builder.dart';
import 'package:riverpod_infinite_scroll_page/widgets/helpers/paging_status_widget.dart';

class PagedSliverList<PageKeyType, T extends PagingItem> extends ConsumerWidget {
  const PagedSliverList({
    required this.builderDelegate,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.itemExtent,
    this.prototypeItem,
    this.semanticIndexCallback,
    this.shrinkWrapFirstPageIndicators = false,
    super.key,
    required this.pagingBuilderController,
    this.statusBuilderDelegate,
    this.layoutProtocol,
    this.persistent,
    this.forceUseInitData,
  })  : assert(
          itemExtent == null || prototypeItem == null,
          'You can only pass itemExtent or prototypeItem, not both',
        ),
        _separatorBuilder = null;

  const PagedSliverList.separated({
    required this.builderDelegate,
    required IndexedWidgetBuilder separatorBuilder,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.itemExtent,
    this.semanticIndexCallback,
    this.shrinkWrapFirstPageIndicators = false,
    super.key,
    required this.pagingBuilderController,
    this.layoutProtocol,
    this.statusBuilderDelegate,
    this.persistent,
    this.forceUseInitData,
  })  : prototypeItem = null,
        _separatorBuilder = separatorBuilder;

  /// Matches [PagedLayoutBuilder.builderDelegate].
  final PagedChildBuilderDelegate<T> builderDelegate;

  final PagedChildStatusBuilderDelegate? statusBuilderDelegate;

  /// The builder for list item separators, just like in [ListView.separated].
  final IndexedWidgetBuilder? _separatorBuilder;

  /// Matches [SliverChildBuilderDelegate.addAutomaticKeepAlives].
  final bool addAutomaticKeepAlives;

  /// Matches [SliverChildBuilderDelegate.addRepaintBoundaries].
  final bool addRepaintBoundaries;

  /// Matches [SliverChildBuilderDelegate.addSemanticIndexes].
  final bool addSemanticIndexes;

  /// Matches [SliverChildBuilderDelegate.semanticIndexCallback].
  final SemanticIndexCallback? semanticIndexCallback;

  /// Matches [SliverFixedExtentList.itemExtent].
  ///
  /// If this is not null, [prototypeItem] must be null, and vice versa.
  final double? itemExtent;

  /// Matches [SliverPrototypeExtentList.prototypeItem].
  ///
  /// If this is not null, [itemExtent] must be null, and vice versa.
  final Widget? prototypeItem;

  /// Matches [PagedLayoutBuilder.shrinkWrapFirstPageIndicators].
  final bool shrinkWrapFirstPageIndicators;

  // 加载下一页失败时的重试回调
  final PagingDataController pagingBuilderController;

  final PagedLayoutProtocol? layoutProtocol;

  final bool? persistent;
  final bool? forceUseInitData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PagedLayoutBuilder<PageKeyType, T>(
      layoutProtocol: layoutProtocol ?? PagedLayoutProtocol.sliver,
      builderDelegate: builderDelegate,
      shrinkWrapFirstPageIndicators: shrinkWrapFirstPageIndicators,
      pagingDataController: pagingBuilderController,
      isPersistent: persistent ?? false,
      itemListingBuilder: (BuildContext context, Widget Function(BuildContext, int) itemWidgetBuilder, int itemCount,
              PagedLayoutProtocol layoutProtocol) =>
          _buildSliverList(
        itemWidgetBuilder,
        itemCount,
        layoutProtocol,
      ),
      forceUseInitData: forceUseInitData ?? false,
    );
  }

  SliverMultiBoxAdaptorWidget _buildSliverList(IndexedWidgetBuilder itemBuilder, int itemCount, layoutProtocol) {
    final delegate = _buildSliverDelegate(
      itemBuilder,
      itemCount,
      layoutProtocol,
    );

    final itemExtent = this.itemExtent;

    return ((itemExtent == null && prototypeItem == null) || _separatorBuilder != null)
        ? SliverList(
            delegate: delegate,
          )
        : (itemExtent != null)
            ? SliverFixedExtentList(
                delegate: delegate,
                itemExtent: itemExtent,
              )
            : SliverPrototypeExtentList(
                delegate: delegate,
                prototypeItem: prototypeItem!,
              );
  }

  SliverChildBuilderDelegate _buildSliverDelegate(
    IndexedWidgetBuilder itemBuilder,
    int itemCount,
    PagedLayoutProtocol layoutProtocol,
  ) {
    final separatorBuilder = _separatorBuilder;

    return separatorBuilder == null
        ? AppendedSliverChildBuilderDelegate(
            builder: (context, index) {
              final itemKey = Key('item_$index'); // Using Key to track individual items
              return ProviderScope(
                key: itemKey,
                child: itemBuilder(context, index),
              );
            },
            childCount: itemCount,
            appendixBuilder: (context) {
              return PagingStatusWidget(
                builderDelegate: statusBuilderDelegate,
                pagingDataController: pagingBuilderController,
                layoutProtocol: layoutProtocol,
                shrinkWrapFirstPageIndicators: shrinkWrapFirstPageIndicators,
                isPersistent: persistent ?? false,
              );
            },
            addAutomaticKeepAlives: addAutomaticKeepAlives,
            addRepaintBoundaries: addRepaintBoundaries,
            addSemanticIndexes: addSemanticIndexes,
            semanticIndexCallback: semanticIndexCallback,
          )
        : AppendedSliverChildBuilderDelegate.separated(
            builder: itemBuilder,
            childCount: itemCount,
            appendixBuilder: (context) {
              return PagingStatusWidget(
                builderDelegate: statusBuilderDelegate,
                pagingDataController: pagingBuilderController,
                layoutProtocol: layoutProtocol,
                shrinkWrapFirstPageIndicators: shrinkWrapFirstPageIndicators,
                isPersistent: persistent ?? false,
              );
            },
            separatorBuilder: separatorBuilder,
            addAutomaticKeepAlives: addAutomaticKeepAlives,
            addRepaintBoundaries: addRepaintBoundaries,
            addSemanticIndexes: addSemanticIndexes,
          );
  }
}
