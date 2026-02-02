package com.fooddelivery.clients;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

@FeignClient(name = "hotel-service")
public interface HotelServiceClient {

    @GetMapping("/api/hotels/{id}")
    Object getHotelById(@PathVariable("id") Long id);

    @GetMapping("/api/hotels")
    Object getAllHotels();

    @PostMapping("/api/hotels")
    Object createHotel(@RequestBody Object hotelRequest);
}
