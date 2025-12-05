-- LendLedger Database Schema
-- Version: 1.0
-- Database: PostgreSQL/SQLite compatible

-- ============================================
-- USERS TABLE
-- ============================================
CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    full_name VARCHAR(255),
    biometric_enabled BOOLEAN DEFAULT false,
    cloud_backup_enabled BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP
);

-- ============================================
-- BORROWERS TABLE
-- ============================================
CREATE TABLE borrowers (
    borrower_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(255),
    address TEXT,
    contact_id VARCHAR(100), -- Phone contact ID for integration
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, phone)
);

-- ============================================
-- LOANS TABLE (Core Transaction Entity)
-- ============================================
CREATE TABLE loans (
    loan_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    borrower_id UUID NOT NULL REFERENCES borrowers(borrower_id) ON DELETE CASCADE,
    
    -- Financial Details
    principal_amount DECIMAL(15, 2) NOT NULL,
    interest_rate DECIMAL(5, 2) NOT NULL, -- Percentage
    interest_rate_type VARCHAR(20) NOT NULL CHECK (interest_rate_type IN ('monthly', 'yearly')),
    payment_frequency VARCHAR(20) NOT NULL CHECK (payment_frequency IN ('daily', 'monthly', 'quarterly')),
    
    -- Fund Source Tracking
    fund_source VARCHAR(20) NOT NULL CHECK (fund_source IN ('self_funded', 'borrowed')),
    transaction_mode VARCHAR(20) NOT NULL CHECK (transaction_mode IN ('cash', 'bank')),
    cost_of_capital DECIMAL(5, 2), -- Interest rate paid to original lender (if borrowed)
    
    -- Source Buyout Tracking
    original_fund_source VARCHAR(20), -- Stores original source if converted
    source_converted_at TIMESTAMP, -- Date when converted from borrowed to self_funded
    source_conversion_notes TEXT,
    
    -- Dates
    loan_start_date DATE NOT NULL,
    due_date DATE NOT NULL,
    
    -- Status
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'paid', 'overdue', 'defaulted')),
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_user_loans (user_id),
    INDEX idx_borrower_loans (borrower_id),
    INDEX idx_loan_status (status),
    INDEX idx_due_date (due_date)
);

-- ============================================
-- PAYMENTS TABLE
-- ============================================
CREATE TABLE payments (
    payment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    loan_id UUID NOT NULL REFERENCES loans(loan_id) ON DELETE CASCADE,
    
    -- Payment Details
    payment_amount DECIMAL(15, 2) NOT NULL,
    principal_paid DECIMAL(15, 2) NOT NULL,
    interest_paid DECIMAL(15, 2) NOT NULL,
    payment_date DATE NOT NULL,
    payment_mode VARCHAR(20) CHECK (payment_mode IN ('cash', 'bank')),
    
    -- Metadata
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_loan_payments (loan_id),
    INDEX idx_payment_date (payment_date)
);

-- ============================================
-- AUDIT LOGS TABLE (Immutable)
-- ============================================
CREATE TABLE audit_logs (
    log_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(user_id),
    
    -- Action Details
    action_type VARCHAR(50) NOT NULL, -- 'delete_loan', 'delete_payment', 'source_conversion', etc.
    entity_type VARCHAR(50) NOT NULL, -- 'loan', 'payment', 'borrower'
    entity_id UUID NOT NULL,
    
    -- Snapshot of deleted/modified data
    data_snapshot JSONB NOT NULL,
    
    -- Metadata
    ip_address VARCHAR(45),
    device_info TEXT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_user_audit (user_id),
    INDEX idx_action_type (action_type),
    INDEX idx_timestamp (timestamp)
);

-- ============================================
-- NOTIFICATIONS TABLE
-- ============================================
CREATE TABLE notifications (
    notification_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    loan_id UUID REFERENCES loans(loan_id) ON DELETE CASCADE,
    
    -- Notification Details
    notification_type VARCHAR(50) NOT NULL, -- 'due_soon', 'due_today', 'overdue'
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    scheduled_for TIMESTAMP NOT NULL,
    sent_at TIMESTAMP,
    read_at TIMESTAMP,
    
    -- Status
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'sent', 'failed')),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_user_notifications (user_id),
    INDEX idx_scheduled_notifications (scheduled_for, status)
);

