import 'package:riverpod_infinite_scroll_page/riverpod_infinite_scroll_page.dart';

class TestItem extends PagingItem {
  final String name;

  TestItem(this.name);

  @override
  String get itemType => '1';

  // Override == and hashCode to compare items properly
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TestItem && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}
