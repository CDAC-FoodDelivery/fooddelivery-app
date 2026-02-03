import React, { useState, useEffect } from "react";
import { useCart } from "../context/CartContext";
import { useAuth } from "../context/AuthContext";
import axios from "axios";
import { toast } from "react-toastify";
import { useNavigate } from "react-router-dom";
import { API_ENDPOINTS } from '../config/api';

function Payment() {
  const { cartItems, totalPrice, clearCart } = useCart();
  const { user } = useAuth();
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  const [method, setMethod] = useState("card");

  const RAZORPAY_KEY_ID = "rzp_test_1DP5mmOlF5G5ag";
  const [card, setCard] = useState({
    name: "",
    number: "",
    expiry: "",
    cvv: ""
  });
  const [upiId, setUpiId] = useState("");
  const [deliveryAddress, setDeliveryAddress] = useState("");

  useEffect(() => {
    if (user?.address) {
      setDeliveryAddress(user.address);
    }
  }, [user]);

  const deliveryFee = totalPrice > 500 ? 0 : 29;
  const platformFee = 10;
  const finalTotal = totalPrice + deliveryFee + platformFee;

  const handleCardChange = (e) => {
    const { name, value } = e.target;
    setCard((prev) => ({ ...prev, [name]: value }));
  };

  const handleRazorpayPayment = async () => {
    try {
      const { data } = await axios.post(API_ENDPOINTS.PAYMENTS.CREATE, {
        amount: finalTotal,
        currency: "INR"
      });

      const options = {
        key: RAZORPAY_KEY_ID,
        amount: data.amount * 100,
        currency: data.currency,
        name: "Food Delivery App",
        description: "Order Payment",
        ...(data.orderId.startsWith("order_mock") ? {} : { order_id: data.orderId }),
        handler: async (response) => {
          try {
            await axios.post(API_ENDPOINTS.PAYMENTS.VERIFY, {
              razorpayOrderId: response.razorpay_order_id,
              razorpayPaymentId: response.razorpay_payment_id,
              razorpaySignature: response.razorpay_signature,
              email: user.email,
              amount: finalTotal
            });
            await finalizeOrder();
          } catch (e) {
            toast.error("Verification failed");
          }
        },
        prefill: {
          name: user.name,
          email: user.email,
        },
        theme: {
          color: "#ff8a24",
        },
      };

      if (RAZORPAY_KEY_ID === "rzp_test_your_key_id") {
        const confirmMock = window.confirm("Razorpay Keys are not set. Simulate successful payment?");
        if (confirmMock) {

          if (method === "card") {
            const cleanNum = card.number.replace(/\s/g, '');
            if (cleanNum.length < 16) {
              toast.error("Simulated Validation Error: Card number must be 16 digits.");
              setLoading(false);
              return;
            }
          }

          try {
            await axios.post(API_ENDPOINTS.PAYMENTS.VERIFY, {
              razorpayOrderId: data.orderId,
              razorpayPaymentId: "mock_pay_" + Date.now(),
              razorpaySignature: "mock_sig_" + Date.now(),
              amount: finalTotal,
              email: user.email
            });

            await finalizeOrder();
          } catch (err) {
            console.error("Mock Verification Failed", err);
            toast.error("Payment verification failed on backend during simulation.");
          }
          return;
        }
      }

      const rzp1 = new window.Razorpay(options);
      rzp1.open();
    } catch (error) {
      console.error("Razorpay error", error);
      toast.error("Failed to initialize Razorpay checkout. Check if backend is running.");
    } finally {
      setLoading(false);
    }
  };

  const finalizeOrder = async () => {
    if (!deliveryAddress || deliveryAddress.trim() === "") {
      toast.error("Please enter a delivery address");
      setLoading(false);
      return;
    }

    try {
      const orderData = {
        userEmail: user.email,
        totalAmount: finalTotal,
        paymentMethod: method.toUpperCase(),
        deliveryAddress: deliveryAddress.trim(),
        items: cartItems.map(item => ({
          name: item.name,
          price: item.price,
          quantity: item.quantity
        }))
      };

      const response = await axios.post(API_ENDPOINTS.ORDERS.BASE, orderData);

      if (response.status === 200) {
        toast.success(`Order placed successfully! ID: ${response.data.id} 🍛`);
        clearCart();
        navigate("/home");
      }
    } catch (error) {
      console.error("Finalizing order failed", error);
      toast.error(`Payment successful but failed to save order: ${error.message}`);
    }
  };

  const handlePay = async (e) => {
    e.preventDefault();
    if (!user) {
      toast.error("Please login to place an order");
      return;
    }

    setLoading(true);

    if (method === "cod") {
      await finalizeOrder();
      setLoading(false);
    } else {
      await handleRazorpayPayment();
    }
  };

  useEffect(() => {
    document.body.style.overflow = "hidden";
    return () => {
      document.body.style.overflow = "auto";
    };
  }, []);

  return (
    <div
      style={{
        minHeight: "100vh",
        background: "#f7f7fb",
        display: "flex",
        justifyContent: "center",
        alignItems: "flex-start",
        padding: "70px 24px 24px 24px"
      }}
    >
      <div
        style={{
          maxWidth: "1040px",
          width: "100%",
          background: "#fff",
          borderRadius: "20px",
          boxShadow: "0 16px 40px rgba(15,23,42,0.12)",
          display: "grid",
          gridTemplateColumns: "minmax(0, 3fr) minmax(280px, 2fr)",
          gap: "28px",
          padding: "28px"
        }}
      >
        {/* LEFT: payment form */}
        <section>
          <h2 style={{ marginBottom: 6 }}>Payment</h2>
          <p style={{ color: "#9a9aad", fontSize: 14, marginBottom: 20 }}>
            Choose a payment method and confirm your order.
          </p>

          {/* Delivery Address Section */}
          <div style={{ marginBottom: 20 }}>
            <label style={labelStyle}>Delivery Address *</label>
            <textarea
              style={{ ...inputStyle, minHeight: "80px", resize: "vertical" }}
              value={deliveryAddress}
              onChange={(e) => setDeliveryAddress(e.target.value)}
              placeholder="Enter your complete delivery address"
              required
            />
          </div>

          <div
            style={{
              display: "inline-flex",
              padding: 4,
              borderRadius: 999,
              background: "#f3f3f7",
              marginBottom: 20
            }}
          >
            <button
              onClick={() => setMethod("card")}
              style={{
                ...tabBase,
                background: method === "card" ? "#ff8a24" : "transparent",
                color: method === "card" ? "#fff" : "#555"
              }}
            >
              Card
            </button>
            <button
              onClick={() => setMethod("upi")}
              style={{
                ...tabBase,
                background: method === "upi" ? "#ff8a24" : "transparent",
                color: method === "upi" ? "#fff" : "#555"
              }}
            >
              UPI
            </button>
            <button
              onClick={() => setMethod("cod")}
              style={{
                ...tabBase,
                background: method === "cod" ? "#ff8a24" : "transparent",
                color: method === "cod" ? "#fff" : "#555"
              }}
            >
              Cash on Delivery
            </button>
          </div>

          <form onSubmit={handlePay}>
            {method === "card" && (
              <>
                <div style={{ marginBottom: 14 }}>
                  <label style={labelStyle}>Cardholder Name</label>
                  <input
                    style={inputStyle}
                    name="name"
                    value={card.name}
                    onChange={handleCardChange}
                    placeholder="Name on card"
                    required
                  />
                </div>

                <div style={{ marginBottom: 14 }}>
                  <label style={labelStyle}>Card Number</label>
                  <input
                    style={inputStyle}
                    name="number"
                    value={card.number}
                    onChange={handleCardChange}
                    placeholder="1234 5678 9012 3456"
                    required
                  />
                </div>

                <div
                  style={{
                    display: "grid",
                    gridTemplateColumns: "1.5fr 1fr",
                    gap: 12,
                    marginBottom: 14
                  }}
                >
                  <div>
                    <label style={labelStyle}>Expiry</label>
                    <input
                      style={inputStyle}
                      name="expiry"
                      value={card.expiry}
                      onChange={handleCardChange}
                      placeholder="MM/YY"
                      required
                    />
                  </div>
                  <div>
                    <label style={labelStyle}>CVV</label>
                    <input
                      style={inputStyle}
                      name="cvv"
                      value={card.cvv}
                      onChange={handleCardChange}
                      placeholder="123"
                      required
                    />
                  </div>
                </div>
              </>
            )}

            {method === "upi" && (
              <div style={{ marginBottom: 18 }}>
                <label style={labelStyle}>UPI ID</label>
                <input
                  style={inputStyle}
                  value={upiId}
                  onChange={(e) => setUpiId(e.target.value)}
                  placeholder="yourname@upi"
                  required
                />
              </div>
            )}

            {method === "cod" && (
              <div
                style={{
                  marginBottom: 18,
                  padding: 12,
                  borderRadius: 10,
                  background: "#fff7e6",
                  border: "1px solid #ffe0a3",
                  fontSize: 13,
                  color: "#8a5800"
                }}
              >
                Pay in cash when the order is delivered.
              </div>
            )}

            <button
              type="submit"
              disabled={loading}
              style={{
                width: "100%",
                padding: "16px 0",
                borderRadius: "12px",
                border: "none",
                background: loading ? "#ccc" : "#ff8a24",
                color: "#fff",
                fontWeight: 700,
                fontSize: 16,
                cursor: loading ? "not-allowed" : "pointer",
                marginTop: 10,
                boxShadow: loading ? "none" : "0 4px 15px rgba(255, 138, 36, 0.3)",
                transition: "all 0.3s ease"
              }}
            >
              {loading ? "Processing..." : (method === "cod" ? "Place Order (COD)" : `Pay ₹${finalTotal}`)}
            </button>
          </form>
        </section>

        {/* RIGHT: order summary */}
        <aside
          style={{
            background: "#f7f7fb",
            borderRadius: 18,
            padding: 18,
            display: "flex",
            flexDirection: "column"
          }}
        >
          <h3 style={{ marginBottom: 10 }}>Order Summary</h3>

          <div style={{ flex: 1, overflowY: "auto", maxHeight: "300px" }}>
            {cartItems.map((item, idx) => (
              <div
                key={idx}
                style={{
                  display: "flex",
                  justifyContent: "space-between",
                  marginBottom: 10,
                  borderBottom: "1px solid #eee",
                  paddingBottom: 8
                }}
              >
                <div>
                  <p style={{ fontSize: 13, margin: 0, fontWeight: 500 }}>{item.name}</p>
                  <span style={{ fontSize: 12, color: "#9a9aad" }}>
                    {item.quantity} x ₹{item.price}
                  </span>
                </div>
                <span style={{ fontWeight: 600, fontSize: 14 }}>
                  ₹{item.price * item.quantity}
                </span>
              </div>
            ))}
          </div>

          <div style={{ borderTop: "1px dashed #d4d4e0", paddingTop: 10 }}>
            <Row label="Item Total" value={`₹${totalPrice}`} />
            <Row label="Delivery Fee" value={deliveryFee === 0 ? "FREE" : `₹${deliveryFee}`} />
            <Row label="Platform Fee" value={`₹${platformFee}`} />
            <div
              style={{
                display: "flex",
                justifyContent: "space-between",
                marginTop: 12,
                fontSize: 18,
                fontWeight: 700,
                color: "#3d4152"
              }}
            >
              <span>Total</span>
              <span>₹{finalTotal}</span>
            </div>
          </div>
        </aside>
      </div>
    </div>
  );
}

function Row({ label, value }) {
  return (
    <div
      style={{
        display: "flex",
        justifyContent: "space-between",
        fontSize: 13,
        marginBottom: 4
      }}
    >
      <span>{label}</span>
      <span>{value}</span>
    </div>
  );
}

const tabBase = {
  border: "none",
  borderRadius: 999,
  padding: "8px 18px",
  fontSize: 14,
  cursor: "pointer"
};

const labelStyle = {
  display: "block",
  fontSize: 13,
  marginBottom: 4,
  color: "#555"
};

const inputStyle = {
  width: "100%",
  borderRadius: 10,
  border: "1px solid #dedee8",
  padding: "9px 10px",
  fontSize: 14,
  outline: "none",
  background: "#fff"
};

export default Payment;
