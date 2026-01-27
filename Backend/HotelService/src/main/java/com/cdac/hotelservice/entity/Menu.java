package com.cdac.hotelservice.entity;

import lombok.Data;
import javax.persistence.*;

@Entity
@Data
@Table(name = "menus")
public class Menu {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;
    private String description;
    private Double price;
    private String imageUrl;
    private String category; // e.g., Starter, Main Course
    private boolean isVeg;
    private boolean available;

    private Long hotelId;
}
