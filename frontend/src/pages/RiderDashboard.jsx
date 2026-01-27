import React, { useState } from "react";
import axios from "axios";
import "./RiderDashboard.css";

function RiderDashboard() {
  const [activeTab, setActiveTab] = useState("deliveries");

  const [deliveries, setDeliveries] = useState([]);

  React.useEffect(() => {
    fetchDeliveries();
  }, []);

  const fetchDeliveries = async () => {
    try {
      const res = await axios.get("http://localhost:8084/rider/deliveries");
      // Map backend fields to frontend if needed, but they look similar
      // Backend: id, customerName, address, status
      // Frontend: id, customer, address, status
      setDeliveries(res.data.map(d => ({
        ...d,
        customer: d.customerName
      })));
    } catch (error) {
      console.error("Error fetching deliveries", error);
      // Fallback or empty
    }
  };

  const handleStatusUpdate = async (id, newStatus) => {
    try {
      await axios.put(`http://localhost:8084/rider/update/${id}/${newStatus}`);
      fetchDeliveries(); // Refresh
    } catch (error) {
      console.error("Error updating status", error);
    }
  };

  return (
    <div className="rider-page">
      <header className="rider-header">
        <h1>Rider Dashboard</h1>
        <p>Your Deliveries at a Glance</p>
      </header>

      {/* Navigation Tabs */}
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
