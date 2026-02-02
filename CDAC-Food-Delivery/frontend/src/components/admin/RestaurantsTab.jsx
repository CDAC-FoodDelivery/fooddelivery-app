import React from "react";

const RestaurantsTab = ({
    restaurants,
    setShowAddModal,
    handleManageMenu,
    handleUpdateRestaurant,
    handleDeleteRestaurant
}) => {
    return (
        <>
            <div className="section-header">
                <h2>Restaurants</h2>
                <button className="add-btn" onClick={() => setShowAddModal(true)}>＋ Add Restaurant</button>
            </div>

            <div className="grid">
                {restaurants.length === 0 ? (
                    <p>No restaurants found</p>
                ) : (
                    restaurants.map((r) => (
                        <div className="card restaurant-card" key={r.id}>
                            <div>
                                <h3>{r.name}</h3>
                                <p>{r.location || "No location"}</p>
                                <p><small>{r.cuisine || "Multi-Cuisine"}</small></p>
                                <span className="badge">₹{r.price}</span>
                            </div>

                            <div className="card-actions">
                                <button className="update" onClick={() => handleManageMenu(r)}>Manage Menu</button>
                                <button className="update" onClick={() => handleUpdateRestaurant(r.id)}>Update</button>
                                <button className="delete" onClick={() => handleDeleteRestaurant(r.id)}>Delete</button>
                            </div>
                        </div>
                    ))
                )}
            </div>
        </>
    );
};

export default RestaurantsTab;
