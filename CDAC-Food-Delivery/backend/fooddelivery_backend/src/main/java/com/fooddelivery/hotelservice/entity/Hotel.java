package com.fooddelivery.hotelservice.entity;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Data // adds getters, setters, toString, equals, hashCode
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "hotels")
public class Hotel {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @JsonProperty("id")
    private Long id;

    @Column(nullable = false)
    @JsonProperty("name")
    private String name;

    @Column(nullable = false)
    @JsonProperty("cuisine")
    private String cuisine;

    @Column(nullable = false)
    @JsonProperty("location")
    private String location;

    @Column(nullable = false)
    @JsonProperty("rating")
    private Double rating;

    @Column(nullable = false)
    @JsonProperty("price")
    private Integer price;

    @Column(name = "image_url")
    @JsonProperty("imageUrl") // Match C# property name
    private String imageUrl;
}
