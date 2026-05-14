import 'package:flutter/material.dart';

import 'seek_bar.dart';
import 'transport_row.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({required this.itemId, super.key});

  final String itemId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black87],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SeekBar(itemId: itemId),
            TransportRow(itemId: itemId),
          ],
        ),
      ),
    );
  }
}
