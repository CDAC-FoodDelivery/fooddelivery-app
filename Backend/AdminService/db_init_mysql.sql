CREATE TABLE IF NOT EXISTS Orders (
    Id INT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Status VARCHAR(100) NOT NULL,
    Amount DECIMAL(18,2) NOT NULL
);

ALTER TABLE hotels ADD COLUMN IF NOT EXISTS status VARCHAR(50) DEFAULT 'Open';

INSERT INTO users (id, name, email, password, role, address, phone) 
VALUES (100, 'Admin', 'admin@example.com', 'hashed_pass', 'ADMIN', 'Pune', '0000000000')
ON DUPLICATE KEY UPDATE name='Admin';

INSERT INTO Orders (Id, Name, Status, Amount) VALUES
(101, 'Ravi', 'Preparing', 120.00),
(102, 'Anita', 'Placed', 85.00)
ON DUPLICATE KEY UPDATE Status=VALUES(Status);
