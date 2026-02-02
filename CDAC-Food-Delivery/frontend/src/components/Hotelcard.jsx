import React, { useState } from "react";
import "./HotelCard.css";
import { StarFill } from "react-bootstrap-icons";

const HotelCard = ({ name, rating, cuisine, location, image, offers }) => {
  const [imageError, setImageError] = useState(false);

  return (
    <div className="hotel-card" style={{ pointerEvents: "none" }}>
      <div className="image-wrapper">
        {!imageError ? (
          <img
            src={image?.startsWith('data:') ? image : (image + '?w=400&fit=crop&fm=jpg')}
            alt={name}
            onError={() => setImageError(true)}
            onLoad={() => setImageError(false)}
          />
        ) : (
          <div className="image-placeholder">
            🍽️
          </div>
        )}
        {offers?.length > 0 && (
          <span className="offer-badge">{offers[0]}</span>
        )}
      </div>

      <div className="card-body">
        <h6 className="hotel-name">{name}</h6>
        <div className="rating-time">
          <span className="rating">
            <StarFill size={12} /> {rating}
          </span>
        </div>
        <p className="cuisine">{cuisine}</p>
        <p className="location">{location}</p>
      </div>
    </div>
  );
};

export default HotelCard;
