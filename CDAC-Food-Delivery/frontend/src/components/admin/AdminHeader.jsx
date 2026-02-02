import React from "react";

const AdminHeader = ({ logout, activeTab, setActiveTab }) => {
    return (
        <>
            <header className="admin-header">
                <div className="header-top">
                    <h1>Admin Dashboard</h1>
                    <button className="logout-btn" onClick={logout}>Logout</button>
                </div>
                <p>Food Delivery Management</p>
            </header>

            <nav className="tabs">
                {["orders", "restaurants", "users", "insights"].map((tab) => (
                    <button
                        key={tab}
                        className={activeTab === tab ? "active" : ""}
                        onClick={() => setActiveTab(tab)}
                    >
                        {tab.charAt(0).toUpperCase() + tab.slice(1)}
                    </button>
                ))}
            </nav>
        </>
    );
};

export default AdminHeader;
