import React, { useEffect, useState } from "react";
import { useSearchParams, Link } from "react-router-dom";
import axios from "axios";
import HotelCard from "../components/Hotelcard";
import { API_ENDPOINTS } from '../config/api';
import "./ProductsPage.css";

const SearchPage = () => {
    const [searchParams] = useSearchParams();
    const query = searchParams.get("q") || "";
    const [hotels, setHotels] = useState([]);
    const [filteredHotels, setFilteredHotels] = useState([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchHotels = async () => {
            setLoading(true);
            try {
                const response = await axios.get(API_ENDPOINTS.HOTELS.BASE);
                setHotels(response.data);
            } catch (error) {
                console.error("Error fetching hotels for search:", error);
            } finally {
                setLoading(false);
            }
        };
        fetchHotels();
    }, []);

    useEffect(() => {
        if (!loading) {
            const results = hotels.filter(hotel =>
                hotel.name.toLowerCase().includes(query.toLowerCase()) ||
                hotel.cuisine.toLowerCase().includes(query.toLowerCase())
            );
            setFilteredHotels(results);
        }
    }, [query, hotels, loading]);

    if (loading) return <div className="text-center p-5">Searching for restaurants...</div>;

    return (
        <div className="products-page">
            <div style={{ marginBottom: "30px", borderBottom: "1px solid #f0f0f0", paddingBottom: "10px" }}>
                <h2 style={{ fontSize: "24px", fontWeight: "700", color: "#3d4152" }}>
                    Results for "{query}"
                </h2>
                <p style={{ color: "#686b78", fontSize: "14px" }}>
                    Found {filteredHotels.length} restaurant{filteredHotels.length !== 1 ? 's' : ''}
                </p>
            </div>

            {filteredHotels.length > 0 ? (
                <div style={{
                    display: "grid",
                    gridTemplateColumns: "repeat(auto-fill, minmax(280px, 1fr))",
                    gap: "25px"
                }}>
                    {filteredHotels.map((hotel) => (
                        <Link
                            key={hotel.id}
                            to={`/home/hotel/${hotel.id}/menu`}
                            style={{ textDecoration: "none", color: "inherit" }}
                        >
                            <HotelCard
                                id={hotel.id}
                                name={hotel.name}
                                rating={hotel.rating}
                                cuisine={hotel.cuisine}
                                location={hotel.location}
                                image={hotel.imageUrl}
                            />
                        </Link>
                    ))}
                </div>
            ) : (
                <div style={{ textAlign: "center", padding: "100px 20px" }}>
                    <div style={{ fontSize: "50px", marginBottom: "20px" }}>🔍</div>
                    <h3 style={{ color: "#3d4152", marginBottom: "10px" }}>No restaurants found</h3>
                    <p style={{ color: "#686b78" }}>
                        Try searching for a different restaurant or cuisine.
                    </p>
                    <button
                        onClick={() => window.history.back()}
                        style={{
                            marginTop: "20px",
                            padding: "10px 24px",
                            borderRadius: "8px",
                            border: "1px solid #F15928",
                            background: "white",
                            color: "#F15928",
                            fontWeight: "600",
                            cursor: "pointer"
                        }}
                    >
                        Go Back
                    </button>
                </div>
            )}
        </div>
    );
};

export default SearchPage;
