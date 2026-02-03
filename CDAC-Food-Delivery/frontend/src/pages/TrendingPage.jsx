import React, { useEffect, useState } from "react";
import axios from "axios";
import ProductCard from "../components/ProductCard";
import { useCart } from "../context/CartContext";
import { API_ENDPOINTS } from '../config/api';
import "./ProductsPage.css";

const TrendingPage = () => {
    const [trendingItems, setTrendingItems] = useState([]);
    const [loading, setLoading] = useState(true);
    const { addToCart } = useCart();

    useEffect(() => {
        const fetchTrendingData = async () => {
            setLoading(true);
            try {
                const hotelsRes = await axios.get(API_ENDPOINTS.HOTELS.BASE);
                const hotels = hotelsRes.data;

                const topHotels = [...hotels]
                    .sort((a, b) => b.rating - a.rating)
                    .slice(0, 3);

                const menuPromises = topHotels.map(hotel =>
                    axios.get(API_ENDPOINTS.MENU.BY_HOTEL(hotel.id))
                        .then(res => res.data.map(item => ({
                            ...item,
                            hotelName: hotel.name,
                            hotelRating: hotel.rating
                        })))
                );

                const menus = await Promise.all(menuPromises);

                const allItems = menus.flat();
                setTrendingItems(allItems);
            } catch (error) {
                console.error("Error fetching trending items:", error);
            } finally {
                setLoading(false);
            }
        };

        fetchTrendingData();
    }, []);

    if (loading) return <div className="text-center p-5">Loading trending items...</div>;

    return (
        <div className="products-page">
            <div style={{ marginBottom: "30px", borderBottom: "1px solid #f0f0f0", paddingBottom: "10px" }}>
                <h2 style={{ fontSize: "24px", fontWeight: "700", color: "#3d4152" }}>Trending Now 🔥</h2>
                <p style={{ color: "#686b78", fontSize: "14px" }}>Highest rated items from top restaurants</p>
            </div>

            <div className="products-container">
                {trendingItems.map((item, index) => (
                    <ProductCard
                        key={`${item.id}-${index}`}
                        name={item.name}
                        description={item.description}
                        price={item.price}
                        image={item.imageUrl}
                        hotel_name={item.hotelName}
                        onAddToCart={() => addToCart({
                            name: item.name,
                            description: item.description,
                            price: item.price,
                            image: item.imageUrl
                        })}
                    />
                ))}
            </div>
        </div>
    );
};

export default TrendingPage;
