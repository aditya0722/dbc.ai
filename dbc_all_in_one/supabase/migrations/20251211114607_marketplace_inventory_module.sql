-- Location: supabase/migrations/20251211114607_marketplace_inventory_module.sql
-- Schema Analysis: Existing schema has hiring module (user_profiles, job_positions, job_applications, interview_schedules)
-- Integration Type: NEW_MODULE - Adding marketplace functionality for inventory goods
-- Dependencies: Existing user_profiles table

-- 1. ENUM Types
CREATE TYPE public.product_category AS ENUM ('food_beverage', 'equipment', 'supplies', 'raw_materials');
CREATE TYPE public.product_availability_status AS ENUM ('in_stock', 'low_stock', 'out_of_stock', 'pre_order');
CREATE TYPE public.listing_status AS ENUM ('active', 'pending', 'out_of_stock', 'discontinued');

-- 2. Core Tables

-- Vendors table
CREATE TABLE public.vendors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_name TEXT NOT NULL,
    contact_email TEXT NOT NULL,
    contact_phone TEXT,
    business_address TEXT,
    rating DECIMAL(3, 2) DEFAULT 0.00 CHECK (rating >= 0 AND rating <= 5),
    total_reviews INTEGER DEFAULT 0,
    is_verified BOOLEAN DEFAULT false,
    created_by UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Marketplace products master table
CREATE TABLE public.marketplace_products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_name TEXT NOT NULL,
    description TEXT,
    category public.product_category NOT NULL,
    base_unit TEXT NOT NULL,
    image_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Vendor product listings
CREATE TABLE public.vendor_product_listings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_id UUID REFERENCES public.vendors(id) ON DELETE CASCADE,
    product_id UUID REFERENCES public.marketplace_products(id) ON DELETE CASCADE,
    vendor_sku TEXT,
    price_per_unit DECIMAL(10, 2) NOT NULL CHECK (price_per_unit >= 0),
    min_order_quantity INTEGER DEFAULT 1 CHECK (min_order_quantity > 0),
    current_stock INTEGER DEFAULT 0 CHECK (current_stock >= 0),
    availability_status public.product_availability_status DEFAULT 'in_stock'::public.product_availability_status,
    listing_status public.listing_status DEFAULT 'active'::public.listing_status,
    delivery_time_days INTEGER,
    bulk_pricing JSONB,
    certifications TEXT[],
    location_proximity TEXT,
    views_count INTEGER DEFAULT 0,
    orders_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Indexes
CREATE INDEX idx_vendors_created_by ON public.vendors(created_by);
CREATE INDEX idx_vendors_rating ON public.vendors(rating DESC);
CREATE INDEX idx_marketplace_products_category ON public.marketplace_products(category);
CREATE INDEX idx_marketplace_products_active ON public.marketplace_products(is_active);
CREATE INDEX idx_vendor_listings_vendor ON public.vendor_product_listings(vendor_id);
CREATE INDEX idx_vendor_listings_product ON public.vendor_product_listings(product_id);
CREATE INDEX idx_vendor_listings_status ON public.vendor_product_listings(listing_status);
CREATE INDEX idx_vendor_listings_availability ON public.vendor_product_listings(availability_status);

-- 4. Functions (MUST BE BEFORE RLS POLICIES)

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $func$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$func$;

-- Function to get active marketplace products count
CREATE OR REPLACE FUNCTION public.get_active_products_count()
RETURNS BIGINT
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT COUNT(*)
FROM public.marketplace_products
WHERE is_active = true
$$;

-- Function to check vendor ownership
CREATE OR REPLACE FUNCTION public.is_vendor_owner(vendor_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.vendors v
    WHERE v.id = vendor_uuid 
    AND v.created_by = auth.uid()
)
$$;

-- 5. Enable RLS
ALTER TABLE public.vendors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.marketplace_products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vendor_product_listings ENABLE ROW LEVEL SECURITY;

-- 6. RLS Policies

-- Vendors policies
CREATE POLICY "public_can_view_vendors"
ON public.vendors
FOR SELECT
TO public
USING (true);

CREATE POLICY "users_manage_own_vendors"
ON public.vendors
FOR ALL
TO authenticated
USING (created_by = auth.uid())
WITH CHECK (created_by = auth.uid());

-- Marketplace products policies (public read, vendors manage)
CREATE POLICY "public_can_view_products"
ON public.marketplace_products
FOR SELECT
TO public
USING (is_active = true);

CREATE POLICY "authenticated_manage_products"
ON public.marketplace_products
FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- Vendor listings policies
CREATE POLICY "public_can_view_active_listings"
ON public.vendor_product_listings
FOR SELECT
TO public
USING (listing_status = 'active'::public.listing_status);

CREATE POLICY "vendors_manage_own_listings"
ON public.vendor_product_listings
FOR ALL
TO authenticated
USING (public.is_vendor_owner(vendor_id))
WITH CHECK (public.is_vendor_owner(vendor_id));

