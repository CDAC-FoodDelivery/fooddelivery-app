import React, { useState } from "react";
import {
  FaHome,
  FaShoppingCart,
  FaFire,
  FaCog,
  FaSignOutAlt,
} from "react-icons/fa";

const LeftSidebar = () => {
  const [activeIndex, setActiveIndex] = useState(0);

  // Define your sidebar items
  const items = [
    { icon: <FaHome />, title: "Home", onClick: () => setActiveIndex(0) },
    {
      icon: <FaShoppingCart />,
      title: "Orders",
      onClick: () => setActiveIndex(1),
    },
    { icon: <FaFire />, title: "Trending", onClick: () => setActiveIndex(2) },
  ];
  // Bottom sidebar items
  const bottomItems = [
    { icon: <FaCog />, title: "Settings", onClick: () => setActiveIndex(3) },
    {
      icon: <FaSignOutAlt />,
      title: "Logout",
      onClick: () => alert("Logout!"),
    },
  ];

  return (
    <div
      style={{
        position: "fixed",      // Makes it sticky to the viewport!
        top: 0,
        left: 0,
        background: "#fff",
        width: "70px",
        height: "100vh",
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        paddingTop: "20px",
        boxShadow: "2px 0 5px rgba(0,0,0,0.05)",
        justifyContent: "space-between",
        zIndex: 100,   
      }}
    >
      <div>
        <div style={{ marginBottom: "50px" }}>
          <div
            style={{
              width: "36px",
              height: "36px",
              borderRadius: "10px",
              background: "#F15928",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              fontWeight: "bold",
              color: "#fff",
            }}
          >
            <img
              src="https://media.istockphoto.com/id/1435983029/vector/food-delivery-logo-images.jpg?s=612x612&w=0&k=20&c=HXPxcjOxUiW4pMW1u9E0k2dJYQOU37a_0qZAy3so8fY="
              alt=""
              style={{ width: "80px", height: "80px" }}
            />
          </div>
        </div>
        <nav style={{ display: "flex", flexDirection: "column", gap: "35px" }}>
          {items.map((item, idx) => (
            <SidebarIcon
              key={item.title}
              icon={item.icon}
              title={item.title}
              active={activeIndex === idx}
              onClick={item.onClick}
            />
          ))}
        </nav>
      </div>
      <div
        style={{
          marginBottom: "30px",
          display: "flex",
          flexDirection: "column",
          gap: "20px",
        }}
      >
        {bottomItems.map((item, idx) => (
          <SidebarIcon
            key={item.title}
            icon={item.icon}
            title={item.title}
            active={activeIndex === idx + items.length}
            onClick={item.onClick}
          />
        ))}
      </div>
    </div>
  );
};

const SidebarIcon = ({ icon, title, active, onClick }) => (
  <div
    title={title}
    onClick={onClick}
    style={{
      width: "36px",
      height: "36px",
      borderRadius: "8px",
      background: active ? "#F15928" : "#fafafa",
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      marginBottom: "8px",
      cursor: "pointer",
      color: active ? "#fff" : "#F15928",
      transition: "background 0.15s, color 0.15s, transform 0.15s",
    }}
    className="sidebar-icon"
  >
    <span style={{ fontSize: "22px" }}>{icon}</span>
    <style>
      {`
        .sidebar-icon:hover {
          background: #ffecd6;
          transform: scale(1.07);
        }
      `}
    </style>
  </div>
);

export default LeftSidebar;
