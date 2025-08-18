-- 1. Merchant Table
CREATE TABLE merchants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wallet_address TEXT NOT NULL,
    business_name TEXT NOT NULL,
    business_logo TEXT,
    business_email TEXT NOT NULL,
    webhook TEXT,
    local_currency TEXT NOT NULL,
    supported_currencies TEXT[] DEFAULT '{}',
    is_verified BOOLEAN DEFAULT true,
    metadata JSONB,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 2. API Key Table
CREATE TABLE api_keys (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    merchant_id UUID NOT NULL REFERENCES merchants(id) ON DELETE CASCADE,
    secret_key TEXT NOT NULL,
    public_key TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 3. Transactions Table
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    merchant_id UUID NOT NULL REFERENCES merchants(id) ON DELETE CASCADE,
    currency_amount NUMERIC(18, 8) NOT NULL,
    wallet_amount NUMERIC(18, 8) NOT NULL,
    alt_amount NUMERIC(18, 8),
    to_address TEXT NOT NULL,
    status TEXT NOT NULL,
    timestamp TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);

-- 4. Invoice Table
CREATE TABLE invoices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    merchant_id UUID NOT NULL REFERENCES merchants(id) ON DELETE CASCADE,
    payment_ref TEXT NOT NULL,
    secondary_ref TEXT,
    access_code TEXT,
    status TEXT NOT NULL,
    local_amount NUMERIC(18, 8) NOT NULL,
    usdc_amount NUMERIC(18, 8) NOT NULL,
	token_amount NUMERIC(18, 8) NOT NULL,
    payment_token TEXT,
	local_currency TEXT,
	chains TEXT,
    receipt_number TEXT,
    secondary_endpoint TEXT,
    paid_at TIMESTAMP,
    ip_address TEXT,
    metadata JSONB,
	channel TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Optional: Update trigger for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = NOW();
   RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_merchant_updated_at
BEFORE UPDATE ON merchants
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
-- 5. Merchant Activity Logs Table
CREATE TABLE merchant_activity_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    merchant_id UUID NOT NULL REFERENCES merchants(id) ON DELETE CASCADE,
    activity_type TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Add indexes for better performance
CREATE INDEX idx_merchants_wallet_address ON merchants(wallet_address);
CREATE INDEX idx_merchants_email ON merchants(business_email);
CREATE INDEX idx_api_keys_merchant_id ON api_keys(merchant_id);
CREATE INDEX idx_transactions_merchant_id ON transactions(merchant_id);
CREATE INDEX idx_invoices_merchant_id ON invoices(merchant_id);
CREATE INDEX idx_activity_logs_merchant_id ON merchant_activity_logs(merchant_id);

-- Add unique constraints
ALTER TABLE merchants ADD CONSTRAINT unique_wallet_address UNIQUE(wallet_address);
ALTER TABLE merchants ADD CONSTRAINT unique_business_email UNIQUE(business_email);