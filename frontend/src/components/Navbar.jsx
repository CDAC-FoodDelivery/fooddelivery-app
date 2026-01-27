import React from "react";
import { FaSearch } from "react-icons/fa";

const SIDEBAR_LEFT = 70;
const NAVBAR_HEIGHT = 78;

const Navbar = () => {
  return (
    <nav
      style={{
        position: "fixed",
        top: 0,
        left: SIDEBAR_LEFT,   // start after left sidebar
        right: 0,             // go till screen edge
        height: NAVBAR_HEIGHT,
        background: "#fff",
        boxShadow: "0 2px 10px rgba(0,0,0,0.035)",
        zIndex: 1000,
        display: "flex",
        alignItems: "center",
        padding: "0 44px",
        boxSizing: "border-box",
      }}
    >
      {/* Left content */}
      <div>
        <div style={{ fontSize: 22, fontWeight: 600 }}>
          Welcome, Gorry
        </div>
        <div style={{ fontSize: 14, color: "#989898" }}>
          Discover whatever you need easily
        </div>
      </div>

      {/* Push search fully right */}
      <div style={{ marginLeft: "auto" }}>
        <div
          style={{
            display: "flex",
            alignItems: "center",
            background: "#fafafa",
            borderRadius: 13,
            padding: "8px 16px",
            boxShadow: "0 0 4px rgba(0,0,0,0.06)",
            gap: 12,
          }}
        >
          <input
            type="text"
            placeholder="Search product..."
            style={{
              border: "none",
              outline: "none",
              background: "transparent",
              fontSize: 15,
              width: 260,
            }}
          />
          <FaSearch style={{ color: "#c6c6c6" }} />
        </div>
      </div>
    </nav>
    // ✅ Spacer div removed - MainLayout handles paddingTop: 78px
  );
};

export default Navbar;
