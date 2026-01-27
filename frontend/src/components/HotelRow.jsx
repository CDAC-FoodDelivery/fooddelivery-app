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
      .get("http://localhost:5102/api/Admin/restaurants")
      .then((response) => {
        const hotelData = response.data.map((hotel) => ({
          id: hotel.id,
          name: hotel.name,
          rating: hotel.rating,
          cuisine: hotel.cuisine,
          location: hotel.city, // Backend uses 'city'
          image: hotel.imageUrl,
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

  if (loading) return <div className="text-center p-5">Loading hotels...</div>;
  if (error) return <div className="text-center p-5 text-danger">{error}</div>;

  return (
    <div className="mt-3">
      <h2 className="fw-bold mb-4 text-center">Discover restaurants...</h2>

      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(280px, 1fr))",
          gap: "25px",
          padding: "0 20px",
        }}
      >
        {hotels.map((hotel) => (
          <Link
            key={hotel.id}
            to={`/home/hotel/${hotel.id}/menu`} // ✅ Matches nested route
            className="hotel-link"
            style={{
              textDecoration: "none",
              color: "inherit",
              display: "block",
              width: "100%",
            }}
          >
            <HotelCard {...hotel} />
          </Link>
        ))}
      </div>
    </div>
  );
};

export default HotelsRow;
