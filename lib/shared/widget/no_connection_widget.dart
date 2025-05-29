import 'package:flutter/material.dart';

class NoConnectionWidget extends StatelessWidget {
  final VoidCallback onRetry;
  final Color? color;

  const NoConnectionWidget({super.key, required this.onRetry, this.color});

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? Theme.of(context).colorScheme.secondary;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.wifi_off, size: 80, color: iconColor),
          const SizedBox(height: 20),
          Text(
            'Sin conexión a Internet',
            style: TextStyle(fontSize: 18, color: iconColor),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white60),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
