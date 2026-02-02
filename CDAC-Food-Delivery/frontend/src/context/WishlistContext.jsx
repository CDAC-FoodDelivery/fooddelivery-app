import React, { createContext, useContext, useState, useEffect } from "react";
import { useAuth } from "./AuthContext";

const WishlistContext = createContext();

export const WishlistProvider = ({ children }) => {
    const { user } = useAuth();
    const storageKey = user ? `wishlist_${user.email}` : "wishlist_guest";

    const [wishlist, setWishlist] = useState([]);

    useEffect(() => {
        const saved = localStorage.getItem(storageKey);
        setWishlist(saved ? JSON.parse(saved) : []);
    }, [storageKey]);

    useEffect(() => {
        if (wishlist.length > 0 || localStorage.getItem(storageKey)) {
            localStorage.setItem(storageKey, JSON.stringify(wishlist));
        }
    }, [wishlist, storageKey]);

    const toggleWishlist = (product) => {
        setWishlist((prev) => {
            const exists = prev.find((item) => item.name === product.name);
            if (exists) {
                return prev.filter((item) => item.name !== product.name);
            }
            return [...prev, product];
        });
    };

    const isInWishlist = (name) => {
        return wishlist.some((item) => item.name === name);
    };

    const removeFromWishlist = (name) => {
        setWishlist((prev) => prev.filter((item) => item.name !== name));
    };

    return (
        <WishlistContext.Provider value={{ wishlist, toggleWishlist, isInWishlist, removeFromWishlist }}>
            {children}
        </WishlistContext.Provider>
    );
};

export const useWishlist = () => useContext(WishlistContext);
