import React, { useState } from "react";
import "./AdminDashboard.css";

function AdminDashboard() {
  const [activeTab, setActiveTab] = useState("orders");

  const [orders] = useState([
    { id: 101, name: "Ravi", status: "Preparing" },
    { id: 102, name: "Anita", status: "Placed" },
  ]);

  const [restaurants, setRestaurants] = useState([
    { id: 1, name: "Spice Hub", city: "Pune", status: "Open" },
    { id: 2, name: "Food Fiesta", city: "Mumbai", status: "Closed" },
  ]);

  const [users] = useState([
    { id: 1, name: "Rahul", role: "Customer" },
    { id: 2, name: "Admin", role: "Admin" },
  ]);

  const handleAddRestaurant = () => {
    setRestaurants([
      ...restaurants,
      {
        id: Date.now(),
        name: "New Restaurant",
        city: "City",
        status: "Open",
      },
    ]);
  };

  const handleDeleteRestaurant = (id) => {
    setRestaurants(restaurants.filter((r) => r.id !== id));
  };

  const handleUpdateRestaurant = (id) => {
    alert("Update Restaurant ID: " + id);
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
                    <button className="update" onClick={() => handleUpdateRestaurant(r.id)}>Update</button>
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
            <div className="card insight">📦 120 Orders</div>
            <div className="card insight">🍽 45 Restaurants</div>
            <div className="card insight">👥 560 Users</div>
            <div className="card insight">💰 ₹2.4L Revenue</div>
          </div>
        )}
      </section>
    </div>
  );

}

export default AdminDashboard;
