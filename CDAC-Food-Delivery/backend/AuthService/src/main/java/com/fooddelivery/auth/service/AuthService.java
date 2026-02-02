package com.fooddelivery.auth.service;

import com.fooddelivery.auth.dto.AuthResponse;
import com.fooddelivery.auth.entity.User;
import com.fooddelivery.auth.repository.UserRepository;
import com.fooddelivery.auth.util.JwtUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

    @Autowired
    private UserRepository repository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtUtils jwtUtils;

    public AuthResponse saveUser(User credential) {

        if (repository.findByEmail(credential.getEmail()).isPresent()) {
            throw new RuntimeException("Email already exists");
        }
        credential.setPassword(passwordEncoder.encode(credential.getPassword()));
        repository.save(credential);
        String token = jwtUtils.generateToken(credential.getEmail());

        return new AuthResponse("User registered successfully", token);
    }

    public String generateToken(String username) {
        return jwtUtils.generateToken(username);
    }

    public void validateToken(String token) {
        String email = jwtUtils.extractUsername(token);

        User user = repository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        jwtUtils.validateToken(token, user.getEmail());
    }

    public User updateUser(String token, User updatedUser) {
        String email = jwtUtils.extractUsername(token);
        User existingUser = repository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        if (updatedUser.getName() != null) existingUser.setName(updatedUser.getName());
        if (updatedUser.getPhone() != null) existingUser.setPhone(updatedUser.getPhone());
        if (updatedUser.getAddress() != null) existingUser.setAddress(updatedUser.getAddress());
        if (updatedUser.getPincode() != null) existingUser.setPincode(updatedUser.getPincode());
        if (updatedUser.getLocation() != null) existingUser.setLocation(updatedUser.getLocation());

        return repository.save(existingUser);
    }

    public User getUserProfile(String token) {
        String email = jwtUtils.extractUsername(token);
        return repository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }

}
