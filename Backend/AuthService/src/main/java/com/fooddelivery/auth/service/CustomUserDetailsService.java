package com.fooddelivery.auth.service;

import com.fooddelivery.auth.entity.User;
import com.fooddelivery.auth.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.Collections;

@Service
public class CustomUserDetailsService implements UserDetailsService {

    @Autowired
    private UserRepository userRepository;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        // Try finding by name first, if not found try email?
        // Wait, the "username" parameter is just the identifier passed by Spring
        // Security.
        // Since my login uses email conceptually, I should check email.
        // However, standard is username.
        // I will use email as username for spring security context.

        User user = userRepository.findByEmail(username)
                .orElseThrow(() -> new UsernameNotFoundException("User not found with email: " + username));

        return new org.springframework.security.core.userdetails.User(
                user.getEmail(),
                user.getPassword(),
                Collections.emptyList() // Add roles/authorities here if needed
        );
    }
}
