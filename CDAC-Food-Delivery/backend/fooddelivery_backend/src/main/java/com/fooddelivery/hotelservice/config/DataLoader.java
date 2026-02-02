package com.fooddelivery.hotelservice.config;

import com.fooddelivery.hotelservice.entity.Hotel;
import com.fooddelivery.hotelservice.repository.HotelRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class DataLoader implements CommandLineRunner {

        private static final Logger log = LoggerFactory.getLogger(DataLoader.class);
        private final HotelRepository hotelRepository;

        public DataLoader(HotelRepository hotelRepository) {
                this.hotelRepository = hotelRepository;
        }

        @Override
        public void run(String... args) {
                if (hotelRepository.count() == 0) {
                        log.info("Loading initial restaurant data...");
                        loadRestaurants();
                        log.info("Loaded {} restaurants", hotelRepository.count());
                } else {
                        log.info("Restaurant data already exists, skipping initialization");
                }
        }

        private void loadRestaurants() {
                List<Hotel> restaurants = List.of(
                                new Hotel(null, "Vaishali", "South Indian, Snacks", "FC Road, Deccan, Pune", 4.5, 250,
                                                "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400"),

                                new Hotel(null, "Shreemaya Celebration", "Multi-Cuisine, North Indian",
                                                "Apte Road, Deccan, Pune", 4.3,
                                                450,
                                                "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=400"),

                                new Hotel(null, "German Bakery", "Bakery, Continental", "Koregaon Park, Pune", 4.6, 500,
                                                "https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400"),

                                new Hotel(null, "Wadeshwar", "South Indian, Maharashtrian", "Karve Nagar, Pune", 4.4,
                                                200,
                                                "https://images.unsplash.com/photo-1601050690597-df0568f70950?w=400"),

                                new Hotel(null, "Marrakesh", "Middle Eastern, Mediterranean", "Koregaon Park, Pune",
                                                4.5, 800,
                                                "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400"),

                                new Hotel(null, "The French Window", "French, Bakery, Desserts", "Kalyani Nagar, Pune",
                                                4.7, 600,
                                                "https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=400"),

                                new Hotel(null, "Malaka Spice", "Pan Asian, Thai, Chinese", "Koregaon Park, Pune", 4.6,
                                                700,
                                                "https://images.unsplash.com/photo-1512058564366-18510be2db19?w=400"),

                                new Hotel(null, "Kayani Bakery", "Bakery, Irani Cafe", "Camp, Pune", 4.4, 150,
                                                "https://images.unsplash.com/photo-1517433670267-30f41c09e2f0?w=400"),

                                new Hotel(null, "Darios", "Italian, Pizza, Pasta", "Koregaon Park, Pune", 4.5, 650,
                                                "https://images.unsplash.com/photo-1579684947550-22e945225d9a?w=400"),

                                new Hotel(null, "Hotel Shreyas", "Gujarati Thali, Pure Veg", "FC Road, Pune", 4.3, 300,
                                                "https://images.unsplash.com/photo-1476224203421-9ac39bcb3327?w=400"),

                                new Hotel(null, "Atmosphere 6", "Multi-Cuisine, Continental", "Aundh, Pune", 4.4, 750,
                                                "https://images.unsplash.com/photo-1550966871-3ed3cdb5ed0c?w=400"),

                                new Hotel(null, "Baan Thai", "Thai, Asian Fusion", "Viman Nagar, Pune", 4.5, 800,
                                                "https://images.unsplash.com/photo-1559314809-0d155014e29e?w=400"));

                hotelRepository.saveAll(restaurants);
        }
}
