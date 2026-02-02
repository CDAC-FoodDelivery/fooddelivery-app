import React from "react";
import { Navbar, Container, Nav, Dropdown } from "react-bootstrap";

const TopNavbar = ({ userName }) => {
  return (
    <Navbar bg="light" expand="lg" className="shadow-sm px-4 py-3">
      <Container fluid>
        {/* Welcome message on the left */}
        <Navbar.Brand>
          <span className="fw-bold" style={{ color: "#ff6600" }}>
            Welcome, {userName}!
          </span>
        </Navbar.Brand>

        {/* Right side menu */}
        <Nav className="ms-auto">
          {/* Profile dropdown */}
          <Dropdown align="end">
            <Dropdown.Toggle variant="light" id="dropdown-basic">
              Profile
            </Dropdown.Toggle>

            <Dropdown.Menu>
              <Dropdown.Item href="/profile">My Profile</Dropdown.Item>
              <Dropdown.Item href="/settings">Settings</Dropdown.Item>
            </Dropdown.Menu>
          </Dropdown>

          {/* Logout button */}
          <Nav.Link
            href="/"
            className="ms-3"
            style={{ color: "#ff4d4d", fontWeight: "500", cursor: "pointer" }}
            onClick={() => alert("Logged out!")}
          >
            Logout
          </Nav.Link>
        </Nav>
      </Container>
    </Navbar>
  );
};

export default TopNavbar;
