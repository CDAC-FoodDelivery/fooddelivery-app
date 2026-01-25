package com.fooddelivery.hotelservice.controller;

import java.util.List;

import org.springframework.web.bind.annotation.*;

import com.fooddelivery.hotelservice.DTO.HotelListResponseDTO;
import com.fooddelivery.hotelservice.service.HotelService;

@RestController
@RequestMapping("/api/hotels")
@CrossOrigin(origins = "http://localhost:5173") // React Vite
public class HotelController {

    private final HotelService hotelService;

    public HotelController(HotelService hotelService) {
        this.hotelService = hotelService;
    }

    @GetMapping
    public List<HotelListResponseDTO> getHotels() {
        return hotelService.getAllHotels();
    }
}
