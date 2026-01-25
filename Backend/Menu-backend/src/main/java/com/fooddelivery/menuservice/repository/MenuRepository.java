package com.fooddelivery.menuservice.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fooddelivery.menuservice.entity.Menu;
import com.fooddelivery.menuservice.enums.FoodType;

public interface MenuRepository extends JpaRepository<Menu, Long> {

    List<Menu> findByHotelId(Long hotelId);

    List<Menu> findByHotelIdAndFoodType(Long hotelId, FoodType foodType);
}
