import 'package:flutter/material.dart';

Future<bool> showSingleMerchantConflictDialog(
  BuildContext context, {
  required String currentMerchant,
  required String newMerchant,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Start New Order?'),
      content: Text(
        'Your cart already contains items from "$currentMerchant". '
        'You can only order from one restaurant at a time.\n\n'
        'Would you like to clear your cart and start a new order from "$newMerchant"?',
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).primaryColor,
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Clear & Add'),
        ),
      ],
    ),
  );
  return result ?? false;
}
