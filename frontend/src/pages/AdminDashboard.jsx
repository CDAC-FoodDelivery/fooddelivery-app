import React, { useState, useEffect } from "react";
import "./AdminDashboard.css";
import axios from "axios";

function AdminDashboard() {
  const [activeTab, setActiveTab] = useState("orders");

  const [orders, setOrders] = useState([]);
  const [restaurants, setRestaurants] = useState([]);
  const [users, setUsers] = useState([]);
  const [insights, setInsights] = useState({ orders: 0, restaurants: 0, users: 0, revenue: 0 });

  const API_URL = "http://localhost:5102/api/admin";

  useEffect(() => {
    fetchData();
  }, [activeTab]);

  const fetchData = async () => {
    try {
      if (activeTab === "orders") {
        const res = await axios.get(`${API_URL}/orders`);
        setOrders(res.data);
      } else if (activeTab === "restaurants") {
        const res = await axios.get(`${API_URL}/restaurants`);
        setRestaurants(res.data);
      } else if (activeTab === "users") {
        const res = await axios.get(`${API_URL}/users`);
        setUsers(res.data);
      } else if (activeTab === "insights") {
        const res = await axios.get(`${API_URL}/insights`);
        setInsights(res.data);
      }
    } catch (error) {
      console.error("Error fetching data", error);
    }
  };

  const handleAddRestaurant = async () => {
    // Demo values, ideally this should come from a form modal
    const newRestaurant = {
      name: "New Restaurant " + Math.floor(Math.random() * 100),
      city: "Pune",
      email: "test_hotel_" + Math.floor(Math.random() * 100) + "@mail.com",
      phone: "9876543210",
      cuisine: "Indian",
      password: "" // will be auto-generated
    };
    try {
      const res = await axios.post(`${API_URL}/restaurants`, newRestaurant);
      // The backend returns the Restaurant object, so we can display it directly
      setRestaurants([...restaurants, res.data]);
      alert("Restaurant and User added! Credentials sent to email.");
    } catch (error) {
      console.error("Error adding restaurant", error);
      alert("Failed to add restaurant: " + (error.response?.data || error.message));
    }
  };

  const handleDeleteRestaurant = async (id) => {
    try {
      await axios.delete(`${API_URL}/restaurants/${id}`);
      setRestaurants(restaurants.filter((r) => r.id !== id));
    } catch (error) {
      console.error("Error deleting restaurant", error);
    }
  };

  const handleUpdateRestaurant = async (id) => {
    // Simple toggle status for demo
    const restaurant = restaurants.find(r => r.id === id);
    if (!restaurant) return;

    const updated = { ...restaurant, status: restaurant.status === "Open" ? "Closed" : "Open" };
    try {
      await axios.put(`${API_URL}/restaurants/${id}`, updated);
      setRestaurants(restaurants.map(r => r.id === id ? updated : r));
    } catch (error) {
      console.error("Error updating restaurant", error);
    }
  };

  return (
    <div className="admin-page">
      <header className="admin-header">
        <h1>Admin Dashboard</h1>
        <p>Food Delivery Management</p>
      </header>

      {/* Navigation Tabs */}
      <nav className="tabs">
        <button className={activeTab === "orders" ? "active" : ""} onClick={() => setActiveTab("orders")}>
          Orders
        </button>
        <button className={activeTab === "restaurants" ? "active" : ""} onClick={() => setActiveTab("restaurants")}>
          Restaurants
        </button>
        <button className={activeTab === "users" ? "active" : ""} onClick={() => setActiveTab("users")}>
          Users
        </button>
        <button className={activeTab === "insights" ? "active" : ""} onClick={() => setActiveTab("insights")}>
          Insights
        </button>
      </nav>

      <section className="content">
        {activeTab === "orders" && (
          <div className="grid">
            {orders.map(o => (
              <div className="card" key={o.id}>
                <h3>Order #{o.id}</h3>
                <p>Customer: {o.name}</p>
                <span className="badge">{o.status}</span>
              </div>
            ))}
          </div>
        )}

        {activeTab === "restaurants" && (
          <>
            <div className="section-header">
              <h2>Restaurants</h2>
              <button className="add-btn" onClick={handleAddRestaurant}>＋ Add Restaurant</button>
            </div>

            <div className="grid">
              {restaurants.map(r => (
                <div className="card restaurant-card" key={r.id}>
                  <div>
                    <h3>{r.name}</h3>
                    <p>{r.city}</p>
                    <span className="badge">{r.status}</span>
                  </div>

                  <div className="card-actions">
                    <button className="update" onClick={() => handleUpdateRestaurant(r.id)}>Toggle Status</button>
                    <button className="delete" onClick={() => handleDeleteRestaurant(r.id)}>Delete</button>
                  </div>
                </div>
              ))}
            </div>
          </>
        )}

        {activeTab === "users" && (
          <div className="grid">
            {users.map(u => (
              <div className="card" key={u.id}>
                <h3>{u.name}</h3>
                <p>Role: {u.role}</p>
              </div>
            ))}
          </div>
        )}

        {activeTab === "insights" && (
          <div className="grid">
            <div className="card insight">📦 {insights.orders || 0} Orders</div>
            <div className="card insight">🍽 {insights.restaurants || 0} Restaurants</div>
            <div className="card insight">👥 {insights.users || 0} Users</div>
            <div className="card insight">💰 ₹{insights.revenue || 0} Revenue</div>
          </div>
        )}
      </section>
    </div>
  );

}

export default AdminDashboard;
