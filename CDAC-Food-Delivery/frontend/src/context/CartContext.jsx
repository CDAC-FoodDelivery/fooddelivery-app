import React, { createContext, useContext, useState, useEffect } from "react";
import { toast } from "react-toastify";
import { useAuth } from "./AuthContext";

const CartContext = createContext();

export const CartProvider = ({ children }) => {
  const { user } = useAuth();
  const storageKey = user ? `cart_${user.email}` : "cart_guest";

  const [cartItems, setCartItems] = useState([]);

  useEffect(() => {
    const savedCart = localStorage.getItem(storageKey);
    setCartItems(savedCart ? JSON.parse(savedCart) : []);
  }, [storageKey]);

  useEffect(() => {
    if (cartItems.length > 0 || localStorage.getItem(storageKey)) {
      localStorage.setItem(storageKey, JSON.stringify(cartItems));
    }
  }, [cartItems, storageKey]);

  const addToCart = (item) => {
    setCartItems((prev) => {
      const existing = prev.find(p => p.name === item.name);

      if (existing) {
        return prev.map(p =>
          p.name === item.name
            ? { ...p, quantity: p.quantity + 1 }
            : p
        );
      }

      return [...prev, { ...item, quantity: 1 }];
    });
    toast.success(`${item.name} added to cart! 🛒`);
  };

  const removeFromCart = (name) => {
    setCartItems(prev => prev.filter(p => p.name !== name));
    toast.info("Item removed from cart");
  };

  const updateQuantity = (name, qty) => {
    if (qty < 1) {
      removeFromCart(name);
      return;
    }
    setCartItems(prev =>
      prev.map(p =>
        p.name === name ? { ...p, quantity: qty } : p
      )
    );
  };

  const clearCart = () => {
    setCartItems([]);
    localStorage.removeItem(storageKey);
  };

  const totalPrice = cartItems.reduce(
    (sum, item) => sum + item.price * item.quantity,
    0
  );

  return (
    <CartContext.Provider
      value={{
        cartItems,
        addToCart,
        removeFromCart,
        updateQuantity,
        clearCart,
        totalPrice
      }}
    >
      {children}
    </CartContext.Provider>
  );
};

export const useCart = () => useContext(CartContext);
