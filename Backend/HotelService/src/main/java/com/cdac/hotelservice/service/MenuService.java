package com.cdac.hotelservice.service;

import com.cdac.hotelservice.entity.Menu;
import com.cdac.hotelservice.repository.MenuRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class MenuService {
    @Autowired
    private MenuRepository menuRepository;

    public Menu addMenu(Menu menu) {
        return menuRepository.save(menu);
    }

    public List<Menu> getMenusByHotel(Long hotelId) {
        return menuRepository.findByHotelId(hotelId);
    }

    public void deleteMenu(Long id) {
        menuRepository.deleteById(id);
    }

    public Menu updateMenu(Long id, Menu updatedMenu) {
        Menu menu = menuRepository.findById(id).orElseThrow(() -> new RuntimeException("Menu not found"));
        menu.setName(updatedMenu.getName());
        menu.setDescription(updatedMenu.getDescription());
        menu.setPrice(updatedMenu.getPrice());
        menu.setImageUrl(updatedMenu.getImageUrl());
        menu.setCategory(updatedMenu.getCategory());
        menu.setVeg(updatedMenu.isVeg());
        menu.setAvailable(updatedMenu.isAvailable());
        return menuRepository.save(menu);
    }
}
