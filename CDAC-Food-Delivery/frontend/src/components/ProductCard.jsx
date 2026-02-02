import { FaHeart, FaRegHeart } from "react-icons/fa";
import { useWishlist } from "../context/WishlistContext";
import { useState } from "react";
import "./ProductCard.css";

const ProductCard = ({
  name,
  description,
  price,
  image,
  food_type,
  category,
  onAddToCart,
  hotel_name
}) => {
  const { toggleWishlist, isInWishlist } = useWishlist();
  const [imageError, setImageError] = useState(false);
  const isFavorite = isInWishlist(name);

  return (
    <div className="product-card">
      <div className="wishlist-icon" onClick={() => toggleWishlist({
        name, description, price, image, food_type, hotel_name
      })}>
        {isFavorite ? <FaHeart color="#e74c3c" /> : <FaRegHeart />}
      </div>

      <div className="image-wrapper">
        {!imageError ? (
          <img
            src={image?.startsWith('data:') ? image : (image + '?w=300&fm=jpg')}
            alt={name}
            className="product-image"
            onError={() => setImageError(true)}
          />
        ) : (
          <div className="image-placeholder">
            🍽️
          </div>
        )}
      </div>

      <div className="product-content">
        <div className="item-header">
          <h3>{name}</h3>
        </div>

        <p className="description">{description || category}</p>
        {hotel_name && (
          <p className="hotel-name">{hotel_name}</p>
        )}

        <div className="product-footer">
          <span className="price">₹{price}</span>
          <button onClick={onAddToCart} className="add-btn">
            ADD
          </button>
        </div>
      </div>
    </div>
  );
};

export default ProductCard;
