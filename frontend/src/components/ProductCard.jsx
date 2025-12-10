import React from "react";

const ProductCard = ({
    
  name,
  description,
  price,
  pieces,
  image,
  onAddToCart,
}) => (
  <div
    style={{
      width: 225,
      minHeight: 314,
      borderRadius: 14,
      background: "#fff",
      boxShadow: "0 4px 24px 0 rgba(241,89,40,0.09)",
      display: "flex",
      flexDirection: "column",
      alignItems: "center",
      padding: "22px 16px 15px",
      position: "relative",
      marginBottom: 23,
      transition: "box-shadow 0.17s",
      overflow: "hidden"
    }}
  >
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
          boxShadow: "0 2px 10px 0 rgba(241,89,40,0.11)",
        }}
      />
    </div>

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
        ${price}
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

    <button
      onClick={onAddToCart}
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
        boxShadow: "0 2px 8px 0 rgba(241,89,40,.16)",
        transition: "background 0.15s",
      }}
      aria-label="Add to cart"
      onMouseOver={e => (e.currentTarget.style.background = "#d6521f")}
      onMouseOut={e => (e.currentTarget.style.background = "#F15928")}
    >
      <span style={{ marginTop: -2 }}>+</span>
    </button>
  </div>
);

export default ProductCard;
