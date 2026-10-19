import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/core/models/food.dart';
import 'package:pos/core/models/restaurant.dart';
import 'package:pos/core/services/payment_service.dart';
import 'package:pos/features/cart/domain/cart_item.dart';
import 'package:pos/features/cart/presentation/cart_controller.dart';
import 'package:pos/features/tracking/presentation/courier_tracking_screen.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  Widget _buildCartItem({
    required BuildContext context,
    required Food food,
    required Restaurant restaurant,
    required int quantity,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      height: 170.0,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Row(
              children: <Widget>[
                Container(
                  width: 150.0,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(food.imageUrl),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          food.name,
                          style: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10.0),
                        Text(
                          restaurant.name,
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10.0),
                        Container(
                          width: 110.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              width: 0.8,
                              color: Colors.black54,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              GestureDetector(
                                onTap: onDecrement,
                                child: Text(
                                  '-',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16.0),
                              Text(
                                quantity.toString(),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 16.0),
                              GestureDetector(
                                onTap: onIncrement,
                                child: Text(
                                  '+',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.all(10.0),
            child: Text(
              '\$${(quantity * food.price).toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final cartController = ref.read(cartProvider.notifier);

    final int itemCount = cartState.itemCount;
    final double totalPrice = cartState.subtotal;
    final bool isCartEmpty = cartState.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text('Cart ($itemCount)'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: isCartEmpty
          ? const Center(
              child: Text(
                'Your cart is empty',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            )
          : ListView.separated(
              itemCount: cartState.items.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index < cartState.items.length) {
                  final CartItem item = cartState.items[index];
                  return _buildCartItem(
                    context: context,
                    food: item.food,
                    restaurant: item.restaurant,
                    quantity: item.quantity,
                    onIncrement: () => cartController.incrementQuantity(item),
                    onDecrement: () => cartController.decrementQuantity(item),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: <Widget>[
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Estimated Delivery Time',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '25 min',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Cost:',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '\$${totalPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 80.0),
                    ],
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider(
                  height: 1.0,
                  color: Colors.grey,
                );
              },
            ),
      bottomSheet: isCartEmpty
          ? null
          : Container(
              height: 80.0,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, -1),
                    blurRadius: 6.0,
                  ),
                ],
              ),
              child: Center(
                child: TextButton(
                  child: const Text(
                    'CHECKOUT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                  onPressed: () => _openStripeCheckout(context, totalPrice),
                ),
              ),
            ),
    );
  }

  void _openStripeCheckout(BuildContext context, double totalPrice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => _StripePaymentSheet(
        totalPrice: totalPrice,
        onPaymentSuccess: (String transactionId) {
          final amountFormatted = totalPrice.toStringAsFixed(2);
          ref.read(cartProvider.notifier).clearCart();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green.shade800,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Text(
                      'Stripe Payment Confirmed!\nTx: $transactionId | Total: \$$amountFormatted',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CourierTrackingScreen(),
            ),
          );
        },
      ),
    );
  }
}

class _StripePaymentSheet extends ConsumerStatefulWidget {
  final double totalPrice;
  final ValueChanged<String> onPaymentSuccess;

  const _StripePaymentSheet({
    required this.totalPrice,
    required this.onPaymentSuccess,
  });

  @override
  ConsumerState<_StripePaymentSheet> createState() => _StripePaymentSheetState();
}

class _StripePaymentSheetState extends ConsumerState<_StripePaymentSheet> {
  final _cardNumberController = TextEditingController(text: '4242  4242  4242  4242');
  final _expiryController = TextEditingController(text: '12 / 28');
  final _cvcController = TextEditingController(text: '123');
  final _zipController = TextEditingController(text: '90210');

  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  void _fillTestCard(String cardNumber) {
    setState(() {
      _cardNumberController.text = cardNumber;
      _expiryController.text = '12 / 28';
      _cvcController.text = '123';
      _errorMessage = null;
    });
  }

  Future<void> _handlePayment() async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    final paymentService = ref.read(paymentServiceProvider);
    final result = await paymentService.processPayment(
      amount: widget.totalPrice,
      orderId: 'ord_${DateTime.now().millisecondsSinceEpoch}',
      customerEmail: 'alex.rivera@example.com',
      paymentMethodId: 'pm_card_visa',
    );

    if (!mounted) return;

    if (result.isSuccess) {
      Navigator.pop(context); // Close bottom sheet
      widget.onPaymentSuccess(result.transactionId ?? 'tx_mock_stripe');
    } else {
      setState(() {
        _isProcessing = false;
        _errorMessage = result.errorMessage ?? 'Payment processing failed';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentService = ref.read(paymentServiceProvider);
    final amountCents = paymentService.toCents(widget.totalPrice);
    const stripePurple = Color(0xFF635BFF);

    return Container(
      padding: EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        top: 20.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Modal Handle
            Center(
              child: Container(
                width: 40.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // Header with Stripe Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lock_rounded, size: 20.0, color: stripePurple),
                    SizedBox(width: 8.0),
                    Text(
                      'Stripe Checkout',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: Colors.amber.shade700),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.build_circle_outlined, size: 14.0, color: Colors.amber.shade900),
                      const SizedBox(width: 4.0),
                      Text(
                        'TEST MODE',
                        style: TextStyle(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w700,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),

            // Amount breakdown card
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FC),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Due',
                        style: TextStyle(fontSize: 13.0, color: Colors.black54),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        '\$${widget.totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade900,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Stripe Integer Cents',
                        style: TextStyle(fontSize: 12.0, color: Colors.black54),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        '$amountCents cents',
                        style: const TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w600,
                          color: stripePurple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),

            // Card Number Field
            const Text(
              'Card Information',
              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _cardNumberController,
              enabled: !_isProcessing,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.credit_card, color: stripePurple),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                labelText: 'Card number',
              ),
            ),
            const SizedBox(height: 8.0),

            // Expiry & CVC Row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _expiryController,
                    enabled: !_isProcessing,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                      labelText: 'MM / YY',
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: TextField(
                    controller: _cvcController,
                    enabled: !_isProcessing,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                      labelText: 'CVC',
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: TextField(
                    controller: _zipController,
                    enabled: !_isProcessing,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                      labelText: 'ZIP',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),

            // Quick Test Cards Helpers
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.credit_card, size: 16.0),
                  label: const Text('Test Card (Success: 4242)', style: TextStyle(fontSize: 12.0)),
                  onPressed: _isProcessing ? null : () => _fillTestCard('4242  4242  4242  4242'),
                ),
                ActionChip(
                  avatar: const Icon(Icons.shield_outlined, size: 16.0),
                  label: const Text('3D Secure (3000)', style: TextStyle(fontSize: 12.0)),
                  onPressed: _isProcessing ? null : () => _fillTestCard('4000  0027  6000  3184'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Error display if any
            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12.0),
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700, size: 18.0),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade900, fontSize: 13.0),
                      ),
                    ),
                  ],
                ),
              ),

            // Pay Button
            ElevatedButton(
              onPressed: _isProcessing ? null : _handlePayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: stripePurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                elevation: 2.0,
              ),
              child: _isProcessing
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20.0,
                          height: 20.0,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.0,
                          ),
                        ),
                        SizedBox(width: 12.0),
                        Text(
                          'Contacting Stripe Gateway...',
                          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                  : Text(
                      'Pay \$${widget.totalPrice.toStringAsFixed(2)} with Stripe',
                      style: const TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(height: 8.0),

            // Guarantee footer
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified_user, size: 14.0, color: Colors.grey.shade600),
                const SizedBox(width: 6.0),
                Text(
                  'Encrypted 256-bit SSL • Powered by Stripe Payments',
                  style: TextStyle(fontSize: 11.0, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
