import React from "react";
import { useParams } from "react-router-dom";

const HotelMenuPage = () => {
  const { id } = useParams();

  return (
    <div className="container mt-5">
      <h2>Hotel Menu Page</h2>
      <p>Showing menu for hotel ID: {id}</p>
      {/* Fetch menu by hotel ID from API or static data */}
    </div>
  );
};

export default HotelMenuPage;
