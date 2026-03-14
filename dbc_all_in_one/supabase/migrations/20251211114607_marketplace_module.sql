-- Location: supabase/migrations/20251211114607_marketplace_module.sql
-- Schema Analysis: Existing schema has staff hiring tables (user_profiles referenced)
-- Integration Type: NEW MODULE - Marketplace for inventory goods
-- Dependencies: References existing user_profiles table

-- 1. Create ENUM types for marketplace
CREATE TYPE public.product_condition AS ENUM ('new', 'like_new', 'good', 'fair', 'poor');
CREATE TYPE public.product_category AS ENUM ('raw_materials', 'equipment', 'finished_goods', 'supplies', 'electronics', 'furniture', 'other');
CREATE TYPE public.listing_status AS ENUM ('active', 'sold', 'reserved', 'inactive');
CREATE TYPE public.order_status AS ENUM ('pending', 'confirmed', 'shipped', 'delivered', 'cancelled');

-- 2. Create marketplace_products table
CREATE TABLE public.marketplace_products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    seller_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    category public.product_category NOT NULL,
    condition public.product_condition DEFAULT 'good'::public.product_condition,
    price DECIMAL(10,2) NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    unit TEXT NOT NULL DEFAULT 'piece',
    image_url TEXT,
    status public.listing_status DEFAULT 'active'::public.listing_status,
    location TEXT,
    is_featured BOOLEAN DEFAULT false,
    views INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Create marketplace_orders table
CREATE TABLE public.marketplace_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID REFERENCES public.marketplace_products(id) ON DELETE CASCADE,
    buyer_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    seller_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    status public.order_status DEFAULT 'pending'::public.order_status,
    delivery_address TEXT,
    delivery_date TIMESTAMPTZ,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 4. Create marketplace_reviews table
CREATE TABLE public.marketplace_reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID REFERENCES public.marketplace_products(id) ON DELETE CASCADE,
    reviewer_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 5. Create indexes for performance
CREATE INDEX idx_marketplace_products_seller ON public.marketplace_products(seller_id);
CREATE INDEX idx_marketplace_products_category ON public.marketplace_products(category);
CREATE INDEX idx_marketplace_products_status ON public.marketplace_products(status);
CREATE INDEX idx_marketplace_products_created ON public.marketplace_products(created_at DESC);
CREATE INDEX idx_marketplace_orders_buyer ON public.marketplace_orders(buyer_id);
CREATE INDEX idx_marketplace_orders_seller ON public.marketplace_orders(seller_id);
CREATE INDEX idx_marketplace_orders_product ON public.marketplace_orders(product_id);
CREATE INDEX idx_marketplace_orders_status ON public.marketplace_orders(status);
CREATE INDEX idx_marketplace_reviews_product ON public.marketplace_reviews(product_id);

-- 6. Enable RLS
ALTER TABLE public.marketplace_products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.marketplace_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.marketplace_reviews ENABLE ROW LEVEL SECURITY;

-- 7. RLS Policies for marketplace_products
-- Pattern 4: Public read, authenticated write
CREATE POLICY "public_can_read_products"
ON public.marketplace_products
FOR SELECT
TO public
USING (true);

CREATE POLICY "users_manage_own_products"
ON public.marketplace_products
FOR ALL
TO authenticated
USING (seller_id = auth.uid())
WITH CHECK (seller_id = auth.uid());

-- 8. RLS Policies for marketplace_orders
-- Pattern 2: Simple user ownership (buyer or seller can access)
CREATE POLICY "users_manage_own_orders"
ON public.marketplace_orders
FOR ALL
TO authenticated
USING (buyer_id = auth.uid() OR seller_id = auth.uid())
WITH CHECK (buyer_id = auth.uid() OR seller_id = auth.uid());

-- 9. RLS Policies for marketplace_reviews
-- Pattern 4: Public read, authenticated write
CREATE POLICY "public_can_read_reviews"
ON public.marketplace_reviews
FOR SELECT
TO public
USING (true);

