import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SharedHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const SharedHeader({
    Key? key,
    this.title = 'Smart Sleep',
    this.subtitle = 'Embedded Sound Therapy',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateFormat = DateFormat('MM/dd/yyyy');
    final dayFormat = DateFormat('EEEE');

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                dateFormat.format(now),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              Text(
                dayFormat.format(now),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
