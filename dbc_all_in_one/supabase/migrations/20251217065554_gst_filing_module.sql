-- Location: supabase/migrations/20251217065554_gst_filing_module.sql
-- Schema Analysis: Existing tables: invoices (with tax_amount), invoice_items, user_profiles
-- Integration Type: New GST Filing Module extending existing invoicing system
-- Dependencies: invoices, user_profiles tables

-- 1. Create ENUM types for GST module
CREATE TYPE public.gst_period_type AS ENUM ('monthly', 'quarterly', 'annual');
CREATE TYPE public.gst_filing_status AS ENUM ('draft', 'pending', 'filed', 'overdue', 'approved');

-- 2. GST Returns table - Core GST filing records
CREATE TABLE public.gst_returns (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    return_period TEXT NOT NULL,
    period_type public.gst_period_type DEFAULT 'monthly'::public.gst_period_type,
    period_start_date DATE NOT NULL,
    period_end_date DATE NOT NULL,
    filing_deadline DATE NOT NULL,
    total_sales NUMERIC(12,2) DEFAULT 0.00,
    total_purchases NUMERIC(12,2) DEFAULT 0.00,
    input_tax_credit NUMERIC(12,2) DEFAULT 0.00,
    output_tax NUMERIC(12,2) DEFAULT 0.00,
    gst_payable NUMERIC(12,2) DEFAULT 0.00,
    filing_status public.gst_filing_status DEFAULT 'draft'::public.gst_filing_status,
    filed_date TIMESTAMPTZ,
    acknowledgment_number TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. GST Transactions table - Individual transaction records
CREATE TABLE public.gst_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    gst_return_id UUID REFERENCES public.gst_returns(id) ON DELETE CASCADE,
    invoice_id UUID REFERENCES public.invoices(id) ON DELETE SET NULL,
    transaction_date DATE NOT NULL,
    transaction_type TEXT NOT NULL,
    party_name TEXT NOT NULL,
    invoice_number TEXT,
    taxable_amount NUMERIC(12,2) DEFAULT 0.00,
    cgst NUMERIC(12,2) DEFAULT 0.00,
    sgst NUMERIC(12,2) DEFAULT 0.00,
    igst NUMERIC(12,2) DEFAULT 0.00,
    total_gst NUMERIC(12,2) DEFAULT 0.00,
    gst_rate NUMERIC(5,2) DEFAULT 18.00,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 4. GST Filing Settings table - Business GST configuration
CREATE TABLE public.gst_filing_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    gstin TEXT,
    business_name TEXT NOT NULL,
    business_address TEXT,
    default_gst_rate NUMERIC(5,2) DEFAULT 18.00,
    auto_calculate BOOLEAN DEFAULT true,
    reminder_days_before INT DEFAULT 7,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id)
);

-- 5. Create indexes for efficient queries
CREATE INDEX idx_gst_returns_user_id ON public.gst_returns(user_id);
CREATE INDEX idx_gst_returns_period_start ON public.gst_returns(period_start_date);
CREATE INDEX idx_gst_returns_filing_status ON public.gst_returns(filing_status);
CREATE INDEX idx_gst_returns_filing_deadline ON public.gst_returns(filing_deadline);
CREATE INDEX idx_gst_transactions_return_id ON public.gst_transactions(gst_return_id);
CREATE INDEX idx_gst_transactions_invoice_id ON public.gst_transactions(invoice_id);
CREATE INDEX idx_gst_transactions_date ON public.gst_transactions(transaction_date);
CREATE INDEX idx_gst_filing_settings_user_id ON public.gst_filing_settings(user_id);

-- 6. Enable RLS for all GST tables
ALTER TABLE public.gst_returns ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gst_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gst_filing_settings ENABLE ROW LEVEL SECURITY;

-- 7. RLS Policies - Pattern 2: Simple User Ownership
CREATE POLICY "users_manage_own_gst_returns"
ON public.gst_returns
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_view_own_gst_transactions"
ON public.gst_transactions
FOR SELECT
TO authenticated
USING (
    gst_return_id IN (
        SELECT id FROM public.gst_returns WHERE user_id = auth.uid()
    )
);

CREATE POLICY "users_manage_own_gst_settings"
ON public.gst_filing_settings
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- 8. Trigger for updated_at
CREATE OR REPLACE FUNCTION public.update_gst_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

CREATE TRIGGER update_gst_returns_timestamp
BEFORE UPDATE ON public.gst_returns
FOR EACH ROW
EXECUTE FUNCTION public.update_gst_updated_at();

CREATE TRIGGER update_gst_settings_timestamp
BEFORE UPDATE ON public.gst_filing_settings
FOR EACH ROW
EXECUTE FUNCTION public.update_gst_updated_at();

