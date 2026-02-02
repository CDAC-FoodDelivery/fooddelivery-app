import React from "react";
import { useCart } from "../context/CartContext";
import { useNavigate } from "react-router-dom";
import { FaTrash, FaMinus, FaPlus, FaShoppingCart } from "react-icons/fa";
import "./ProductsPage.css";

const CartPage = () => {
  const { cartItems, totalPrice, updateQuantity, removeFromCart } = useCart();
  const navigate = useNavigate();

  if (cartItems.length === 0) {
    return (
      <div className="products-page" style={{
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        minHeight: "60vh"
      }}>
        <div style={{ fontSize: "60px", marginBottom: "20px" }}>🛒</div>
        <h3 style={{ color: "#3d4152", marginBottom: "10px" }}>Your cart is empty</h3>
        <p style={{ color: "#686b78", marginBottom: "24px" }}>
          Looks like you haven't added anything to your cart yet.
        </p>
        <button
          onClick={() => navigate("/home")}
          style={{
            padding: "12px 30px",
            borderRadius: "8px",
            border: "none",
            background: "#F15928",
            color: "white",
            fontWeight: "600",
            cursor: "pointer"
          }}
        >
          Order Something Now
        </button>
      </div>
    );
  }

  const deliveryFee = totalPrice > 500 ? 0 : 29;
  const platformFee = 10;
  const finalTotal = totalPrice + deliveryFee + platformFee;

  return (
    <div className="products-page">
      <div style={{ marginBottom: "30px", borderBottom: "1px solid #f0f0f0", paddingBottom: "10px" }}>
        <h2 style={{ fontSize: "24px", fontWeight: "700", color: "#3d4152", display: "flex", alignItems: "center", gap: "12px" }}>
          <FaShoppingCart size={24} color="#F15928" />
          My Cart
        </h2>
        <p style={{ color: "#686b78", fontSize: "14px" }}>
          {cartItems.length} item{cartItems.length !== 1 ? 's' : ''} in your cart
        </p>

        {totalPrice > 500 ? (
          <div style={{
            background: "#e7f9ed",
            color: "#1ca345",
            padding: "8px 16px",
            borderRadius: "8px",
            fontSize: "14px",
            fontWeight: "600",
            display: "inline-block",
            marginTop: "10px"
          }}>
            Woohoo! You've unlocked FREE delivery! 🎉
          </div>
        ) : (
          <div style={{
            color: "#F15928",
            fontSize: "13px",
            fontWeight: "500",
            marginTop: "8px"
          }}>
            Add ₹{500 - totalPrice} more for free delivery
          </div>
        )}
      </div>

      <div style={{ display: "grid", gridTemplateColumns: "1fr 350px", gap: "40px" }}>
        {/* ITEMS LIST */}
        <div style={{ display: "flex", flexDirection: "column", gap: "20px" }}>
          {cartItems.map((item) => (
            <div key={item.name} style={{
              display: "grid",
              gridTemplateColumns: "100px 1fr auto",
              gap: "20px",
              padding: "20px",
              background: "white",
              borderRadius: "16px",
              boxShadow: "0 4px 12px rgba(0,0,0,0.05)",
              alignItems: "center"
            }}>
              <img
                src={item.image}
                alt={item.name}
                style={{ width: "100px", height: "80px", borderRadius: "12px", objectFit: "cover" }}
              />
              <div>
                <h4 style={{ margin: 0, fontSize: "18px", color: "#3d4152" }}>{item.name}</h4>
                <p style={{ margin: "4px 0 0 0", color: "#686b78", fontSize: "14px" }}>₹{item.price}</p>
              </div>
              <div style={{ display: "flex", alignItems: "center", gap: "20px" }}>
                <div style={{
                  display: "flex",
                  alignItems: "center",
                  border: "1px solid #e0e0e0",
                  borderRadius: "8px",
                  overflow: "hidden"
                }}>
                  <button
                    onClick={() => updateQuantity(item.name, Math.max(0, item.quantity - 1))}
                    style={{ padding: "8px 12px", border: "none", background: "#f8f9fa", cursor: "pointer", color: "#F15928" }}
                  >
                    <FaMinus size={14} fontWeight="bold" />
                  </button>
                  <span style={{ padding: "0 15px", fontWeight: "700", color: "#3d4152", minWidth: "40px", textAlign: "center" }}>{item.quantity}</span>
                  <button
                    onClick={() => updateQuantity(item.name, item.quantity + 1)}
                    style={{ padding: "8px 12px", border: "none", background: "#f8f9fa", cursor: "pointer", color: "#F15928" }}
                  >
                    <FaPlus size={14} fontWeight="bold" />
                  </button>
                </div>
                <button
                  onClick={() => removeFromCart(item.name)}
                  style={{ border: "none", background: "none", color: "#ff4d4d", cursor: "pointer" }}
                >
                  <FaTrash />
                </button>
                <span style={{ fontWeight: "700", width: "80px", textAlign: "right", color: "#3d4152" }}>
                  ₹{item.price * item.quantity}
                </span>
              </div>
            </div>
          ))}
        </div>

        {/* SUMMARY BLOCK */}
        <div style={{ position: "sticky", top: "100px", height: "fit-content" }}>
          <div style={{
            background: "white",
            borderRadius: "20px",
            padding: "24px",
            boxShadow: "0 8px 24px rgba(0,0,0,0.08)"
          }}>
            <h3 style={{ margin: "0 0 20px 0", fontSize: "20px" }}>Bill Details</h3>

            <div style={{ display: "flex", justifyContent: "space-between", marginBottom: "12px", color: "#686b78" }}>
              <span>Item Total</span>
              <span>₹{totalPrice}</span>
            </div>
            <div style={{ display: "flex", justifyContent: "space-between", marginBottom: "12px", color: "#686b78" }}>
              <span>Delivery Partner Fee</span>
              <div style={{ display: "flex", gap: "8px" }}>
                {deliveryFee === 0 && <span style={{ textDecoration: "line-through", color: "#b1b4be" }}>₹29</span>}
                <span style={{ color: deliveryFee === 0 ? "#1ca345" : "#686b78", fontWeight: deliveryFee === 0 ? "600" : "400" }}>
                  {deliveryFee === 0 ? "FREE" : `₹${deliveryFee}`}
                </span>
              </div>
            </div>
            <div style={{ display: "flex", justifyContent: "space-between", marginBottom: "20px", color: "#686b78" }}>
              <span>Platform Fee</span>
              <span>₹{platformFee}</span>
            </div>

            <hr style={{ border: "none", borderTop: "1px dashed #e0e0e0", margin: "20px 0" }} />

            <div style={{ display: "flex", justifyContent: "space-between", marginBottom: "24px", fontSize: "18px", fontWeight: "700" }}>
              <span>To Pay</span>
              <span style={{ color: "#3d4152" }}>₹{finalTotal}</span>
            </div>

            <button
              onClick={() => navigate("/home/payment")}
              style={{
                width: "100%",
                padding: "16px",
                borderRadius: "12px",
                border: "none",
                background: "#F15928",
                color: "white",
                fontWeight: "700",
                fontSize: "16px",
                cursor: "pointer",
                boxShadow: "0 4px 15px rgba(241, 89, 40, 0.3)",
                transition: "all 0.2s ease"
              }}
              onMouseEnter={(e) => e.currentTarget.style.transform = "scale(1.02)"}
              onMouseLeave={(e) => e.currentTarget.style.transform = "scale(1)"}
            >
              PROCEED TO PAY
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default CartPage;
