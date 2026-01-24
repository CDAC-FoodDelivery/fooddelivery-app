import React from "react";
import HotelCard from "./Hotelcard";
import { Link } from "react-router-dom";


const hotels = [
  {
    id: 1,
    name: "Circle Of Crust",
    rating: "4.0",
    cuisine: "Italian · Pizza",
    location: "Magarpatta City, Pune",
    distance: "10.4 km",
    price: 900,
    image: "https://images.unsplash.com/photo-1542281286-9e0a16bb7366",
    offers: ["Flat 25% off on pre-booking", "Up to 10% off with bank offers"]
  },
  {
    id: 2,
    name: "Haldiram's Restaurant",
    rating: "4.5",
    cuisine: "North Indian · Mithai",
    location: "Shivaji Nagar, Pune",
    distance: "1.8 km",
    price: 800,
    image: "https://images.unsplash.com/photo-1604908554027-5c5a59f0b29c",
    offers: ["Up to 10% off with bank offers"]
  },
  
  {
    id: 3,
    name: "Bean Social",
    rating: "5.0",
    cuisine: "Beverages · Sandwich",
    location: "Shivaji Nagar, Pune",
    distance: "0.8 km",
    price: 400,
    image: "https://images.unsplash.com/photo-1559339352-11d035aa65de",
    offers: ["Flat 25% off on pre-booking", "+4 more"]
  },
  
  {
    id: 4,
    name: "Bean Social",
    rating: "5.0",
    cuisine: "Beverages · Sandwich",
    location: "Shivaji Nagar, Pune",
    distance: "0.8 km",
    price: 400,
    image: "https://images.unsplash.com/photo-1559339352-11d035aa65de",
    offers: ["Flat 25% off on pre-booking", "+4 more"]
  }
  ,
  
  {
    id: 5,
    name: "Bean Social",
    rating: "5.0",
    cuisine: "Beverages · Sandwich",
    location: "Shivaji Nagar, Pune",
    distance: "0.8 km",
    price: 400,
    image: "https://images.unsplash.com/photo-1559339352-11d035aa65de",
    offers: ["Flat 25% off on pre-booking", "+4 more"]
  }
  ,
  
  {
    id: 6,
    name: "Bean Social",
    rating: "5.0",
    cuisine: "Beverages · Sandwich",
    location: "Shivaji Nagar, Pune",
    distance: "0.8 km",
    price: 400,
    image: "https://images.unsplash.com/photo-1559339352-11d035aa65de",
    offers: ["Flat 25% off on pre-booking", "+4 more"]
  }
  ,
  
  {
    id: 7,
    name: "Bean Social",
    rating: "5.0",
    cuisine: "Beverages · Sandwich",
    location: "Shivaji Nagar, Pune",
    distance: "0.8 km",
    price: 400,
    image: "https://images.unsplash.com/photo-1559339352-11d035aa65de",
    offers: ["Flat 25% off on pre-booking", "+4 more"]
  }
  ,
  
  {
    id: 8,
    name: "Bean Social",
    rating: "5.0",
    cuisine: "Beverages · Sandwich",
    location: "Shivaji Nagar, Pune",
    distance: "0.8 km",
    price: 400,
    image: "https://images.unsplash.com/photo-1559339352-11d035aa65de",
    offers: ["Flat 25% off on pre-booking", "+4 more"]
  }
  ,
  
  {
    id: 9,
    name: "Bean Social",
    rating: "5.0",
    cuisine: "Beverages · Sandwich",
    location: "Shivaji Nagar, Pune",
    distance: "0.8 km",
    price: 400,
    image: "https://images.unsplash.com/photo-1559339352-11d035aa65de",
    offers: ["Flat 25% off on pre-booking", "+4 more"]
  }
  ,
  
  {
    id: 10,
    name: "Bean Social",
    rating: "5.0",
    cuisine: "Beverages · Sandwich",
    location: "Shivaji Nagar, Pune",
    distance: "0.8 km",
    price: 400,
    image: "https://images.unsplash.com/photo-1559339352-11d035aa65de",
    offers: ["Flat 25% off on pre-booking", "+4 more"]
  }
  ,
  
  {
    id: 11,
    name: "Bean Social",
    rating: "5.0",
    cuisine: "Beverages · Sandwich",
    location: "Shivaji Nagar, Pune",
    distance: "0.8 km",
    price: 400,
    image: "https://images.unsplash.com/photo-1559339352-11d035aa65de",
    offers: ["Flat 25% off on pre-booking", "+4 more"]
  }
  ,
  
  {
    id: 12,
    name: "Bean Social",
    rating: "5.0",
    cuisine: "Beverages · Sandwich",
    location: "Shivaji Nagar, Pune",
    distance: "0.8 km",
    price: 400,
    image: "https://images.unsplash.com/photo-1559339352-11d035aa65de",
    offers: ["Flat 25% off on pre-booking", "+4 more"]
  }
  ,
  
  {
    id: 13,
    name: "Bean Social",
    rating: "5.0",
    cuisine: "Beverages · Sandwich",
    location: "Shivaji Nagar, Pune",
    distance: "0.8 km",
    price: 400,
    image: "https://images.unsplash.com/photo-1559339352-11d035aa65de",
    offers: ["Flat 25% off on pre-booking", "+4 more"]
  }


  // ... add id for all hotels
];

const HotelsRow = () => {
  return (
    <div className="mt-4">
      <h5 className="fw-bold mb-3">Discover best restaurants</h5>

      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(4, 1fr)",
          gap: "25px"
        }}
      >
        {hotels.map((hotel) => (
          <Link
            key={hotel.id}
            to={`/product`}   // Navigate to hotel menu page
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
