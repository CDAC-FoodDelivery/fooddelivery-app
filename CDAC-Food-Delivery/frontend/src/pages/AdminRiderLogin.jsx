import React, { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import axios from "axios";
import { toast } from "react-toastify";
import { useAuth } from "../context/AuthContext";

function AdminRiderLogin() {
    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    const [isRider, setIsRider] = useState(false);

    const navigate = useNavigate();
    const { login } = useAuth();

    const handleLogin = async (e) => {
        e.preventDefault();
        try {
            const response = await axios.post("http://localhost:8080/api/admin/login", {
                email: email,
                password: password,
            });
            if (response.data) {
                const token = response.data;
                const profileUrl = "http://localhost:8080/api/admin/profile";
                await login(token, profileUrl);

                const profileResponse = await axios.get(profileUrl, {
                    headers: { Authorization: `Bearer ${token}` },
                });
                const user = profileResponse.data;
                const userRole = user.role || user.Role;

                if (userRole === "ADMIN") {
                    toast.success("Admin Login Successful");
                    navigate("/adminDashboard", { replace: true });
                } else if (userRole === "RIDER") {
                    toast.success("Rider Login Successful");
                    navigate("/riderDashboard", { replace: true });
                } else {
                    toast.error("Unauthorized: This portal is for Admins and Riders only.");
                }
            }
        } catch (error) {
            console.error("Login failed", error);
            toast.error("Invalid Credentials");
        }
    };

    return (
        <div style={styles.container}>
            <div style={styles.card}>
                <div style={styles.tabContainer}>
                    <button
                        style={{ ...styles.tab, borderBottom: !isRider ? "3px solid #ff6733" : "none", color: !isRider ? "#ff6733" : "#888" }}
                        onClick={() => setIsRider(false)}
                    >
                        ADMIN LOGIN
                    </button>
                    <button
                        style={{ ...styles.tab, borderBottom: isRider ? "3px solid #ff6733" : "none", color: isRider ? "#ff6733" : "#888" }}
                        onClick={() => setIsRider(true)}
                    >
                        RIDER LOGIN
                    </button>
                </div>

                <form style={styles.form} onSubmit={handleLogin}>
                    <h2 style={styles.title}>
                        {isRider ? "Rider Portal" : "Admin Portal"}
                    </h2>

                    <label style={styles.label}>Email Address</label>
                    <input
                        type="email"
                        value={email}
                        onChange={(e) => setEmail(e.target.value)}
                        style={styles.input}
                        placeholder={isRider ? "rider@example.com" : "admin@fooddelivery.com"}
                        required
                    />

                    <label style={styles.label}>Password</label>
                    <input
                        type="password"
                        value={password}
                        onChange={(e) => setPassword(e.target.value)}
                        style={styles.input}
                        placeholder="••••••••"
                        required
                    />

                    <button type="submit" style={styles.button}>
                        LOG IN
                    </button>

                    <div style={styles.footerLinks}>
                        {isRider && (
                            <p style={styles.text}>
                                New rider? <Link to="/rider-signup" style={{ color: "#ff6733", fontWeight: "600" }}>Register here</Link>
                            </p>
                        )}
                        <p style={styles.text}>
                            New User? <Link to="/signup" style={{ color: "#ff6733", fontWeight: "600" }}>Register here</Link>
                        </p>
                        <p style={styles.text}>
                            Customer? <Link to="/" style={{ color: "#ff6733", fontWeight: "600" }}>User Login</Link>
                        </p>
                    </div>
                </form>
            </div>
            <footer style={styles.footer}>©2025-2026 Food Delivery Inc. | Management Portal</footer>
        </div>
    );
}

const styles = {
    container: {
        minHeight: "100vh",
        background: "linear-gradient(180deg, #fffbe9 0%, #ffe0bb 100%)",
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        fontFamily: "'Segoe UI', Tahoma, Geneva, Verdana, sans-serif",
    },
    card: {
        background: "transparent",
        borderRadius: "15px",
        boxShadow: "0 0 8px rgba(0,0,0,0.04)",
        width: "400px",
        overflow: "hidden",
    },
    tabContainer: {
        display: "flex",
        borderBottom: "1px solid #f17a5344",
    },
    tab: {
        flex: 1,
        padding: "15px",
        border: "none",
        background: "none",
        fontWeight: "bold",
        fontSize: "14px",
        cursor: "pointer",
        transition: "all 0.3s ease",
    },
    form: {
        padding: "30px",
        textAlign: "center",
    },
    title: {
        fontSize: "24px",
        fontWeight: "bold",
        marginBottom: "25px",
        color: "#333",
    },
    label: {
        display: "block",
        textAlign: "left",
        marginBottom: "6px",
        marginTop: "14px",
        fontSize: "14px",
        fontWeight: "600",
        color: "#333",
    },
    input: {
        width: "100%",
        padding: "10px 12px",
        borderRadius: "6px",
        border: "1px solid #f17a53ff",
        marginBottom: "10px",
        fontSize: "16px",
        outline: "none",
        transition: "border-color 0.3s ease",
    },
    button: {
        width: "100%",
        padding: "12px",
        background: "#ff6733",
        color: "#fff",
        border: "none",
        borderRadius: "6px",
        fontWeight: "bold",
        fontSize: "16px",
        cursor: "pointer",
        marginTop: "12px",
        textDecoration: "none",
    },
    footerLinks: {
        marginTop: "20px",
    },
    text: {
        fontSize: "14px",
        color: "#666",
        margin: "5px 0",
    },
    footer: {
        marginTop: "30px",
        fontSize: "13px",
        color: "#444",
    },
};

export default AdminRiderLogin;
