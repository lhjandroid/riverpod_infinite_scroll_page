import 'package:flutter/foundation.dart';
import 'package:riverpod_infinite_scroll_page/riverpod_infinite_scroll_page.dart';

/// The current item's list, error, and next page key
/// for a paginated widget.
@immutable
class PagingState<PageKeyType, T extends PagingItem> {
  const PagingState({
    this.nextPageKey,
    this.itemList,
    this.error,
    this.isRefreshing,
  });

  /// List with all items loaded so far.
  final List<T>? itemList;

  /// The current error, if any.
  final dynamic error;

  /// The key for the next page to be fetched.
  final PageKeyType? nextPageKey;
  final bool? isRefreshing;

  /// The copyWith method for creating a copy of PagingState with modified properties
  PagingState<PageKeyType, T> copyWith({
    List<T>? itemList,
    dynamic error,
    PageKeyType? nextPageKey,
    bool? isRefreshing,
  }) {
    return PagingState<PageKeyType, T>(
      itemList: itemList,
      error: error,
      nextPageKey: nextPageKey,
      isRefreshing: isRefreshing,
    );
  }

  @override
  String toString() => '${objectRuntimeType(this, 'PagingState')}'
      '(itemList: \u2524$itemList\u251C, error: $error, nextPageKey: $nextPageKey)';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PagingState &&
            other.itemList == itemList &&
            other.error == error &&
            other.nextPageKey == nextPageKey &&
            other.isRefreshing == isRefreshing);
  }

  @override
  int get hashCode => Object.hash(
        itemList.hashCode,
        error.hashCode,
        nextPageKey.hashCode,
        isRefreshing.hashCode,
      );
}
