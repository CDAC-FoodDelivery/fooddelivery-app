import React, { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import axios from "axios";
import { toast } from 'react-toastify';
import { useAuth } from "../context/AuthContext";

function SignIn() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  const navigate = useNavigate();
  const { login } = useAuth();

  const handleLogin = async (e) => {
    e.preventDefault();
    try {
      const res = await axios.post("http://localhost:8083/auth/login", {
        username: email,
        password: password,
      });
      // Handle both string (old) and object (new) responses for safety
      const data = res.data;
      if (typeof data === "string") {
        localStorage.setItem("token", data);
        toast.success("Login Successful");
        navigate("/home");
      } else if (data && data.token) {
        localStorage.setItem("token", data.token);
        localStorage.setItem("role", data.role);
        localStorage.setItem("restaurantId", data.restaurantId || "");

        toast.success("Login Successful");
        if (data.role === "HOTEL") {
          navigate("/hotelDashboard");
        } else if (data.role === "ADMIN") {
          navigate("/adminDashboard");
        } else if (data.role === "RIDER") {
          navigate("/riderDashboard");
        } else {
          navigate("/home"); // Customer to Home
        }
      }
    } catch (error) {
      console.error("Login failed", error);
      toast.error("Invalid Credentials");
    }
  };

  return (
    <div style={styles.container}>
      <form style={styles.form} onSubmit={handleLogin}>
        <h2 style={styles.title}>Sign in to your account</h2>

        <label style={styles.label}>Email or username</label>
        <input
          type="text"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          style={styles.input}
        />

        <label style={styles.label}>Password</label>
        <input
          type="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          style={styles.input}
        />

        <div style={styles.linksContainer}>
          <a href="#" style={styles.link}>
            Forgot password?
          </a>
          <Link to="/adminDashboard" style={styles.adminLink}>
            Sign in as Admin
          </Link>
        </div>

        <button type="submit" style={styles.button}>
          SIGN IN
        </button>

        <div style={styles.newUser}>
          New to this site?{" "}
          <Link to="/signup" style={styles.registerLink}>
            SignUp
          </Link>
        </div>
      </form>

      <footer style={styles.footer}>©2025-2026 Food Delivery Inc.</footer>
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
  },
  form: {
    background: "transparent",
    padding: "32px",
    borderRadius: "10px",
    boxShadow: "0 0 8px rgba(0,0,0,0.04)",
    textAlign: "center",
  },
  title: {
    fontWeight: "bold",
    marginBottom: "24px",
  },
  label: {
    display: "block",
    textAlign: "left",
    marginBottom: "6px",
    marginTop: "14px",
  },
  input: {
    width: "100%",
    padding: "10px 12px",
    borderRadius: "6px",
    border: "1px solid #f17a53ff",
    marginBottom: "10px",
    fontSize: "16px",
    outline: "none",
  },
  linksContainer: {
    display: "flex",
    justifyContent: "space-between",
    marginBottom: "18px",
    fontSize: "14px",
  },
  link: {
    color: "#ff6733",
    textDecoration: "none",
  },
  adminLink: {
    color: "#6c63ff",
    textDecoration: "none",
    fontWeight: "600",
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
  newUser: {
    marginTop: "20px",
    fontSize: "15px",
  },
  registerLink: {
    color: "#ff6733",
    textDecoration: "none",
  },
  footer: {
    marginTop: "40px",
    fontSize: "13px",
    color: "#444",
  },
};

export default SignIn;
