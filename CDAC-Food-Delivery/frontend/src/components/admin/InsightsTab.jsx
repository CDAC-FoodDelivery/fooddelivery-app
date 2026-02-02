import React from "react";

const InsightsTab = ({ insights }) => {
    return (
        <div className="grid">
            <div className="card insight">📦 {insights.totalOrders} Orders</div>
            <div className="card insight">🍽 {insights.totalRestaurants} Restaurants</div>
            <div className="card insight">👥 {insights.totalUsers} Users</div>
            <div className="card insight">💰 ₹{insights.totalRevenue?.toLocaleString() || 0} Revenue</div>
        </div>
    );
};

export default InsightsTab;
