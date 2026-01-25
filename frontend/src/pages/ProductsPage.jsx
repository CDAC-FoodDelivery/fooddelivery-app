import React, { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import axios from "axios";
import ProductCard from "../components/ProductCard";

const ProductsPage = () => {
  const { hotelId } = useParams(); // from /product/:hotelId

  const [products, setProducts] = useState([]);
  const [foodType, setFoodType] = useState("ALL"); // ALL | VEG | NON_VEG
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
    <div
      style={{
        marginLeft: "125px",
        marginRight: "350px",
        marginTop: "78px",
      }}
    >
      {/* FILTER BAR */}
      <div style={{ marginBottom: "20px", display: "flex", gap: "12px" }}>
        <button
          onClick={() => setFoodType("ALL")}
          className={foodType === "ALL" ? "active-filter" : ""}
        >
          All
        </button>
        <button
          onClick={() => setFoodType("VEG")}
          className={foodType === "VEG" ? "active-filter" : ""}
        >
          Veg 🌱
        </button>
        <button
          onClick={() => setFoodType("NON_VEG")}
          className={foodType === "NON_VEG" ? "active-filter" : ""}
        >
          Non-Veg 🍗
        </button>
      </div>

      {/* MENU GRID */}
      {loading ? (
        <p>Loading menu...</p>
      ) : (
        <div
          style={{
            display: "flex",
            flexWrap: "wrap",
            gap: "32px",
            padding: "24px 0",
          }}
        >
          {products.map((prod) => (
            <ProductCard
              key={prod.id}
              name={prod.name}
              description={prod.description}
              price={prod.price}
              image={prod.imageUrl}
              onAddToCart={() => alert(`Added ${prod.name} to cart!`)}
            />
          ))}
        </div>
      )}
    </div>
  );
};

export default ProductsPage;
