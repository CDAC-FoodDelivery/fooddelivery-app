import React, { useEffect, useState } from "react";
import HotelCard from "./Hotelcard";
import { Link } from "react-router-dom";
import axios from "axios";

const HotelsRow = () => {
  const [hotels, setHotels] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    axios
      .get("http://localhost:8081/api/hotels") // Your backend endpoint
      .then((response) => {
        // Map backend JSON fields to HotelCard props
        const hotelData = response.data.map((hotel) => ({
          id: hotel.id,
          name: hotel.name,
          rating: hotel.rating,
          cuisine: hotel.cuisine,
          location: hotel.location,
          image: hotel.imageUrl, // <-- map 'imageUrl' to 'image'
          offers: hotel.offers || [], // in case you add offers later
        }));

        setHotels(hotelData);
        setLoading(false);
      })
      .catch((err) => {
        console.error("Error fetching hotels:", err);
        setError("Failed to fetch hotels.");
        setLoading(false);
      });
  }, []);

  if (loading) return <p>Loading hotels...</p>;
  if (error) return <p>{error}</p>;

  return (
    <div className="mt-4">
      <h5 className="fw-bold mb-3">Discover best restaurants</h5>

      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(250px, 1fr))",
          gap: "25px",
        }}
      >
        {hotels.map((hotel) => (
          <Link
            key={hotel.id}
            to={`/product/${hotel.id}`} // clickable card
            style={{ textDecoration: "none", color: "inherit" }}
          >
            <HotelCard {...hotel} />
          </Link>
        ))}
      </div>
    </div>
  );
};

export default HotelsRow;
