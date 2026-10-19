import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum OrderLifecycleStage {
  orderPlaced(title: 'Order Placed', description: 'Restaurant has received your order'),
  preparing(title: 'Kitchen Preparing', description: 'Chef is crafting your artisanal dishes'),
  pickedUp(title: 'Courier En Route', description: 'Courier has picked up and is heading to you'),
  delivered(title: 'Delivered', description: 'Enjoy your meal!');

  final String title;
  final String description;
  const OrderLifecycleStage({required this.title, required this.description});
}

class CourierLocation {
  final double latitude;
  final double longitude;
  final double heading;

  const CourierLocation({
    required this.latitude,
    required this.longitude,
    this.heading = 0.0,
  });
}

class TrackingState {
  final String orderId;
  final String restaurantName;
  final String destinationAddress;
  final OrderLifecycleStage stage;
  final CourierLocation courierLocation;
  final int remainingEtaMinutes;
  final double progressPercent; // 0.0 to 1.0

  const TrackingState({
    required this.orderId,
    required this.restaurantName,
    required this.destinationAddress,
    required this.stage,
    required this.courierLocation,
    required this.remainingEtaMinutes,
    required this.progressPercent,
  });

  TrackingState copyWith({
    String? orderId,
    String? restaurantName,
    String? destinationAddress,
    OrderLifecycleStage? stage,
    CourierLocation? courierLocation,
    int? remainingEtaMinutes,
    double? progressPercent,
  }) {
    return TrackingState(
      orderId: orderId ?? this.orderId,
      restaurantName: restaurantName ?? this.restaurantName,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      stage: stage ?? this.stage,
      courierLocation: courierLocation ?? this.courierLocation,
      remainingEtaMinutes: remainingEtaMinutes ?? this.remainingEtaMinutes,
      progressPercent: progressPercent ?? this.progressPercent,
    );
  }
}

class TelemetryService extends Notifier<TrackingState> {
  Timer? _simulationTimer;

  // Origin (Restaurant: SoHo) -> Destination (Customer: City Hall)
  static const double originLat = 40.7250;
  static const double originLng = -73.9984;
  static const double destLat = 40.7128;
  static const double destLng = -74.0060;

  @override
  TrackingState build() {
    ref.onDispose(() {
      _simulationTimer?.cancel();
    });

    return const TrackingState(
      orderId: 'SW-89421',
      restaurantName: 'The Rustic Table Bistro',
      destinationAddress: '250 Broadway, New York, NY',
      stage: OrderLifecycleStage.orderPlaced,
      courierLocation: CourierLocation(latitude: originLat, longitude: originLng),
      remainingEtaMinutes: 25,
      progressPercent: 0.0,
    );
  }

  /// Starts or advances the real-time telemetry simulation stream (TASK-4.4)
  void startTrackingSimulation() {
    _simulationTimer?.cancel();
    int tick = 0;
    const totalTicks = 20;

    _simulationTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      tick++;
      if (tick > totalTicks) {
        timer.cancel();
        state = state.copyWith(
          stage: OrderLifecycleStage.delivered,
          remainingEtaMinutes: 0,
          progressPercent: 1.0,
          courierLocation: const CourierLocation(latitude: destLat, longitude: destLng),
        );
        return;
      }

      final double progress = tick / totalTicks;
      final double currentLat = originLat + (destLat - originLat) * progress;
      final double currentLng = originLng + (destLng - originLng) * progress;
      final int eta = ((1.0 - progress) * 25).round();

      OrderLifecycleStage currentStage;
      if (progress < 0.25) {
        currentStage = OrderLifecycleStage.orderPlaced;
      } else if (progress < 0.50) {
        currentStage = OrderLifecycleStage.preparing;
      } else if (progress < 0.95) {
        currentStage = OrderLifecycleStage.pickedUp;
      } else {
        currentStage = OrderLifecycleStage.delivered;
      }

      state = state.copyWith(
        stage: currentStage,
        courierLocation: CourierLocation(
          latitude: currentLat,
          longitude: currentLng,
        ),
        remainingEtaMinutes: eta,
        progressPercent: progress,
      );
    });
  }

  /// Manually transitions the order state for testing
  void setStage(OrderLifecycleStage stage) {
    state = state.copyWith(stage: stage);
  }
}

final telemetryProvider = NotifierProvider<TelemetryService, TrackingState>(TelemetryService.new);
