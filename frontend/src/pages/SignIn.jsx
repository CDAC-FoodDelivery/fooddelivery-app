import React, { useState } from "react";
import { Link } from "react-router-dom";

function SignIn() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  return (
    <div style={styles.container}>
      <form style={styles.form}>
        <h2 style={styles.title}>Sign in to your account</h2>
        <label style={styles.label}>Email or username</label>
        <input
          type="text"
          value={email}
          onChange={(e) => {
            setEmail(e.target.value);
            console.log("Email:", e.target.value);
          }}
          style={styles.input}
        />
        <label style={styles.label}>Password</label>
        <input
          type="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          style={styles.input}
        />
        <div style={styles.forgot}>
          <a href="#" style={styles.forgotLink}>
            Forgot password?
          </a>
        </div>
        <Link to="/home" type="submit" style={styles.button}>
          SIGN IN
        </Link>
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
  forgot: {
    textAlign: "right",
    marginBottom: "18px",
  },
  forgotLink: {
    color: "#ff6733",
    textDecoration: "none",
    fontSize: "14px",
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
