-- ============================================
-- DATABASE-PER-SERVICE SETUP SCRIPT
-- Food Delivery Microservices Architecture
-- ============================================

-- Create all required databases
CREATE DATABASE IF NOT EXISTS fooddelivery_admin_rider;
CREATE DATABASE IF NOT EXISTS fooddelivery_auth;
CREATE DATABASE IF NOT EXISTS fooddelivery_menu;
CREATE DATABASE IF NOT EXISTS fooddelivery_hotel;

-- ============================================
-- DATA MIGRATION (if migrating from shared DB)
-- ============================================

-- ONLY RUN THIS IF YOU HAVE DATA IN THE OLD "fooddelivery" DATABASE
-- Comment out if starting fresh

-- Migrate Menu Data
-- INSERT INTO fooddelivery_menu.menu
-- SELECT * FROM fooddelivery.menu;

-- Migrate Hotel Data
-- INSERT INTO fooddelivery_hotel.hotels
-- SELECT * FROM fooddelivery.hotels;

-- Migrate Orders
-- INSERT INTO fooddelivery_hotel.customer_orders
-- SELECT * FROM fooddelivery.customer_orders;

-- Migrate Order Items
-- INSERT INTO fooddelivery_hotel.order_items
-- SELECT * FROM fooddelivery.order_items;

-- Migrate Payments
-- INSERT INTO fooddelivery_hotel.payment_details
-- SELECT * FROM fooddelivery.payment_details;

-- ============================================
-- VERIFICATION QUERIES
-- ============================================

-- Check all databases exist
SHOW DATABASES LIKE 'fooddelivery%';

-- Check menu database
USE fooddelivery_menu;
SHOW TABLES;
SELECT COUNT(*) as menu_count FROM menu;

-- Check hotel database
USE fooddelivery_hotel;
SHOW TABLES;
SELECT COUNT(*) as hotel_count FROM hotels;
SELECT COUNT(*) as order_count FROM customer_orders;

-- Check admin database
USE fooddelivery_admin_rider;
SHOW TABLES;
SELECT COUNT(*) as user_count FROM users;

-- Check auth database (should have NO tables or empty)
USE fooddelivery_auth;
SHOW TABLES;

-- ============================================
-- SAMPLE DATA INSERTION (For Testing)
-- ============================================

-- Sample User in AdminRiderService database
USE fooddelivery_admin_rider;

-- Insert sample customer user
-- INSERT INTO users (name, email, password, phone, address, role, created_at)
-- VALUES (
--   'Test User',
--   'test@example.com',
--   '$2a$10$dummyHashedPassword', -- Replace with actual BCrypt hash
--   '1234567890',
--   '123 Test Street',
--   'USER',
--   NOW()
-- );

-- Insert sample admin user
-- INSERT INTO users (name, email, password, phone, address, role, created_at)
-- VALUES (
--   'Admin User',
--   'admin@fooddelivery.com',
--   '$2a$10$dummyHashedPassword', -- Replace with actual BCrypt hash
--   '9999999999',
--   'Admin Office',
--   'ADMIN',
--   NOW()
-- );

-- Sample Hotels
USE fooddelivery_hotel;

-- INSERT INTO hotels (name, cuisine, location, rating, price, image_url)
-- VALUES
-- ('Pizza Palace', 'Italian', 'Downtown', 4.5, 500, 'https://example.com/pizza.jpg'),
-- ('Burger King', 'Fast Food', 'Mall Road', 4.2, 300, 'https://example.com/burger.jpg'),
-- ('Sushi Station', 'Japanese', 'Beach Area', 4.8, 800, 'https://example.com/sushi.jpg');

-- Sample Menu Items
USE fooddelivery_menu;

-- INSERT INTO menu (hotel_id, name, description, price, image_url, category, food_type, is_available)
-- VALUES
-- (1, 'Margherita Pizza', 'Classic Italian pizza', 250, 'pizza.jpg', 'Main Course', 'VEG', true),
-- (1, 'Chicken Pizza', 'Loaded with chicken', 350, 'chicken-pizza.jpg', 'Main Course', 'NON_VEG', true),
-- (2, 'Cheese Burger', 'Double patty burger', 200, 'burger.jpg', 'Main Course', 'NON_VEG', true),
-- (3, 'California Roll', 'Fresh sushi roll', 450, 'sushi.jpg', 'Appetizer', 'NON_VEG', true);

-- ============================================
-- DATABASE STATUS CHECK
-- ============================================

SELECT 
    'fooddelivery_admin_rider' as database_name,
    (SELECT COUNT(*) FROM fooddelivery_admin_rider.users) as table_count,
    'users' as main_table
UNION ALL
SELECT 
    'fooddelivery_menu',
    (SELECT COUNT(*) FROM fooddelivery_menu.menu),
    'menu'
UNION ALL
SELECT 
    'fooddelivery_hotel',
    (SELECT COUNT(*) FROM fooddelivery_hotel.hotels),
    'hotels'
UNION ALL
SELECT 
    'fooddelivery_hotel',
    (SELECT COUNT(*) FROM fooddelivery_hotel.customer_orders),
    'customer_orders';

-- ============================================
-- CLEANUP (Use with caution!)
-- ============================================

-- DANGER: Only run this if you want to START FRESH
-- This will DELETE all databases
-- UNCOMMENT ONLY IF YOU'RE SURE!

-- DROP DATABASE IF EXISTS fooddelivery_admin_rider;
-- DROP DATABASE IF EXISTS fooddelivery_auth;
-- DROP DATABASE IF EXISTS fooddelivery_menu;
-- DROP DATABASE IF EXISTS fooddelivery_hotel;
-- DROP DATABASE IF EXISTS fooddelivery; -- Old shared database

-- ============================================
-- END OF SCRIPT
-- ============================================

-- Next Steps:
-- 1. Run this script in MySQL
-- 2. Start all microservices
-- 3. Check Eureka dashboard (http://localhost:8761)
-- 4. Test API endpoints
-- 5. Verify data isolation

SHOW DATABASES LIKE 'fooddelivery%';
