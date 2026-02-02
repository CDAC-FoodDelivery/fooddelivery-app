package com.fooddelivery.hotelservice.service;

import java.util.List;
import java.util.Optional;
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
        return hotels.stream()
                .map(HotelListResponseDTO::new)
                .collect(Collectors.toList());
    }

    @Override
    public List<HotelListResponseDTO> getTopRatedHotels() {
        return hotelRepository.findTop3ByOrderByRatingDesc().stream()
                .map(HotelListResponseDTO::new)
                .collect(Collectors.toList());
    }

    @Override
    public Optional<Hotel> getHotelById(Long id) {
        return hotelRepository.findById(id);
    }

    @Override
    public Hotel createHotel(Hotel hotel) {
        if (hotel.getName() == null || hotel.getName().trim().isEmpty()) {
            throw new IllegalArgumentException("Hotel name is required");
        }
        if (hotel.getCuisine() == null || hotel.getCuisine().trim().isEmpty()) {
            throw new IllegalArgumentException("Cuisine type is required");
        }
        if (hotel.getLocation() == null || hotel.getLocation().trim().isEmpty()) {
            throw new IllegalArgumentException("Location is required");
        }

        if (hotel.getRating() == null) {
            hotel.setRating(0.0);
        }
        if (hotel.getPrice() == null || hotel.getPrice() == 0) {
            throw new IllegalArgumentException("Price is required and must be greater than 0");
        }
        if (hotel.getImageUrl() == null || hotel.getImageUrl().trim().isEmpty()) {
            hotel.setImageUrl("https://via.placeholder.com/400x300?text=No+Image");
        }

        hotel.setName(hotel.getName().trim());
        hotel.setCuisine(hotel.getCuisine().trim());
        hotel.setLocation(hotel.getLocation().trim());
        hotel.setImageUrl(hotel.getImageUrl().trim());

        return hotelRepository.save(hotel);
    }

    @Override
    public Hotel updateHotel(Long id, Hotel hotelDetails) {
        Hotel hotel = hotelRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Hotel not found with id: " + id));

        if (hotelDetails.getName() != null && !hotelDetails.getName().trim().isEmpty()) {
            hotel.setName(hotelDetails.getName().trim());
        }
        if (hotelDetails.getCuisine() != null && !hotelDetails.getCuisine().trim().isEmpty()) {
            hotel.setCuisine(hotelDetails.getCuisine().trim());
        }
        if (hotelDetails.getLocation() != null && !hotelDetails.getLocation().trim().isEmpty()) {
            hotel.setLocation(hotelDetails.getLocation().trim());
        }
        if (hotelDetails.getRating() != null) {
            hotel.setRating(hotelDetails.getRating());
        }
        if (hotelDetails.getPrice() != null && hotelDetails.getPrice() > 0) {
            hotel.setPrice(hotelDetails.getPrice());
        }
        if (hotelDetails.getImageUrl() != null && !hotelDetails.getImageUrl().trim().isEmpty()) {
            hotel.setImageUrl(hotelDetails.getImageUrl().trim());
        }

        return hotelRepository.save(hotel);
    }

    @Override
    public void deleteHotel(Long id) {
        Hotel hotel = hotelRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Hotel not found with id: " + id));
        hotelRepository.delete(hotel);
    }
}
