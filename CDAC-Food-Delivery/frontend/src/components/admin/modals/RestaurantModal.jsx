import React from "react";

const RestaurantModal = ({
    showAddModal,
    setShowAddModal,
    handleAddRestaurant,
    newRestaurant,
    setNewRestaurant
}) => {
    if (!showAddModal) return null;

    return (
        <div className="modal-overlay">
            <div className="admin-modal">
                <div className="modal-header">
                    <h2>Add New Restaurant</h2>
                    <button className="close-btn" onClick={() => setShowAddModal(false)}>&times;</button>
                </div>
                <form onSubmit={handleAddRestaurant} className="modal-form">
                    <div className="form-group">
                        <label>Restaurant Name</label>
                        <input
                            type="text"
                            required
                            value={newRestaurant.name}
                            onChange={(e) => setNewRestaurant({ ...newRestaurant, name: e.target.value })}
                            placeholder="e.g. Spice Hub"
                        />
                    </div>
                    <div className="form-group">
                        <label>Cuisine</label>
                        <input
                            type="text"
                            required
                            value={newRestaurant.cuisine}
                            onChange={(e) => setNewRestaurant({ ...newRestaurant, cuisine: e.target.value })}
                            placeholder="e.g. Indian, Chinese"
                        />
                    </div>
                    <div className="form-group">
                        <label>Location / Address</label>
                        <input
                            type="text"
                            required
                            value={newRestaurant.location}
                            onChange={(e) => setNewRestaurant({ ...newRestaurant, location: e.target.value })}
                            placeholder="e.g. MG Road, Pune"
                        />
                    </div>
                    <div className="form-group">
                        <label>Average Price (₹)</label>
                        <input
                            type="number"
                            required
                            value={newRestaurant.price}
                            onChange={(e) => setNewRestaurant({ ...newRestaurant, price: e.target.value })}
                            placeholder="e.g. 500"
                        />
                    </div>
                    <div className="form-group">
                        <label>Initial Rating (0-5)</label>
                        <input
                            type="number"
                            step="0.1"
                            min="0"
                            max="5"
                            required
                            value={newRestaurant.rating}
                            onChange={(e) => setNewRestaurant({ ...newRestaurant, rating: e.target.value })}
                            placeholder="e.g. 4.5"
                        />
                    </div>
                    <div className="form-group">
                        <label>Image URL</label>
                        <input
                            type="url"
                            value={newRestaurant.imageUrl}
                            onChange={(e) => setNewRestaurant({ ...newRestaurant, imageUrl: e.target.value })}
                            placeholder="https://example.com/image.jpg"
                        />
                    </div>
                    <div className="modal-footer">
                        <button type="button" className="cancel-btn" onClick={() => setShowAddModal(false)}>Cancel</button>
                        <button type="submit" className="save-btn">Save Restaurant</button>
                    </div>
                </form>
            </div>
        </div>
    );
};

export default RestaurantModal;
