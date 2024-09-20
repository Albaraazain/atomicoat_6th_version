import 'package:flutter/material.dart';

class SystemHealthIndicator extends StatelessWidget {
  final double systemHealth;

  const SystemHealthIndicator({Key? key, required this.systemHealth}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color healthColor = _getHealthColor(systemHealth);

    return Container(
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.health_and_safety, color: healthColor),
          SizedBox(width: 8),
          Text(
            'System Health: ${(systemHealth * 100).toStringAsFixed(1)}%',
            style: TextStyle(color: healthColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Color _getHealthColor(double health) {
    if (health > 0.8) return Colors.green;
    if (health > 0.6) return Colors.yellow;
    return Colors.red;
  }
}