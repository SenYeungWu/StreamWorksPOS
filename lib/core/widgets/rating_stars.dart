import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final int rating;

  const RatingStars(this.rating, {super.key});

  @override
  Widget build(BuildContext context) {
    String stars = '';
    for (int i = 0; i < rating; i++) {
      stars += '⭐ ';
    }
    return Text(
      stars.trim(),
      style: const TextStyle(fontSize: 18.0),
    );
  }
}
