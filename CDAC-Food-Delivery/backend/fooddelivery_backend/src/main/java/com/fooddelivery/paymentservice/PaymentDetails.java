package com.fooddelivery.paymentservice;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Entity
@Data
@Table(name = "payment_details")
public class PaymentDetails {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "order_id", nullable = false)
    private String orderId;

    @Column(name = "payment_id")
    private String paymentId;

    @Column(name = "signature")
    private String signature; // Storing for audit, though verification happens on the fly

    private String status;
    private Double amount;
    private String currency;
    private String userEmail;

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();
}
