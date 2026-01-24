import React from "react";

const Footer = () => {
  return (
    <footer style={styles.footer}>
      <div style={styles.container}>
        {/* Brand */}
        <div>
          <h2 style={styles.logo}>Foodie</h2>
          <p style={styles.text}>
            Order food from your favourite restaurants near you.
          </p>
        </div>

        {/* Company */}
        <div>
          <h4 style={styles.heading}>Company</h4>
          <ul style={styles.list}>
            <li>About</li>
            <li>Careers</li>
            <li>Team</li>
            <li>Foodie One</li>
          </ul>
        </div>

        {/* Contact */}
        <div>
          <h4 style={styles.heading}>Contact</h4>
          <ul style={styles.list}>
            <li>Help & Support</li>
            <li>Partner with us</li>
            <li>Ride with us</li>
          </ul>
        </div>

        {/* Cities */}
        <div>
          <h4 style={styles.heading}>We deliver to</h4>
          <ul style={styles.list}>
            <li>Pune</li>
            <li>Mumbai</li>
            <li>Bangalore</li>
            <li>Delhi</li>
          </ul>
        </div>
      </div>

      <div style={styles.bottom}>
        © {new Date().getFullYear()} Foodie. All rights reserved.
      </div>
    </footer>
  );
};

const styles = {
  footer: {
    backgroundColor: "#02060c", // Swiggy dark
    color: "#fff",
    paddingTop: "50px",
    marginTop: "80px",
  },

  container: {
    maxWidth: "1200px",
    margin: "0 auto",
    padding: "0 20px 40px",
    display: "grid",
    gridTemplateColumns: "repeat(auto-fit, minmax(200px, 1fr))",
    gap: "40px",
  },

  logo: {
    fontSize: "26px",
    fontWeight: "700",
    marginBottom: "12px",
  },

  heading: {
    fontSize: "16px",
    marginBottom: "12px",
    color: "#ffffff",
  },

  text: {
    color: "#b5b5b5",
    fontSize: "14px",
    lineHeight: "1.6",
  },

  list: {
    listStyle: "none",
    padding: 0,
    margin: 0,
    color: "#b5b5b5",
    fontSize: "14px",
    lineHeight: "2",
    cursor: "pointer",
  },

  bottom: {
    borderTop: "1px solid #1a1a1a",
    textAlign: "center",
    padding: "20px",
    fontSize: "13px",
    color: "#8a8a8a",
  },
};

export default Footer;