-- ============================================
-- APP SETTINGS TABLE
-- ============================================
CREATE TABLE app_settings (
    setting_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    
    -- Notification Preferences
    notification_time TIME DEFAULT '09:00:00',
    notification_enabled BOOLEAN DEFAULT true,
    reminder_days_before INTEGER DEFAULT 3,
    
    -- Display Preferences
    currency_symbol VARCHAR(10) DEFAULT '₹',
    date_format VARCHAR(20) DEFAULT 'DD/MM/YYYY',
    theme VARCHAR(20) DEFAULT 'light',
    
    -- Security
    auto_lock_minutes INTEGER DEFAULT 5,
    require_biometric BOOLEAN DEFAULT true,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(user_id)
);

-- ============================================
-- VIEWS FOR COMMON QUERIES
-- ============================================

-- Active Loans with Calculated Interest
CREATE VIEW active_loans_with_interest AS
SELECT 
    l.loan_id,
    l.user_id,
    l.borrower_id,
    b.name as borrower_name,
    l.principal_amount,
    l.interest_rate,
    l.interest_rate_type,
    l.fund_source,
    l.transaction_mode,
    l.loan_start_date,
    l.due_date,
    l.status,
    -- Calculate interest based on days elapsed
    CASE 
        WHEN l.interest_rate_type = 'yearly' THEN
            l.principal_amount * (l.interest_rate / 100) * 
            (EXTRACT(EPOCH FROM (CURRENT_DATE - l.loan_start_date)) / (365 * 86400))
        WHEN l.interest_rate_type = 'monthly' THEN
            l.principal_amount * (l.interest_rate / 100) * 
            (EXTRACT(EPOCH FROM (CURRENT_DATE - l.loan_start_date)) / (30 * 86400))
    END as interest_accrued,
    -- Total amount due
    l.principal_amount + 
    CASE 
        WHEN l.interest_rate_type = 'yearly' THEN
            l.principal_amount * (l.interest_rate / 100) * 
            (EXTRACT(EPOCH FROM (CURRENT_DATE - l.loan_start_date)) / (365 * 86400))
        WHEN l.interest_rate_type = 'monthly' THEN
            l.principal_amount * (l.interest_rate / 100) * 
            (EXTRACT(EPOCH FROM (CURRENT_DATE - l.loan_start_date)) / (30 * 86400))
    END as total_due
FROM loans l
JOIN borrowers b ON l.borrower_id = b.borrower_id
WHERE l.status = 'active';

-- Dashboard Summary View
CREATE VIEW dashboard_summary AS
SELECT 
    user_id,
    COUNT(*) as total_active_loans,
    SUM(principal_amount) as total_principal_outstanding,
    SUM(CASE WHEN fund_source = 'self_funded' THEN principal_amount ELSE 0 END) as self_funded_capital,
    SUM(CASE WHEN fund_source = 'borrowed' THEN principal_amount ELSE 0 END) as borrowed_capital,
    COUNT(CASE WHEN due_date = CURRENT_DATE THEN 1 END) as due_today_count,
    COUNT(CASE WHEN due_date < CURRENT_DATE THEN 1 END) as overdue_count
FROM loans
WHERE status = 'active'
GROUP BY user_id;

-- ============================================
-- FUNCTIONS
-- ============================================

-- Function to update timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers for updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_borrowers_updated_at BEFORE UPDATE ON borrowers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_loans_updated_at BEFORE UPDATE ON loans
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================

CREATE INDEX idx_loans_user_status ON loans(user_id, status);
CREATE INDEX idx_loans_due_date_status ON loans(due_date, status);
CREATE INDEX idx_borrowers_user ON borrowers(user_id);
CREATE INDEX idx_payments_loan ON payments(loan_id);

-- ============================================
-- SAMPLE DATA (Optional - for testing)
-- ============================================

-- Insert sample user
-- INSERT INTO users (email, full_name, biometric_enabled) 
-- VALUES ('demo@lendledger.com', 'Demo User', true);
