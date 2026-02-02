package com.fooddelivery.menuservice.dto;

import com.fooddelivery.menuservice.entity.Menu;
import com.fooddelivery.menuservice.enums.FoodType;
import lombok.*;

@Getter
@Setter
public class MenuResponseDTO {

    private Long id;
    private String name;
    private String description;
    private Integer price;
    private String imageUrl;
    private String category;
    private FoodType foodType;

    public MenuResponseDTO(Menu menu) {
        this.id = menu.getId();
        this.name = menu.getName();
        this.description = menu.getDescription();
        this.price = menu.getPrice();
        this.imageUrl = menu.getImageUrl();
        this.category = menu.getCategory();
        this.foodType = menu.getFoodType();
    }
}
