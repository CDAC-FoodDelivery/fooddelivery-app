import React, { useState, useEffect } from "react";
import "./AdminDashboard.css";
import axios from "axios";
import { Modal, Button, Form } from "react-bootstrap";
import { toast } from "react-toastify";

function AdminDashboard() {
  const [activeTab, setActiveTab] = useState("orders");

  const [orders, setOrders] = useState([]);
  const [restaurants, setRestaurants] = useState([]);
  const [users, setUsers] = useState([]);
  const [insights, setInsights] = useState({ orders: 0, restaurants: 0, users: 0, revenue: 0 });

  // Modal State
  const [showModal, setShowModal] = useState(false);
  const [formData, setFormData] = useState({
    name: "",
    city: "",
    email: "",
    phone: "",
    cuisine: "",
    password: ""
  });

  const API_URL = "http://localhost:5102/api/admin";

  useEffect(() => {
    fetchData();
  }, [activeTab]);

  const fetchData = async () => {
    try {
      if (activeTab === "orders") {
        const res = await axios.get(`${API_URL}/orders`);
        setOrders(res.data);
      } else if (activeTab === "restaurants") {
        const res = await axios.get(`${API_URL}/restaurants`);
        setRestaurants(res.data);
      } else if (activeTab === "users") {
        const res = await axios.get(`${API_URL}/users`);
        setUsers(res.data);
      } else if (activeTab === "insights") {
        const res = await axios.get(`${API_URL}/insights`);
        setInsights(res.data);
      }
    } catch (error) {
      console.error("Error fetching data", error);
      toast.error("Failed to fetch data.");
    }
  };

  // Handle Input Change for Form
  const handleInputChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  // Submit New Restaurant
  const handleSubmitRestaurant = async (e) => {
    e.preventDefault();
    try {
      const res = await axios.post(`${API_URL}/restaurants`, formData);
      setRestaurants([...restaurants, res.data]);
      toast.success("Restaurant and User added! Credentials sent to email.");
      setShowModal(false);
      setFormData({ name: "", city: "", email: "", phone: "", cuisine: "", password: "" }); // Reset form
    } catch (error) {
      console.error("Error adding restaurant", error);
      toast.error("Failed to add restaurant: " + (error.response?.data || error.message));
    }
  };

  const handleDeleteRestaurant = async (id) => {
    if (!window.confirm("Are you sure you want to delete this restaurant?")) return;
    try {
      await axios.delete(`${API_URL}/restaurants/${id}`);
      setRestaurants(restaurants.filter((r) => r.id !== id));
      toast.success("Restaurant deleted successfully.");
    } catch (error) {
      console.error("Error deleting restaurant", error);
      toast.error("Failed to delete restaurant.");
    }
  };

  const handleUpdateRestaurant = async (id) => {
    const restaurant = restaurants.find(r => r.id === id);
    if (!restaurant) return;

    const updated = { ...restaurant, status: restaurant.status === "Open" ? "Closed" : "Open" };
    try {
      await axios.put(`${API_URL}/restaurants/${id}`, updated);
      setRestaurants(restaurants.map(r => r.id === id ? updated : r));
      toast.success(`Restaurant is now ${updated.status}`);
    } catch (error) {
      console.error("Error updating restaurant", error);
      toast.error("Failed to update status.");
    }
  };

  return (
    <div className="admin-page">
      <header className="admin-header">
        <h1>Admin Dashboard</h1>
        <p>Food Delivery Management</p>
      </header>

      <nav className="tabs">
        <button className={activeTab === "orders" ? "active" : ""} onClick={() => setActiveTab("orders")}>
          Orders
        </button>
        <button className={activeTab === "restaurants" ? "active" : ""} onClick={() => setActiveTab("restaurants")}>
          Restaurants
        </button>
        <button className={activeTab === "users" ? "active" : ""} onClick={() => setActiveTab("users")}>
          Users
        </button>
        <button className={activeTab === "insights" ? "active" : ""} onClick={() => setActiveTab("insights")}>
          Insights
        </button>
      </nav>

      <section className="content">
        {activeTab === "orders" && (
          <div className="grid">
            {orders.map(o => (
              <div className="card" key={o.id}>
                <h3>Order #{o.id}</h3>
                <p>Customer: {o.name}</p>
                <span className="badge">{o.status}</span>
              </div>
            ))}
          </div>
        )}

        {activeTab === "restaurants" && (
          <>
            <div className="section-header">
              <h2>Restaurants</h2>
              <button className="add-btn" onClick={() => setShowModal(true)}>＋ Add Restaurant</button>
            </div>

            <div className="grid">
              {restaurants.map(r => (
                <div className="card restaurant-card" key={r.id}>
                  <div>
                    <h3>{r.name}</h3>
                    <p>{r.city}</p>
                    <p className="text-muted small">{r.cuisine}</p>
                    <span className="badge">{r.status}</span>
                  </div>

                  <div className="card-actions">
                    <button className="update" onClick={() => handleUpdateRestaurant(r.id)}>Toggle Status</button>
                    <button className="delete" onClick={() => handleDeleteRestaurant(r.id)}>Delete</button>
                  </div>
                </div>
              ))}
            </div>
          </>
        )}

        {activeTab === "users" && (
          <div className="grid">
            {users.map(u => (
              <div className="card" key={u.id}>
                <h3>{u.name}</h3>
                <p>Role: {u.role}</p>
                <p>{u.email}</p>
              </div>
            ))}
          </div>
        )}

        {activeTab === "insights" && (
          <div className="grid">
            <div className="card insight">📦 {insights.orders || 0} Orders</div>
            <div className="card insight">🍽 {insights.restaurants || 0} Restaurants</div>
            <div className="card insight">👥 {insights.users || 0} Users</div>
            <div className="card insight">💰 ₹{insights.revenue || 0} Revenue</div>
          </div>
        )}
      </section>

      {/* Add Restaurant Modal */}
      <Modal show={showModal} onHide={() => setShowModal(false)} centered>
        <Modal.Header closeButton>
          <Modal.Title>Add New Restaurant</Modal.Title>
        </Modal.Header>
        <Modal.Body>
          <Form onSubmit={handleSubmitRestaurant}>
            <Form.Group className="mb-3">
              <Form.Label>Restaurant Name</Form.Label>
              <Form.Control
                type="text"
                name="name"
                value={formData.name}
                onChange={handleInputChange}
                required
                placeholder="Ex: Spice Garden"
              />
            </Form.Group>

            <Form.Group className="mb-3">
              <Form.Label>Owner Email</Form.Label>
              <Form.Control
                type="email"
                name="email"
                value={formData.email}
                onChange={handleInputChange}
                required
                placeholder="owner@example.com"
              />
            </Form.Group>

            <Form.Group className="mb-3">
              <Form.Label>Password</Form.Label>
              <Form.Control
                type="password"
                name="password"
                value={formData.password}
                onChange={handleInputChange}
                required
                placeholder="Secure Password"
              />
            </Form.Group>

            <Form.Group className="mb-3">
              <Form.Label>City</Form.Label>
              <Form.Control
                type="text"
                name="city"
                value={formData.city}
                onChange={handleInputChange}
                required
                placeholder="Ex: Pune"
              />
            </Form.Group>

            <Form.Group className="mb-3">
              <Form.Label>Phone</Form.Label>
              <Form.Control
                type="text"
                name="phone"
                value={formData.phone}
                onChange={handleInputChange}
                required
                placeholder="Ex: 9876543210"
              />
            </Form.Group>

            <Form.Group className="mb-3">
              <Form.Label>Cuisine</Form.Label>
              <Form.Control
                type="text"
                name="cuisine"
                value={formData.cuisine}
                onChange={handleInputChange}
                required
                placeholder="Ex: Indian, Chinese"
              />
            </Form.Group>

            <div className="d-flex justify-content-end gap-2">
              <Button variant="secondary" onClick={() => setShowModal(false)}>
                Cancel
              </Button>
              <Button className="btn-orange" type="submit">
                Add Restaurant
              </Button>
            </div>
          </Form>
        </Modal.Body>
      </Modal>

    </div>
  );
}

export default AdminDashboard;
