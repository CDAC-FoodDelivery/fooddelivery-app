import { useState } from "react";
import { FaSearch, FaTimes } from "react-icons/fa";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";

const SIDEBAR_LEFT = 70;
const NAVBAR_HEIGHT = 78;

const Navbar = () => {
  const { user } = useAuth();
  const userName = user?.name || "Guest";
  const [query, setQuery] = useState("");
  const navigate = useNavigate();

  const handleSearch = () => {
    if (query.trim()) {
      navigate(`/home/search?q=${encodeURIComponent(query.trim())}`);
    }
  };

  const handleKeyDown = (e) => {
    if (e.key === "Enter") {
      handleSearch();
    }
  };

  return (
    <nav
      style={{
        position: "fixed",
        top: 0,
        left: SIDEBAR_LEFT,
        right: 0,
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
          Welcome, {userName}
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
            position: "relative"
          }}
        >
          <input
            type="text"
            placeholder="Search restaurants or cuisines..."
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            onKeyDown={handleKeyDown}
            style={{
              border: "none",
              outline: "none",
              background: "transparent",
              fontSize: 15,
              width: 260,
            }}
          />
          {query && (
            <FaTimes
              style={{ color: "#c6c6c6", cursor: "pointer", fontSize: 13 }}
              onClick={() => setQuery("")}
            />
          )}
          <FaSearch
            style={{ color: "#F15928", cursor: "pointer" }}
            onClick={handleSearch}
          />
        </div>
      </div>
    </nav>
  );
};

export default Navbar;
