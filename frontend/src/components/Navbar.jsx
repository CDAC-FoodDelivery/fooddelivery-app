import React from "react";
import { FaSearch, FaFilter } from "react-icons/fa";

// Dummy avatar URL, swap for actual image or asset
const avatarUrl = "https://cdn-icons-png.flaticon.com/128/1946/1946429.png";
const SIDEBAR_LEFT = 70;    // pixel width of left sidebar
const SIDEBAR_RIGHT = 350;  // pixel width of right sidebar

const Navbar = () => (
  <nav
    style={{
      position: "fixed",                 // Sticky to top!
      top: 0,
      left: SIDEBAR_LEFT,                // Start after left sidebar
      right: SIDEBAR_RIGHT,              // End before right sidebar
      height: 78,
      background: "#fff",
      display: "flex",
      alignItems: "center",
      justifyContent: "space-between",
      padding: "0 44px",
      boxShadow: "0 2px 10px rgba(0,0,0,0.035)",
      zIndex: 50,
    }}
  >
    {/* Welcome + Subtitle */}
    <div
      style={{
        display: "flex",
        flexDirection: "column",
        justifyContent: "center",
      }}
    >
      <span style={{ fontSize: 22, fontWeight: 600 }}>Welcome, Gorry</span>
      <span style={{ fontSize: 14, color: "#989898", marginTop: 2 }}>
        Discover whatever you need easily
      </span>
    </div>

    {/* Search Area */}
    <div
      style={{
        display: "flex",
        alignItems: "center",
        background: "#fafafa",
        borderRadius: 13,
        padding: "8px 18px",
        boxShadow: "0 0 4px rgba(0,0,0,0.06)",
        minWidth: 410,
        gap: 15,
      }}
    >
      <FaSearch style={{ fontSize: 18, color: "#c6c6c6" }} />
      <input
        type="text"
        placeholder="Search product..."
        style={{
          border: "none",
          outline: "none",
          background: "transparent",
          fontSize: 15,
          width: 230,
        }}
      />
      <button
        style={{
          border: "none",
          background: "#F15928",
          color: "#fff",
          borderRadius: 8,
          padding: "8px 12px",
          fontSize: 14,
          display: "flex",
          alignItems: "center",
          cursor: "pointer",
        }}
        onMouseOver={(e) => (e.currentTarget.style.background = "#d6521f")}
        onMouseOut={(e) => (e.currentTarget.style.background = "#F15928")}
      >
        <FaFilter style={{ fontSize: 15 }} />
        <span style={{ marginLeft: 6 }}>Filter</span>
      </button>
    </div>
  </nav>
);

export default Navbar;
