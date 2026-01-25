package com.fooddelivery.menuservice.service;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import com.fooddelivery.menuservice.dto.MenuResponseDTO;
import com.fooddelivery.menuservice.entity.Menu;
import com.fooddelivery.menuservice.enums.FoodType;
import com.fooddelivery.menuservice.repository.MenuRepository;

@Service
public class MenuServiceImpl implements MenuService {

    private final MenuRepository menuRepository;

    public MenuServiceImpl(MenuRepository menuRepository) {
        this.menuRepository = menuRepository;
    }

    @Override
    public List<MenuResponseDTO> getMenuByHotel(Long hotelId) {
        return menuRepository.findByHotelId(hotelId)
                .stream()
                .map(MenuResponseDTO::new)
                .collect(Collectors.toList());
    }

    @Override
    public List<MenuResponseDTO> getMenuByHotelAndFoodType(Long hotelId, String foodType) {
        FoodType type = FoodType.valueOf(foodType.toUpperCase());
        return menuRepository.findByHotelIdAndFoodType(hotelId, type)
                .stream()
                .map(MenuResponseDTO::new)
                .collect(Collectors.toList());
    }
}
