import React from "react";
import ProductCard from "../components/ProductCard"; // update the path as needed

const products = [
  {
    name: "Almond Brown Sugar Croissant",
    description: "Sweet croissant with topping almonds and brown sugar",
    price: 12.98,
    pieces: 3,
    image: "https://images.unsplash.com/photo-1519861531864-07a5a0a1a389?auto=format&fit=crop&w=260&q=80",
  },
  {
    name: "Smoke Tenderloin Slice Croissant",
    description: "Plain croissant with smoke tenderloin beef sliced and vegetable",
    price: 10.01,
    pieces: 2,
    image: "https://images.unsplash.com/photo-1458642849426-cfb724f15ef7?auto=format&fit=crop&w=260&q=80",
  },
  {
    name: "Berry Whipped Cream Croissant",
    description: "Sweet croissant with blueberries and strawberries inside",
    price: 8.92,
    pieces: 3,
    image: "https://images.unsplash.com/photo-1514958106963-cd1391bd1d83?auto=format&fit=crop&w=260&q=80",
  },
  {
    name: "Sweet Granulated Sugar Croissant",
    description: "Sweet croissant",
    price: 5.58,
    pieces: 1,
    image: "https://images.unsplash.com/photo-1525755662778-989d0524087e?auto=format&fit=crop&w=260&q=80",
  },
  {
    name: "Sweet Chocolate Chocochips Croissant",
    description: "Chocolate croissant",
    price: 22.02,
    pieces: 2,
    image: "https://images.unsplash.com/photo-1447078806655-40579c2e9c89?auto=format&fit=crop&w=260&q=80",
  },
  {
    name: "Classic Margherita Pizza",
    description: "Stone-baked pizza topped with tomato sauce, mozzarella, and fresh basil leaves",
    price: 15.90,
    pieces: 1,
    image: "https://images.unsplash.com/photo-1542281286-9e0a16bb7366?auto=format&fit=crop&w=260&q=80"
  },
  {
    name: "Chicken Caesar Salad",
    description: "Crisp romaine lettuce, grilled chicken, parmesan, croutons, and Caesar dressing",
    price: 13.50,
    pieces: 1,
    image: "https://images.unsplash.com/photo-1519861531864-07a5a0a1a389?auto=format&fit=crop&w=260&q=80"
  },
  {
    name: "Grilled Salmon Fillet",
    description: "Fresh grilled salmon served with steamed broccoli and lemon butter sauce",
    price: 18.25,
    pieces: 1,
    image: "https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=260&q=80"
  },
  {
    name: "Vegetable Spring Rolls",
    description: "Golden crispy rolls stuffed with mixed vegetables, served with sweet chili sauce",
    price: 7.60,
    pieces: 4,
    image: "https://images.unsplash.com/photo-1476718406336-bb5a9690ee2a?auto=format&fit=crop&w=260&q=80"
  },
  {
    name: "Beef Cheeseburger",
    description: "Juicy grilled beef patty, cheddar cheese, pickles, and onions in a sesame bun",
    price: 14.00,
    pieces: 1,
    image: "https://images.unsplash.com/photo-1550547660-d9450f859349?auto=format&fit=crop&w=260&q=80"
  },
  {
    name: "Chocolate Lava Cake",
    description: "Warm chocolate cake with gooey molten center, served with vanilla ice cream",
    price: 9.85,
    pieces: 2,
    image: "https://images.unsplash.com/photo-1505250463000-180dd4864904?auto=format&fit=crop&w=260&q=80"
  }
];

const ProductsPage = () => (
  <div style={{
    display: "flex",
    flexWrap: "wrap",
    gap: "32px",
    padding: "24px 0",
    marginLeft: "125px",    // matches left sidebar width
    marginRight: "350px",  // matches right sidebar width
    marginTop: "78px",
  }}>
    {products.map((prod, idx) => (
      <ProductCard
        key={idx}
        {...prod}
        onAddToCart={() => alert(`Added ${prod.name} to cart!`)}
      />
    ))}
  </div>
);

export default ProductsPage;