CREATE POLICY "users_manage_own_reviews"
ON public.marketplace_reviews
FOR ALL
TO authenticated
USING (reviewer_id = auth.uid())
WITH CHECK (reviewer_id = auth.uid());

-- 10. Functions for automatic timestamp updates
CREATE OR REPLACE FUNCTION public.handle_marketplace_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

CREATE TRIGGER marketplace_products_updated_at
BEFORE UPDATE ON public.marketplace_products
FOR EACH ROW
EXECUTE FUNCTION public.handle_marketplace_updated_at();

CREATE TRIGGER marketplace_orders_updated_at
BEFORE UPDATE ON public.marketplace_orders
FOR EACH ROW
EXECUTE FUNCTION public.handle_marketplace_updated_at();

-- 11. Mock data for marketplace
DO $$
DECLARE
    existing_user_id UUID;
    product1_id UUID := gen_random_uuid();
    product2_id UUID := gen_random_uuid();
    product3_id UUID := gen_random_uuid();
    product4_id UUID := gen_random_uuid();
    product5_id UUID := gen_random_uuid();
BEGIN
    -- Get existing user ID from user_profiles
    SELECT id INTO existing_user_id FROM public.user_profiles LIMIT 1;
    
    IF existing_user_id IS NOT NULL THEN
        -- Insert sample products
        INSERT INTO public.marketplace_products (
            id, seller_id, title, description, category, condition, price, quantity, unit, image_url, status, location, is_featured
        ) VALUES
            (product1_id, existing_user_id, 'Commercial Grade Tomatoes', 'Fresh organic tomatoes, perfect for restaurants. Bulk quantities available.', 
             'raw_materials'::public.product_category, 'new'::public.product_condition, 45.00, 100, 'kg', 
             'https://img.rocket.new/generatedImages/rocket_gen_img_187bc0b48-1764686062386.png', 
             'active'::public.listing_status, 'Main Warehouse', true),
            
            (product2_id, existing_user_id, 'Industrial Kitchen Mixer', 'Heavy-duty commercial mixer, barely used. 3-year warranty remaining.', 
             'equipment'::public.product_category, 'like_new'::public.product_condition, 1200.00, 1, 'piece', 
             'https://images.unsplash.com/photo-1614887153139-d47c98c4f0c6', 
             'active'::public.listing_status, 'Kitchen Store', true),
            
            (product3_id, existing_user_id, 'Premium Olive Oil', 'Extra virgin olive oil in bulk. Perfect for commercial use.', 
             'raw_materials'::public.product_category, 'new'::public.product_condition, 35.00, 50, 'bottles', 
             'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5', 
             'active'::public.listing_status, 'Counter', false),
            
            (product4_id, existing_user_id, 'Restaurant Tables Set', 'Set of 10 wooden restaurant tables. Good condition, some minor scratches.', 
             'furniture'::public.product_category, 'good'::public.product_condition, 500.00, 10, 'pieces', 
             'https://images.unsplash.com/photo-1555041469-a586c61ea9bc', 
             'active'::public.listing_status, 'Storage Room', false),
            
            (product5_id, existing_user_id, 'Commercial Coffee Machine', 'Professional espresso machine with grinder. Excellent condition.', 
             'equipment'::public.product_category, 'like_new'::public.product_condition, 850.00, 1, 'piece', 
             'https://images.unsplash.com/photo-1690983325192-a4c13c2e331d', 
             'active'::public.listing_status, 'Counter', true);
        
        -- Insert sample reviews
        INSERT INTO public.marketplace_reviews (product_id, reviewer_id, rating, comment) VALUES
            (product1_id, existing_user_id, 5, 'Excellent quality tomatoes! Fresh and perfect for our restaurant.'),
            (product2_id, existing_user_id, 4, 'Great mixer, works perfectly. Delivery was fast.'),
            (product3_id, existing_user_id, 5, 'Best olive oil we have purchased. Highly recommend!');
    ELSE
        RAISE NOTICE 'No existing users found. Run auth migration first or create users manually.';
    END IF;
END $$;