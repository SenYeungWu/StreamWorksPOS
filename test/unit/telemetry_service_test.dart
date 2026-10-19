import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/core/services/telemetry_service.dart';

void main() {
  group('TelemetryService & Real-Time Tracking Tests (TASK-4.4)', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial telemetry state represents an active pending order', () {
      final state = container.read(telemetryProvider);

      expect(state.orderId, 'SW-89421');
      expect(state.stage, OrderLifecycleStage.orderPlaced);
      expect(state.remainingEtaMinutes, 25);
      expect(state.progressPercent, 0.0);
      expect(state.courierLocation.latitude, closeTo(40.7250, 0.001));
      expect(state.courierLocation.longitude, closeTo(-73.9984, 0.001));
    });

    test('Transitions through order lifecycle stages correctly', () {
      final notifier = container.read(telemetryProvider.notifier);

      notifier.setStage(OrderLifecycleStage.preparing);
      expect(container.read(telemetryProvider).stage, OrderLifecycleStage.preparing);

      notifier.setStage(OrderLifecycleStage.pickedUp);
      expect(container.read(telemetryProvider).stage, OrderLifecycleStage.pickedUp);

      notifier.setStage(OrderLifecycleStage.delivered);
      expect(container.read(telemetryProvider).stage, OrderLifecycleStage.delivered);
    });
  });
}
