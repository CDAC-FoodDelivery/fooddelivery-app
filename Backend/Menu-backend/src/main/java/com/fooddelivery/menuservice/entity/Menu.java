package com.fooddelivery.menuservice.entity;

import com.fooddelivery.menuservice.enums.FoodType;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "menu")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Menu {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long hotelId;   // 🔥 NO JPA relation

    private String name;
    private String description;
    private Integer price;
    private String imageUrl;
    private String category;

    @Enumerated(EnumType.STRING)
    private FoodType foodType;

    private Boolean isAvailable;
}
