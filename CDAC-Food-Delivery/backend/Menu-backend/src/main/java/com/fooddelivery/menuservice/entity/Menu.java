package com.fooddelivery.menuservice.entity;

import com.fasterxml.jackson.annotation.JsonProperty;
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
    @JsonProperty("id")
    private Long id;

    @JsonProperty("hotelId")
    private Long hotelId;

    @Column(nullable = false)
    @JsonProperty("name")
    private String name;

    @JsonProperty("description")
    private String description;

    @Column(nullable = false)
    @JsonProperty("price")
    private Integer price;

    @JsonProperty("imageUrl")
    private String imageUrl;

    @JsonProperty("category")
    private String category;

    @Enumerated(EnumType.STRING)
    @JsonProperty("foodType")
    private FoodType foodType;

    @JsonProperty("isAvailable")
    private Boolean isAvailable;
}
