package com.fooddelivery.auth.config;

import com.fooddelivery.auth.entity.User;
import com.fooddelivery.auth.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
public class AdminInitializer implements CommandLineRunner {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception {
        String adminEmail = "admin@fooddelivery.com";
        Optional<User> admin = userRepository.findByEmail(adminEmail);

        if (!admin.isPresent()) {
            User newUser = new User();
            newUser.setName("System Admin");
            newUser.setEmail(adminEmail);
            newUser.setPassword(passwordEncoder.encode("admin123"));
            newUser.setRole("ADMIN");
            newUser.setPhone("0000000000");
            newUser.setAddress("System");
            newUser.setPincode("000000");
            newUser.setLocation("System");
            
            userRepository.save(newUser);
            System.out.println("Admin user created: " + adminEmail);
        } else {
            System.out.println("Admin user already exists.");
        }
    }
}
