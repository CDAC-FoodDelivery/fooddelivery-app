import React, { useState } from "react";
import { FaHeart, FaRegHeart } from "react-icons/fa";

const ProductCard = ({
  name,
  description,
  price,
  pieces,
  image,
  onAddToCart,
}) => {
  const [isWishlisted, setIsWishlisted] = useState(false);

  const toggleWishlist = () => {
    setIsWishlisted((prev) => !prev);
  };

  return (
    <div
      style={{
        width: 225,
        minHeight: 314,
        borderRadius: 14,
        background: "#fff",
        boxShadow: "0 4px 24px rgba(241,89,40,0.09)",
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        padding: "22px 16px 15px",
        position: "relative",
        marginBottom: 23,
        overflow: "hidden",
      }}
    >
      {/* ❤️ WISHLIST */}
      <button
        onClick={toggleWishlist}
        aria-label="Add to wishlist"
        style={{
          position: "absolute",
          top: 18,
          left: 15,
          width: 30,
          height: 30,
          borderRadius: "50%",
          border: "none",
          background: isWishlisted ? "#ffe6e6" : "#fff",
          color: isWishlisted ? "#e11d48" : "#222",
          cursor: "pointer",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          boxShadow: isWishlisted
            ? "0 4px 12px rgba(225,29,72,0.35)"
            : "0 2px 8px rgba(0,0,0,.18)",
          transition: "all 0.2s ease",
        }}
        onMouseEnter={(e) =>
          (e.currentTarget.style.transform = "scale(1.12)")
        }
        onMouseLeave={(e) =>
          (e.currentTarget.style.transform = "scale(1)")
        }
      >
        {isWishlisted ? (
          <FaHeart size={14} />
        ) : (
          <FaRegHeart size={14} />
        )}
      </button>

      {/* IMAGE */}
      <div
        style={{
          width: "100%",
          height: 103,
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          marginBottom: 18,
        }}
      >
        <img
          src={image}
          alt={name}
          style={{
            width: 168,
            height: 103,
            objectFit: "cover",
            borderRadius: 12,
            boxShadow: "0 2px 10px rgba(241,89,40,0.11)",
          }}
        />
      </div>

      {/* NAME */}
      <div
        style={{
          width: "100%",
          textAlign: "left",
          marginBottom: 9,
          fontWeight: 700,
          fontSize: 16,
          color: "#363636",
          lineHeight: 1.13,
        }}
      >
        {name}
      </div>

      {/* DESCRIPTION */}
      <div
        style={{
          width: "100%",
          minHeight: 38,
          fontSize: 13.5,
          color: "#969696",
          marginBottom: 11,
          textAlign: "left",
          fontWeight: 500,
          lineHeight: "1.38",
        }}
      >
        {description}
      </div>

      {/* PRICE + PCS */}
      <div
        style={{
          width: "100%",
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
          marginTop: "auto",
        }}
      >
        <span
          style={{
            fontSize: 18,
            fontWeight: 800,
            color: "#F15928",
          }}
        >
          ₹{price}
        </span>

        <span
          style={{
            fontSize: 13,
            color: "#7a7a7a",
            background: "#f8f4ef",
            borderRadius: 5,
            padding: "2.5px 11px",
            fontWeight: 600,
          }}
        >
          {pieces} pcs
        </span>
      </div>

      {/* ADD TO CART */}
      <button
        onClick={onAddToCart}
        aria-label="Add to cart"
        style={{
          position: "absolute",
          top: 18,
          right: 15,
          width: 30,
          height: 30,
          borderRadius: "50%",
          border: "none",
          background: "#F15928",
          color: "#fff",
          fontWeight: 900,
          fontSize: 21,
          cursor: "pointer",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          boxShadow: "0 2px 8px rgba(241,89,40,.16)",
          transition: "background 0.15s",
        }}
        onMouseEnter={(e) =>
          (e.currentTarget.style.background = "#d6521f")
        }
        onMouseLeave={(e) =>
          (e.currentTarget.style.background = "#F15928")
        }
      >
        <span style={{ marginTop: -2 }}>+</span>
      </button>
    </div>
  );
};

export default ProductCard;
