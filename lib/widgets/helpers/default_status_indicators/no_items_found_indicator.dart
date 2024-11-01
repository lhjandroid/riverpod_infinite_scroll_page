import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_infinite_scroll_page/widgets/helpers/default_status_indicators/first_page_exception_indicator.dart';

class NoItemsFoundIndicator extends StatelessWidget {
  const NoItemsFoundIndicator({super.key});

  @override
  Widget build(BuildContext context) => const FirstPageExceptionIndicator(
        title: 'No items found',
        message: 'The list is currently empty.',
      );
}
