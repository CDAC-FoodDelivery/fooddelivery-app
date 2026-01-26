import React from "react";
import "./ProductCard.css";

const ProductCard = ({
  name,
  description,
  price,
  pieces,
  image,
  onAddToCart
}) => {
  return (
    <div className="product-card">
      <img src={image} alt={name} className="product-image" />

      <div className="product-content">
        <h3>{name}</h3>
        <p className="description">{description}</p>

        <div className="product-footer">
          <span className="price">₹{price}</span>
          <button onClick={onAddToCart}>ADD</button>
        </div>
      </div>
    </div>
  );
};

export default ProductCard;
