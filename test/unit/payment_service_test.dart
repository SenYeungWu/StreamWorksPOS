import 'package:flutter_test/flutter_test.dart';
import 'package:pos/core/services/payment_service.dart';

void main() {
  group('PaymentService & Stripe Integration Tests (TASK-5.1)', () {
    const paymentService = PaymentService();

    test('Converts dollar amounts to integer cents accurately for Stripe API', () {
      expect(paymentService.toCents(17.99), 1799);
      expect(paymentService.toCents(34.50), 3450);
      expect(paymentService.toCents(0.99), 99);
      expect(paymentService.toCents(100.00), 10000);
    });

    test('Formats integer cents into financial currency strings', () {
      expect(paymentService.formatCurrency(1799), '\$17.99');
      expect(paymentService.formatCurrency(3450), '\$34.50');
      expect(paymentService.formatCurrency(99), '\$0.99');
    });

    test('Processes valid checkout payment successfully', () async {
      final result = await paymentService.processPayment(
        amount: 25.50,
        orderId: 'SW-89421',
        customerEmail: 'rebecca@streamworks.app',
      );

      expect(result.isSuccess, isTrue);
      expect(result.status, PaymentStatus.succeeded);
      expect(result.amountPaid, 25.50);
      expect(result.transactionId, isNotNull);
      expect(result.transactionId, startsWith('pi_'));
    });

    test('Rejects zero and negative amounts with failed status', () async {
      final zeroResult = await paymentService.processPayment(
        amount: 0.00,
        orderId: 'SW-89421',
        customerEmail: 'rebecca@streamworks.app',
      );
      expect(zeroResult.isSuccess, isFalse);
      expect(zeroResult.status, PaymentStatus.failed);
      expect(zeroResult.errorMessage, contains('greater than zero'));

      final negativeResult = await paymentService.processPayment(
        amount: -15.00,
        orderId: 'SW-89421',
        customerEmail: 'rebecca@streamworks.app',
      );
      expect(negativeResult.isSuccess, isFalse);
      expect(negativeResult.status, PaymentStatus.failed);
    });
  });
}