-- 9. Demo data for GST Filing functionality
DO $$
DECLARE
    existing_user_id UUID;
    demo_return_q1 UUID := gen_random_uuid();
    demo_return_q2 UUID := gen_random_uuid();
BEGIN
    -- Get existing user ID from user_profiles
    SELECT id INTO existing_user_id FROM public.user_profiles LIMIT 1;
    
    IF existing_user_id IS NULL THEN
        RAISE NOTICE 'No existing users found. Run auth migration first or create users manually.';
        RETURN;
    END IF;

    -- Create demo GST filing settings
    INSERT INTO public.gst_filing_settings (
        user_id, 
        gstin, 
        business_name, 
        business_address,
        default_gst_rate,
        auto_calculate,
        reminder_days_before
    ) VALUES (
        existing_user_id,
        '29ABCDE1234F1Z5',
        'DBC Cafe & Bistro',
        '123 Business Park, Bangalore, Karnataka - 560001',
        18.00,
        true,
        7
    );

    -- Create Q1 2025 GST Return (January-March)
    INSERT INTO public.gst_returns (
        id,
        user_id,
        return_period,
        period_type,
        period_start_date,
        period_end_date,
        filing_deadline,
        total_sales,
        total_purchases,
        input_tax_credit,
        output_tax,
        gst_payable,
        filing_status,
        filed_date,
        acknowledgment_number,
        notes
    ) VALUES (
        demo_return_q1,
        existing_user_id,
        'Q1-2025 (Jan-Mar)',
        'quarterly'::public.gst_period_type,
        '2025-01-01',
        '2025-03-31',
        '2025-04-20',
        450000.00,
        180000.00,
        32400.00,
        81000.00,
        48600.00,
        'filed'::public.gst_filing_status,
        '2025-04-15 14:30:00+00',
        'ACK-2025-Q1-000123',
        'Successfully filed Q1 2025 return'
    );

    -- Create Q2 2025 GST Return (April-June) - Pending
    INSERT INTO public.gst_returns (
        id,
        user_id,
        return_period,
        period_type,
        period_start_date,
        period_end_date,
        filing_deadline,
        total_sales,
        total_purchases,
        input_tax_credit,
        output_tax,
        gst_payable,
        filing_status,
        notes
    ) VALUES (
        demo_return_q2,
        existing_user_id,
        'Q2-2025 (Apr-Jun)',
        'quarterly'::public.gst_period_type,
        '2025-04-01',
        '2025-06-30',
        '2025-07-20',
        525000.00,
        195000.00,
        35100.00,
        94500.00,
        59400.00,
        'pending'::public.gst_filing_status,
        'Auto-calculated from sales and purchase records'
    );

    -- Create demo transactions for Q1
    INSERT INTO public.gst_transactions (
        gst_return_id,
        transaction_date,
        transaction_type,
        party_name,
        invoice_number,
        taxable_amount,
        cgst,
        sgst,
        igst,
        total_gst,
        gst_rate
    ) VALUES
    (
        demo_return_q1,
        '2025-01-15',
        'Sales',
        'ABC Enterprises',
        'INV-2025-001',
        50000.00,
        4500.00,
        4500.00,
        0.00,
        9000.00,
        18.00
    ),
    (
        demo_return_q1,
        '2025-02-20',
        'Sales',
        'XYZ Corporation',
        'INV-2025-045',
        75000.00,
        6750.00,
        6750.00,
        0.00,
        13500.00,
        18.00
    ),
    (
        demo_return_q1,
        '2025-01-10',
        'Purchase',
        'PQR Suppliers',
        'PINV-2025-012',
        30000.00,
        2700.00,
        2700.00,
        0.00,
        5400.00,
        18.00
    ),
    (
        demo_return_q1,
        '2025-03-05',
        'Purchase',
        'LMN Traders',
        'PINV-2025-089',
        45000.00,
        4050.00,
        4050.00,
        0.00,
        8100.00,
        18.00
    );

    -- Create demo transactions for Q2
    INSERT INTO public.gst_transactions (
        gst_return_id,
        transaction_date,
        transaction_type,
        party_name,
        invoice_number,
        taxable_amount,
        cgst,
        sgst,
        igst,
        total_gst,
        gst_rate
    ) VALUES
    (
        demo_return_q2,
        '2025-04-12',
        'Sales',
        'DEF Industries',
        'INV-2025-101',
        85000.00,
        7650.00,
        7650.00,
        0.00,
        15300.00,
        18.00
    ),
    (
        demo_return_q2,
        '2025-05-18',
        'Purchase',
        'GHI Supplies Co',
        'PINV-2025-145',
        40000.00,
        3600.00,
        3600.00,
        0.00,
        7200.00,
        18.00
    );

END $$;