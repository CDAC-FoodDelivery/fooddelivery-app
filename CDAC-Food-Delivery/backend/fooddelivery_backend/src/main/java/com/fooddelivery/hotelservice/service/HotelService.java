package com.fooddelivery.hotelservice.service;

import java.util.List;
import java.util.Optional;

import com.fooddelivery.hotelservice.DTO.HotelListResponseDTO;
import com.fooddelivery.hotelservice.entity.Hotel;

public interface HotelService {
    List<HotelListResponseDTO> getAllHotels();

    List<HotelListResponseDTO> getTopRatedHotels();

    Optional<Hotel> getHotelById(Long id);

    Hotel createHotel(Hotel hotel);

    Hotel updateHotel(Long id, Hotel hotel);

    void deleteHotel(Long id);
}
