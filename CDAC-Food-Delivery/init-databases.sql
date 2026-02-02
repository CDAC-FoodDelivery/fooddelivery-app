-- ============================================
-- DATABASE-PER-SERVICE SETUP SCRIPT
-- Food Delivery Microservices Architecture
-- ============================================

-- Create all required databases
CREATE DATABASE IF NOT EXISTS fooddelivery_admin_rider;
CREATE DATABASE IF NOT EXISTS fooddelivery_auth;
CREATE DATABASE IF NOT EXISTS fooddelivery_menu;
CREATE DATABASE IF NOT EXISTS fooddelivery_hotel;

-- Grant all privileges (optional, for dev environment)
GRANT ALL PRIVILEGES ON fooddelivery_admin_rider.* TO 'root'@'%';
GRANT ALL PRIVILEGES ON fooddelivery_auth.* TO 'root'@'%';
GRANT ALL PRIVILEGES ON fooddelivery_menu.* TO 'root'@'%';
GRANT ALL PRIVILEGES ON fooddelivery_hotel.* TO 'root'@'%';
FLUSH PRIVILEGES;

-- Show created databases
SHOW DATABASES LIKE 'fooddelivery%';
