import 'package:flutter/material.dart';
import 'package:riverpod_infinite_scroll_page/widgets/helpers/default_status_indicators/footer_tile.dart';

class NewPageErrorIndicator extends StatelessWidget {
  const NewPageErrorIndicator({
    super.key,
    this.onTap,
  });
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: const FooterTile(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Something went wrong. Tap to try again.',
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 4,
              ),
              Icon(
                Icons.refresh,
                size: 16,
              ),
            ],
          ),
        ),
      );
}