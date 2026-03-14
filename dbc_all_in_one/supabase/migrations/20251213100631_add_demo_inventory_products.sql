-- Location: supabase/migrations/20251213100631_add_demo_inventory_products.sql
-- Schema Analysis: Existing marketplace_products and vendor_product_listings tables with ENUMs
-- Integration Type: Additive - Adding comprehensive demo products
-- Dependencies: marketplace_products, vendor_product_listings, vendors

-- Add diverse demo products across all categories
DO $$
DECLARE
    -- Product IDs
    olive_oil_id UUID := gen_random_uuid();
    rice_id UUID := gen_random_uuid();
    pasta_id UUID := gen_random_uuid();
    flour_id UUID := gen_random_uuid();
    sugar_id UUID := gen_random_uuid();
    coffee_id UUID := gen_random_uuid();
    tea_id UUID := gen_random_uuid();
    milk_id UUID := gen_random_uuid();
    
    commercial_oven_id UUID := gen_random_uuid();
    industrial_mixer_id UUID := gen_random_uuid();
    refrigerator_id UUID := gen_random_uuid();
    food_processor_id UUID := gen_random_uuid();
    
    gloves_id UUID := gen_random_uuid();
    aprons_id UUID := gen_random_uuid();
    containers_id UUID := gen_random_uuid();
    cleaning_supplies_id UUID := gen_random_uuid();
    
    beef_id UUID := gen_random_uuid();
    fish_id UUID := gen_random_uuid();
    vegetables_id UUID := gen_random_uuid();
    spices_id UUID := gen_random_uuid();
    
    -- Vendor IDs (get existing vendors)
    vendor1_id UUID;
    vendor2_id UUID;