-- 7. Triggers
CREATE TRIGGER update_vendors_updated_at
BEFORE UPDATE ON public.vendors
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_marketplace_products_updated_at
BEFORE UPDATE ON public.marketplace_products
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_vendor_listings_updated_at
BEFORE UPDATE ON public.vendor_product_listings
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

-- 8. Mock Data
DO $$
DECLARE
    existing_user_id UUID;
    vendor1_id UUID := gen_random_uuid();
    vendor2_id UUID := gen_random_uuid();
    vendor3_id UUID := gen_random_uuid();
    product1_id UUID := gen_random_uuid();
    product2_id UUID := gen_random_uuid();
    product3_id UUID := gen_random_uuid();
    product4_id UUID := gen_random_uuid();
    product5_id UUID := gen_random_uuid();
BEGIN
    -- Get existing user ID
    SELECT id INTO existing_user_id FROM public.user_profiles LIMIT 1;
    
    IF existing_user_id IS NULL THEN
        RAISE NOTICE 'No existing users found. Run auth migration first or create users manually.';
        RETURN;
    END IF;
    
    -- Insert vendors
    INSERT INTO public.vendors (id, vendor_name, contact_email, contact_phone, business_address, rating, total_reviews, is_verified, created_by)
    VALUES
        (vendor1_id, 'Fresh Farms Supply', 'contact@freshfarms.com', '+1-555-0101', '123 Farm Road, Agricultural District', 4.8, 156, true, existing_user_id),
        (vendor2_id, 'Premium Meats Co', 'sales@premiummeats.com', '+1-555-0102', '456 Industrial Ave, Food Zone', 4.6, 98, true, existing_user_id),
        (vendor3_id, 'Global Equipment Ltd', 'info@globalequip.com', '+1-555-0103', '789 Commerce St, Business Park', 4.7, 124, true, existing_user_id);
    
    -- Insert marketplace products
    INSERT INTO public.marketplace_products (id, product_name, description, category, base_unit, image_url, is_active)
    VALUES
        (product1_id, 'Organic Tomatoes', 'Fresh organic tomatoes from local farms', 'food_beverage'::public.product_category, 'kg', 'https://images.unsplash.com/photo-1546470427-227a4e2d9b6a', true),
        (product2_id, 'Premium Chicken Breast', 'Grade A chicken breast, hormone-free', 'raw_materials'::public.product_category, 'kg', 'https://images.unsplash.com/photo-1604503468506-a8da13d82791', true),
        (product3_id, 'Extra Virgin Olive Oil', 'First cold pressed olive oil, 1L bottles', 'food_beverage'::public.product_category, 'bottle', 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5', true),
        (product4_id, 'Commercial Pasta', 'Bulk pasta for restaurants, various shapes', 'supplies'::public.product_category, 'kg', 'https://images.unsplash.com/photo-1551462147-37d682293562', true),
        (product5_id, 'Industrial Coffee Maker', 'Professional grade coffee machine, 50 cups capacity', 'equipment'::public.product_category, 'unit', 'https://images.unsplash.com/photo-1517668808822-9ebb02f2a0e6', true);
    
    -- Insert vendor listings
    INSERT INTO public.vendor_product_listings (vendor_id, product_id, vendor_sku, price_per_unit, min_order_quantity, current_stock, availability_status, listing_status, delivery_time_days, bulk_pricing, certifications, location_proximity, views_count, orders_count)
    VALUES
        (vendor1_id, product1_id, 'FF-TOM-001', 3.50, 10, 500, 'in_stock'::public.product_availability_status, 'active'::public.listing_status, 2, '{"50": 3.20, "100": 2.80}'::jsonb, ARRAY['Organic', 'Non-GMO'], '15 km', 234, 45),
        (vendor1_id, product3_id, 'FF-OIL-001', 12.99, 5, 150, 'in_stock'::public.product_availability_status, 'active'::public.listing_status, 3, '{"20": 11.50, "50": 10.00}'::jsonb, ARRAY['Organic', 'First Press'], '15 km', 189, 32),
        (vendor2_id, product2_id, 'PM-CHK-001', 8.75, 5, 80, 'low_stock'::public.product_availability_status, 'active'::public.listing_status, 1, '{"50": 8.00, "100": 7.50}'::jsonb, ARRAY['Grade A', 'Hormone-Free'], '8 km', 312, 67),
        (vendor3_id, product4_id, 'GE-PST-001', 4.20, 20, 300, 'in_stock'::public.product_availability_status, 'active'::public.listing_status, 5, '{"100": 3.80, "200": 3.50}'::jsonb, ARRAY['Food Safe'], '25 km', 156, 28),
        (vendor3_id, product5_id, 'GE-CFM-001', 1299.99, 1, 5, 'low_stock'::public.product_availability_status, 'active'::public.listing_status, 7, NULL, ARRAY['Commercial Grade', 'Warranty 2 Years'], '25 km', 89, 12);
END $$;