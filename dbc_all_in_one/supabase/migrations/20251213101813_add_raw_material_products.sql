-- =====================================================
-- Migration: Add Raw Material Products
-- Timestamp: 20251213101813
-- Description: Add fresh raw materials like tomatoes, onions, and other ingredients
-- =====================================================

-- Insert raw material products into marketplace_products
INSERT INTO public.marketplace_products (product_name, category, description, base_unit, image_url, is_active) VALUES
('Fresh Tomatoes', 'raw_materials'::product_category, 'Vine-ripened fresh tomatoes, perfect for cooking and salads', 'kg', 'https://images.pexels.com/photos/1327838/pexels-photo-1327838.jpeg', true),
('Red Onions', 'raw_materials'::product_category, 'Premium quality red onions with strong flavor', 'kg', 'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb', true),
('White Onions', 'raw_materials'::product_category, 'Fresh white onions ideal for all cooking needs', 'kg', 'https://images.pexels.com/photos/1359326/pexels-photo-1359326.jpeg', true),
('Fresh Garlic', 'raw_materials'::product_category, 'High-quality fresh garlic bulbs with intense flavor', 'kg', 'https://images.unsplash.com/photo-1588595243912-ed7dfc8fa7ce', true),
('Fresh Ginger', 'raw_materials'::product_category, 'Premium quality fresh ginger root', 'kg', 'https://images.pexels.com/photos/161556/ginger-plant-asia-rhizome-161556.jpeg', true),
('Green Chillies', 'raw_materials'::product_category, 'Fresh green chillies for spicy dishes', 'kg', 'https://images.unsplash.com/photo-1583663835648-62c5dba30e4e', true),
('Coriander Leaves', 'raw_materials'::product_category, 'Fresh coriander leaves (cilantro) for garnishing', 'bunch', 'https://images.pexels.com/photos/4113896/pexels-photo-4113896.jpeg', true),
('Fresh Spinach', 'raw_materials'::product_category, 'Organic fresh spinach leaves, nutrient-rich', 'kg', 'https://images.unsplash.com/photo-1576045057995-568f588f82fb', true),
('Potatoes', 'raw_materials'::product_category, 'Premium quality fresh potatoes for all cooking methods', 'kg', 'https://images.pexels.com/photos/144248/potatoes-vegetables-erdfrucht-bio-144248.jpeg', true),
('Carrots', 'raw_materials'::product_category, 'Fresh orange carrots, crisp and sweet', 'kg', 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37', true),
('Bell Peppers (Mixed)', 'raw_materials'::product_category, 'Colorful mix of red, yellow, and green bell peppers', 'kg', 'https://images.pexels.com/photos/594137/pexels-photo-594137.jpeg', true),
('Fresh Cabbage', 'raw_materials'::product_category, 'Crisp green cabbage, perfect for salads and cooking', 'piece', 'https://images.unsplash.com/photo-1594282032003-d45a35890ff4', true),
('Cauliflower', 'raw_materials'::product_category, 'Fresh white cauliflower heads', 'piece', 'https://images.pexels.com/photos/1420226/pexels-photo-1420226.jpeg', true),
('Fresh Lemons', 'raw_materials'::product_category, 'Juicy fresh lemons for cooking and beverages', 'kg', 'https://images.unsplash.com/photo-1590502593747-42a996133562', true),
('Fresh Mint Leaves', 'raw_materials'::product_category, 'Aromatic fresh mint leaves for beverages and cooking', 'bunch', 'https://images.pexels.com/photos/5794415/pexels-photo-5794415.jpeg', true);

-- Insert vendor listings for raw material products
-- Using existing vendor IDs from the vendors table
-- Vendor ID: 310a8603-4122-4033-9531-6bb67ec94be2 (Fresh Farms Supply)
-- Vendor ID: 32af7afb-4e59-41b5-9f8b-074b5366ff8d (Premium Meats Co - can also supply vegetables)

WITH inserted_products AS (
  SELECT id, product_name FROM public.marketplace_products 
  WHERE category = 'raw_materials'::product_category
  AND created_at >= NOW() - INTERVAL '1 minute'
)
INSERT INTO public.vendor_product_listings (
  vendor_id, 
  product_id, 
  price_per_unit, 
  current_stock, 
  min_order_quantity, 
  delivery_time_days, 
  location_proximity, 
  availability_status, 
  listing_status, 
  vendor_sku, 
  certifications, 
  bulk_pricing,
  views_count,
  orders_count
)
SELECT 
  '310a8603-4122-4033-9531-6bb67ec94be2'::uuid,
  id,
  CASE product_name
    WHEN 'Fresh Tomatoes' THEN 2.99
    WHEN 'Red Onions' THEN 1.99
    WHEN 'White Onions' THEN 1.79
    WHEN 'Fresh Garlic' THEN 4.99
    WHEN 'Fresh Ginger' THEN 3.49
    WHEN 'Green Chillies' THEN 2.49
    WHEN 'Coriander Leaves' THEN 1.50
    WHEN 'Fresh Spinach' THEN 3.99
    WHEN 'Potatoes' THEN 1.49
    WHEN 'Carrots' THEN 1.99
    WHEN 'Bell Peppers (Mixed)' THEN 5.99
    WHEN 'Fresh Cabbage' THEN 2.50
    WHEN 'Cauliflower' THEN 3.50
    WHEN 'Fresh Lemons' THEN 2.99
    WHEN 'Fresh Mint Leaves' THEN 1.80
  END,
  CASE product_name
    WHEN 'Fresh Tomatoes' THEN 500
    WHEN 'Red Onions' THEN 800
    WHEN 'White Onions' THEN 750
    WHEN 'Fresh Garlic' THEN 300
    WHEN 'Fresh Ginger' THEN 400
    WHEN 'Green Chillies' THEN 200
    WHEN 'Coriander Leaves' THEN 150
    WHEN 'Fresh Spinach' THEN 250
    WHEN 'Potatoes' THEN 1000
    WHEN 'Carrots' THEN 600
    WHEN 'Bell Peppers (Mixed)' THEN 350
    WHEN 'Fresh Cabbage' THEN 200
    WHEN 'Cauliflower' THEN 180
    WHEN 'Fresh Lemons' THEN 400
    WHEN 'Fresh Mint Leaves' THEN 100
  END,
  CASE product_name
    WHEN 'Coriander Leaves' THEN 5
    WHEN 'Fresh Mint Leaves' THEN 5
    WHEN 'Fresh Cabbage' THEN 1
    WHEN 'Cauliflower' THEN 1
    ELSE 2
  END,
  1,
  '10 km',
  'in_stock'::product_availability_status,
  'active'::listing_status,
  'FF-RM-' || LPAD((ROW_NUMBER() OVER())::text, 3, '0'),
  ARRAY['Fresh', 'Local Farm', 'Daily Harvest']::text[],
  jsonb_build_object(
    '50', ROUND((
      CASE product_name
        WHEN 'Fresh Tomatoes' THEN 2.99
        WHEN 'Red Onions' THEN 1.99
        WHEN 'White Onions' THEN 1.79
        WHEN 'Fresh Garlic' THEN 4.99
        WHEN 'Fresh Ginger' THEN 3.49
        WHEN 'Green Chillies' THEN 2.49
        WHEN 'Coriander Leaves' THEN 1.50
        WHEN 'Fresh Spinach' THEN 3.99
        WHEN 'Potatoes' THEN 1.49
        WHEN 'Carrots' THEN 1.99
        WHEN 'Bell Peppers (Mixed)' THEN 5.99
        WHEN 'Fresh Cabbage' THEN 2.50
        WHEN 'Cauliflower' THEN 3.50
        WHEN 'Fresh Lemons' THEN 2.99
        WHEN 'Fresh Mint Leaves' THEN 1.80
      END * 0.90
    )::numeric, 2),
    '100', ROUND((
      CASE product_name
        WHEN 'Fresh Tomatoes' THEN 2.99
        WHEN 'Red Onions' THEN 1.99
        WHEN 'White Onions' THEN 1.79
        WHEN 'Fresh Garlic' THEN 4.99
        WHEN 'Fresh Ginger' THEN 3.49
        WHEN 'Green Chillies' THEN 2.49
        WHEN 'Coriander Leaves' THEN 1.50
        WHEN 'Fresh Spinach' THEN 3.99
        WHEN 'Potatoes' THEN 1.49
        WHEN 'Carrots' THEN 1.99
        WHEN 'Bell Peppers (Mixed)' THEN 5.99
        WHEN 'Fresh Cabbage' THEN 2.50
        WHEN 'Cauliflower' THEN 3.50
        WHEN 'Fresh Lemons' THEN 2.99
        WHEN 'Fresh Mint Leaves' THEN 1.80
      END * 0.85
    )::numeric, 2)
  ),
  FLOOR(RANDOM() * 200 + 50)::integer,
  FLOOR(RANDOM() * 80 + 10)::integer
FROM inserted_products;

-- Verify insertion
DO $$
DECLARE
  product_count INTEGER;
  listing_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO product_count FROM public.marketplace_products WHERE category = 'raw_materials'::product_category;
  SELECT COUNT(*) INTO listing_count FROM public.vendor_product_listings vpl
  INNER JOIN public.marketplace_products mp ON vpl.product_id = mp.id
  WHERE mp.category = 'raw_materials'::product_category;
  
  RAISE NOTICE 'Migration completed successfully!';
  RAISE NOTICE 'Total raw material products: %', product_count;
  RAISE NOTICE 'Total vendor listings for raw materials: %', listing_count;
END $$;