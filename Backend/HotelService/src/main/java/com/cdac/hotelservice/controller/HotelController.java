package com.cdac.hotelservice.controller;

import com.cdac.hotelservice.entity.Menu;
import com.cdac.hotelservice.service.MenuService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/hotel")
@CrossOrigin(origins = "*") // Allow all for dev
public class HotelController {

    @Autowired
    private MenuService menuService;

    @PostMapping("/menu")
    public Menu addMenu(@RequestBody Menu menu) {
        return menuService.addMenu(menu);
    }

    @GetMapping("/{hotelId}/menu")
    public List<Menu> getMenus(@PathVariable Long hotelId) {
        return menuService.getMenusByHotel(hotelId);
    }

    @DeleteMapping("/menu/{id}")
    public void deleteMenu(@PathVariable Long id) {
        menuService.deleteMenu(id);
    }

    @PutMapping("/menu/{id}")
    public Menu updateMenu(@PathVariable Long id, @RequestBody Menu menu) {
        return menuService.updateMenu(id, menu);
    }
}
