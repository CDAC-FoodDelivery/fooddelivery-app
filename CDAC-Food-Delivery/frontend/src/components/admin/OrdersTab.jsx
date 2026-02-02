import React from "react";

const OrdersTab = ({ orders, handleUpdateOrderStatus }) => {
    return (
        <div className="grid">
            {orders.length === 0 ? (
                <p>No orders found</p>
            ) : (
                orders.map((o) => {
                    const deliveryAddr = o.deliveryAddress || o.DeliveryAddress || "N/A";
                    const customerInfo = o.customerName || o.CustomerName || o.userEmail || o.UserEmail || "Unknown";
                    const orderItems = o.items || o.Items || [];
                    const orderAmount = o.totalAmount || o.TotalAmount || 0;
                    const orderStatus = o.status || o.Status || "Placed";

                    return (
                        <div className="card" key={o.id || o.Id}>
                            <h3>Order #{o.id || o.Id}</h3>
                            <p><strong>Customer:</strong> {customerInfo}</p>
                            <p><strong>Amount:</strong> ₹{orderAmount}</p>
                            <p><strong>Address:</strong> {deliveryAddr}</p>

                            {orderItems && orderItems.length > 0 && (
                                <div className="order-items-list" style={{ marginTop: "10px", fontSize: "0.9em", color: "#555" }}>
                                    <strong>Items:</strong>
                                    <ul style={{ margin: "5px 0", paddingLeft: "20px" }}>
                                        {orderItems.map((item, idx) => (
                                            <li key={idx}>
                                                {item.name || item.Name} (x{item.quantity || item.Quantity})
                                            </li>
                                        ))}
                                    </ul>
                                </div>
                            )}

                            <span className="badge">{orderStatus}</span>
                            <div className="card-actions">
                                <button
                                    className="update"
                                    onClick={() => handleUpdateOrderStatus(o.id || o.Id, orderStatus)}
                                    disabled={orderStatus === "Delivered"}
                                >
                                    Update Status
                                </button>
                            </div>
                        </div>
                    );
                })
            )}
        </div>
    );
};

export default OrdersTab;
