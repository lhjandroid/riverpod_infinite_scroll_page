import 'package:flutter/widgets.dart';
import 'package:riverpod_infinite_scroll_page/model/paging_item.dart';

typedef ItemWidgetBuilder = Widget Function(
  BuildContext context,
  int index,
);

typedef ErrorIndicatorBuilder = Widget Function(
    BuildContext context, VoidCallback retryCallback);

/// Supplies builders for the visual components of paged views.
///
/// The generic type [ItemType] must be specified in order to properly identify
/// the list item’s type.
class PagedChildBuilderDelegate<T extends PagingItem> {
  PagedChildBuilderDelegate({
    required this.itemBuilder,
    this.animateTransitions = false,
    this.transitionDuration = const Duration(milliseconds: 250),
  });

  /// The builder for list items.
  final ItemWidgetBuilder itemBuilder;

  /// Whether status transitions should be animated.
  final bool animateTransitions;

  /// The duration of animated transitions when [animateTransitions] is `true`.
  final Duration transitionDuration;
}

class PagedChildStatusBuilderDelegate<T extends PagingItem> {
  PagedChildStatusBuilderDelegate({
    this.firstPageErrorIndicatorBuilder,
    this.newPageErrorIndicatorBuilder,
    this.firstPageProgressIndicatorBuilder,
    this.newPageProgressIndicatorBuilder,
    this.noItemsFoundIndicatorBuilder,
    this.noMoreItemsIndicatorBuilder,
    this.animateTransitions = false,
    this.transitionDuration = const Duration(milliseconds: 250),
  });

  /// The builder for the first page's error indicator.
  final ErrorIndicatorBuilder? firstPageErrorIndicatorBuilder;

  /// The builder for a new page's error indicator.
  final ErrorIndicatorBuilder? newPageErrorIndicatorBuilder;

  /// The builder for the first page's progress indicator.
  final WidgetBuilder? firstPageProgressIndicatorBuilder;

  /// The builder for a new page's progress indicator.
  final WidgetBuilder? newPageProgressIndicatorBuilder;

  /// The builder for a no items list indicator.
  final WidgetBuilder? noItemsFoundIndicatorBuilder;

  /// The builder for an indicator that all items have been fetched.
  final WidgetBuilder? noMoreItemsIndicatorBuilder;

  /// Whether status transitions should be animated.
  final bool animateTransitions;

  /// The duration of animated transitions when [animateTransitions] is `true`.
  final Duration transitionDuration;
}
