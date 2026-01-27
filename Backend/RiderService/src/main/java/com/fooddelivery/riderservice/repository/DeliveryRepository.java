package com.fooddelivery.riderservice.repository;

import com.fooddelivery.riderservice.entity.Delivery;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface DeliveryRepository extends JpaRepository<Delivery, Long> {
    List<Delivery> findByRiderId(Long riderId);
    // return all if riderId is null or just findAll
}
