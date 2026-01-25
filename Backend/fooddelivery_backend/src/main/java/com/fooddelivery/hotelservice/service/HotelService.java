package com.fooddelivery.hotelservice.service;

import java.util.List;
import com.fooddelivery.hotelservice.DTO.HotelListResponseDTO;

public interface HotelService {
    List<HotelListResponseDTO> getAllHotels();
}
