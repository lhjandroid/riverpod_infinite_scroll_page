import 'package:flutter/material.dart';
import 'package:riverpod_infinite_scroll_page/model/paging_item.dart';

typedef PagingItemBuilder = Widget Function<T extends PagingItem>(
    BuildContext context, T data, int index);

class PagingItemRegister<T extends PagingItem> {
  final Map<Type, PagingItemBuilder> itemRegister;

  PagingItemRegister({required this.itemRegister});

  bool containsKey(Type key) {
    return itemRegister.containsKey(key);
  }

  PagingItemBuilder? operator [](Type key) {
    return itemRegister[key];
  }
}
