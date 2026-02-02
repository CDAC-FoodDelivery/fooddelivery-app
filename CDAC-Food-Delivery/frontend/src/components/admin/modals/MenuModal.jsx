import React from "react";

const MenuModal = ({
    showMenuModal,
    setShowMenuModal,
    selectedRestaurant,
    setShowAddMenuModal,
    menuItems,
    menuSearchTerm,
    handleMenuSearch,
    filteredMenuItems,
    handleEditMenuItem,
    handleDeleteMenuItem
}) => {
    if (!showMenuModal || !selectedRestaurant) return null;

    return (
        <div className="modal-overlay">
            <div className="admin-modal" style={{ maxWidth: "900px" }}>
                <div className="modal-header">
                    <h2>Menu - {selectedRestaurant.name}</h2>
                    <button className="close-btn" onClick={() => setShowMenuModal(false)}>&times;</button>
                </div>
                <div style={{ padding: "20px" }}>
                    <button className="add-btn" onClick={() => setShowAddMenuModal(true)} style={{ marginBottom: "20px" }}>＋ Add Menu Item</button>

                    {menuItems.length === 0 ? (
                        <p className="no-menu-items">No menu items found. Add your first item!</p>
                    ) : (
                        <>
                            <input
                                type="text"
                                className="menu-search-box"
                                placeholder="🔍 Search menu items by name, category, or description..."
                                value={menuSearchTerm}
                                onChange={(e) => handleMenuSearch(e.target.value)}
                            />
                            {filteredMenuItems.length === 0 ? (
                                <p className="no-menu-items">No menu items match your search.</p>
                            ) : (
                                <div className="grid">
                                    {filteredMenuItems.map(item => (
                                        <div className="card menu-item-card" key={item.id}>
                                            {item.imageUrl ? (
                                                <img
                                                    src={item.imageUrl}
                                                    alt={item.name}
                                                    className="menu-item-image"
                                                    onError={(e) => e.target.style.display = 'none'}
                                                />
                                            ) : (
                                                <div className="menu-item-placeholder">📷 No Image</div>
                                            )}
                                            <h3>{item.name}</h3>
                                            <p><strong>Price:</strong> ₹{item.price}</p>
                                            {item.description && <p><small>{item.description}</small></p>}
                                            <p><strong>Category:</strong> {item.category || "N/A"}</p>
                                            <span className="badge" style={{
                                                background: item.foodType === "VEG" ? "#4caf50" : item.foodType === "VEGAN" ? "#8bc34a" : "#f44336"
                                            }}>{item.foodType}</span>
                                            <span className="badge" style={{ marginLeft: "5px" }}>
                                                {item.isAvailable ? "Available" : "Unavailable"}
                                            </span>
                                            <div className="card-actions" style={{ marginTop: "10px" }}>
                                                <button className="update" onClick={() => handleEditMenuItem(item)}>Edit</button>
                                                <button className="delete" onClick={() => handleDeleteMenuItem(item.id)}>Delete</button>
                                            </div>
                                        </div>
                                    ))}
                                </div>
                            )}
                        </>
                    )}
                </div>
            </div>
        </div>
    );
};

export default MenuModal;
