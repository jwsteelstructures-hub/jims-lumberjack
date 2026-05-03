-- =========================================================
--  LUMBER BUSINESS OWNERSHIP SYSTEM
-- =========================================================

-- Main table for lumber camps
CREATE TABLE IF NOT EXISTS lumber_camps (
    camp_id VARCHAR(50) PRIMARY KEY,
    owner_identifier VARCHAR(100) DEFAULT NULL,
    funds INT DEFAULT 0,
    phase INT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Transaction log for company ledger
CREATE TABLE IF NOT EXISTS lumber_transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    camp_id VARCHAR(50),
    type VARCHAR(20),
    amount INT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Optional: worker assignments (future expansion)
CREATE TABLE IF NOT EXISTS lumber_workers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    camp_id VARCHAR(50),
    worker_identifier VARCHAR(100),
    role VARCHAR(50) DEFAULT 'worker',
    hired_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);