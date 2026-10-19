import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/core/services/telemetry_service.dart';

class CourierTrackingScreen extends ConsumerStatefulWidget {
  const CourierTrackingScreen({super.key});

  @override
  ConsumerState<CourierTrackingScreen> createState() => _CourierTrackingScreenState();
}

class _CourierTrackingScreenState extends ConsumerState<CourierTrackingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(telemetryProvider.notifier).startTrackingSimulation();
    });
  }

  Widget _buildStepIndicator(
    BuildContext context, {
    required String title,
    required String description,
    required bool isCompleted,
    required bool isCurrent,
    required IconData icon,
  }) {
    final primaryColor = Theme.of(context).primaryColor;
    final color = isCompleted || isCurrent ? primaryColor : Colors.grey.shade400;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 36.0,
              height: 36.0,
              decoration: BoxDecoration(
                color: isCompleted ? primaryColor : (isCurrent ? Colors.white : Colors.grey.shade200),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2.0),
              ),
              child: Icon(
                isCompleted ? Icons.check : icon,
                size: 18.0,
                color: isCompleted ? Colors.white : color,
              ),
            ),
          ],
        ),
        const SizedBox(width: 14.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                  color: isCurrent ? Colors.black : Colors.black87,
                ),
              ),
              const SizedBox(height: 2.0),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13.0,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final tracking = ref.watch(telemetryProvider);
    const stages = OrderLifecycleStage.values;
    final currentStageIndex = stages.indexOf(tracking.stage);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Order Tracking'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          // Order ID & ETA Hero Banner
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8.0,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order #${tracking.orderId}',
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Text(
                        tracking.stage.title,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                Text(
                  tracking.remainingEtaMinutes > 0
                      ? 'Estimated Delivery in ${tracking.remainingEtaMinutes} min'
                      : 'Delivered to your door',
                  style: const TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12.0),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: LinearProgressIndicator(
                    value: tracking.progressPercent,
                    minHeight: 8.0,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20.0),

          // Route Map Simulator (TASK-4.5)
          Container(
            height: 200.0,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map_outlined, size: 48.0, color: Colors.grey.shade400),
                      const SizedBox(height: 8.0),
                      Text(
                        'Live GPS Telemetry Stream',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                          fontSize: 16.0,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Courier Lat: ${tracking.courierLocation.latitude.toStringAsFixed(4)}, Lng: ${tracking.courierLocation.longitude.toStringAsFixed(4)}',
                        style: TextStyle(
                          fontSize: 13.0,
                          color: Colors.grey.shade600,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 16.0,
                  left: 16.0,
                  child: Row(
                    children: [
                      const Icon(Icons.store, size: 20.0, color: Colors.deepOrangeAccent),
                      const SizedBox(width: 6.0),
                      Text(
                        tracking.restaurantName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 16.0,
                  right: 16.0,
                  child: Row(
                    children: [
                      const Icon(Icons.home, size: 20.0, color: Colors.green),
                      const SizedBox(width: 6.0),
                      Text(
                        tracking.destinationAddress,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24.0),

          // Order Lifecycle Stepper (TASK-4.4)
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8.0,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Delivery Progress',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16.0),
                _buildStepIndicator(
                  context,
                  title: 'Order Placed',
                  description: 'Restaurant has received your order',
                  isCompleted: currentStageIndex > 0,
                  isCurrent: currentStageIndex == 0,
                  icon: Icons.receipt_long,
                ),
                _buildStepIndicator(
                  context,
                  title: 'Kitchen Preparing',
                  description: 'Chef is crafting your artisanal dishes',
                  isCompleted: currentStageIndex > 1,
                  isCurrent: currentStageIndex == 1,
                  icon: Icons.outdoor_grill,
                ),
                _buildStepIndicator(
                  context,
                  title: 'Courier En Route',
                  description: 'Courier picked up and is heading to you',
                  isCompleted: currentStageIndex > 2,
                  isCurrent: currentStageIndex == 2,
                  icon: Icons.delivery_dining,
                ),
                _buildStepIndicator(
                  context,
                  title: 'Delivered',
                  description: 'Order completed and delivered to your door',
                  isCompleted: currentStageIndex == 3,
                  isCurrent: currentStageIndex == 3,
                  icon: Icons.check_circle_outline,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
