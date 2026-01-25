package com.fooddelivery.hotelservice.service;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import com.fooddelivery.hotelservice.DTO.HotelListResponseDTO;
import com.fooddelivery.hotelservice.entity.Hotel;
import com.fooddelivery.hotelservice.repository.HotelRepository;

@Service
public class HotelServiceImpl implements HotelService {

    private final HotelRepository hotelRepository;

    public HotelServiceImpl(HotelRepository hotelRepository) {
        this.hotelRepository = hotelRepository;
    }

    @Override
    public List<HotelListResponseDTO> getAllHotels() {
        List<Hotel> hotels = hotelRepository.findAll();

        // Convert each Hotel entity to DTO
        return hotels.stream()
                     .map(HotelListResponseDTO::new)
                     .collect(Collectors.toList());
    }
}
