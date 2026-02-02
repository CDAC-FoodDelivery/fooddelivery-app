package com.fooddelivery.paymentservice.dto;

import lombok.Data;

@Data
public class OrderRequest {
    private Double amount;
    private String currency; // Optional, defaults to INR
    private String receipt; // Optional
}
