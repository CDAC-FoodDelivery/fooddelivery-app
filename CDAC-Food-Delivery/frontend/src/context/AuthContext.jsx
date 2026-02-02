import React, { createContext, useState, useEffect, useContext } from "react";
import axios from "axios";

const AuthContext = createContext();

export const useAuth = () => useContext(AuthContext);

export const AuthProvider = ({ children }) => {
    const [user, setUser] = useState(null);
    const [loading, setLoading] = useState(true);

    const fetchUser = async () => {
        const token = localStorage.getItem("token");
        const serviceUrl = localStorage.getItem("authServiceUrl") || "http://localhost:8080/api/auth/profile";

        if (!token) {
            setUser(null);
            setLoading(false);
            return;
        }

        setLoading(true);
        try {
            const response = await axios.get(serviceUrl, {
                headers: { Authorization: `Bearer ${token}` },
            });
            setUser(response.data);
        } catch (error) {
            console.error("Error fetching user profile", error);
            localStorage.removeItem("token");
            localStorage.removeItem("authServiceUrl");
            setUser(null);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchUser();
    }, []);

    const login = async (tokenData, serviceUrl = "http://localhost:8080/api/auth/profile") => {
        const token = typeof tokenData === 'string' ? tokenData : tokenData.token;
        if (token) {
            localStorage.setItem("token", token);
            localStorage.setItem("authServiceUrl", serviceUrl);
            await fetchUser();
        }
    };

    const logout = () => {
        localStorage.removeItem("token");
        localStorage.removeItem("authServiceUrl");
        setUser(null);
        window.location.replace("/");
    };

    return (
        <AuthContext.Provider value={{ user, loading, login, logout, fetchUser }}>
            {children}
        </AuthContext.Provider>
    );
};
