package com.fooddelivery.riderservice.controller;

import com.fooddelivery.riderservice.entity.Delivery;
import com.fooddelivery.riderservice.repository.DeliveryRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import javax.annotation.PostConstruct;
import java.util.List;

@RestController
@RequestMapping("/rider")
@CrossOrigin(origins = "*")
public class RiderController {

    @Autowired
    private DeliveryRepository deliveryRepository;

    @PostConstruct
    public void init() {
        if (deliveryRepository.count() == 0) {
            deliveryRepository.save(new Delivery(null, "Suresh P.", "123 MG Road, Pune", "Assigned", 1L));
            deliveryRepository.save(new Delivery(null, "Meera K.", "45 FC Road, Pune", "Picked Up", 1L));
            deliveryRepository.save(new Delivery(null, "Amit B.", "78 Hinjewadi, Pune", "Delivered", 1L));
        }
    }

    @GetMapping("/deliveries")
    public List<Delivery> getAllDeliveries() {
        return deliveryRepository.findAll();
    }

    @GetMapping("/deliveries/{riderId}")
    public List<Delivery> getDeliveriesByRider(@PathVariable Long riderId) {
        return deliveryRepository.findByRiderId(riderId);
    }

    @PutMapping("/update/{id}/{status}")
    public Delivery updateStatus(@PathVariable Long id, @PathVariable String status) {
        Delivery d = deliveryRepository.findById(id).orElseThrow(() -> new RuntimeException("Not found"));
        d.setStatus(status);
        return deliveryRepository.save(d);
    }
}
