import React, { useState } from "react";
import { Link } from 'react-router-dom';

const initialOrders = [
  {
    name: "Smoke Tenderloin Slice Croissant",
    price: 10.01,
    quantity: 1,
    image:
      "https://images.unsplash.com/photo-1519861531864-07a5a0a1a389?auto=format&fit=crop&w=64&q=80",
  },
  {
    name: "Sweet Chocolate Chocochips Croissant",
    price: 22.02,
    quantity: 2,
    image:
      "https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=64&q=80",
  },
  {
    name: "Sweet Granulated Sugar Croissant",
    price: 5.58,
    quantity: 1,
    image:
      "https://images.unsplash.com/photo-1519861531864-07a5a0a1a389?auto=format&fit=crop&w=64&q=80",
  },
];

const discount = 5.0;
const taxRate = 2.25; // flat value here, for demo

const RightSidebar = () => {
  const [orders, setOrders] = useState(initialOrders);

  const updateQuantity = (index, amount) => {
    setOrders((prev) =>
      prev.map((item, idx) =>
        idx === index
          ? { ...item, quantity: Math.max(item.quantity + amount, 1) }
          : item
      )
    );
  };

  const subtotal = orders.reduce(
    (sum, item) => sum + item.price * item.quantity,
    0
  );
  const total = subtotal - discount + taxRate;

  return (
    <aside
      style={{
        position: "fixed",        // Make sidebar sticky
        top: 0,
        right: 0,
        width: 350,
        height: "100vh",
        background: "#fff",
        boxShadow: "-2px 0 5px rgba(0,0,0,0.05)",
        padding: 28,
        display: "flex",
        flexDirection: "column",
        justifyContent: "space-between",
        zIndex: 99, 
      }}
    >
      <div>
        <h2
          style={{
            fontSize: 22,
            fontWeight: 600,
            margin: 0,
            marginBottom: 20,
          }}
        >
          Current Order
        </h2>
        <div
          style={{
            flex: "1 1 auto",
            overflowY: "auto",
            marginBottom: 30,
            maxHeight: 340,
          }}
        >
          {orders.map((item, idx) => (
            <div
              key={idx}
              style={{
                display: "flex",
                alignItems: "center",
                marginBottom: 20,
                paddingBottom: 12,
                borderBottom: "1px solid #f0f0f0",
              }}
            >
              <img
                src={item.image}
                alt={item.name}
                style={{
                  width: 48,
                  height: 48,
                  borderRadius: 12,
                  objectFit: "cover",
                  marginRight: 16,
                }}
              />
              <div style={{ flexGrow: 1 }}>
                <span
                  style={{
                    fontSize: 15,
                    fontWeight: 500,
                    display: "block",
                    marginBottom: 2,
                  }}
                >
                  {item.name}
                </span>
                <span
                  style={{ fontWeight: 600, color: "#F15928", fontSize: 14 }}
                >
                  ${item.price.toFixed(2)}
                </span>
              </div>
              <div
                style={{
                  marginLeft: 20,
                  fontWeight: 600,
                  fontSize: 15,
                  background: "#f8f4ef",
                  borderRadius: 6,
                  padding: "3px 8px",
                  display: "flex",
                  alignItems: "center",
                  gap: 8,
                }}
              >
                <button
                  style={{
                    background: "#F15928",
                    color: "#fff",
                    border: "none",
                    borderRadius: 4,
                    width: 24,
                    height: 28,
                    fontSize: 17,
                    cursor: "pointer",
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                  }}
                  onClick={() => updateQuantity(idx, -1)}
                  aria-label="Decrease"
                  onMouseOver={(e) =>
                    (e.currentTarget.style.background = "#d6521f")
                  }
                  onMouseOut={(e) =>
                    (e.currentTarget.style.background = "#F15928")
                  }
                >
                  -
                </button>
                <span style={{ margin: "0 4px" }}>{item.quantity}</span>
                <button
                  style={{
                    background: "#F15928",
                    color: "#fff",
                    border: "none",
                    borderRadius: 4,
                    width: 24,
                    height: 28,
                    fontSize: 17,
                    cursor: "pointer",
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                  }}
                  onClick={() => updateQuantity(idx, 1)}
                  aria-label="Increase"
                  onMouseOver={(e) =>
                    (e.currentTarget.style.background = "#d6521f")
                  }
                  onMouseOut={(e) =>
                    (e.currentTarget.style.background = "#F15928")
                  }
                >
                  +
                </button>
              </div>
            </div>
          ))}
        </div>
        <div
          style={{
            background: "#fafafa",
            borderRadius: 12,
            padding: "20px 18px",
            marginBottom: 24,
            fontSize: 15,
          }}
        >
          <div
            style={{
              display: "flex",
              justifyContent: "space-between",
              marginBottom: 10,
            }}
          >
            <span>Subtotal</span>
            <span>${subtotal.toFixed(2)}</span>
          </div>
          <div
            style={{
              display: "flex",
              justifyContent: "space-between",
              marginBottom: 10,
            }}
          >
            <span>Discount sales</span>
            <span style={{ color: "#2db97f" }}>- ${discount.toFixed(2)}</span>
          </div>
          <div style={{ display: "flex", justifyContent: "space-between" }}>
            <span>Total sales tax</span>
            <span>${taxRate.toFixed(2)}</span>
          </div>
        </div>
        <div
          style={{
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
            marginBottom: 24,
          }}
        >
          <span style={{ fontSize: 19, fontWeight: 600 }}>Total</span>
          <span style={{ fontSize: 21, fontWeight: 700, color: "#F15928" }}>
            ${total.toFixed(2)}
          </span>
        </div>
      </div>
      <Link
      to="/payment"   // route of your PaymentPage
      style={{
        display: "inline-block",
        textAlign: "center",
        textDecoration: "none",
        background: "#F15928",
        border: "none",
        color: "#fff",
        borderRadius: 11,
        padding: "15px 0",
        width: "100%",
        fontSize: 17,
        fontWeight: 600,
        cursor: "pointer",
      }}
      onMouseOver={(e) => (e.currentTarget.style.background = "#d6521f")}
      onMouseOut={(e) => (e.currentTarget.style.background = "#F15928")}
    >
      Continue to Payment
    </Link>
    </aside>
  );
};

export default RightSidebar;
