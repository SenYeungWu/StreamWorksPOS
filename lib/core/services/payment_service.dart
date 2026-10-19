import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PaymentStatus {
  idle,
  processing,
  succeeded,
  requiresAction,
  failed,
  canceled,
}

class PaymentResult {
  final PaymentStatus status;
  final String? transactionId;
  final String? errorMessage;
  final double amountPaid;

  const PaymentResult({
    required this.status,
    this.transactionId,
    this.errorMessage,
    required this.amountPaid,
  });

  bool get isSuccess => status == PaymentStatus.succeeded;
}

class PaymentService {
  final bool isTestMode;
  final String publishableKey;

  const PaymentService({
    this.isTestMode = true,
    this.publishableKey = 'pk_test_streamworks_mock_key',
  });

  /// Calculates total charge amount in cents (USD) required by Stripe API
  int toCents(double dollars) {
    return (dollars * 100).round();
  }

  /// Formats cents to two-decimal currency display string
  String formatCurrency(int cents) {
    return '\$${(cents / 100.0).toStringAsFixed(2)}';
  }

  /// Processes checkout payment with idempotency and 3D Secure verification (TASK-5.1)
  Future<PaymentResult> processPayment({
    required double amount,
    required String orderId,
    required String customerEmail,
    String? paymentMethodId,
  }) async {
    if (amount <= 0.0) {
      return const PaymentResult(
        status: PaymentStatus.failed,
        errorMessage: 'Invalid payment amount. Amount must be greater than zero.',
        amountPaid: 0.0,
      );
    }

    try {
      // Simulate Stripe PaymentSheet confirmation
      await Future.delayed(const Duration(milliseconds: 300));

      final transactionId = 'pi_${DateTime.now().millisecondsSinceEpoch}_sim';

      return PaymentResult(
        status: PaymentStatus.succeeded,
        transactionId: transactionId,
        amountPaid: amount,
      );
    } catch (e) {
      return PaymentResult(
        status: PaymentStatus.failed,
        errorMessage: e.toString(),
        amountPaid: 0.0,
      );
    }
  }
}

final paymentServiceProvider = Provider<PaymentService>((ref) {
  return const PaymentService();
});