BEGIN
    -- Get existing vendor IDs
    SELECT id INTO vendor1_id FROM public.vendors WHERE vendor_name = 'Fresh Farms Supply' LIMIT 1;
    SELECT id INTO vendor2_id FROM public.vendors WHERE vendor_name = 'Premium Meats Co' LIMIT 1;
    
    -- Insert demo products - Food & Beverage category
    INSERT INTO public.marketplace_products (id, product_name, description, category, base_unit, image_url, is_active) VALUES
        (olive_oil_id, 'Extra Virgin Olive Oil', 'Cold-pressed premium olive oil from Italy', 'food_beverage'::public.product_category, 'liter', 'https://images.pexels.com/photos/33783/olive-oil-salad-dressing-cooking-olive.jpg', true),
        (rice_id, 'Basmati Rice', 'Long-grain aromatic rice, perfect for biryanis', 'food_beverage'::public.product_category, 'kg', 'https://images.unsplash.com/photo-1586201375761-83865001e31c', true),
        (pasta_id, 'Italian Penne Pasta', 'Authentic Italian durum wheat pasta', 'food_beverage'::public.product_category, 'kg', 'https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg', true),
        (flour_id, 'All-Purpose Wheat Flour', 'Premium quality refined wheat flour', 'food_beverage'::public.product_category, 'kg', 'https://images.unsplash.com/photo-1586444248902-2f64eddc13df', true),
        (sugar_id, 'White Granulated Sugar', 'Pure cane sugar for cooking and baking', 'food_beverage'::public.product_category, 'kg', 'https://images.pexels.com/photos/7283338/pexels-photo-7283338.jpeg', true),
        (coffee_id, 'Arabica Coffee Beans', 'Premium roasted coffee beans from Colombia', 'food_beverage'::public.product_category, 'kg', 'https://images.unsplash.com/photo-1447933601403-0c6688de566e', true),
        (tea_id, 'Green Tea Leaves', 'Organic green tea from Darjeeling', 'food_beverage'::public.product_category, 'kg', 'https://images.pexels.com/photos/1638280/pexels-photo-1638280.jpeg', true),
        (milk_id, 'Fresh Dairy Milk', 'Full-cream pasteurized milk', 'food_beverage'::public.product_category, 'liter', 'https://images.unsplash.com/photo-1550583724-b2692b85b150', true);
    
    -- Insert demo products - Equipment category
    INSERT INTO public.marketplace_products (id, product_name, description, category, base_unit, image_url, is_active) VALUES
        (commercial_oven_id, 'Commercial Gas Oven', 'Heavy-duty stainless steel oven for restaurants', 'equipment'::public.product_category, 'unit', 'https://images.pexels.com/photos/2253643/pexels-photo-2253643.jpeg', true),
        (industrial_mixer_id, 'Industrial Stand Mixer', '20-liter professional mixer for bakeries', 'equipment'::public.product_category, 'unit', 'https://images.unsplash.com/photo-1556912172-45b7abe8b7e1', true),
        (refrigerator_id, 'Walk-in Refrigerator', 'Large capacity cold storage unit', 'equipment'::public.product_category, 'unit', 'https://images.pexels.com/photos/2291599/pexels-photo-2291599.jpeg', true),
        (food_processor_id, 'Commercial Food Processor', 'Heavy-duty food processor with multiple blades', 'equipment'::public.product_category, 'unit', 'https://images.unsplash.com/photo-1615485500185-c2f60d7831c7', true);
    
    -- Insert demo products - Supplies category
    INSERT INTO public.marketplace_products (id, product_name, description, category, base_unit, image_url, is_active) VALUES
        (gloves_id, 'Disposable Food Gloves', 'Latex-free food handling gloves', 'supplies'::public.product_category, 'box', 'https://images.pexels.com/photos/4226890/pexels-photo-4226890.jpeg', true),
        (aprons_id, 'Chef Aprons', 'Professional waterproof kitchen aprons', 'supplies'::public.product_category, 'piece', 'https://images.unsplash.com/photo-1556906781-9a412961c28c', true),
        (containers_id, 'Food Storage Containers', 'BPA-free plastic storage containers with lids', 'supplies'::public.product_category, 'set', 'https://images.pexels.com/photos/6053761/pexels-photo-6053761.jpeg', true),
        (cleaning_supplies_id, 'Industrial Cleaning Kit', 'Complete cleaning supplies for commercial kitchens', 'supplies'::public.product_category, 'kit', 'https://images.unsplash.com/photo-1585421514738-01798e348b17', true);
    
    -- Insert demo products - Raw Materials category
    INSERT INTO public.marketplace_products (id, product_name, description, category, base_unit, image_url, is_active) VALUES
        (beef_id, 'Fresh Beef Cuts', 'Premium quality grass-fed beef', 'raw_materials'::public.product_category, 'kg', 'https://images.pexels.com/photos/2267872/pexels-photo-2267872.jpeg', true),
        (fish_id, 'Fresh Atlantic Salmon', 'Wild-caught salmon fillets', 'raw_materials'::public.product_category, 'kg', 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2', true),
        (vegetables_id, 'Mixed Fresh Vegetables', 'Assorted seasonal vegetables', 'raw_materials'::public.product_category, 'kg', 'https://images.pexels.com/photos/1300972/pexels-photo-1300972.jpeg', true),
        (spices_id, 'Whole Spice Mix', 'Premium blend of Indian spices', 'raw_materials'::public.product_category, 'kg', 'https://images.unsplash.com/photo-1596040033229-a0b3b3e35c02', true);
    
    -- Create vendor listings for food & beverage products
    INSERT INTO public.vendor_product_listings 
        (product_id, vendor_id, vendor_sku, price_per_unit, current_stock, min_order_quantity, 
         availability_status, listing_status, delivery_time_days, location_proximity, 
         bulk_pricing, certifications, views_count, orders_count) 
    VALUES
        (olive_oil_id, vendor1_id, 'FF-OLV-002', 14.99, 200, 5, 'in_stock'::public.product_availability_status, 'active'::public.listing_status, 2, '10 km', '{"10":13.5,"20":12.0}'::jsonb, ARRAY['Organic','Cold Pressed'], 145, 28),
        (rice_id, vendor1_id, 'FF-RIC-001', 5.99, 500, 10, 'in_stock'::public.product_availability_status, 'active'::public.listing_status, 2, '10 km', '{"50":5.5,"100":5.0}'::jsonb, ARRAY['Grade A','Non-GMO'], 312, 67),
        (pasta_id, vendor1_id, 'FF-PST-001', 4.50, 300, 5, 'in_stock'::public.product_availability_status, 'active'::public.listing_status, 3, '10 km', '{"20":4.0,"50":3.5}'::jsonb, ARRAY['Italian Certified'], 198, 45),
        (flour_id, vendor1_id, 'FF-FLR-001', 2.99, 1000, 25, 'in_stock'::public.product_availability_status, 'active'::public.listing_status, 1, '10 km', '{"100":2.5,"200":2.0}'::jsonb, ARRAY['Premium Grade'], 276, 89),
        (sugar_id, vendor1_id, 'FF-SGR-001', 3.25, 800, 20, 'in_stock'::public.product_availability_status, 'active'::public.listing_status, 2, '10 km', '{"50":3.0,"100":2.8}'::jsonb, ARRAY['Pure Cane'], 189, 54),
        (coffee_id, vendor1_id, 'FF-COF-001', 18.99, 150, 2, 'in_stock'::public.product_availability_status, 'active'::public.listing_status, 4, '10 km', '{"5":17.5,"10":16.0}'::jsonb, ARRAY['Fair Trade','Organic'], 234, 42),
        (tea_id, vendor1_id, 'FF-TEA-001', 12.50, 120, 1, 'in_stock'::public.product_availability_status, 'active'::public.listing_status, 3, '10 km', '{"5":11.5,"10":10.5}'::jsonb, ARRAY['Organic','Darjeeling'], 167, 31),
        (milk_id, vendor1_id, 'FF-MLK-001', 3.99, 200, 5, 'in_stock'::public.product_availability_status, 'active'::public.listing_status, 1, '10 km', '{"20":3.5,"50":3.0}'::jsonb, ARRAY['Pasteurized','Full Cream'], 289, 78);
    
    -- Create vendor listings for equipment
    INSERT INTO public.vendor_product_listings 
        (product_id, vendor_id, vendor_sku, price_per_unit, current_stock, min_order_quantity, 
         availability_status, listing_status, delivery_time_days, location_proximity, 
         bulk_pricing, certifications, views_count, orders_count) 
    VALUES
        (commercial_oven_id, vendor2_id, 'PM-OVN-001', 2499.99, 5, 1, 'in_stock'::public.product_availability_status, 'active'::public.listing_status, 7, '20 km', '{"2":2300,"3":2100}'::jsonb, ARRAY['CE Certified','Energy Star'], 89, 3),
        (industrial_mixer_id, vendor2_id, 'PM-MXR-001', 1899.99, 8, 1, 'in_stock'::public.product_availability_status, 'active'::public.listing_status, 5, '20 km', '{"2":1750,"3":1600}'::jsonb, ARRAY['Commercial Grade'], 124, 7),
        (refrigerator_id, vendor2_id, 'PM-RFG-001', 4999.99, 3, 1, 'low_stock'::public.product_availability_status, 'active'::public.listing_status, 10, '20 km', '{"2":4500}'::jsonb, ARRAY['Industrial Grade','Energy Efficient'], 67, 2),
        (food_processor_id, vendor2_id, 'PM-FPR-001', 899.99, 12, 1, 'in_stock'::public.product_availability_status, 'active'::public.listing_status, 4, '20 km', '{"3":850,"5":800}'::jsonb, ARRAY['Heavy Duty'], 156, 11);
    
    -- Create vendor listings for supplies
    INSERT INTO public.vendor_product_listings 
        (product_id, vendor_id, vendor_sku, price_per_unit, current_stock, min_order_quantity, 
         availability_status, listing_status, delivery_time_days, location_proximity, 
         bulk_pricing, certifications, views_count, orders_count) 
    VALUES
        (gloves_id, vendor1_id, 'FF-GLV-001', 8.99, 500, 10, 'in_stock'::public.product_availability_status, 'active'::public.listing_status, 2, '10 km', '{"50":8.0,"100":7.5}'::jsonb, ARRAY['Latex-free','FDA Approved'], 245, 56),
        (aprons_id, vendor1_id, 'FF-APR-001', 15.99, 200, 5, 'in_stock'::public.product_availability_status, 'active'::public.listing_status, 3, '10 km', '{"20":14.5,"50":13.0}'::jsonb, ARRAY['Waterproof','Professional'], 178, 34),
        (containers_id, vendor2_id, 'PM-CNT-001', 24.99, 150, 2, 'in_stock'::public.product_availability_status, 'active'::public.listing_status, 3, '20 km', '{"10":22.0,"20":20.0}'::jsonb, ARRAY['BPA-free','Microwave Safe'], 203, 41),
        (cleaning_supplies_id, vendor2_id, 'PM-CLN-001', 49.99, 80, 1, 'in_stock'::public.product_availability_status, 'active'::public.listing_status, 2, '20 km', '{"5":45.0,"10":42.0}'::jsonb, ARRAY['Industrial Grade','Food Safe'], 134, 23);
    
    -- Create vendor listings for raw materials
    INSERT INTO public.vendor_product_listings 
        (product_id, vendor_id, vendor_sku, price_per_unit, current_stock, min_order_quantity, 
         availability_status, listing_status, delivery_time_days, location_proximity, 
         bulk_pricing, certifications, views_count, orders_count) 
    VALUES
        (beef_id, vendor2_id, 'PM-BEF-001', 16.99, 300, 5, 'in_stock'::public.product_availability_status, 'active'::public.listing_status, 1, '20 km', '{"20":15.5,"50":14.0}'::jsonb, ARRAY['Grass-fed','Premium Grade'], 267, 61),
        (fish_id, vendor2_id, 'PM-FSH-001', 22.99, 150, 3, 'in_stock'::public.product_availability_status, 'active'::public.listing_status, 1, '20 km', '{"10":21.0,"20":19.5}'::jsonb, ARRAY['Wild-caught','Fresh'], 189, 38),
        (vegetables_id, vendor1_id, 'FF-VEG-001', 4.99, 400, 10, 'in_stock'::public.product_availability_status, 'active'::public.listing_status, 1, '10 km', '{"50":4.5,"100":4.0}'::jsonb, ARRAY['Organic','Farm Fresh'], 312, 87),
        (spices_id, vendor1_id, 'FF-SPC-001', 8.99, 200, 2, 'in_stock'::public.product_availability_status, 'active'::public.listing_status, 2, '10 km', '{"10":8.0,"20":7.5}'::jsonb, ARRAY['Premium Blend','Authentic'], 198, 47);
    
END $$;