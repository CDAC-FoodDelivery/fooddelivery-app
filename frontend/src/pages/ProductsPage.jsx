import React, { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import axios from "axios";
import ProductCard from "../components/ProductCard";
import "./ProductsPage.css";

const ProductsPage = () => {
  const { hotelId } = useParams();

  const [products, setProducts] = useState([]);
  const [foodType, setFoodType] = useState("ALL");
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchMenu();
  }, [hotelId, foodType]);

  const fetchMenu = async () => {
    setLoading(true);
    try {
      let url = `http://localhost:8082/api/menu?hotelId=${hotelId}`;

      if (foodType !== "ALL") {
        url = `http://localhost:8082/api/menu/filter?hotelId=${hotelId}&foodType=${foodType}`;
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
          className={foodType === "ALL" ? "active" : ""}
          onClick={() => setFoodType("ALL")}
        >
          All
        </button>

        <button
          className={foodType === "VEG" ? "active veg" : "veg"}
          onClick={() => setFoodType("VEG")}
        >
          Veg 🌱
        </button>

        <button
          className={foodType === "NON_VEG" ? "active nonveg" : "nonveg"}
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
            />
          ))}
        </div>
      )}
    </div>
  );
};

export default ProductsPage;
