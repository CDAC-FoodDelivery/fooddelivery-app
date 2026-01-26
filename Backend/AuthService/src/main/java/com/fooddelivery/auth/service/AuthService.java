package com.fooddelivery.auth.service;

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

    public String saveUser(User credential) {
        credential.setPassword(passwordEncoder.encode(credential.getPassword()));
        repository.save(credential);
        return "User added to the system";
    }

    public String generateToken(String username) {
        return jwtUtils.generateToken(username);
    }

    public void validateToken(String token) {
        jwtUtils.validateToken(token, repository.findByEmail(jwtUtils.extractUsername(token)).get().getEmail());
    }
}
