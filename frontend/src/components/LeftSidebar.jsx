import React, { useState } from "react";
// import Trending from "./pages/Trending";

import {
  FaHome,
  FaFire,
  FaHeart,
  FaUserEdit,
  FaSignOutAlt,
  FaLocationArrow,
} from "react-icons/fa";

/* ================= EDIT PROFILE MODAL ================= */

const EditProfileModal = ({ onClose }) => {
  const [profile, setProfile] = useState({
    name: "",
    phone: "",
    address: "",
    pincode: "",
    location: "",
  });

  const [locating, setLocating] = useState(false);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setProfile((p) => ({ ...p, [name]: value }));
  };

  // 📍 BEST "USE CURRENT LOCATION"
  const useCurrentLocation = () => {
    if (!navigator.geolocation) {
      alert("Geolocation not supported");
      return;
    }

    setLocating(true);

    navigator.geolocation.getCurrentPosition(
      (pos) => {
        const { latitude, longitude } = pos.coords;

        // Demo readable location (replace with API later)
        const locationName = `Near you (Lat ${latitude.toFixed(
          2,
        )}, Lng ${longitude.toFixed(2)})`;

        setProfile((p) => ({
          ...p,
          location: locationName,
        }));

        setLocating(false);
      },
      () => {
        alert("Unable to fetch location");
        setLocating(false);
      },
    );
  };

  return (
    <>
      {/* BLUR BACKDROP */}
      <div
        onClick={onClose}
        style={{
          position: "fixed",
          inset: 0,
          background: "rgba(0,0,0,0.25)",
          backdropFilter: "blur(6px)",
          WebkitBackdropFilter: "blur(6px)",
          zIndex: 150,
        }}
      />

      {/* MODAL */}
      <div
        style={{
          position: "fixed",
          top: "50%",
          left: "50%",
          transform: "translate(-50%, -50%)",
          width: "440px",
          background: "#fff",
          borderRadius: "20px",
          padding: "28px",
          boxShadow: "0 20px 50px rgba(0,0,0,0.25)",
          zIndex: 200,
        }}
      >
        <h3 style={{ marginBottom: 6 }}>Edit Profile</h3>
        <p style={{ fontSize: 13, color: "#9a9aad", marginBottom: 20 }}>
          Update your delivery and personal details
        </p>

        <Input
          label="Full Name"
          name="name"
          placeholder="Enter your full name"
          value={profile.name}
          onChange={handleChange}
        />

        <Input
          label="Phone Number"
          name="phone"
          placeholder="Enter phone number"
          value={profile.phone}
          onChange={handleChange}
        />

        <Input
          label="Delivery Address"
          name="address"
          placeholder="Flat / Area / City"
          value={profile.address}
          onChange={handleChange}
        />

        <Input
          label="Pincode"
          name="pincode"
          placeholder="Enter pincode"
          value={profile.pincode}
          onChange={handleChange}
        />

        <div className="text-center">OR</div>

        {/* 📍 BEST LOCATION FIELD */}
        <div style={{ marginBottom: 14 }}>
          <label style={{ fontSize: 13, color: "#555" }}>
            Use Current Location
          </label>

          <div
            style={{
              display: "grid",
              gridTemplateColumns: "1fr auto",
              gap: "10px",
              marginTop: 6,
            }}
          >
            <button
              onClick={useCurrentLocation}
              disabled={locating}
              title="Use Current Location"
              style={{
                height: "42px",
                padding: "0 14px",
                borderRadius: "10px",
                border: "1px solid #dedee8",
                background: "#fff",
                color: locating ? "#f2b27a" : "#ff8a24", // 🔥 ORANGE TEXT
                fontWeight: 600,
                cursor: locating ? "not-allowed" : "pointer",
                display: "flex",
                alignItems: "center",
                gap: "6px",
                transition: "color 0.15s, background 0.15s",
              }}
              onMouseEnter={(e) => {
                if (!locating) e.currentTarget.style.background = "#fff6ec";
              }}
              onMouseLeave={(e) => {
                e.currentTarget.style.background = "#fff";
              }}
            >
              <FaLocationArrow />
              {locating ? "Locating..." : "Use Current"}
            </button>
          </div>
        </div>

        {/* ACTIONS */}
        <div
          style={{
            display: "flex",
            justifyContent: "flex-end",
            gap: "12px",
            marginTop: 22,
          }}
        >
          <button onClick={onClose} style={btnSecondary}>
            Cancel
          </button>
          <button
            onClick={() => {
              alert("Profile updated!");
              onClose();
            }}
            style={btnPrimary}
          >
            Save
          </button>
        </div>
      </div>
    </>
  );
};

/* ================= LEFT SIDEBAR ================= */

const LeftSidebar = () => {
  const [activeIndex, setActiveIndex] = useState(0);
  const [showEditProfile, setShowEditProfile] = useState(false);

  const items = [
    { icon: <FaHome />, title: "Home", index: 0 },
    { icon: <FaFire />, title: "Trending", index: 1 },
    { icon: <FaHeart />, title: "Wishlist", index: 2 },
  ];

  const bottomItems = [
    { icon: <FaUserEdit />, title: "Edit Profile", index: 3 },
    { icon: <FaSignOutAlt />, title: "Logout", index: 4 },
  ];

  return (
    <>
      <div
        style={{
          position: "fixed",
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
          filter: showEditProfile ? "blur(4px)" : "none",
        }}
      >
        
        {/* TOP */}
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

          <nav
            style={{ display: "flex", flexDirection: "column", gap: "35px" }}
          >
            {items.map((item) => (
              <SidebarIcon
                key={item.title}
                icon={item.icon}
                title={item.title}
                active={activeIndex === item.index}
                onClick={() => setActiveIndex(item.index)}
              />
            ))}
          </nav>
        </div>

        {/* BOTTOM */}
        <div
          style={{
            marginBottom: "30px",
            display: "flex",
            flexDirection: "column",
            gap: "20px",
          }}
        >
          {bottomItems.map((item) => (
            <SidebarIcon
              key={item.title}
              icon={item.icon}
              title={item.title}
              active={activeIndex === item.index && item.title !== "Logout"}
              onClick={() =>
                item.title === "Logout"
                  ? alert("Logout!")
                  : setShowEditProfile(true)
              }
            />
          ))}
        </div>
      </div>

      {showEditProfile && (
        <EditProfileModal onClose={() => setShowEditProfile(false)} />
      )}
    </>
  );
};

/* ================= SHARED ================= */

const SidebarIcon = ({ icon, title, active, onClick }) => (
  <div
    title={title}
    onClick={onClick}
    className="sidebar-icon"
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

const Input = ({ label, ...props }) => (
  <div style={{ marginBottom: 14 }}>
    <label style={{ fontSize: 13, color: "#555" }}>{label}</label>
    <input
      {...props}
      style={{
        width: "100%",
        marginTop: 6,
        padding: "10px",
        borderRadius: "10px",
        border: "1px solid #dedee8",
        fontSize: 14,
        background: props.disabled ? "#f3f3f7" : "#fff",
      }}
    />
  </div>
);

const btnPrimary = {
  padding: "10px 22px",
  borderRadius: "999px",
  border: "none",
  background: "#ff8a24",
  color: "#fff",
  fontWeight: 600,
  cursor: "pointer",
};

const btnSecondary = {
  padding: "10px 22px",
  borderRadius: "999px",
  border: "1px solid #dedee8",
  background: "#fff",
  cursor: "pointer",
};

export default LeftSidebar;
