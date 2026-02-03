import React, { useState, useEffect } from "react";
import "./AdminDashboard.css";
import { useAuth } from "../context/AuthContext";
import axios from "axios";
import { toast } from "react-toastify";
import { API_ENDPOINTS } from '../config/api';

// Import sub-components
import AdminHeader from "../components/admin/AdminHeader";
import OrdersTab from "../components/admin/OrdersTab";
import RestaurantsTab from "../components/admin/RestaurantsTab";
import UsersTab from "../components/admin/UsersTab";
import InsightsTab from "../components/admin/InsightsTab";

// Import modals
import RestaurantModal from "../components/admin/modals/RestaurantModal";
import MenuModal from "../components/admin/modals/MenuModal";
import MenuItemModal from "../components/admin/modals/MenuItemModal";

function AdminDashboardPage() {
    const { logout } = useAuth();
    const [activeTab, setActiveTab] = useState("orders");
    const [loading, setLoading] = useState(false);

    const [orders, setOrders] = useState([]);
    const [restaurants, setRestaurants] = useState([]);
    const [users, setUsers] = useState([]);
    const [insights, setInsights] = useState({
        totalOrders: 0,
        totalRestaurants: 0,
        totalUsers: 0,
        totalRevenue: 0
    });

    const [showAddModal, setShowAddModal] = useState(false);
    const [newRestaurant, setNewRestaurant] = useState({
        name: "",
        cuisine: "",
        location: "",
        price: "",
        rating: "0.0",
        imageUrl: ""
    });

    const [selectedRestaurant, setSelectedRestaurant] = useState(null);
    const [menuItems, setMenuItems] = useState([]);
    const [filteredMenuItems, setFilteredMenuItems] = useState([]);
    const [menuSearchTerm, setMenuSearchTerm] = useState("");
    const [showMenuModal, setShowMenuModal] = useState(false);
    const [showAddMenuModal, setShowAddMenuModal] = useState(false);
    const [showEditMenuModal, setShowEditMenuModal] = useState(false);
    const [currentMenuItem, setCurrentMenuItem] = useState(null);
    const [newMenuItem, setNewMenuItem] = useState({
        name: "",
        description: "",
        price: "",
        imageUrl: "",
        category: "",
        foodType: "VEG",
        isAvailable: true
    });

    const API_BASE = API_ENDPOINTS.ADMIN.BASE;
    const token = localStorage.getItem("token");

    const axiosConfig = {
        headers: { Authorization: `Bearer ${token}` }
    };

    useEffect(() => {
        fetchData();
    }, [activeTab]);

    const fetchData = async () => {
        setLoading(true);
        try {
            switch (activeTab) {
                case "orders":
                    await fetchOrders();
                    break;
                case "restaurants":
                    await fetchRestaurants();
                    break;
                case "users":
                    await fetchUsers();
                    break;
                case "insights":
                    await fetchInsights();
                    break;
            }
        } catch (error) {
            console.error("Error fetching data:", error);
            toast.error("Failed to load data");
        } finally {
            setLoading(false);
        }
    };

    const fetchOrders = async () => {
        const response = await axios.get(`${API_BASE}/orders`, axiosConfig);
        setOrders(response.data);
    };

    const fetchRestaurants = async () => {
        const response = await axios.get(`${API_BASE}/restaurants`, axiosConfig);
        setRestaurants(response.data);
    };

    const fetchUsers = async () => {
        const response = await axios.get(`${API_BASE}/users`, axiosConfig);
        setUsers(response.data);
    };

    const fetchInsights = async () => {
        const response = await axios.get(`${API_BASE}/insights`, axiosConfig);
        setInsights(response.data);
    };

    const handleAddRestaurant = async (e) => {
        if (e) e.preventDefault();
        try {
            await axios.post(`${API_BASE}/restaurants`, {
                ...newRestaurant,
                price: parseInt(newRestaurant.price) || 0,
                rating: parseFloat(newRestaurant.rating) || 0.0
            }, axiosConfig);
            toast.success("Restaurant added successfully");
            setShowAddModal(false);
            setNewRestaurant({ name: "", cuisine: "", location: "", price: "", rating: "0.0", imageUrl: "" });
            fetchRestaurants();
        } catch (error) {
            console.error("Error adding restaurant:", error);
            toast.error("Failed to add restaurant");
        }
    };

    const handleDeleteRestaurant = async (id) => {
        if (!window.confirm("Are you sure you want to delete this restaurant?")) return;
        try {
            await axios.delete(`${API_BASE}/restaurants/${id}`, axiosConfig);
            toast.success("Restaurant deleted successfully");
            fetchRestaurants();
        } catch (error) {
            console.error("Error deleting restaurant:", error);
            toast.error("Failed to delete restaurant");
        }
    };

    const handleUpdateRestaurant = async (id) => {
        const restaurant = restaurants.find(r => r.id === id);
        if (!restaurant) return;
        const updatedName = prompt("Enter new restaurant name:", restaurant.name);
        if (!updatedName) return;
        try {
            await axios.put(`${API_BASE}/restaurants/${id}`, { ...restaurant, name: updatedName }, axiosConfig);
            toast.success("Restaurant updated successfully");
            fetchRestaurants();
        } catch (error) {
            console.error("Error updating restaurant:", error);
            toast.error("Failed to update restaurant");
        }
    };

    const handleUpdateOrderStatus = async (id, currentStatus) => {
        const statuses = ["Placed", "Preparing", "Out for Delivery", "Delivered"];
        const currentIndex = statuses.indexOf(currentStatus);
        const nextStatus = statuses[Math.min(currentIndex + 1, statuses.length - 1)];
        try {
            await axios.put(`${API_BASE}/orders/${id}/status`, { status: nextStatus }, axiosConfig);
            toast.success("Order status updated");
            fetchOrders();
        } catch (error) {
            console.error("Error updating order status:", error);
            toast.error("Failed to update order status");
        }
    };

    const handleManageMenu = async (restaurant) => {
        setSelectedRestaurant(restaurant);
        setMenuSearchTerm("");
        setLoading(true);
        try {
            const response = await axios.get(`${API_BASE}/restaurants/${restaurant.id}/menu`, axiosConfig);
            setMenuItems(response.data);
            setFilteredMenuItems(response.data);
            setShowMenuModal(true);
        } catch (error) {
            console.error("Error fetching menu items:", error);
            toast.error(`Failed to load menu items: ${error.response?.data?.message || error.message}`);
        } finally {
            setLoading(false);
        }
    };

    const handleAddMenuItem = async (e) => {
        if (e) e.preventDefault();
        try {
            await axios.post(`${API_BASE}/restaurants/${selectedRestaurant.id}/menu`, {
                ...newMenuItem,
                price: parseInt(newMenuItem.price) || 0
            }, axiosConfig);
            toast.success("Menu item added successfully");
            setShowAddMenuModal(false);
            setNewMenuItem({ name: "", description: "", price: "", imageUrl: "", category: "", foodType: "VEG", isAvailable: true });
            const menuResponse = await axios.get(`${API_BASE}/restaurants/${selectedRestaurant.id}/menu`, axiosConfig);
            setMenuItems(menuResponse.data);
            setFilteredMenuItems(menuResponse.data);
        } catch (error) {
            console.error("Error adding menu item:", error);
            toast.error(`Failed to add menu item: ${error.response?.data?.message || error.message}`);
        }
    };

    const handleEditMenuItem = (item) => {
        setCurrentMenuItem(item);
        setNewMenuItem({
            name: item.name,
            description: item.description || "",
            price: item.price.toString(),
            imageUrl: item.imageUrl || "",
            category: item.category || "",
            foodType: item.foodType || "VEG",
            isAvailable: item.isAvailable
        });
        setShowEditMenuModal(true);
    };

    const handleUpdateMenuItem = async (e) => {
        if (e) e.preventDefault();
        try {
            await axios.put(`${API_BASE}/menu/${currentMenuItem.id}`, {
                ...newMenuItem,
                price: parseInt(newMenuItem.price) || 0
            }, axiosConfig);
            toast.success("Menu item updated successfully");
            setShowEditMenuModal(false);
            setCurrentMenuItem(null);
            setNewMenuItem({ name: "", description: "", price: "", imageUrl: "", category: "", foodType: "VEG", isAvailable: true });
            const response = await axios.get(`${API_BASE}/restaurants/${selectedRestaurant.id}/menu`, axiosConfig);
            setMenuItems(response.data);
            setFilteredMenuItems(response.data);
        } catch (error) {
            console.error("Error updating menu item:", error);
            toast.error("Failed to update menu item");
        }
    };

    const handleDeleteMenuItem = async (id) => {
        if (!window.confirm("Are you sure you want to delete this menu item?")) return;
        try {
            await axios.delete(`${API_BASE}/menu/${id}`, axiosConfig);
            toast.success("Menu item deleted successfully");
            const response = await axios.get(`${API_BASE}/restaurants/${selectedRestaurant.id}/menu`, axiosConfig);
            setMenuItems(response.data);
            setFilteredMenuItems(response.data);
        } catch (error) {
            console.error("Error deleting menu item:", error);
            toast.error("Failed to delete menu item");
        }
    };

    const handleMenuSearch = (searchTerm) => {
        setMenuSearchTerm(searchTerm);
        if (!searchTerm.trim()) {
            setFilteredMenuItems(menuItems);
            return;
        }
        const filtered = menuItems.filter(item =>
            item.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
            (item.category && item.category.toLowerCase().includes(searchTerm.toLowerCase())) ||
            (item.description && item.description.toLowerCase().includes(searchTerm.toLowerCase()))
        );
        setFilteredMenuItems(filtered);
    };

    return (
        <div className="admin-page">
            <AdminHeader logout={logout} activeTab={activeTab} setActiveTab={setActiveTab} />

            <section className="content">
                {loading ? (
                    <div className="loading">Loading...</div>
                ) : (
                    <>
                        {activeTab === "orders" && <OrdersTab orders={orders} handleUpdateOrderStatus={handleUpdateOrderStatus} />}
                        {activeTab === "restaurants" && (
                            <RestaurantsTab
                                restaurants={restaurants}
                                setShowAddModal={setShowAddModal}
                                handleManageMenu={handleManageMenu}
                                handleUpdateRestaurant={handleUpdateRestaurant}
                                handleDeleteRestaurant={handleDeleteRestaurant}
                            />
                        )}
                        {activeTab === "users" && <UsersTab users={users} />}
                        {activeTab === "insights" && <InsightsTab insights={insights} />}
                    </>
                )}
            </section>

            <RestaurantModal
                showAddModal={showAddModal}
                setShowAddModal={setShowAddModal}
                handleAddRestaurant={handleAddRestaurant}
                newRestaurant={newRestaurant}
                setNewRestaurant={setNewRestaurant}
            />

            <MenuModal
                showMenuModal={showMenuModal}
                setShowMenuModal={setShowMenuModal}
                selectedRestaurant={selectedRestaurant}
                setShowAddMenuModal={setShowAddMenuModal}
                menuItems={menuItems}
                menuSearchTerm={menuSearchTerm}
                handleMenuSearch={handleMenuSearch}
                filteredMenuItems={filteredMenuItems}
                handleEditMenuItem={handleEditMenuItem}
                handleDeleteMenuItem={handleDeleteMenuItem}
            />

            <MenuItemModal
                showModal={showAddMenuModal}
                setShowModal={setShowAddMenuModal}
                title="Add Menu Item"
                handleSubmit={handleAddMenuItem}
                newMenuItem={newMenuItem}
                setNewMenuItem={setNewMenuItem}
                buttonText="Add Item"
            />

            <MenuItemModal
                showModal={showEditMenuModal}
                setShowModal={setShowEditMenuModal}
                title="Edit Menu Item"
                handleSubmit={handleUpdateMenuItem}
                newMenuItem={newMenuItem}
                setNewMenuItem={setNewMenuItem}
                buttonText="Update Item"
            />
        </div>
    );
}

export default AdminDashboardPage;
