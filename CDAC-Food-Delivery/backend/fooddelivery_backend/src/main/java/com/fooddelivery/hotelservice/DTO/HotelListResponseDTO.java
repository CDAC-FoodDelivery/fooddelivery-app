package com.fooddelivery.hotelservice.DTO;

import com.fooddelivery.hotelservice.entity.Hotel;

public class HotelListResponseDTO {

    private Long id;
    private String name;
    private String cuisine;
    private String location;
    private Double rating;
    private Integer price;
    private String imageUrl;

    public HotelListResponseDTO(Hotel hotel) {
        this.id = hotel.getId();
        this.name = hotel.getName();
        this.cuisine = hotel.getCuisine();
        this.location = hotel.getLocation();
        this.rating = hotel.getRating();
        this.price = hotel.getPrice();
        this.imageUrl = hotel.getImageUrl();
    }

    public Long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public String getCuisine() {
        return cuisine;
    }

    public String getLocation() {
        return location;
    }

    public Double getRating() {
        return rating;
    }

    public Integer getPrice() {
        return price;
    }

    public String getImageUrl() {
        return imageUrl;
    }
}
