import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_infinite_scroll_page/core/paged_child_builder_delegate.dart';
import 'package:riverpod_infinite_scroll_page/register/paging_item_register.dart';
import 'package:riverpod_infinite_scroll_page/widgets/helpers/paged_layout_builder.dart';
import 'package:tuple/tuple.dart';

class MultiItemChildBuilderDelegate extends PagedChildBuilderDelegate {
  final PagingItemRegister pagingItemRegister;

  MultiItemChildBuilderDelegate(
    String pageKey, {
    required this.pagingItemRegister,
    super.animateTransitions = false,
  }) : super(
          itemBuilder: (context, index) {
            return PopScope(
              child: ItemWidget(
                pageKey: pageKey,
                pagingItemRegister: pagingItemRegister,
                index: index,
              ),
            );
          },
        );
}

// Widget for displaying an individual item
class ItemWidget extends ConsumerWidget {
  final PagingItemRegister pagingItemRegister;
  final int index;
  final String pageKey;

  const ItemWidget({
    super.key,
    required this.pageKey,
    required this.pagingItemRegister,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use ref.watch to get the specific item at this index
    var itemData = ref.watch(itemAtProvider(Tuple2(pageKey, index)));
    final itemType = itemData.runtimeType;

    // 判断 itemRegister 是否包含该类型的 builder
    if (pagingItemRegister.containsKey(itemType)) {
      final builder = pagingItemRegister[itemType] as PagingItemBuilder;
      return builder(context, itemData, index);
    }

    return Container();
  }
}
