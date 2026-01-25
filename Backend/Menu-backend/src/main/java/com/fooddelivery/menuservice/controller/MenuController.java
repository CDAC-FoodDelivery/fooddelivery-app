package com.fooddelivery.menuservice.controller;

import java.util.List;

import org.springframework.web.bind.annotation.*;

import com.fooddelivery.menuservice.dto.MenuResponseDTO;
import com.fooddelivery.menuservice.service.MenuService;

@RestController
@RequestMapping("/api/menu")
@CrossOrigin(origins = "http://localhost:5173")
public class MenuController {

    private final MenuService menuService;

    public MenuController(MenuService menuService) {
        this.menuService = menuService;
    }

    // GET /api/menu?hotelId=5
    @GetMapping
    public List<MenuResponseDTO> getMenu(@RequestParam Long hotelId) {
        return menuService.getMenuByHotel(hotelId);
    }

    // GET /api/menu/filter?hotelId=5&foodType=veg
    @GetMapping("/filter")
    public List<MenuResponseDTO> getMenuByType(
            @RequestParam Long hotelId,
            @RequestParam String foodType) {
        return menuService.getMenuByHotelAndFoodType(hotelId, foodType);
    }
}
