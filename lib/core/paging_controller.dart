import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_infinite_scroll_page/model/paging_item.dart';
import 'package:riverpod_infinite_scroll_page/model/paging_state.dart';

abstract class PagingDataControllerInterface<PageKeyType, T extends PagingItem> {
  void appendPage(List<T> newItems, PageKeyType? nextPageKey);

  void loadError(dynamic error);

  void appendLastPage(List<T> newItems);

  void updateItemAt(int index, T updatedItem);

  void refresh(PageKeyType firstPageKey);

  void onGoing();
}

class PagingController<PageKeyType, T extends PagingItem>
    extends AutoDisposeFamilyNotifier<PagingState<PageKeyType, T>, PageKeyType>
    implements PagingDataControllerInterface<PageKeyType, T> {
  @override
  PagingState<PageKeyType, T> build(PageKeyType arg) {
    // Initialize the state when the PagingController is built
    return PagingState<PageKeyType, T>(
      nextPageKey: arg,
      itemList: null,
      error: null,
    );
  }

  /// Append new items to the current list and set the next page key
  void appendPage(List<T> newItems, PageKeyType? nextPageKey) {
    final updatedItems = <T>[...(state.itemList ?? []), ...newItems];
    state = state.copyWith(
      itemList: updatedItems,
      nextPageKey: nextPageKey,
      error: null,
    );
  }

  /// Updates the state with an error when an error occurs while loading data.
  /// This method is used to handle errors that occur during the data loading process.
  /// It keeps the current item list and next page key unchanged, but sets the error
  /// to the provided error object.
  ///
  /// @param error The error object that occurred while loading data.
  void loadError(dynamic error) {
    state = state.copyWith(
      itemList: state.itemList,
      nextPageKey: state.nextPageKey,
      error: error,
    );
  }

  /// Append the last page and set the nextPageKey to null
  void appendLastPage(List<T> newItems) {
    final updatedItems = <T>[...(state.itemList ?? []), ...newItems];
    state = state.copyWith(
      itemList: updatedItems,
      nextPageKey: null, // Indicating this is the last page
      error: null,
    );
  }

  /// Update a specific item in the list at the given index
  void updateItemAt(int index, T updatedItem) {
    final items = state.itemList ?? [];
    if (index >= 0 && index < items.length) {
      final updatedItemList = List<T>.from(items); // Copy the list
      updatedItemList[index] = updatedItem; // Update the item at the given index

      state = state.copyWith(
        itemList: updatedItemList,
        nextPageKey: state.nextPageKey,
        error: state.error,
      );
    }
  }

  /// Reset the state to the initial state (clear items and reset to the first page key)
  void refresh(PageKeyType firstPageKey) {
    state = PagingState<PageKeyType, T>(
      nextPageKey: firstPageKey,
      itemList: <T>[],
      error: null,
    );
  }

  /// Determine whether the next page should be fetched based on the current index
  bool shouldRequestNextPage(int currentIndex) {
    final itemCount = state.itemList?.length ?? 0;
    final requestThreshold = itemCount - 3; // Invisible item threshold
    return currentIndex >= requestThreshold;
  }

  /// Update the state to indicate that data loading is in progress
  void onGoing() {
    state = state.copyWith(
      itemList: state.itemList,
      nextPageKey: state.nextPageKey,
      error: null,
    );
  }
}

class PersistentPagingController<PageKeyType, T extends PagingItem>
    extends FamilyNotifier<PagingState<PageKeyType, T>, PageKeyType>
    implements PagingDataControllerInterface<PageKeyType, T> {
  @override
  PagingState<PageKeyType, T> build(PageKeyType arg) {
    // Initialize the state when the PagingController is built
    return PagingState<PageKeyType, T>(
      nextPageKey: arg,
      itemList: null,
      error: null,
    );
  }

  /// Append new items to the current list and set the next page key
  void appendPage(List<T> newItems, PageKeyType? nextPageKey) {
    final updatedItems = <T>[...(state.itemList ?? []), ...newItems];
    state = state.copyWith(
      itemList: updatedItems,
      nextPageKey: nextPageKey,
      error: null,
    );
  }

  /// Updates the state with an error when an error occurs while loading data.
  /// This method is used to handle errors that occur during the data loading process.
  /// It keeps the current item list and next page key unchanged, but sets the error
  /// to the provided error object.
  ///
  /// @param error The error object that occurred while loading data.
  void loadError(dynamic error) {
    state = state.copyWith(
      itemList: state.itemList,
      nextPageKey: state.nextPageKey,
      error: error,
    );
  }

  /// Append the last page and set the nextPageKey to null
  void appendLastPage(List<T> newItems) {
    final updatedItems = <T>[...(state.itemList ?? []), ...newItems];
    state = state.copyWith(
      itemList: updatedItems,
      nextPageKey: null, // Indicating this is the last page
      error: null,
    );
  }

  /// Update a specific item in the list at the given index
  void updateItemAt(int index, T updatedItem) {
    final items = state.itemList ?? [];
    if (index >= 0 && index < items.length) {
      final updatedItemList = List<T>.from(items); // Copy the list
      updatedItemList[index] = updatedItem; // Update the item at the given index

      state = state.copyWith(
        itemList: updatedItemList,
        nextPageKey: state.nextPageKey,
        error: state.error,
      );
    }
  }

  /// Reset the state to the initial state (clear items and reset to the first page key)
  void refresh(PageKeyType firstPageKey) {
    state = PagingState<PageKeyType, T>(
      nextPageKey: firstPageKey,
      itemList: <T>[],
      error: null,
    );
  }

  /// Determine whether the next page should be fetched based on the current index
  bool shouldRequestNextPage(int currentIndex) {
    final itemCount = state.itemList?.length ?? 0;
    final requestThreshold = itemCount - 3; // Invisible item threshold
    return currentIndex >= requestThreshold;
  }

  /// Update the state to indicate that data loading is in progress
  void onGoing() {
    state = state.copyWith(
      itemList: state.itemList,
      nextPageKey: state.nextPageKey,
      error: null,
    );
  }
}
