package com.fooddelivery.menuservice.service;

import java.util.List;
import java.util.Optional;

import com.fooddelivery.menuservice.dto.MenuResponseDTO;
import com.fooddelivery.menuservice.entity.Menu;

public interface MenuService {

    List<MenuResponseDTO> getMenuByHotel(Long hotelId);

    List<MenuResponseDTO> getMenuByHotelAndFoodType(Long hotelId, String foodType);

    Optional<Menu> getMenuById(Long id);

    Menu createMenu(Menu menu);

    Menu updateMenu(Long id, Menu menu);

    void deleteMenu(Long id);
}
