import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pos/core/models/restaurant.dart';

Future<void> showRestaurantContactModal(
  BuildContext context,
  Restaurant restaurant,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext ctx) => RestaurantContactModal(restaurant: restaurant),
  );
}

class RestaurantContactModal extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantContactModal({super.key, required this.restaurant});

  String _getPhoneNumber(Restaurant r) {
    // Generate a stable, realistic NYC phone number based on restaurant name
    final code = r.name.codeUnits.fold<int>(0, (prev, elem) => prev + elem);
    final suffix = (1000 + (code % 8999)).toString();
    return '(212) 555-$suffix';
  }

  void _openSendMessageDialog(BuildContext context) {
    final textController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Row(
            children: [
              Icon(
                Icons.mail_outline,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8.0),
              const Text(
                'Contact Merchant',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Send a message to ${restaurant.name}:',
                style: const TextStyle(fontSize: 14.0),
              ),
              const SizedBox(height: 12.0),
              TextField(
                controller: textController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Inquire about reservations, dietary options, or orders...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  contentPadding: const EdgeInsets.all(12.0),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () {
                final message = textController.text.trim();
                if (message.isNotEmpty) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Message sent to ${restaurant.name}. Expect a reply shortly!'),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
              child: const Text('Send Message'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final phoneNumber = _getPhoneNumber(restaurant);

    return DraggableScrollableSheet(
      initialChildSize: 0.70,
      minChildSize: 0.40,
      maxChildSize: 0.90,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag Handle
              const SizedBox(height: 12.0),
              Container(
                width: 40.0,
                height: 5.0,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Merchant Contact & Info',
                            style: TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            restaurant.name,
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1.0),
              // Scrollable Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  children: [
                    // Status Badge Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 20.0),
                          const SizedBox(width: 8.0),
                          const Text(
                            'Open Now',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 15.0,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            restaurant.distance,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 13.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Phone Tile
                    _buildSectionCard(
                      icon: Icons.phone_outlined,
                      iconColor: primaryColor,
                      title: 'Phone Number',
                      subtitle: phoneNumber,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.copy, size: 20.0),
                            tooltip: 'Copy Phone',
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: phoneNumber));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Phone number copied to clipboard!'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            icon: const Icon(Icons.call, size: 16.0),
                            label: const Text('Call'),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Calling $phoneNumber...'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12.0),

                    // Address Tile
                    _buildSectionCard(
                      icon: Icons.location_on_outlined,
                      iconColor: primaryColor,
                      title: 'Location & Address',
                      subtitle: restaurant.address,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.copy, size: 20.0),
                            tooltip: 'Copy Address',
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: restaurant.address));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Address copied to clipboard!'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primaryColor,
                              side: BorderSide(color: primaryColor),
                              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            icon: const Icon(Icons.directions, size: 16.0),
                            label: const Text('Directions'),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Opening navigation to ${restaurant.address}...'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12.0),

                    // Hours of Operation Tile
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.access_time, color: primaryColor, size: 22.0),
                              const SizedBox(width: 8.0),
                              const Text(
                                'Hours of Operation',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12.0),
                          _buildHourRow('Monday – Thursday', '11:00 AM – 10:00 PM'),
                          _buildHourRow('Friday – Saturday', '11:00 AM – 11:00 PM'),
                          _buildHourRow('Sunday', '12:00 PM – 9:30 PM'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Send Inquiry Button
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      icon: const Icon(Icons.email_outlined),
                      label: const Text(
                        'Send Message to Merchant',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () => _openSendMessageDialog(context),
                    ),
                    const SizedBox(height: 30.0),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: iconColor, size: 24.0),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey[700],
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Align(
            alignment: Alignment.centerRight,
            child: trailing,
          ),
        ],
      ),
    );
  }

  Widget _buildHourRow(String days, String hours) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            days,
            style: const TextStyle(fontSize: 13.0, color: Colors.black87),
          ),
          Text(
            hours,
            style: TextStyle(
              fontSize: 13.0,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
