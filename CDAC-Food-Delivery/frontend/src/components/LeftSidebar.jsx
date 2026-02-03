import React, { useState, useEffect } from "react";
import axios from "axios";
import { toast } from 'react-toastify';
import { useNavigate, useLocation } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import { API_ENDPOINTS } from '../config/api';
import {
  FaHome,
  FaFire,
  FaHeart,
  FaUserEdit,
  FaSignOutAlt,
  FaLocationArrow,
  FaShoppingCart,
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

  useEffect(() => {
    const fetchProfile = async () => {
      const token = localStorage.getItem("token");
      if (!token) return;

      try {
        const response = await axios.get(API_ENDPOINTS.AUTH.PROFILE, {
          headers: { Authorization: `Bearer ${token}` },
        });
        const user = response.data;
        setProfile({
          name: user.name || "",
          phone: user.phone || "",
          address: user.address || "",
          pincode: user.pincode || "",
          location: user.location || "",
        });
      } catch (error) {
        console.error("Error fetching profile", error);
      }
    };
    fetchProfile();
  }, []);

  const handleSave = async () => {
    const token = localStorage.getItem("token"); // Get latest token
    if (!token) {
      toast.error("You are not logged in!");
      return;
    }

    try {
      const response = await axios.put(
        API_ENDPOINTS.AUTH.PROFILE,
        profile,
        {
          headers: { Authorization: `Bearer ${token}` },
        }
      );
      if (response.status === 200) {
        toast.success("Profile updated successfully!");
        onClose();
      }
    } catch (error) {
      console.error("Error updating profile", error);
      const errMsg = error.response?.data?.message || error.response?.data?.error || error.message || "Failed to update profile";
      toast.error(`Update failed: ${errMsg}`);
    }
  };


  const useCurrentLocation = () => {
    if (!navigator.geolocation) {
      toast.error("Geolocation not supported by your browser");
      return;
    }

    setLocating(true);

    navigator.geolocation.getCurrentPosition(
      async (pos) => {
        const { latitude, longitude } = pos.coords;

        try {
          const response = await axios.get(
            `https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${latitude}&lon=${longitude}`,
            {
              headers: {
                'Accept-Language': 'en'
              }
            }
          );

          if (response.data) {
            const addressData = response.data.address;
            const fullAddress = response.data.display_name;
            const pincode = addressData.postcode || "";

            setProfile((p) => ({
              ...p,
              address: fullAddress,
              pincode: pincode,
              location: `Lat: ${latitude.toFixed(4)}, Lng: ${longitude.toFixed(4)}`,
            }));

            toast.success("Location updated!");
          }
        } catch (error) {
          console.error("Error fetching address:", error);
          toast.error("Failed to fetch address details");

          setProfile((p) => ({
            ...p,
            location: `Near you (Lat ${latitude.toFixed(2)}, Lng ${longitude.toFixed(2)})`,
          }));
        } finally {
          setLocating(false);
        }
      },
      (error) => {
        let msg = "Unable to fetch location";
        if (error.code === error.PERMISSION_DENIED) msg = "Please enable location access";
        if (error.code === error.TIMEOUT) msg = "Location request timed out";
        toast.error(msg);
        setLocating(false);
      },
      {
        enableHighAccuracy: true,
        timeout: 15000,
        maximumAge: 0
      }
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
          zIndex: 1100,
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
          zIndex: 1200,
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
                width: "100%",
                height: "42px",
                padding: "0 14px",
                borderRadius: "10px",
                border: "1px solid #dedee8",
                background: "#fff6ec",
                color: locating ? "#f2b27a" : "#ff8a24", // 🔥 ORANGE TEXT
                fontWeight: 600,
                cursor: locating ? "not-allowed" : "pointer",
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                gap: "8px",
                transition: "all 0.2s ease",
              }}
              onMouseEnter={(e) => {
                if (!locating) {
                  e.currentTarget.style.background = "#ffead1";
                  e.currentTarget.style.borderColor = "#ff8a24";
                }
              }}
              onMouseLeave={(e) => {
                if (!locating) {
                  e.currentTarget.style.background = "#fff6ec";
                  e.currentTarget.style.borderColor = "#dedee8";
                }
              }}
            >
              <FaLocationArrow className={locating ? "fa-spin" : ""} />
              {locating ? "Locating..." : "Use Current Location"}
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
            zIndex: 1400,
          }}
        >
          <button onClick={onClose} style={btnSecondary} className="btn-cancel">
            Cancel
          </button>
          <button
            onClick={handleSave}
            style={btnPrimary}
            className="btn-save"
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
  const navigate = useNavigate();
  const location = useLocation();
  const { logout } = useAuth();
  const [showEditProfile, setShowEditProfile] = useState(false);

  const items = [
    { icon: <FaHome />, title: "Home", path: "/home" },
    { icon: <FaFire />, title: "Trending", path: "/home/trending" },
    { icon: <FaHeart />, title: "Wishlist", path: "/home/wishlist" },
    { icon: <FaShoppingCart />, title: "Cart", path: "/home/cart" },
  ];

  const bottomItems = [
    { icon: <FaUserEdit />, title: "Edit Profile" },
    { icon: <FaSignOutAlt />, title: "Logout" },
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
                active={location.pathname === item.path}
                onClick={() => navigate(item.path)}
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
              active={false}
              onClick={() => {
                if (item.title === "Logout") {
                  logout();
                } else {
                  setShowEditProfile(true);
                }
              }}
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
        .btn-cancel:hover {
          background: #f8f9fa !important;
          border-color: #d0d0d0 !important;
          color: #3d4152 !important;
        }
        .btn-save:hover {
          background: #e67a1d !important;
          transform: scale(1.02);
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
  border: "1px solid #e0e0e0",
  background: "transparent",
  color: "#686b78",
  fontWeight: 600,
  cursor: "pointer",
  transition: "all 0.2s ease",
};

export default LeftSidebar;