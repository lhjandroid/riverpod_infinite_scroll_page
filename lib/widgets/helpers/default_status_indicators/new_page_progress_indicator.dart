import 'package:flutter/material.dart';
import 'package:riverpod_infinite_scroll_page/widgets/helpers/default_status_indicators/footer_tile.dart';

class NewPageProgressIndicator extends StatelessWidget {
  const NewPageProgressIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) => const FooterTile(
        child: CircularProgressIndicator(),
      );
}
