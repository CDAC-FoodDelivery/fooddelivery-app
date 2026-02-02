package com.fooddelivery.menuservice.config;

import com.fooddelivery.menuservice.entity.Menu;
import com.fooddelivery.menuservice.enums.FoodType;
import com.fooddelivery.menuservice.repository.MenuRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;

@Component
public class DataLoader implements CommandLineRunner {

        private static final Logger log = LoggerFactory.getLogger(DataLoader.class);
        private final MenuRepository menuRepository;

        public DataLoader(MenuRepository menuRepository) {
                this.menuRepository = menuRepository;
        }

        @Override
        public void run(String... args) {
                if (menuRepository.count() == 0) {
                        log.info("Loading initial menu data...");
                        loadMenuItems();
                        log.info("Loaded {} menu items", menuRepository.count());
                } else {
                        log.info("Menu data already exists, skipping initialization");
                }
        }

        private void loadMenuItems() {
                List<Menu> allItems = new ArrayList<>();

                allItems.addAll(List.of(
                                createMenu(1L, "Masala Dosa", "Crispy dosa with potato filling", 120, "Breakfast",
                                                FoodType.VEG,
                                                "https://images.unsplash.com/photo-1668236543090-82eba5ee5976?w=300"),
                                createMenu(1L, "Idli Sambar", "Soft idlis with sambar and chutney", 80, "Breakfast",
                                                FoodType.VEG,
                                                "https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=300"),
                                createMenu(1L, "Medu Vada", "Crispy lentil fritters", 70, "Snacks", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1630383249896-424e482df921?w=300"),
                                createMenu(1L, "Filter Coffee", "Traditional South Indian coffee", 40, "Beverages",
                                                FoodType.VEG,
                                                "https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=300"),
                                createMenu(1L, "Rava Dosa", "Semolina dosa with onions", 130, "Breakfast", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1567337710282-00832b415979?w=300"),
                                createMenu(1L, "Upma", "Semolina breakfast with vegetables", 90, "Breakfast",
                                                FoodType.VEG,
                                                "https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=300"),
                                createMenu(1L, "Pongal", "Rice and lentil comfort food", 100, "Breakfast", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=300"),
                                createMenu(1L, "Uttapam", "Thick pancake with toppings", 110, "Breakfast", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1630383249896-424e482df921?w=300"),
                                createMenu(1L, "Mysore Bonda", "Spicy lentil fritters", 60, "Snacks", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1601050690597-df0568f70950?w=300"),
                                createMenu(1L, "Kesari Bath", "Sweet semolina dessert", 70, "Desserts", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1551024506-0bccd828d307?w=300")));

                allItems.addAll(List.of(
                                createMenu(2L, "Paneer Butter Masala", "Cottage cheese in creamy tomato gravy", 280,
                                                "Main Course",
                                                FoodType.VEG,
                                                "https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=300"),
                                createMenu(2L, "Dal Makhani", "Black lentils slow cooked with cream", 220,
                                                "Main Course", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=300"),
                                createMenu(2L, "Butter Naan", "Soft buttered bread", 50, "Breads", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=300"),
                                createMenu(2L, "Chicken Biryani", "Aromatic rice with spiced chicken", 320,
                                                "Main Course",
                                                FoodType.NON_VEG,
                                                "https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=300"),
                                createMenu(2L, "Mutton Rogan Josh", "Kashmiri style lamb curry", 380, "Main Course",
                                                FoodType.NON_VEG,
                                                "https://images.unsplash.com/photo-1545247181-516773cae754?w=300"),
                                createMenu(2L, "Tandoori Chicken", "Marinated chicken cooked in tandoor", 350,
                                                "Starters",
                                                FoodType.NON_VEG,
                                                "https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=300"),
                                createMenu(2L, "Veg Pulao", "Fragrant rice with vegetables", 180, "Main Course",
                                                FoodType.VEG,
                                                "https://images.unsplash.com/photo-1596797038530-2c107229654b?w=300"),
                                createMenu(2L, "Gulab Jamun", "Deep fried milk dumplings in syrup", 80, "Desserts",
                                                FoodType.VEG,
                                                "https://images.unsplash.com/photo-1666190094762-2cdc0d4c770b?w=300"),
                                createMenu(2L, "Raita", "Yogurt with cucumber and spices", 60, "Accompaniments",
                                                FoodType.VEG,
                                                "https://images.unsplash.com/photo-1567337710282-00832b415979?w=300"),
                                createMenu(2L, "Lassi", "Sweet yogurt drink", 70, "Beverages", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1571006682583-c72e4fbd3f8e?w=300")));

                allItems.addAll(List.of(
                                createMenu(3L, "Croissant", "Buttery flaky French pastry", 120, "Bakery", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=300"),
                                createMenu(3L, "Cappuccino", "Italian coffee with steamed milk", 180, "Beverages",
                                                FoodType.VEG,
                                                "https://images.unsplash.com/photo-1572442388796-11668a67e53d?w=300"),
                                createMenu(3L, "Eggs Benedict", "Poached eggs with hollandaise", 280, "Breakfast",
                                                FoodType.NON_VEG,
                                                "https://images.unsplash.com/photo-1608039829572-9b0e1caee678?w=300"),
                                createMenu(3L, "Avocado Toast", "Smashed avocado on sourdough", 250, "Breakfast",
                                                FoodType.VEG,
                                                "https://images.unsplash.com/photo-1541519227354-08fa5d50c44d?w=300"),
                                createMenu(3L, "Chocolate Cake", "Rich Belgian chocolate cake", 220, "Desserts",
                                                FoodType.VEG,
                                                "https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=300"),
                                createMenu(3L, "Caesar Salad", "Romaine lettuce with Caesar dressing", 240, "Salads",
                                                FoodType.VEG,
                                                "https://images.unsplash.com/photo-1550304943-4f24f54ddde9?w=300"),
                                createMenu(3L, "Club Sandwich", "Triple decker chicken sandwich", 280, "Sandwiches",
                                                FoodType.NON_VEG,
                                                "https://images.unsplash.com/photo-1528735602780-2552fd46c7af?w=300"),
                                createMenu(3L, "Pancakes", "Fluffy pancakes with maple syrup", 200, "Breakfast",
                                                FoodType.VEG,
                                                "https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=300"),
                                createMenu(3L, "Fresh Juice", "Orange or mixed fruit juice", 150, "Beverages",
                                                FoodType.VEG,
                                                "https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=300"),
                                createMenu(3L, "Blueberry Muffin", "Fresh baked blueberry muffin", 130, "Bakery",
                                                FoodType.VEG,
                                                "https://images.unsplash.com/photo-1558303025-a70dd43a7bad?w=300")));

                allItems.addAll(List.of(
                                createMenu(4L, "Misal Pav", "Spicy sprouts curry with bread", 100, "Breakfast",
                                                FoodType.VEG,
                                                "https://images.unsplash.com/photo-1606491956689-2ea866880c84?w=300"),
                                createMenu(4L, "Poha", "Flattened rice with spices", 70, "Breakfast", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1645177628172-a94c1f96e6db?w=300"),
                                createMenu(4L, "Sabudana Khichdi", "Tapioca pearls with peanuts", 90, "Breakfast",
                                                FoodType.VEG,
                                                "https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=300"),
                                createMenu(4L, "Vada Pav", "Spiced potato fritter in bread", 40, "Snacks", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1606755456206-b25206cde27e?w=300"),
                                createMenu(4L, "Thalipeeth", "Multi-grain savory pancake", 80, "Breakfast",
                                                FoodType.VEG,
                                                "https://images.unsplash.com/photo-1567337710282-00832b415979?w=300"),
                                createMenu(4L, "Puran Poli", "Sweet stuffed flatbread", 60, "Desserts", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1631515243349-e0cb75fb8d3a?w=300"),
                                createMenu(4L, "Batata Vada", "Spiced potato fritters", 50, "Snacks", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1601050690597-df0568f70950?w=300"),
                                createMenu(4L, "Kothimbir Vadi", "Coriander fritters", 70, "Snacks", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=300"),
                                createMenu(4L, "Ukadiche Modak", "Steamed sweet dumplings", 100, "Desserts",
                                                FoodType.VEG,
                                                "https://images.unsplash.com/photo-1666190094762-2cdc0d4c770b?w=300"),
                                createMenu(4L, "Solkadhi", "Coconut milk digestive drink", 40, "Beverages",
                                                FoodType.VEG,
                                                "https://images.unsplash.com/photo-1571006682583-c72e4fbd3f8e?w=300")));

                allItems.addAll(List.of(
                                createMenu(5L, "Hummus", "Chickpea dip with olive oil", 280, "Starters", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1577805947697-89e18249d767?w=300"),
                                createMenu(5L, "Falafel Platter", "Crispy chickpea fritters", 320, "Main Course",
                                                FoodType.VEG,
                                                "https://images.unsplash.com/photo-1593001874117-c99c800e3eb2?w=300"),
                                createMenu(5L, "Shawarma", "Spiced meat wrap", 350, "Main Course", FoodType.NON_VEG,
                                                "https://images.unsplash.com/photo-1529006557810-274b9b2fc783?w=300"),
                                createMenu(5L, "Kebab Platter", "Assorted grilled meats", 550, "Main Course",
                                                FoodType.NON_VEG,
                                                "https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=300"),
                                createMenu(5L, "Baba Ganoush", "Smoky eggplant dip", 260, "Starters", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1577805947697-89e18249d767?w=300"),
                                createMenu(5L, "Pita Bread", "Warm pocket bread", 80, "Breads", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=300"),
                                createMenu(5L, "Baklava", "Layered pastry with nuts and honey", 180, "Desserts",
                                                FoodType.VEG,
                                                "https://images.unsplash.com/photo-1598110750624-207050c4f28c?w=300"),
                                createMenu(5L, "Moroccan Tagine", "Slow cooked stew", 450, "Main Course",
                                                FoodType.NON_VEG,
                                                "https://images.unsplash.com/photo-1511690656952-34342bb7c2f2?w=300"),
                                createMenu(5L, "Mint Lemonade", "Refreshing mint drink", 120, "Beverages", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1556881286-fc6915169721?w=300"),
                                createMenu(5L, "Tabbouleh", "Fresh parsley salad", 220, "Salads", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=300")));

                allItems.addAll(List.of(
                                createMenu(6L, "French Onion Soup", "Classic caramelized onion soup", 280, "Starters",
                                                FoodType.VEG,
                                                "https://images.unsplash.com/photo-1547592166-23ac45744acd?w=300"),
                                createMenu(6L, "Quiche Lorraine", "Savory egg and bacon tart", 320, "Main Course",
                                                FoodType.NON_VEG,
                                                "https://images.unsplash.com/photo-1608039829572-9b0e1caee678?w=300"),
                                createMenu(6L, "Crepes", "Thin French pancakes", 250, "Desserts", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1519676867240-f03562e64548?w=300"),
                                createMenu(6L, "Croissant aux Amandes", "Almond croissant", 180, "Bakery", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=300"),
                                createMenu(6L, "Eclair", "Chocolate filled pastry", 160, "Desserts", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1558303027-37a46e91f1c6?w=300"),
                                createMenu(6L, "Macaron Set", "Assorted French macarons", 350, "Desserts", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1569864358642-9d1684040f43?w=300"),
                                createMenu(6L, "Croque Monsieur", "Grilled ham and cheese sandwich", 280, "Sandwiches",
                                                FoodType.NON_VEG,
                                                "https://images.unsplash.com/photo-1528735602780-2552fd46c7af?w=300"),
                                createMenu(6L, "Tarte Tatin", "Caramelized apple tart", 280, "Desserts", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1562440499-64c9a111f713?w=300"),
                                createMenu(6L, "Espresso", "Strong Italian coffee", 150, "Beverages", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1510707577719-ae7c14805e3a?w=300"),
                                createMenu(6L, "Pain au Chocolat", "Chocolate filled pastry", 140, "Bakery",
                                                FoodType.VEG,
                                                "https://images.unsplash.com/photo-1530610476181-d83430b64dcd?w=300")));

                allItems.addAll(List.of(
                                createMenu(7L, "Tom Yum Soup", "Thai hot and sour soup", 280, "Starters",
                                                FoodType.NON_VEG,
                                                "https://images.unsplash.com/photo-1548943487-a2e4e43b4853?w=300"),
                                createMenu(7L, "Pad Thai", "Thai stir fried noodles", 350, "Main Course",
                                                FoodType.NON_VEG,
                                                "https://images.unsplash.com/photo-1559314809-0d155014e29e?w=300"),
                                createMenu(7L, "Green Curry", "Thai coconut curry", 380, "Main Course",
                                                FoodType.NON_VEG,
                                                "https://images.unsplash.com/photo-1455619452474-d2be8b1e70cd?w=300"),
                                createMenu(7L, "Spring Rolls", "Crispy vegetable rolls", 220, "Starters", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1548507238-f12ad1e72442?w=300"),
                                createMenu(7L, "Sushi Platter", "Assorted sushi rolls", 550, "Main Course",
                                                FoodType.NON_VEG,
                                                "https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=300"),
                                createMenu(7L, "Dim Sum", "Steamed dumplings", 320, "Starters", FoodType.NON_VEG,
                                                "https://images.unsplash.com/photo-1496116218417-1a781b1c416c?w=300"),
                                createMenu(7L, "Mango Sticky Rice", "Thai dessert with coconut", 180, "Desserts",
                                                FoodType.VEG,
                                                "https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=300"),
                                createMenu(7L, "Thai Iced Tea", "Sweet milk tea", 120, "Beverages", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1558857563-b371033873b8?w=300"),
                                createMenu(7L, "Laksa", "Spicy noodle soup", 340, "Main Course", FoodType.NON_VEG,
                                                "https://images.unsplash.com/photo-1555126634-323283e090fa?w=300"),
                                createMenu(7L, "Satay", "Grilled meat skewers", 280, "Starters", FoodType.NON_VEG,
                                                "https://images.unsplash.com/photo-1529563021893-cc83c992d75d?w=300")));

                allItems.addAll(List.of(
                                createMenu(8L, "Shrewsbury Biscuits", "Famous butter cookies", 280, "Bakery",
                                                FoodType.VEG,
                                                "https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=300"),
                                createMenu(8L, "Mawa Cake", "Traditional milk cake", 45, "Bakery", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=300"),
                                createMenu(8L, "Irani Chai", "Traditional Irani tea", 30, "Beverages", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=300"),
                                createMenu(8L, "Bun Maska", "Soft bun with butter", 40, "Snacks", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1509440159596-0249088772ff?w=300"),
                                createMenu(8L, "Khari Biscuit", "Flaky puff pastry", 60, "Bakery", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1558303027-37a46e91f1c6?w=300"),
                                createMenu(8L, "Fruit Cake", "Rich dried fruit cake", 50, "Bakery", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1563729784474-d77dbb933a9e?w=300"),
                                createMenu(8L, "Apple Pie", "Classic apple dessert", 70, "Desserts", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1568571780765-9276ac8b75a2?w=300"),
                                createMenu(8L, "Cream Roll", "Puff pastry with cream", 35, "Bakery", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1509365390695-33aee754301f?w=300"),
                                createMenu(8L, "Osmania Biscuit", "Traditional tea biscuit", 150, "Bakery",
                                                FoodType.VEG,
                                                "https://images.unsplash.com/photo-1499636136210-6f4ee915583e?w=300"),
                                createMenu(8L, "Cold Coffee", "Chilled coffee drink", 80, "Beverages", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=300")));

                allItems.addAll(List.of(
                                createMenu(9L, "Margherita Pizza", "Classic tomato and mozzarella", 380, "Pizza",
                                                FoodType.VEG,
                                                "https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=300"),
                                createMenu(9L, "Pepperoni Pizza", "Spicy pepperoni with cheese", 450, "Pizza",
                                                FoodType.NON_VEG,
                                                "https://images.unsplash.com/photo-1628840042765-356cda07504e?w=300"),
                                createMenu(9L, "Pasta Carbonara", "Creamy bacon pasta", 380, "Pasta", FoodType.NON_VEG,
                                                "https://images.unsplash.com/photo-1612874742237-6526221588e3?w=300"),
                                createMenu(9L, "Lasagna", "Layered pasta with meat sauce", 420, "Main Course",
                                                FoodType.NON_VEG,
                                                "https://images.unsplash.com/photo-1574894709920-11b28e7367e3?w=300"),
                                createMenu(9L, "Tiramisu", "Coffee flavored Italian dessert", 280, "Desserts",
                                                FoodType.VEG,
                                                "https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=300"),
                                createMenu(9L, "Bruschetta", "Toasted bread with tomatoes", 220, "Starters",
                                                FoodType.VEG,
                                                "https://images.unsplash.com/photo-1572695157366-5e585ab2b69f?w=300"),
                                createMenu(9L, "Risotto", "Creamy Italian rice", 350, "Main Course", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1476124369491-e7addf5db371?w=300"),
                                createMenu(9L, "Garlic Bread", "Toasted bread with garlic butter", 180, "Sides",
                                                FoodType.VEG,
                                                "https://images.unsplash.com/photo-1619531040576-f9416aba7727?w=300"),
                                createMenu(9L, "Panna Cotta", "Italian cream dessert", 220, "Desserts", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1488477181946-6428a0291777?w=300"),
                                createMenu(9L, "Italian Soda", "Flavored sparkling drink", 150, "Beverages",
                                                FoodType.VEG,
                                                "https://images.unsplash.com/photo-1556881286-fc6915169721?w=300")));

                allItems.addAll(List.of(
                                createMenu(10L, "Gujarati Thali", "Complete traditional meal", 350, "Thali",
                                                FoodType.VEG,
                                                "https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=300"),
                                createMenu(10L, "Dhokla", "Steamed gram flour snack", 80, "Snacks", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1601050690597-df0568f70950?w=300"),
                                createMenu(10L, "Thepla", "Spiced flatbread", 60, "Breads", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=300"),
                                createMenu(10L, "Khandvi", "Rolled gram flour snack", 90, "Snacks", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1606491956689-2ea866880c84?w=300"),
                                createMenu(10L, "Undhiyu", "Mixed vegetable curry", 180, "Main Course", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1455619452474-d2be8b1e70cd?w=300"),
                                createMenu(10L, "Fafda Jalebi", "Crispy snack with sweet", 100, "Snacks", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1666190094762-2cdc0d4c770b?w=300"),
                                createMenu(10L, "Shrikhand", "Sweet yogurt dessert", 120, "Desserts", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1551024506-0bccd828d307?w=300"),
                                createMenu(10L, "Dal Dhokli", "Wheat dumplings in dal", 150, "Main Course",
                                                FoodType.VEG,
                                                "https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=300"),
                                createMenu(10L, "Handvo", "Savory vegetable cake", 100, "Snacks", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1567337710282-00832b415979?w=300"),
                                createMenu(10L, "Chaas", "Spiced buttermilk", 40, "Beverages", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1571006682583-c72e4fbd3f8e?w=300")));

                allItems.addAll(List.of(
                                createMenu(11L, "Grilled Salmon", "Fresh Atlantic salmon", 650, "Main Course",
                                                FoodType.NON_VEG,
                                                "https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=300"),
                                createMenu(11L, "Mushroom Risotto", "Creamy arborio rice", 420, "Main Course",
                                                FoodType.VEG,
                                                "https://images.unsplash.com/photo-1476124369491-e7addf5db371?w=300"),
                                createMenu(11L, "Lamb Chops", "Grilled lamb with herbs", 750, "Main Course",
                                                FoodType.NON_VEG,
                                                "https://images.unsplash.com/photo-1544025162-d76694265947?w=300"),
                                createMenu(11L, "Greek Salad", "Fresh Mediterranean salad", 280, "Salads", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=300"),
                                createMenu(11L, "Chicken Steak", "Grilled chicken breast", 450, "Main Course",
                                                FoodType.NON_VEG,
                                                "https://images.unsplash.com/photo-1432139555190-58524dae6a55?w=300"),
                                createMenu(11L, "Prawn Cocktail", "Chilled prawns with sauce", 380, "Starters",
                                                FoodType.NON_VEG,
                                                "https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=300"),
                                createMenu(11L, "Cheesecake", "New York style cheesecake", 280, "Desserts",
                                                FoodType.VEG,
                                                "https://images.unsplash.com/photo-1533134242443-d4fd215305ad?w=300"),
                                createMenu(11L, "Mojito", "Refreshing mint cocktail", 250, "Beverages", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1551538827-9c037cb4f32a?w=300"),
                                createMenu(11L, "Soup of the Day", "Chef's special soup", 180, "Starters", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1547592166-23ac45744acd?w=300"),
                                createMenu(11L, "Fish and Chips", "Beer battered fish", 420, "Main Course",
                                                FoodType.NON_VEG,
                                                "https://images.unsplash.com/photo-1579208030886-b1c5b0ea3b5f?w=300")));

                allItems.addAll(List.of(
                                createMenu(12L, "Massaman Curry", "Rich Thai curry with peanuts", 420, "Main Course",
                                                FoodType.NON_VEG,
                                                "https://images.unsplash.com/photo-1455619452474-d2be8b1e70cd?w=300"),
                                createMenu(12L, "Thai Basil Chicken", "Stir fried with holy basil", 380, "Main Course",
                                                FoodType.NON_VEG,
                                                "https://images.unsplash.com/photo-1512058564366-18510be2db19?w=300"),
                                createMenu(12L, "Papaya Salad", "Spicy green papaya salad", 250, "Salads", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=300"),
                                createMenu(12L, "Red Curry", "Spicy coconut curry", 380, "Main Course",
                                                FoodType.NON_VEG,
                                                "https://images.unsplash.com/photo-1455619452474-d2be8b1e70cd?w=300"),
                                createMenu(12L, "Thai Fish Cakes", "Spiced fish patties", 320, "Starters",
                                                FoodType.NON_VEG,
                                                "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=300"),
                                createMenu(12L, "Coconut Ice Cream", "Creamy coconut dessert", 180, "Desserts",
                                                FoodType.VEG,
                                                "https://images.unsplash.com/photo-1497034825429-c343d7c6a68f?w=300"),
                                createMenu(12L, "Thai Fried Rice", "Wok tossed jasmine rice", 280, "Main Course",
                                                FoodType.NON_VEG,
                                                "https://images.unsplash.com/photo-1596797038530-2c107229654b?w=300"),
                                createMenu(12L, "Fresh Spring Rolls", "Rice paper rolls", 220, "Starters", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1548507238-f12ad1e72442?w=300"),
                                createMenu(12L, "Lemongrass Tea", "Aromatic herbal tea", 120, "Beverages", FoodType.VEG,
                                                "https://images.unsplash.com/photo-1556881286-fc6915169721?w=300"),
                                createMenu(12L, "Banana Fritters", "Fried banana with honey", 150, "Desserts",
                                                FoodType.VEG,
                                                "https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=300")));

                menuRepository.saveAll(allItems);
        }

        private Menu createMenu(Long hotelId, String name, String description, int price,
                        String category, FoodType foodType, String imageUrl) {
                Menu menu = new Menu();
                menu.setHotelId(hotelId);
                menu.setName(name);
                menu.setDescription(description);
                menu.setPrice(price);
                menu.setCategory(category);
                menu.setFoodType(foodType);
                menu.setImageUrl(imageUrl);
                menu.setIsAvailable(true);
                return menu;
        }
}
