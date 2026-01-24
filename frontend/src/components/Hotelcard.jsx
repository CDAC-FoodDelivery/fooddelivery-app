import React from "react";
import "./Hotelcard.css";
import { StarFill } from "react-bootstrap-icons";

const HotelCard = ({ name, rating, cuisine, location, image, offer, time }) => {
  return (
    <div className="hotel-card">
      <div className="image-wrapper">
        <img src={image} alt={name} />
        {offer && <span className="offer-badge">{offer}</span>}
      </div>

      <div className="card-body">
        <h6 className="hotel-name">{name}</h6>

        <div className="rating-time">
          <span className="rating">
            <StarFill size={12} /> {rating}
          </span>
          <span className="dot">•</span>
          <span>{time}</span>
        </div>

        <p className="cuisine">{cuisine}</p>
        <p className="location">{location}</p>
      </div>
    </div>
  );
};

export default HotelCard;
