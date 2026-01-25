package com.fooddelivery.menuservice.service;

import java.util.List;
import com.fooddelivery.menuservice.dto.MenuResponseDTO;

public interface MenuService {

    List<MenuResponseDTO> getMenuByHotel(Long hotelId);

    List<MenuResponseDTO> getMenuByHotelAndFoodType(Long hotelId, String foodType);
}
