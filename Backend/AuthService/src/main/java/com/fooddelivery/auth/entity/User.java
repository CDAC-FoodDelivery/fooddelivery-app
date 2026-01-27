package com.fooddelivery.auth.entity;

import javax.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Data
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;

    @Column(unique = true)
    private String email;

    private String password;

    private String phone;

    private String address;

    private String pincode;

    private String location;

    @Enumerated(EnumType.STRING)
    private Role role;

    @Column(name = "restaurant_id")
    private Long restaurantId;
}
