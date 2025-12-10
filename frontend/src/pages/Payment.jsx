import React, { useState } from "react";

const initialCart = [
  { id: 1, name: "Smoke Tenderloin Slice Croissant", qty: 1, price: 10.01 },
  { id: 2, name: "Sweet Chocolate Chocochips Croissant", qty: 2, price: 11.01 },
  { id: 3, name: "Sweet Granulated Sugar Croissant", qty: 1, price: 5.58 }
];

function Payment() {
  const [cart] = useState(initialCart);
  const [method, setMethod] = useState("card"); // "card" | "upi" | "cod"
  const [card, setCard] = useState({
    name: "",
    number: "",
    expiry: "",
    cvv: ""
  });
  const [upiId, setUpiId] = useState("");

  const subtotal = cart.reduce((s, item) => s + item.price * item.qty, 0);
  const discount = 5;
  const tax = 2.25;
  const total = (subtotal - discount + tax).toFixed(2);

  const handleCardChange = (e) => {
    const { name, value } = e.target;
    setCard((prev) => ({ ...prev, [name]: value }));
  };

  const handlePay = (e) => {
    e.preventDefault();
    if (method === "card") {
      console.log("Pay with CARD", card);
    } else if (method === "upi") {
      console.log("Pay with UPI", upiId);
    } else {
      console.log("Cash on Delivery selected");
    }
    alert(`Order placed with ${method.toUpperCase()} (dummy).`);
  };

  return (
    <div
      style={{
        minHeight: "100vh",
        background: "#f7f7fb",
        display: "flex",
        justifyContent: "center",
        alignItems: "center",
        padding: "24px"
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

          {/* method tabs */}
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
                    maxLength={19}
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
                      maxLength={4}
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
                <p style={{ fontSize: 12, color: "#9a9aad", marginTop: 4 }}>
                  You will receive a collect request on your UPI app. [Demo only]
                </p>
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
                Please keep exact change ready if possible.
              </div>
            )}

            <button
              type="submit"
              style={{
                width: "100%",
                padding: "12px 0",
                borderRadius: 999,
                border: "none",
                background: "#ff8a24",
                color: "#fff",
                fontWeight: 600,
                fontSize: 15,
                cursor: "pointer",
                marginTop: 4
              }}
            >
              {method === "cod" ? "Place Order (COD)" : `Pay $${total}`}
            </button>

            <p
              style={{
                marginTop: 10,
                fontSize: 12,
                color: "#9a9aad",
                textAlign: "center"
              }}
            >
              By confirming, you agree to the Terms & Conditions and Privacy
              Policy.
            </p>
          </form>
        </section>

        {/* RIGHT: order summary */}
        <aside
          style={{
            background: "#f7f7fb",
            borderRadius: 18,
            padding: 18,
            alignSelf: "stretch",
            display: "flex",
            flexDirection: "column"
          }}
        >
          <h3 style={{ marginBottom: 10 }}>Order Summary</h3>
          <div
            style={{
              flex: 1,
              overflowY: "auto",
              marginBottom: 14,
              paddingRight: 4
            }}
          >
            {cart.map((item) => (
              <div
                key={item.id}
                style={{
                  display: "flex",
                  justifyContent: "space-between",
                  alignItems: "center",
                  marginBottom: 10
                }}
              >
                <div>
                  <p style={{ fontSize: 14 }}>{item.name}</p>
                  <span
                    style={{ fontSize: 12, color: "#9a9aad" }}
                  >{`x${item.qty}`}</span>
                </div>
                <span style={{ fontWeight: 600 }}>
                  ${(item.price * item.qty).toFixed(2)}
                </span>
              </div>
            ))}
          </div>

          <div style={{ borderTop: "1px dashed #d4d4e0", paddingTop: 10 }}>
            <Row label="Subtotal" value={`$${subtotal.toFixed(2)}`} />
            <Row label="Discount" value={`- $${discount.toFixed(2)}`} />
            <Row label="Tax" value={`$${tax.toFixed(2)}`} />
            <div
              style={{
                display: "flex",
                justifyContent: "space-between",
                marginTop: 8,
                fontWeight: 700,
                fontSize: 15
              }}
            >
              <span>Total</span>
              <span>${total}</span>
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
