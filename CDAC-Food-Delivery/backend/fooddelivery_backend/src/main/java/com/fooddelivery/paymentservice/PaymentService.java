package com.fooddelivery.paymentservice;

import com.fooddelivery.paymentservice.dto.OrderRequest;
import com.fooddelivery.paymentservice.dto.OrderResponse;
import com.fooddelivery.paymentservice.dto.PaymentVerificationRequest;
import com.razorpay.Order;
import com.razorpay.RazorpayClient;
import com.razorpay.RazorpayException;
import com.razorpay.Utils;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class PaymentService {

    @Autowired
    private PaymentRepository paymentRepository;

    @Autowired(required = false)
    private RazorpayClient razorpayClient;

    private String keyId = "rzp_test_1DP5mmOlF5G5ag";
    private String keySecret = "DUMMY_SECRET_KEY";

    public OrderResponse createOrder(OrderRequest request) throws RazorpayException {
        if (request.getAmount() == null || request.getAmount() <= 0) {
            throw new IllegalArgumentException("Amount must be greater than 0");
        }

        if (isMockMode()) {
            return createMockOrder(request.getAmount());
        }

        JSONObject options = new JSONObject();
        int amountInPaise = (int) (request.getAmount() * 100);

        options.put("amount", amountInPaise);
        options.put("currency", request.getCurrency() != null ? request.getCurrency() : "INR");
        options.put("receipt", "txn_" + System.currentTimeMillis());
        options.put("payment_capture", 1);

        Order order = razorpayClient.orders.create(options);

        return OrderResponse.builder()
                .orderId(order.get("id"))
                .amount(request.getAmount())
                .currency(order.get("currency"))
                .status(order.get("status"))
                .build();
    }

    @Transactional
    public boolean verifyPayment(PaymentVerificationRequest request) throws RazorpayException {
        if (isMockMode()) {
            return savePaymentDetails(request.getRazorpayOrderId(), request.getRazorpayPaymentId(),
                    request.getRazorpaySignature(), "SUCCESS", request);
        }

        try {
            boolean isEqual = Utils.verifyPaymentSignature(
                    new JSONObject()
                            .put("razorpay_order_id", request.getRazorpayOrderId())
                            .put("razorpay_payment_id", request.getRazorpayPaymentId())
                            .put("razorpay_signature", request.getRazorpaySignature()),
                    keySecret);

            String status = isEqual ? "SUCCESS" : "FAILED";
            return savePaymentDetails(request.getRazorpayOrderId(), request.getRazorpayPaymentId(),
                    request.getRazorpaySignature(), status, request);

        } catch (RazorpayException e) {
            throw e;
        }
    }

    private boolean savePaymentDetails(String orderId, String paymentId, String signature, String status,
            PaymentVerificationRequest request) {
        PaymentDetails payment = new PaymentDetails();
        payment.setOrderId(orderId);
        payment.setPaymentId(paymentId);
        payment.setSignature(signature);
        payment.setStatus(status);
        if (request != null) {
            payment.setAmount(request.getAmount());
            payment.setUserEmail(request.getEmail());
        }
        paymentRepository.save(payment);
        return "SUCCESS".equals(status);
    }

    private boolean isMockMode() {
        return "rzp_test_your_key_id".equals(keyId) || "your_key_secret".equals(keySecret) ||
                "rzp_test_1DP5mmOlF5G5ag".equals(keyId) || "DUMMY_SECRET_KEY".equals(keySecret) ||
                razorpayClient == null;
    }

    private OrderResponse createMockOrder(Double amount) {
        return OrderResponse.builder()
                .orderId("order_mock_" + System.currentTimeMillis())
                .amount(amount)
                .currency("INR")
                .status("created")
                .build();
    }
}
