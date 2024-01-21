import 'package:flutter/material.dart';

class PlayerItem extends StatelessWidget {
  const PlayerItem({
    super.key,
    required this.playerName,
  });

  final String playerName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: const Color.fromARGB(255, 123, 193, 255),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Center(
              child: Text(
                playerName,
                style: const TextStyle(
                  fontSize: 22,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
