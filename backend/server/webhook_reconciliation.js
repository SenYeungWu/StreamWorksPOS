/**
 * =============================================================================
 * Stream Works - Server-Side Stripe Webhook Reconciliation Handler (TASK-5.2)
 * =============================================================================
 * 
 * Verifies cryptographic Stripe webhook signatures and reconciles PaymentIntents
 * with transactional order status in PostgreSQL PostGIS ledger.
 */

const crypto = require('crypto');

// Simulated In-Memory Idempotency Ledger
const processedWebhookEvents = new Set();

/**
 * Validates Stripe cryptographic HMAC-SHA256 webhook signature.
 * Prevents replay attacks and unauthorized payload injection.
 * 
 * @param {string} payload - Raw JSON string payload received from request.
 * @param {string} signatureHeader - Value of 'Stripe-Signature' header.
 * @param {string} webhookSecret - Configured webhook endpoint signing secret.
 * @returns {boolean} True if signature is cryptographically valid.
 */
function verifyStripeSignature(payload, signatureHeader, webhookSecret) {
    if (!payload || !signatureHeader || !webhookSecret) {
        return false;
    }

    try {
        const headerParts = signatureHeader.split(',');
        let timestamp = null;
        let signature = null;

        for (const part of headerParts) {
            const [key, value] = part.trim().split('=');
            if (key === 't') timestamp = value;
            if (key === 'v1') signature = value;
        }

        if (!timestamp || !signature) {
            return false;
        }

        // Validate timestamp tolerance (5 minutes = 300 seconds)
        const currentTime = Math.floor(Date.now() / 1000);
        if (Math.abs(currentTime - parseInt(timestamp, 10)) > 300) {
            return false; // Stale or replayed webhook
        }

        const signedPayload = `${timestamp}.${payload}`;
        const expectedSignature = crypto
            .createHmac('sha256', webhookSecret)
            .update(signedPayload)
            .digest('hex');

        return crypto.timingSafeEqual(
            Buffer.from(signature, 'hex'),
            Buffer.from(expectedSignature, 'hex')
        );
    } catch (_) {
        return false;
    }
}

/**
 * Reconciles incoming Stripe webhook event with transactional order state.
 * 
 * @param {Object} event - Decoded Stripe event object.
 * @param {Function} [dbExecutor] - Optional mock/real database query executor.
 * @returns {Promise<{success: boolean, orderId: string, status: string, message: string}>}
 */
async function handleStripeWebhookEvent(event, dbExecutor = null) {
    if (!event || !event.id || !event.type) {
        throw new Error('Invalid Stripe event structure');
    }

    // Enforce Idempotency (prevent duplicate fulfillment)
    if (processedWebhookEvents.has(event.id)) {
        return {
            success: true,
            orderId: event.data?.object?.metadata?.order_id || 'unknown',
            status: 'ALREADY_PROCESSED',
            message: `Event ${event.id} already reconciled via idempotency ledger.`,
        };
    }

    const eventType = event.type;
    const paymentIntent = event.data?.object;
    const orderId = paymentIntent?.metadata?.order_id;

    if (eventType === 'payment_intent.succeeded') {
        const amountReceived = paymentIntent.amount_received;
        
        // Execute transactional state update: orders.status -> 'PREPARING'
        if (dbExecutor) {
            await dbExecutor(
                `UPDATE orders SET status = 'PREPARING', updated_at = NOW() WHERE id = $1`,
                [orderId]
            );
        }

        processedWebhookEvents.add(event.id);

        return {
            success: true,
            orderId: orderId || 'simulated_order',
            status: 'PREPARING',
            message: `Order successfully reconciled. Amount captured: $${(amountReceived / 100).toFixed(2)}.`,
        };
    }

    if (eventType === 'payment_intent.payment_failed') {
        if (dbExecutor) {
            await dbExecutor(
                `UPDATE orders SET status = 'CANCELLED', updated_at = NOW() WHERE id = $1`,
                [orderId]
            );
        }

        processedWebhookEvents.add(event.id);

        return {
            success: false,
            orderId: orderId || 'simulated_order',
            status: 'CANCELLED',
            message: 'Payment failed or declined by issuing bank.',
        };
    }

    return {
        success: true,
        orderId: orderId || 'ignored',
        status: 'IGNORED',
        message: `Unhandled event type: ${eventType}`,
    };
}

module.exports = {
    verifyStripeSignature,
    handleStripeWebhookEvent,
    processedWebhookEvents,
};
