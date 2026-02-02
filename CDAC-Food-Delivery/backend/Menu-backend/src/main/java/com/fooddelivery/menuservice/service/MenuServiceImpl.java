package com.fooddelivery.menuservice.service;

import java.util.List;
import java.util.Optional;
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

    @Override
    public Optional<Menu> getMenuById(Long id) {
        return menuRepository.findById(id);
    }

    @Override
    public Menu createMenu(Menu menu) {
        if (menu.getName() == null || menu.getName().trim().isEmpty()) {
            throw new IllegalArgumentException("Menu item name is required");
        }
        if (menu.getHotelId() == null) {
            throw new IllegalArgumentException("Hotel ID is required");
        }
        if (menu.getPrice() == null || menu.getPrice() <= 0) {
            throw new IllegalArgumentException("Price is required and must be greater than 0");
        }

        if (menu.getIsAvailable() == null) {
            menu.setIsAvailable(true);
        }
        if (menu.getDescription() == null) {
            menu.setDescription("");
        }
        if (menu.getCategory() == null) {
            menu.setCategory("Uncategorized");
        }
        if (menu.getFoodType() == null) {
            menu.setFoodType(FoodType.VEG);
        }

        menu.setName(menu.getName().trim());
        if (menu.getDescription() != null) {
            menu.setDescription(menu.getDescription().trim());
        }
        if (menu.getCategory() != null) {
            menu.setCategory(menu.getCategory().trim());
        }

        return menuRepository.save(menu);
    }

    @Override
    public Menu updateMenu(Long id, Menu menuDetails) {
        Menu menu = menuRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Menu item not found with id: " + id));

        if (menuDetails.getName() != null && !menuDetails.getName().trim().isEmpty()) {
            menu.setName(menuDetails.getName().trim());
        }
        if (menuDetails.getDescription() != null) {
            menu.setDescription(menuDetails.getDescription().trim());
        }
        if (menuDetails.getPrice() != null && menuDetails.getPrice() > 0) {
            menu.setPrice(menuDetails.getPrice());
        }
        if (menuDetails.getImageUrl() != null) {
            menu.setImageUrl(menuDetails.getImageUrl().trim());
        }
        if (menuDetails.getCategory() != null && !menuDetails.getCategory().trim().isEmpty()) {
            menu.setCategory(menuDetails.getCategory().trim());
        }
        if (menuDetails.getFoodType() != null) {
            menu.setFoodType(menuDetails.getFoodType());
        }
        if (menuDetails.getIsAvailable() != null) {
            menu.setIsAvailable(menuDetails.getIsAvailable());
        }

        return menuRepository.save(menu);
    }

    @Override
    public void deleteMenu(Long id) {
        Menu menu = menuRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Menu item not found with id: " + id));
        menuRepository.delete(menu);
    }
}
