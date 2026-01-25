import React from "react";
import "./Hotelcard.css";
import { StarFill } from "react-bootstrap-icons";

const HotelCard = ({ name, rating, cuisine, location, image, offers }) => {
  return (
    <div className="hotel-card">
      <div className="image-wrapper">
        <img src={image} alt={name} />
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
