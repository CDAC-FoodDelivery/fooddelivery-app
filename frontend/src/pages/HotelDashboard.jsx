import React, { useState, useEffect } from "react";
import "./HotelDashboard.css";
import axios from "axios";
import { Modal, Button, Form } from "react-bootstrap";
import { toast } from "react-toastify";

function HotelDashboard() {
    const [activeTab, setActiveTab] = useState("menus");
    const [menus, setMenus] = useState([]);

    // Modal State
    const [showModal, setShowModal] = useState(false);
    const [formData, setFormData] = useState({
        name: "",
        description: "",
        price: "",
        imageUrl: "",
        category: "",
        isVeg: true,
        available: true
    });

    // Base URL for Hotel Service (Spring Boot)
    const API_URL = "http://localhost:8081/api/hotel";

    // Get Hotel ID from localStorage
    const HOTEL_ID = localStorage.getItem("restaurantId");

    useEffect(() => {
        if (HOTEL_ID) {
            fetchMenus();
        } else {
            // If no hotel ID, we can't fetch menus.
        }
    }, [activeTab]);

    const fetchMenus = async () => {
        try {
            const res = await axios.get(`${API_URL}/${HOTEL_ID}/menu`);
            setMenus(res.data);
        } catch (error) {
            console.error("Error fetching menus", error);
        }
    };

    const handleInputChange = (e) => {
        const { name, value, type, checked } = e.target;
        setFormData({
            ...formData,
            [name]: type === "checkbox" ? checked : value
        });
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            // Include hotelId in the payload
            const payload = { ...formData, hotelId: HOTEL_ID };
            const res = await axios.post(`${API_URL}/menu`, payload);
            setMenus([...menus, res.data]);
            toast.success("Menu item added successfully!");
            setShowModal(false);
            setFormData({
                name: "", description: "", price: "", imageUrl: "", category: "", isVeg: true, available: true
            });
        } catch (error) {
            console.error("Error adding menu", error);
            toast.error("Failed to add menu.");
        }
    };

    const handleDelete = async (id) => {
        if (!window.confirm("Are you sure you want to delete this item?")) return;
        try {
            await axios.delete(`${API_URL}/menu/${id}`);
            setMenus(menus.filter((m) => m.id !== id));
            toast.success("Menu item deleted.");
        } catch (error) {
            console.error("Error deleting menu", error);
            toast.error("Failed to delete menu.");
        }
    };

    return (
        <div className="hotel-page">
            <header className="hotel-header">
                <h1>Hotel Dashboard</h1>
                <p>Manage your Restaurant Menu</p>
            </header>

            <nav className="tabs">
                <button className={activeTab === "menus" ? "active" : ""} onClick={() => setActiveTab("menus")}>
                    My Menu
                </button>
                <button disabled style={{ opacity: 0.5 }}>Orders (Coming Soon)</button>
            </nav>

            <section className="content">
                <div className="section-header">
                    <h2>Menu Items</h2>
                    <button className="add-btn" onClick={() => setShowModal(true)}>＋ Add Menu Item</button>
                </div>

                <div className="grid">
                    {menus.length === 0 ? (
                        <p className="p-3">No menu items found. Add one to get started!</p>
                    ) : (
                        menus.map(m => (
                            <div className="card menu-card" key={m.id}>
                                <img src={m.imageUrl || "https://via.placeholder.com/300?text=No+Image"} alt={m.name} className="menu-image" />
                                <h3>{m.name}</h3>
                                <p className="text-muted small">{m.description?.substring(0, 60)}...</p>
                                <div className="d-flex justify-content-between align-items-center mt-2">
                                    <span className="fw-bold">₹{m.price}</span>
                                    <span className={`badge ${m.isVeg ? "veg" : "non-veg"}`}>
                                        {m.isVeg ? "Veg" : "Non-Veg"}
                                    </span>
                                </div>
                                <div className="card-actions">
                                    <button className="delete" onClick={() => handleDelete(m.id)}>Delete</button>
                                </div>
                            </div>
                        ))
                    )}
                </div>
            </section>

            {/* Add Menu Modal */}
            <Modal show={showModal} onHide={() => setShowModal(false)} centered>
                <Modal.Header closeButton>
                    <Modal.Title>Add Menu Item</Modal.Title>
                </Modal.Header>
                <Modal.Body>
                    <Form onSubmit={handleSubmit}>
                        <Form.Group className="mb-3">
                            <Form.Label>Item Name</Form.Label>
                            <Form.Control
                                type="text"
                                name="name"
                                value={formData.name}
                                onChange={handleInputChange}
                                required
                                placeholder="Ex: Paneer Butter Masala"
                            />
                        </Form.Group>

                        <Form.Group className="mb-3">
                            <Form.Label>Description</Form.Label>
                            <Form.Control
                                as="textarea"
                                rows={2}
                                name="description"
                                value={formData.description}
                                onChange={handleInputChange}
                                placeholder="Short description..."
                            />
                        </Form.Group>

                        <div className="row">
                            <div className="col-6">
                                <Form.Group className="mb-3">
                                    <Form.Label>Price (₹)</Form.Label>
                                    <Form.Control
                                        type="number"
                                        name="price"
                                        value={formData.price}
                                        onChange={handleInputChange}
                                        required
                                        placeholder="250"
                                    />
                                </Form.Group>
                            </div>
                            <div className="col-6">
                                <Form.Group className="mb-3">
                                    <Form.Label>Category</Form.Label>
                                    <Form.Control
                                        type="text"
                                        name="category"
                                        value={formData.category}
                                        onChange={handleInputChange}
                                        placeholder="Ex: Main Course"
                                    />
                                </Form.Group>
                            </div>
                        </div>

                        <Form.Group className="mb-3">
                            <Form.Label>Image URL</Form.Label>
                            <Form.Control
                                type="text"
                                name="imageUrl"
                                value={formData.imageUrl}
                                onChange={handleInputChange}
                                placeholder="https://..."
                            />
                        </Form.Group>

                        <Form.Group className="mb-3">
                            <Form.Check
                                type="checkbox"
                                label="Is Vegetarian?"
                                name="isVeg"
                                checked={formData.isVeg}
                                onChange={handleInputChange}
                            />
                        </Form.Group>

                        <div className="d-flex justify-content-end gap-2">
                            <Button variant="secondary" onClick={() => setShowModal(false)}>
                                Cancel
                            </Button>
                            <Button className="btn-orange" type="submit">
                                Add Item
                            </Button>
                        </div>
                    </Form>
                </Modal.Body>
            </Modal>
        </div>
    );
}

export default HotelDashboard;
