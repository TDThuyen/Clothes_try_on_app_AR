SET FOREIGN_KEY_CHECKS=0;
TRUNCATE TABLE products;
TRUNCATE TABLE categories;
SET FOREIGN_KEY_CHECKS=1;

INSERT INTO categories (id,name,description,created_at,updated_at) VALUES
(1,'Kính Nam','Men eyewear',NOW(),NOW()),
(2,'Kính Nữ','Women eyewear',NOW(),NOW()),
(3,'Áo Nam','Men tops',NOW(),NOW()),
(4,'Áo Nữ','Women tops',NOW(),NOW()),
(5,'Quần Nam','Men bottoms',NOW(),NOW()),
(6,'Quần Nữ','Women bottoms',NOW(),NOW()),
(7,'Mũ Nam','Men headwear',NOW(),NOW()),
(8,'Mũ Nữ','Women headwear',NOW(),NOW());

INSERT INTO products
(id,name,description,price,category_id,gender,available_sizes,color,image_url,ar_model_url,rating_avg,created_at,updated_at) VALUES
(2001,'Ion Drift Pilot','Polarized aviator lens, stainless bridge.',3150000,1,'MALE','58-14-145','Gunmetal','https://kinhmateyeplus.com/wp-content/uploads/2024/11/IMG_0863-1.jpg','https://images.unsplash.com/photo-1493663284031-b7e3aefcae8e?auto=format&fit=crop&w=1200&q=80',4.6,NOW(),NOW()),
(2002,'Vector Slate Square','Matte acetate, blue-light filter.',2480000,1,'MALE','54-18-145','Slate','https://down-vn.img.susercontent.com/file/vn-11134275-820l4-mggdg9xi9udq3f.webp','https://images.unsplash.com/photo-1503341455253-b2e723bb3dbb?auto=format&fit=crop&w=1200&q=80',4.7,NOW(),NOW()),
(2003,'Atlas Ember Sport','Wrap TR90 frame, anti-slip temple.',3290000,1,'MALE','64-15-130','Ember','https://images.unsplash.com/photo-1495107334309-fcf20504a5ab?auto=format&fit=crop&w=1200&q=80','https://images.unsplash.com/photo-1518544801095-7cb5c1f0a9c2?auto=format&fit=crop&w=1200&q=80',4.4,NOW(),NOW());
