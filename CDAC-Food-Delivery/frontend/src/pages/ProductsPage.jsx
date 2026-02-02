import React, { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import axios from "axios";
import ProductCard from "../components/ProductCard";
import { useCart } from "../context/CartContext";
import "./ProductsPage.css";

const ProductsPage = () => {
  const { hotelId } = useParams();
  const { addToCart } = useCart();

  const [products, setProducts] = useState([]);
  const [foodType, setFoodType] = useState("ALL");
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchMenu();
  }, [hotelId, foodType]);

  const fetchMenu = async () => {
    setLoading(true);
    try {
      let url = `http://localhost:8080/api/menu?hotelId=${hotelId}`;

      if (foodType !== "ALL") {
        url = `http://localhost:8080/api/menu/filter?hotelId=${hotelId}&foodType=${foodType}`;
      }

      const response = await axios.get(url);
      setProducts(response.data);
    } catch (error) {
      console.error("Error fetching menu:", error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="products-page">

      {/* FILTER BAR */}
      <div className="food-filter-bar">
        <button
          className={`filter-btn ${foodType === "ALL" ? "active all" : ""}`}
          onClick={() => setFoodType("ALL")}
        >
          All Items
        </button>

        <button
          className={`filter-btn veg ${foodType === "VEG" ? "active" : ""}`}
          onClick={() => setFoodType("VEG")}
        >
          Veg 🌱
        </button>

        <button
          className={`filter-btn nonveg ${foodType === "NON_VEG" ? "active" : ""}`}
          onClick={() => setFoodType("NON_VEG")}
        >
          Non-Veg 🍗
        </button>
      </div>

      {/* PRODUCTS GRID */}
      {loading ? (
        <p>Loading menu...</p>
      ) : (
        <div className="products-container">
          {products.map((prod) => (
            <ProductCard
              key={prod.id}
              name={prod.name}
              description={prod.description}
              price={prod.price}
              image={prod.imageUrl}
              onAddToCart={() => addToCart({
                name: prod.name,
                description: prod.description,
                price: prod.price,
                image: prod.imageUrl
              })}
            />
          ))}
        </div>
      )}
    </div>
  );
};

export default ProductsPage;
