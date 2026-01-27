-- 1. Create missing Orders table
CREATE TABLE IF NOT EXISTS Orders (
    Id INT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Status VARCHAR(100) NOT NULL,
    Amount DECIMAL(18,2) NOT NULL
);

-- 2. Add Status column to existing hotels table if it's missing
-- Run this only if 'Status' column doesn't exist. Since it might not, we can try adding it
-- or updating the Backend Model to ignore it if you don't want to modify the table.
-- Assuming you want the functionality, let's add it:
ALTER TABLE hotels ADD COLUMN IF NOT EXISTS status VARCHAR(50) DEFAULT 'Open';

-- 3. Insert Admin User (Using a non-conflicting ID)
-- Check if ID 100 exists to be safe
INSERT INTO users (id, name, email, password, role, address, phone) 
VALUES (100, 'Admin', 'admin@example.com', 'hashed_pass', 'ADMIN', 'Pune', '0000000000')
ON DUPLICATE KEY UPDATE name='Admin';

-- 4. Insert some initial Orders
INSERT INTO Orders (Id, Name, Status, Amount) VALUES
(101, 'Ravi', 'Preparing', 120.00),
(102, 'Anita', 'Placed', 85.00)
ON DUPLICATE KEY UPDATE Status=VALUES(Status);
