import React from "react";
import { toast } from "react-toastify";

const MenuItemModal = ({
    showModal,
    setShowModal,
    title,
    handleSubmit,
    newMenuItem,
    setNewMenuItem,
    buttonText
}) => {
    if (!showModal) return null;

    return (
        <div className="modal-overlay">
            <div className="admin-modal">
                <div className="modal-header">
                    <h2>{title}</h2>
                    <button className="close-btn" onClick={() => setShowModal(false)}>&times;</button>
                </div>
                <form onSubmit={handleSubmit} className="modal-form">
                    <div className="form-group">
                        <label>Item Name</label>
                        <input
                            type="text"
                            required
                            value={newMenuItem.name}
                            onChange={(e) => setNewMenuItem({ ...newMenuItem, name: e.target.value })}
                            placeholder="e.g. Paneer Tikka"
                        />
                    </div>
                    <div className="form-group">
                        <label>Description</label>
                        <textarea
                            value={newMenuItem.description}
                            onChange={(e) => setNewMenuItem({ ...newMenuItem, description: e.target.value })}
                            placeholder="Brief description of the item"
                            rows="3"
                        />
                    </div>
                    <div className="form-group">
                        <label>Price (₹)</label>
                        <input
                            type="number"
                            required
                            value={newMenuItem.price}
                            onChange={(e) => setNewMenuItem({ ...newMenuItem, price: e.target.value })}
                            placeholder="e.g. 250"
                        />
                    </div>
                    <div className="form-group">
                        <label>Category</label>
                        <input
                            type="text"
                            value={newMenuItem.category}
                            onChange={(e) => setNewMenuItem({ ...newMenuItem, category: e.target.value })}
                            placeholder="e.g. Appetizers, Main Course, Desserts"
                        />
                    </div>
                    <div className="form-group">
                        <label>Food Type</label>
                        <select
                            value={newMenuItem.foodType}
                            onChange={(e) => setNewMenuItem({ ...newMenuItem, foodType: e.target.value })}
                        >
                            <option value="VEG">Vegetarian</option>
                            <option value="NON_VEG">Non-Vegetarian</option>
                            <option value="VEGAN">Vegan</option>
                        </select>
                    </div>
                    <div className="form-group">
                        <label>Image URL</label>
                        <input
                            type="url"
                            value={newMenuItem.imageUrl}
                            onChange={(e) => setNewMenuItem({ ...newMenuItem, imageUrl: e.target.value })}
                            placeholder="https://example.com/image.jpg"
                        />
                        {newMenuItem.imageUrl && (
                            <img
                                src={newMenuItem.imageUrl}
                                alt="Preview"
                                className="image-preview"
                                onError={(e) => {
                                    e.target.style.display = 'none';
                                    toast.error("Invalid image URL");
                                }}
                            />
                        )}
                    </div>
                    <div className="form-group">
                        <label>
                            <input
                                type="checkbox"
                                checked={newMenuItem.isAvailable}
                                onChange={(e) => setNewMenuItem({ ...newMenuItem, isAvailable: e.target.checked })}
                            />
                            {" "}Available
                        </label>
                    </div>
                    <div className="modal-footer">
                        <button type="button" className="cancel-btn" onClick={() => setShowModal(false)}>Cancel</button>
                        <button type="submit" className="save-btn">{buttonText}</button>
                    </div>
                </form>
            </div>
        </div>
    );
};

export default MenuItemModal;
