const assert = require('assert');
const crypto = require('crypto');
const {
    verifyStripeSignature,
    handleStripeWebhookEvent,
    processedWebhookEvents,
} = require('./webhook_reconciliation');

async function runWebhookTests() {
    console.log('Running Stripe Webhook Reconciliation Tests (TASK-5.2)...');

    const secret = 'whsec_test_secret_streamworks_987654321';
    const payload = JSON.stringify({
        id: 'evt_test_12345',
        type: 'payment_intent.succeeded',
        data: {
            object: {
                id: 'pi_test_abc',
                amount_received: 2550,
                metadata: {
                    order_id: 'SW-89421',
                },
            },
        },
    });

    const timestamp = Math.floor(Date.now() / 1000);
    const signature = crypto
        .createHmac('sha256', secret)
        .update(`${timestamp}.${payload}`)
        .digest('hex');
    const signatureHeader = `t=${timestamp},v1=${signature}`;

    // Test 1: Signature Verification Success
    const isValid = verifyStripeSignature(payload, signatureHeader, secret);
    assert.strictEqual(isValid, true, 'Cryptographic signature should be valid');

    // Test 2: Signature Verification Failure with Wrong Secret
    const isInvalid = verifyStripeSignature(payload, signatureHeader, 'wrong_secret');
    assert.strictEqual(isInvalid, false, 'Invalid signature should be rejected');

    // Test 3: Reconcile Payment Intent Succeeded
    let dbUpdated = false;
    let updatedStatus = null;
    const mockDb = async (query, params) => {
        dbUpdated = true;
        updatedStatus = 'PREPARING';
    };

    const eventObj = JSON.parse(payload);
    const result = await handleStripeWebhookEvent(eventObj, mockDb);

    assert.strictEqual(result.success, true);
    assert.strictEqual(result.orderId, 'SW-89421');
    assert.strictEqual(result.status, 'PREPARING');
    assert.strictEqual(dbUpdated, true, 'Database should be updated to PREPARING');

    // Test 4: Idempotency Enforcement (Duplicate Event)
    const duplicateResult = await handleStripeWebhookEvent(eventObj, mockDb);
    assert.strictEqual(duplicateResult.status, 'ALREADY_PROCESSED');

    console.log('All Stripe Webhook Reconciliation tests passed successfully!');
}

runWebhookTests().catch((err) => {
    console.error('Webhook tests failed:', err);
    process.exit(1);
});
