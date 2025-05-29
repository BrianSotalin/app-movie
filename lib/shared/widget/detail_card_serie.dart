import 'package:flutter/material.dart';

Widget buildSerieCover(String url) {
  if (url.isNotEmpty && url.startsWith('http')) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Image.network(
        url,
        fit: BoxFit.contain,
        height: 300,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 300,
            color: Colors.grey[300],
            child: Icon(Icons.broken_image, size: 50, color: Colors.grey[600]),
          );
        },
      ),
    );
  } else {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey[600]),
    );
  }
}
