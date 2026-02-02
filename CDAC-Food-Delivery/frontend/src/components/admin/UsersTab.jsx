import React from "react";

const UsersTab = ({ users }) => {
    return (
        <div className="grid">
            {users.length === 0 ? (
                <p>No users found</p>
            ) : (
                users.map((u) => (
                    <div className="card" key={u.id}>
                        <h3>{u.name}</h3>
                        <p><strong>Email:</strong> {u.email}</p>
                        <p><strong>Role:</strong> {u.role}</p>
                        <p><strong>Phone:</strong> {u.phone || "N/A"}</p>
                    </div>
                ))
            )}
        </div>
    );
};

export default UsersTab;
