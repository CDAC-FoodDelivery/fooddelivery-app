import React, { useState } from "react";
import "./RiderDashboard.css";
import { useAuth } from "../context/AuthContext";

function RiderDashboard() {
  const { logout } = useAuth();
  const [activeTab, setActiveTab] = useState("deliveries");

  const [deliveries, setDeliveries] = useState([
    { id: 201, customer: "Suresh P.", address: "123 MG Road, Pune", status: "Assigned" },
    { id: 202, customer: "Meera K.", address: "45 FC Road, Pune", status: "Picked Up" },
    { id: 203, customer: "Amit B.", address: "78 Hinjewadi, Pune", status: "Delivered" },
  ]);

  const handleStatusUpdate = (id, newStatus) => {
    setDeliveries(deliveries.map(d =>
      d.id === id ? { ...d, status: newStatus } : d
    ));
  };

  return (
    <div className="rider-page">
      <header className="rider-header">
        <div className="header-top">
          <h1>Rider Dashboard</h1>
          <button className="logout-btn" onClick={logout}>Logout</button>
        </div>
        <p>Your Deliveries at a Glance</p>
      </header>

      <nav className="tabs">
        <button className={activeTab === "deliveries" ? "active" : ""} onClick={() => setActiveTab("deliveries")}>
          My Deliveries
        </button>
        <button className={activeTab === "insights" ? "active" : ""} onClick={() => setActiveTab("insights")}>
          Insights
        </button>
      </nav>

      <section className="content">
        {activeTab === "deliveries" && (
          <div className="grid">
            {deliveries.map(d => (
              <div className="card" key={d.id}>
                <h3>Order #{d.id}</h3>
                <p><strong>Customer:</strong> {d.customer}</p>
                <p><strong>Address:</strong> {d.address}</p>
                <span className="badge">{d.status}</span>

                <div className="card-actions">
                  {d.status === "Assigned" && (
                    <button className="action-btn" onClick={() => handleStatusUpdate(d.id, "Picked Up")}>Mark Picked Up</button>
                  )}
                  {d.status === "Picked Up" && (
                    <button className="action-btn" onClick={() => handleStatusUpdate(d.id, "Delivered")}>Mark Delivered</button>
                  )}
                  {d.status === "Delivered" && (
                    <button className="action-btn" disabled style={{ opacity: 0.6, cursor: 'not-allowed' }}>Completed</button>
                  )}
                </div>
              </div>
            ))}
          </div>
        )}

        {activeTab === "insights" && (
          <div className="grid">
            <div className="card insight">📦 45 Deliveries</div>
            <div className="card insight">⭐ 4.8 Rating</div>
            <div className="card insight">💰 ₹12,500 Earnings</div>
            <div className="card insight">🕒 250 Hrs Online</div>
          </div>
        )}
      </section>
    </div>
  );
}

export default RiderDashboard;
