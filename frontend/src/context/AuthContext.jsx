import React, { createContext, useState, useEffect, useContext } from "react";
import axios from "axios";
import { toast } from "react-toastify";

const AuthContext = createContext();

export const useAuth = () => useContext(AuthContext);

export const AuthProvider = ({ children }) => {
    const [user, setUser] = useState(null);
    const [loading, setLoading] = useState(true);

    // Fetch user profile if token exists
    useEffect(() => {
        const fetchUser = async () => {
            const token = localStorage.getItem("token");
            if (!token) {
                setLoading(false);
                return;
            }

            try {
                const response = await axios.get("http://localhost:8083/auth/profile", {
                    headers: { Authorization: `Bearer ${token}` },
                });
                setUser(response.data);
            } catch (error) {
                console.error("Error fetching user profile", error);
                // Optional: clear token if invalid?
                // localStorage.removeItem("token");
            } finally {
                setLoading(false);
            }
        };

        fetchUser();
    }, []);

    const login = (userData, token) => {
        localStorage.setItem("token", token);
        setUser(userData);
        // If userData doesn't have full profile (sometimes login returns just token), 
        // we might want to fetch it here or trust the component provided it.
        // For now simplistic approach:
    };

    const logout = () => {
        localStorage.removeItem("token");
        setUser(null);
        window.location.href = "/";
    };

    const updateUser = (updatedData) => {
        setUser((prev) => ({ ...prev, ...updatedData }));
    };

    return (
        <AuthContext.Provider value={{ user, loading, login, logout, updateUser }}>
            {children}
        </AuthContext.Provider>
    );
};
