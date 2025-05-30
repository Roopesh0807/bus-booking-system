-- Create Database
CREATE DATABASE KRISHISETUR;
USE KRISHISETUR;

-- Farmer Registration Table
CREATE TABLE farmerregistration (
    farmer_id VARCHAR(15) PRIMARY KEY,  -- Auto-generated ID (KRST01FR001)
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone_number VARCHAR(15) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,  -- Should be stored as hashed value
    confirm_password VARCHAR(255) NOT NULL  -- Ensure password match during registration
);

-- Trigger for Auto-Generating Farmer ID
DELIMITER //

CREATE TRIGGER before_insert_farmer
BEFORE INSERT ON farmerregistration
FOR EACH ROW
BEGIN
    DECLARE max_id INT DEFAULT 0;
    DECLARE next_id VARCHAR(15);
    
    -- Get the highest numeric part of farmer_id (e.g., 001 from 'KRST01FR001')
    SELECT IFNULL(CAST(SUBSTRING(farmer_id, 9) AS UNSIGNED), 0) INTO max_id 
    FROM farmerregistration ORDER BY farmer_id DESC LIMIT 1;

    -- Generate new farmer_id in the format 'KRST01FR001', 'KRST01FR002', etc.
    SET next_id = CONCAT('KRST01FR', LPAD(max_id + 1, 3, '0'));

    -- Assign the new farmer_id to the inserting row
    SET NEW.farmer_id = next_id;
END;
//

DELIMITER ;

-- Insert Farmer Registration Data
INSERT INTO farmerregistration (first_name, last_name, email, phone_number, password, confirm_password) 
VALUES 
('Ruchita', 'Sharma', 'ruchita@gmail.com', '9886543210', 'hashed_password1', 'hashed_password1'),
('Arush', 'Kumar', 'arush@gmail.com', '9876543211', 'hashed_password2', 'hashed_password2'),
('Pavan', 'Reddy', 'pavan@gmail.com', '9876543212', 'hashed_password3', 'hashed_password3'),
('Teju', 'Naik', 'teju@gmail.com', '9876543213', 'hashed_password4', 'hashed_password4');

-- Consumer Registration Table

CREATE TABLE consumerregistration (
    consumer_id VARCHAR(15) PRIMARY KEY,  -- Auto-generated ID (KRST01CS001)
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone_number VARCHAR(15) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,  -- Should be stored as hashed value
    confirm_password VARCHAR(255) NOT NULL  -- Ensure password match during registration
);

-- Trigger for Auto-Generating Consumer ID
DELIMITER $$

CREATE TRIGGER before_insert_consumer
BEFORE INSERT ON consumerregistration
FOR EACH ROW
BEGIN
    DECLARE max_id INT DEFAULT 0;
    DECLARE next_id VARCHAR(15);
    
    -- Get the highest numeric part of consumer_id
    SELECT IFNULL(MAX(CAST(SUBSTRING(consumer_id, 9) AS UNSIGNED)), 0) 
    INTO max_id
    FROM consumerregistration;
    
    -- Generate new consumer_id in the format 'KRST01CS001'
    SET next_id = CONCAT('KRST01CS', LPAD(max_id + 1, 3, '0'));
    SET NEW.consumer_id = next_id;
END $$

DELIMITER ;


-- Insert Consumer Registration Data
INSERT INTO consumerregistration (first_name, last_name, email, phone_number, password, confirm_password) 
VALUES 
('Amit', 'Sharma', 'amit.sharma@example.com', '9876500010', 'hashed_password1', 'hashed_password1'),
('Neha', 'Verma', 'neha.verma@example.com', '9876500011', 'hashed_password2', 'hashed_password2'),
('Raj', 'Patel', 'raj.patel@example.com', '9876500012', 'hashed_password3', 'hashed_password3'),
('Poonam', 'Gupta', 'poonam.gupta@example.com', '9876500013', 'hashed_password4', 'hashed_password4'),
('Vikas', 'Mishra', 'vikas.mishra@example.com', '9876500014', 'hashed_password5', 'hashed_password5'),
('Anjali', 'Singh', 'anjali.singh@example.com', '9876500015', 'hashed_password6', 'hashed_password6'),
('Rohit', 'Yadav', 'rohit.yadav@example.com', '9876500016', 'hashed_password7', 'hashed_password7'),
('Meera', 'Jain', 'meera.jain@example.com', '9876500017', 'hashed_password8', 'hashed_password8'),
('Sandeep', 'Rao', 'sandeep.rao@example.com', '9876500018', 'hashed_password9', 'hashed_password9'),
('Kavita', 'Thakur', 'kavita.thakur@example.com', '9876500019', 'hashed_password10', 'hashed_password10');

-- Contact Us Table
CREATE TABLE contact_us (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(15),
    message TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert Contact Us Data
INSERT INTO contact_us (name, email, phone, message)  
VALUES  
('Ruchita Sharma', 'ruchita@gmail.com', '9886543210', 'I need help with my recent order.'),  
('Arush Kumar', 'arush@gmail.com', '9876543211', 'I want to update my farm details.'),  
('Pavan Reddy', 'pavan@gmail.com', '9876543212', 'Inquiry about delivery times.'),  
('Teju Naik', 'teju@gmail.com', '9876543213', 'How can I register my farm?'),  
('Amit Sharma', 'amit.sharma@example.com', '9876500010', 'Need assistance with payment issues.'),  
('Neha Verma', 'neha.verma@example.com', '9876500011', 'Requesting more information on organic products.'),  
('Raj Patel', 'raj.patel@example.com', '9876500012', 'Facing login issues, please assist.');

-- Personal Details Table
CREATE TABLE personaldetails (
    farmer_id VARCHAR(15) NOT NULL,
    name VARCHAR(255),
    email VARCHAR(255) NOT NULL,
    profile_photo BLOB,
    dob DATE NOT NULL,
    gender ENUM('Male', 'Female', 'Other') NOT NULL,
    contact_no VARCHAR(15) NOT NULL,
    aadhaar_no VARCHAR(12) NOT NULL,
    residential_address TEXT NOT NULL,
    aadhaar_proof_pdf LONGBLOB,
    bank_account_no VARCHAR(20),
    ifsc_code VARCHAR(11),
    upi_id VARCHAR(255),
    PRIMARY KEY (farmer_id),
    FOREIGN KEY (farmer_id) REFERENCES farmerregistration(farmer_id)
);


-- Trigger for Personal Details
DELIMITER $$

CREATE TRIGGER before_insert_personaldetails
BEFORE INSERT ON personaldetails
FOR EACH ROW
BEGIN
    DECLARE fetched_farmer_id VARCHAR(15);
    DECLARE fetched_full_name VARCHAR(255);

    -- Fetch farmer_id and full_name (first_name + last_name) from farmerregistration based on email
    SELECT farmer_id, CONCAT(first_name, ' ', last_name) INTO fetched_farmer_id, fetched_full_name
    FROM farmerregistration
    WHERE email = NEW.email;

    -- Set farmer_id and name in the personaldetails table
    SET NEW.farmer_id = fetched_farmer_id;
    SET NEW.name = fetched_full_name;
END$$

DELIMITER ;

-- Insert Personal Details Data
INSERT INTO personaldetails (email, profile_photo, dob, gender, contact_no, aadhaar_no, residential_address, aadhaar_proof_pdf, bank_account_no, ifsc_code, upi_id)
VALUES
('ruchita@gmail.com', NULL, '1990-05-15', 'Female', '9876543210', '123456789012', '1234, Main Street, City, State, 12345', NULL, '12345678901234567890', 'IFSC1234567', 'ruchita_upi@bank'),
('arush@gmail.com', NULL, '1992-07-20', 'Male', '9876543211', '123456789013', '4567, Second Street, City, State, 12345', NULL, '12345678901234567891', 'IFSC1234568', 'arush_upi@bank'),
('pavan@gmail.com', NULL, '1988-10-05', 'Male', '9876543212', '123456789014', '7890, Third Street, City, State, 12345', NULL, '12345678901234567892', 'IFSC1234569', 'pavan_upi@bank'),
('teju@gmail.com', NULL, '1995-03-12', 'Female', '9876543213', '123456789015', '1011, Fourth Street, City, State, 12345', NULL, '12345678901234567893', 'IFSC1234570', 'teju_upi@bank');

-- Farm Details Table
CREATE TABLE farmdetails (
    farmer_id VARCHAR(15) NOT NULL,
    email VARCHAR(255) NOT NULL,
    farm_address TEXT NOT NULL,
    farm_size DECIMAL(10,2) NOT NULL,
    crops_grown TEXT NOT NULL,
    farming_method VARCHAR(255) NOT NULL,
    soil_type VARCHAR(100) NOT NULL,
    water_sources TEXT NOT NULL,
    farm_equipment TEXT NOT NULL,
    land_ownership_proof_pdf LONGBLOB,
    certification_pdf LONGBLOB,
    land_lease_agreement_pdf LONGBLOB,
    farm_photographs_pdf LONGBLOB,
    PRIMARY KEY (farmer_id),
    FOREIGN KEY (farmer_id) REFERENCES farmerregistration(farmer_id)
);

-- Trigger for Farm Details
DELIMITER $$

CREATE TRIGGER before_insert_farmdetails
BEFORE INSERT ON farmdetails
FOR EACH ROW
BEGIN
    DECLARE fetched_farmer_id VARCHAR(15);

    -- Fetch farmer_id from farmerregistration based on email
    SELECT farmer_id INTO fetched_farmer_id
    FROM farmerregistration
    WHERE email = NEW.email;

    -- Set farmer_id in the farmdetails table
    SET NEW.farmer_id = fetched_farmer_id;
END$$

DELIMITER ;

-- Insert Farm Details Data
INSERT INTO farmdetails 
(email, farm_address, farm_size, crops_grown, farming_method, soil_type, water_sources, farm_equipment, land_ownership_proof_pdf, certification_pdf, land_lease_agreement_pdf, farm_photographs_pdf)
VALUES
('ruchita@gmail.com', '1234, Main Street, City, State', 2.5, 'Tomatoes, Wheat', 'Organic', 'Loamy', 'Rainwater, Borewell', 'Tractor, Plough', NULL, NULL, NULL, NULL),
('arush@gmail.com', '4567, Second Street, City, State', 3.0, 'Potatoes, Carrots', 'Conventional', 'Clay', 'Canal, Borewell', 'Tractor, Seeder', NULL, NULL, NULL, NULL),
('pavan@gmail.com', '7890, Third Street, City, State', 1.8, 'Onions, Garlic', 'Sustainable', 'Sandy', 'Canal, Well', 'Plough, Harrow', NULL, NULL, NULL, NULL),
('teju@gmail.com', '1011, Fourth Street, City, State', 5.0, 'Rice, Corn', 'Traditional', 'Clay', 'River, Borewell', 'Tractor, Harvester', NULL, NULL, NULL, NULL);

-- Products Table
CREATE TABLE products (
    product_id VARCHAR(10) PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    buy_type VARCHAR(20),
    price_1kg DECIMAL(10,2),
    price_2kg DECIMAL(10,2),
    price_5kg DECIMAL(10,2),
    image BLOB,
    ratings DECIMAL(3,1)
);

-- Trigger for Auto-Generating Product ID
DELIMITER //

CREATE TRIGGER before_product_insert
BEFORE INSERT ON products
FOR EACH ROW
BEGIN
    DECLARE new_id INT;
    DECLARE formatted_id VARCHAR(10);
    
    -- Get the numeric part of the last product_id and increment it
    SELECT IFNULL(CAST(SUBSTRING(MAX(product_id), 4) AS UNSIGNED), 0) + 1 
    INTO new_id FROM products;

    -- Format it as PRD001, PRD002, etc.
    SET formatted_id = CONCAT('PRD', LPAD(new_id, 3, '0'));

    -- Assign the formatted ID to the new row
    SET NEW.product_id = formatted_id;
END;
//

DELIMITER ;

-- Insert Products Data
INSERT INTO products (product_name, category, buy_type, price_1kg, price_2kg, price_5kg, image, ratings) VALUES
('Tomato', 'Vegetables', 'Standard', 24.00, 45.50, 110.00, NULL, 4.2),
('Tomato', 'Vegetables', 'Organic', 27.00, 51.50, 125.00, NULL, 4.3),
('Onion', 'Vegetables', 'Standard', 20.00, 37.50, 90.00, NULL, 4.0),
('Onion', 'Vegetables', 'Organic', 23.00, 43.50, 105.00, NULL, 4.1),
('Potato', 'Vegetables', 'Standard', 22.00, 41.50, 100.00, NULL, 4.0),
('Potato', 'Vegetables', 'Organic', 25.00, 47.50, 115.00, NULL, 4.2),
('Chilly', 'Vegetables', 'Standard', 30.00, 57.50, 140.00, NULL, 4.4),
('Chilly', 'Vegetables', 'Organic', 33.00, 63.50, 155.00, NULL, 4.1),
('Apple', 'Fruits', 'Standard', 120.00, 230.00, 550.00, NULL, 4.3),
('Apple', 'Fruits', 'Organic', 123.00, 236.00, 565.00, NULL, 4.4),
('Pomegranate', 'Fruits', 'Standard', 110.00, 210.00, 500.00, NULL, 4.2),
('Pomegranate', 'Fruits', 'Organic', 113.00, 216.00, 515.00, NULL, 4.1),
('Grapes', 'Fruits', 'Standard', 90.00, 170.00, 400.00, NULL, 4.0),
('Grapes', 'Fruits', 'Organic', 93.00, 176.00, 415.00, NULL, 4.2),
('Butter', 'Dairy Products', 'Standard', 450.00, 890.00, 2200.00, NULL, 4.4),
('Butter', 'Dairy Products', 'Organic', 453.00, 896.00, 2215.00, NULL, 4.3),
('Cheese', 'Dairy Products', 'Standard', 500.00, 990.00, 2450.00, NULL, 4.2),
('Cheese', 'Dairy Products', 'Organic', 503.00, 996.00, 2465.00, NULL, 4.1),
('Rice', 'Grains & Pulses', 'Standard', 50.00, 95.00, 230.00, NULL, 4.0),
('Rice', 'Grains & Pulses', 'Organic', 53.00, 100.00, 240.00, NULL, 4.2),
('Cumin', 'Spices', 'Standard', 100.00, 190.00, 450.00, NULL, 4.2),
('Cumin', 'Spices', 'Organic', 103.00, 195.00, 460.00, NULL, 4.3);

-- Order All Table
CREATE TABLE orderall (
    orderid VARCHAR(10) PRIMARY KEY,
    farmer_id VARCHAR(15) NOT NULL,
    farmer_name VARCHAR(255) NOT NULL,
    order_date DATE NOT NULL,
    produce_name VARCHAR(255) NOT NULL,
    quantity INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    status ENUM('Fulfilled', 'Unfulfilled') NOT NULL,
    payment_status ENUM('Paid', 'Unpaid') NOT NULL,
    FOREIGN KEY (farmer_id) REFERENCES farmerregistration(farmer_id)
);

-- Trigger for Order All Table
DELIMITER //

CREATE TRIGGER before_insert_orderall
BEFORE INSERT ON orderall
FOR EACH ROW
BEGIN
    DECLARE max_id INT DEFAULT 0;
    DECLARE next_id VARCHAR(10);
    DECLARE fetched_farmer_id VARCHAR(15);
    DECLARE farmer_fullname VARCHAR(255);

    -- Get the highest numeric part of orderid
    SELECT IFNULL(CAST(SUBSTRING(orderid, 4) AS UNSIGNED), 0) INTO max_id 
    FROM orderall ORDER BY orderid DESC LIMIT 1;

    -- Generate new orderid in the format 'ORD001', 'ORD002', etc.
    SET next_id = CONCAT('ORD', LPAD(max_id + 1, 3, '0'));
    SET NEW.orderid = next_id;

    -- Fetch farmer_id based on farmer_name
    SELECT farmer_id, CONCAT(first_name, ' ', last_name) 
    INTO fetched_farmer_id, farmer_fullname
    FROM farmerregistration
    WHERE CONCAT(first_name, ' ', last_name) = NEW.farmer_name
    LIMIT 1;

    -- If farmer_id is NULL, prevent insert
    IF fetched_farmer_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: No matching farmer found in farmerregistration.';
    ELSE
        -- Assign fetched values
        SET NEW.farmer_id = fetched_farmer_id;
        SET NEW.farmer_name = farmer_fullname;
    END IF;
END;
//

DELIMITER ;

-- Insert Order All Data
INSERT INTO orderall (farmer_name, order_date, produce_name, quantity, amount, status, payment_status) 
VALUES 
('Ruchita Sharma', '2025-02-05', 'Tomatoes', 50, 200.00, 'Fulfilled', 'Paid'),
('Arush Kumar', '2025-02-06', 'Potatoes', 30, 150.00, 'Unfulfilled', 'Unpaid'),
('Pavan Reddy', '2025-02-07', 'Onions', 40, 180.00, 'Fulfilled', 'Paid'),
('Teju Naik', '2025-02-08', 'Carrots', 25, 120.00, 'Unfulfilled', 'Paid'),
('Ruchita Sharma', '2025-02-09', 'Wheat', 60, 300.00, 'Fulfilled', 'Paid');

-- Fulfilled Orders View
CREATE VIEW fulfilled_orders AS
SELECT 
    orderid,
    farmer_id,
    order_date,
    produce_name,
    quantity,
    amount,
    status
FROM orderall
WHERE status = 'Fulfilled';

-- Unfulfilled Orders View
CREATE VIEW unfulfilled_orders AS
SELECT 
    orderid,
    farmer_id,
    order_date,
    produce_name,
    quantity,
    amount,
    status
FROM orderall
WHERE status = 'Unfulfilled';

-- Consumer Profile Table
CREATE TABLE consumerprofile (
    consumer_id VARCHAR(15),
    name VARCHAR(255) NOT NULL,
    mobile_number VARCHAR(15) NOT NULL,
    email VARCHAR(255) NOT NULL,
    address TEXT NOT NULL,
    pincode VARCHAR(10) NOT NULL,
    location VARCHAR(255) NULL,
    photo TEXT NULL,
    preferred_payment_method VARCHAR(50) NULL,
    subscription_method ENUM('Daily', 'Weekly', 'Monthly') NULL,
    PRIMARY KEY (email, mobile_number),
    FOREIGN KEY (consumer_id) REFERENCES consumerregistration(consumer_id)
);

-- Trigger for Consumer Profile
DELIMITER $$

CREATE TRIGGER before_insert_consumer_profile
BEFORE INSERT ON consumerprofile
FOR EACH ROW
BEGIN
  DECLARE fetched_consumer_id VARCHAR(15);
  DECLARE consumer_exists INT DEFAULT 0;

  SELECT COUNT(*) INTO consumer_exists 
  FROM consumerregistration 
  WHERE email = NEW.email 
  AND phone_number = NEW.mobile_number;

  IF consumer_exists = 0 THEN
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'Invalid consumer: No matching entry found in consumerregistration';
  END IF;

  SELECT consumer_id INTO fetched_consumer_id 
  FROM consumerregistration 
  WHERE email = NEW.email 
  AND phone_number = NEW.mobile_number 
  LIMIT 1;
  
  SET NEW.consumer_id = fetched_consumer_id;
END $$

DELIMITER ;

ALTER TABLE consumerprofile
ADD COLUMN city VARCHAR(100) NULL AFTER location,
ADD COLUMN state VARCHAR(100) NULL AFTER city;

-- Insert Consumer Profile Data
INSERT INTO consumerprofile (name, mobile_number, email, address, pincode, location, photo, preferred_payment_method, subscription_method)
VALUES 
('Amit Sharma', '9876500010', 'amit.sharma@example.com', 'Address of Amit Sharma', '123456', 'Mumbai', NULL, 'UPI', 'Monthly'),
('Neha Verma', '9876500011', 'neha.verma@example.com', 'Address of Neha Verma', '234567', 'Delhi', NULL, 'Credit Card', 'Weekly'),
('Raj Patel', '9876500012', 'raj.patel@example.com', 'Address of Raj Patel', '345678', 'Bangalore', NULL, 'Debit Card', 'Daily'),
('Poonam Gupta', '9876500013', 'poonam.gupta@example.com', 'Address of Poonam Gupta', '456789', 'Hyderabad', NULL, 'Net Banking', 'Monthly'),
('Vikas Mishra', '9876500014', 'vikas.mishra@example.com', 'Address of Vikas Mishra', '567890', 'Pune', NULL, 'UPI', 'Weekly'),
('Anjali Singh', '9876500015', 'anjali.singh@example.com', 'Address of Anjali Singh', '678901', 'Chennai', NULL, 'Credit Card', 'Daily'),
('Rohit Yadav', '9876500016', 'rohit.yadav@example.com', 'Address of Rohit Yadav', '789012', 'Kolkata', NULL, 'Debit Card', 'Monthly'),
('Meera Jain', '9876500017', 'meera.jain@example.com', 'Address of Meera Jain', '890123', 'Ahmedabad', NULL, 'Net Banking', 'Weekly'),
('Sandeep Rao', '9876500018', 'sandeep.rao@example.com', 'Address of Sandeep Rao', '901234', 'Surat', NULL, 'UPI', 'Daily'),
('Kavita Thakur', '9876500019', 'kavita.thakur@example.com', 'Address of Kavita Thakur', '012345', 'Jaipur', NULL, 'Credit Card', 'Monthly');


-- Farmer Profile Table
CREATE TABLE farmerprofile AS
SELECT 
    fr.farmer_id,
    CONCAT(fr.first_name, ' ',fr.last_name) AS full_name,
    p.profile_photo,
    p.dob,
    p.gender,
    p.email,
    p.contact_no,
    p.aadhaar_no,
    p.residential_address,
    p.aadhaar_proof_pdf,
    p.bank_account_no,
    p.ifsc_code,
    p.upi_id,
    f.farm_address,
    f.farm_size,
    f.crops_grown,
    f.farming_method,
    f.soil_type,
    f.water_sources,
    f.farm_equipment,
    f.land_ownership_proof_pdf,
    f.certification_pdf,
    f.land_lease_agreement_pdf,
    f.farm_photographs_pdf
FROM 
    farmerregistration fr
JOIN 
    personaldetails p ON fr.farmer_id = p.farmer_id
JOIN 
    farmdetails f ON fr.farmer_id = f.farmer_id;

    -- Add profile_complete column to farmerregistration table
ALTER TABLE farmerregistration ADD COLUMN profile_complete BOOLEAN DEFAULT FALSE;

-- Add Produce Table
CREATE TABLE add_produce (
    product_id VARCHAR(10) PRIMARY KEY,
    farmer_id VARCHAR(15) NOT NULL,
    farmer_name VARCHAR(255) NOT NULL,
    produce_name VARCHAR(100) NOT NULL,
    availability INT NOT NULL CHECK (availability >= 0),
    price_per_kg DECIMAL(10,2) NOT NULL CHECK (price_per_kg >= 0),
    produce_type ENUM('Organic', 'Standard') NOT NULL,
    market_type ENUM('Bargaining Market', 'KrishiSetu Market') NOT NULL,
    email VARCHAR(255) NOT NULL,
    FOREIGN KEY (farmer_id) REFERENCES farmerregistration(farmer_id) ON DELETE CASCADE
);


DROP TRIGGER IF EXISTS before_insert_add_produce ;
-- Trigger for Add Produce
DELIMITER //


CREATE TRIGGER before_insert_add_produce
BEFORE INSERT ON add_produce
FOR EACH ROW
BEGIN
    DECLARE fetched_farmer_id VARCHAR(15);
    DECLARE fetched_first_name VARCHAR(255);
    DECLARE max_id INT DEFAULT 0;
    DECLARE next_id VARCHAR(10);
    DECLARE farmer_exists INT DEFAULT 0;

    -- Check if farmer exists
    SELECT COUNT(*) INTO farmer_exists
    FROM farmerregistration
    WHERE email = NEW.email;

    IF farmer_exists = 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Invalid email: No matching farmer found';
    END IF;

    -- Fetch farmer details
    SELECT farmer_id, first_name
    INTO fetched_farmer_id, fetched_first_name
    FROM farmerregistration
    WHERE email = NEW.email
    LIMIT 1;

    -- Assign farmer details
    SET NEW.farmer_id = fetched_farmer_id;
    SET NEW.farmer_name = fetched_first_name;

    -- Generate product ID - handles empty table case properly
    SELECT COALESCE(MAX(CAST(SUBSTRING(product_id, 4) AS UNSIGNED)), 0) INTO max_id 
    FROM add_produce
    WHERE product_id REGEXP '^PRD[0-9]+$';
    
    SET next_id = CONCAT('PRD', LPAD(max_id + 1, 3, '0'));
    SET NEW.product_id = next_id;
END //

DELIMITER ;

-- Insert Add Produce Data
INSERT INTO add_produce (email, produce_name, availability, price_per_kg, produce_type, market_type)  
VALUES  
('ruchita@gmail.com', 'Potatoes', 70, 20.00, 'Organic', 'KrishiSetu Market'),  
('ruchita@gmail.com', 'Apples', 60, 120.00, 'Organic', 'Bargaining Market'),  
('ruchita@gmail.com', 'Cabbage', 90, 15.00, 'Standard', 'KrishiSetu Market'),  
('ruchita@gmail.com', 'Grapes', 40, 90.00, 'Organic', 'Bargaining Market'),  
('ruchita@gmail.com', 'Garlic', 30, 80.00, 'Standard', 'KrishiSetu Market'),  
('arush@gmail.com', 'Spinach', 50, 25.00, 'Organic', 'KrishiSetu Market'),  
('arush@gmail.com', 'Pumpkin', 30, 18.00, 'Standard', 'Bargaining Market'),  
('arush@gmail.com', 'Bananas', 100, 40.00, 'Organic', 'KrishiSetu Market'),  
('arush@gmail.com', 'Peanuts', 80, 60.00, 'Standard', 'Bargaining Market'),  
('arush@gmail.com', 'Green Peas', 90, 55.00, 'Organic', 'KrishiSetu Market'),  
('pavan@gmail.com', 'Cucumber', 60, 22.00, 'Standard', 'KrishiSetu Market'),  
('pavan@gmail.com', 'Peppers', 45, 75.00, 'Organic', 'Bargaining Market'),  
('pavan@gmail.com', 'Mangoes', 70, 110.00, 'Organic', 'KrishiSetu Market'),  
('pavan@gmail.com', 'Radish', 30, 20.00, 'Standard', 'Bargaining Market'),  
('pavan@gmail.com', 'Sugarcane', 120, 15.00, 'Standard', 'KrishiSetu Market'),  
('teju@gmail.com', 'Milk', 150, 50.00, 'Organic', 'KrishiSetu Market'),  
('teju@gmail.com', 'Butter', 80, 450.00, 'Standard', 'Bargaining Market'),  
('teju@gmail.com', 'Corn', 200, 35.00, 'Organic', 'KrishiSetu Market'),  
('teju@gmail.com', 'Tomatoes', 90, 28.00, 'Standard', 'Bargaining Market'),  
('teju@gmail.com', 'Lentils', 110, 95.00, 'Organic', 'KrishiSetu Market');

-- Chat Room Table
CREATE TABLE chat_rooms (
    room_id VARCHAR(10) PRIMARY KEY,
    room_name VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trigger for Chat Room
DELIMITER $$

CREATE TRIGGER before_insert_chat_room
BEFORE INSERT ON chat_rooms
FOR EACH ROW
BEGIN
    DECLARE next_id INT;
    DECLARE formatted_id VARCHAR(10);

    -- Get the next incremented ID
    SELECT COALESCE(MAX(CAST(SUBSTRING(room_id, 3, 5) AS UNSIGNED)), 0) + 1 INTO next_id FROM chat_rooms;

    -- Format the room_id as RM001, RM002, ...
    SET formatted_id = CONCAT('RM', LPAD(next_id, 3, '0'));

    -- Assign the formatted ID
    SET NEW.room_id = formatted_id;
END$$

DELIMITER ;

-- Messages Table
CREATE TABLE messages (
    message_id INT AUTO_INCREMENT PRIMARY KEY,
    room_id VARCHAR(10) NOT NULL,
    farmer_id INT NOT NULL,
    sender_name VARCHAR(50) NOT NULL,
    message TEXT NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trigger for Messages
DELIMITER $$

CREATE TRIGGER before_insert_message
BEFORE INSERT ON messages
FOR EACH ROW
BEGIN
    DECLARE next_id INT;
    DECLARE formatted_msg_id VARCHAR(10);
    DECLARE sender_full_name VARCHAR(100);
    DECLARE fetched_room_id VARCHAR(10);

    -- Get the next incremented message ID
    SELECT COALESCE(MAX(CAST(SUBSTRING(message_id, 4, 5) AS UNSIGNED)), 0) + 1 INTO next_id FROM messages;
    
    -- Format the message_id as MSG001, MSG002, ...
    SET formatted_msg_id = CONCAT('MSG', LPAD(next_id, 3, '0'));

    -- Fetch the sender's full name (first_name + last_name) from farmerregistration

    SELECT CONCAT(first_name, ' ', last_name) INTO sender_full_name
    FROM farmerregistration WHERE farmer_id = NEW.farmer_id;

    -- Fetch the room_id from chat_rooms if not provided
    IF NEW.room_id IS NULL THEN
        SELECT room_id INTO fetched_room_id FROM chat_rooms ORDER BY created_at DESC LIMIT 1;
        SET NEW.room_id = fetched_room_id;
    END IF;

    -- Assign the formatted message_id and sender_name
    SET NEW.message_id = formatted_msg_id;
    SET NEW.sender_name = sender_full_name;
END$$

DELIMITER ;

-- Insert Farmer Profile Data
INSERT INTO farmerprofile (
    farmer_id, full_name, profile_photo, dob, gender, email, contact_no, aadhaar_no, 
    residential_address, aadhaar_proof_pdf, bank_account_no, ifsc_code, upi_id, 
    farm_address, farm_size, crops_grown, farming_method, soil_type, water_sources, 
    farm_equipment, land_ownership_proof_pdf, certification_pdf, 
    land_lease_agreement_pdf, farm_photographs_pdf
) 
VALUES 
('KRST01FR006', 'Silvan Suldor', NULL, '1991-06-25', 'Male', 'silvansumanth@gmail.com', '7676126848', '123456789016', 
 '5678, Green Valley, City, State, 12345', NULL, '12345678901234567894', 'IFSC1234571', 'silvan_upi@bank', 
 '5678, Green Valley, City, State', 5.50, 'Mangoes, Sugarcane', 'Organic', 'Loamy', 'Rainwater, Well', 
 'Tractor, Cultivator', NULL, NULL, NULL, NULL),

('KRST01FR007', 'Meera Joshi', NULL, '1993-08-15', 'Female', 'meera@gmail.com', '9876543214', '123456789017', 
 '7891, Lotus Street, City, State, 12345', NULL, '12345678901234567895', 'IFSC1234572', 'meera_upi@bank', 
 '7891, Lotus Street, City, State', 4.25, 'Wheat, Barley', 'Conventional', 'Clay', 'Canal, Borewell', 
 'Tractor, Seeder', NULL, NULL, NULL, NULL),

('KRST01FR008', 'Shree R', NULL, '1989-02-10', 'Male', 'SR@gmail.com', '1234567890', '123456789018', 
 '3456, Sunrise Road, City, State, 12345', NULL, '12345678901234567896', 'IFSC1234573', 'shree_upi@bank', 
 '3456, Sunrise Road, City, State', 3.75, 'Tomatoes, Peppers', 'Sustainable', 'Sandy', 'River, Well', 
 'Plough, Harrow', NULL, NULL, NULL, NULL);

-- Update Consumer Profile Trigger
DELIMITER $$

DROP TRIGGER IF EXISTS before_insert_consumer_profile $$

CREATE TRIGGER before_insert_consumer_profile
BEFORE INSERT ON consumerprofile
FOR EACH ROW
BEGIN
  DECLARE fetched_name VARCHAR(255);
  DECLARE fetched_mobile VARCHAR(15);
  DECLARE fetched_email VARCHAR(255);
  DECLARE consumer_exists INT DEFAULT 0;

  -- Check if the consumer exists in consumerregistration
  SELECT COUNT(*) INTO consumer_exists 
  FROM consumerregistration 
  WHERE consumer_id = NEW.consumer_id;

  IF consumer_exists = 0 THEN
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'Invalid consumer: No matching entry found in consumerregistration';
  END IF;

  -- Fetch consumer details from consumerregistration
  SELECT CONCAT(first_name, ' ', last_name), phone_number, email
  INTO fetched_name, fetched_mobile, fetched_email
  FROM consumerregistration 
  WHERE consumer_id = NEW.consumer_id 
  LIMIT 1;
  
  -- Set values before inserting
  SET NEW.name = fetched_name;
  SET NEW.mobile_number = fetched_mobile;
  SET NEW.email = fetched_email;
END $$

DELIMITER ;

-- Update Consumer Profile Trigger on Update
DELIMITER $$

CREATE TRIGGER before_update_consumerprofile
BEFORE UPDATE ON consumerregistration
FOR EACH ROW
BEGIN
    -- Update the corresponding consumer in consumerprofile
    UPDATE consumerprofile
    SET name = CONCAT(NEW.first_name, ' ', NEW.last_name),
        mobile_number = NEW.phone_number,
        email = NEW.email
    WHERE consumer_id = OLD.consumer_id;
END $$

DELIMITER ;

-- Users Table
CREATE TABLE Users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  phone VARCHAR(15) NOT NULL UNIQUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE communities (
    community_id VARCHAR(15) PRIMARY KEY,  -- Auto-generated ID
    community_name VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,  -- Hashed password
    admin_id VARCHAR(15) NOT NULL,  -- References consumer_id from consumerregistration
    address VARCHAR(255) NOT NULL,
    delivery_date DATE NOT NULL,
    delivery_time TIME NOT NULL,
    FOREIGN KEY (admin_id) REFERENCES consumerregistration(consumer_id)
);

-- Trigger for Auto-Generating Community ID
DELIMITER $$

CREATE TRIGGER before_insert_community
BEFORE INSERT ON communities
FOR EACH ROW
BEGIN
    DECLARE max_id INT DEFAULT 0;
    DECLARE next_id VARCHAR(15);

    -- Get the highest numeric part of community_id (e.g., 001 from 'COMM001')
    SELECT IFNULL(MAX(CAST(SUBSTRING(community_id, 5) AS UNSIGNED)), 0) INTO max_id 
    FROM communities;

    -- Generate new community_id in the format 'COMM001', 'COMM002', etc.
    SET next_id = CONCAT('COMM', LPAD(max_id + 1, 3, '0'));

    -- Assign the new community_id to the inserting row
    SET NEW.community_id = next_id;
END $$




DELIMITER ;


INSERT INTO communities (community_name, password, admin_id, address, delivery_date, delivery_time)
VALUES ('Green Valley', 'hashed_password', 'KRST01CS001', '123 Green St, City', '2023-12-25', '10:00:00');

CREATE TABLE members (
    member_id VARCHAR(15) PRIMARY KEY,  -- Auto-generated ID
    community_id VARCHAR(15) NOT NULL,  -- References community_id from communities
    consumer_id VARCHAR(15) NOT NULL,  -- References consumer_id from consumerregistration
    member_name VARCHAR(255) NOT NULL,  -- Concatenated first_name + last_name
    member_email VARCHAR(255) NOT NULL,  -- References email from consumerregistration
    phone_number VARCHAR(15) NOT NULL,  -- References phone_number from consumerregistration
    FOREIGN KEY (community_id) REFERENCES communities(community_id),
    FOREIGN KEY (consumer_id) REFERENCES consumerregistration(consumer_id),
    FOREIGN KEY (member_email) REFERENCES consumerregistration(email),
    FOREIGN KEY (phone_number) REFERENCES consumerregistration(phone_number)
);

-- Trigger for Auto-Generating Member ID
DELIMITER $$

DELIMITER $$

CREATE TRIGGER before_insert_member
BEFORE INSERT ON members
FOR EACH ROW
BEGIN
    -- Declare all variables at the beginning
    DECLARE max_id INT DEFAULT 0;
    DECLARE next_id VARCHAR(15);
    DECLARE first_name_val VARCHAR(50);
    DECLARE last_name_val VARCHAR(50);
    DECLARE email_val VARCHAR(255);
    DECLARE phone_val VARCHAR(15);

    -- Get the highest numeric part of member_id (e.g., 001 from 'MEM001')
    SELECT IFNULL(MAX(CAST(SUBSTRING(member_id, 4) AS UNSIGNED)), 0) INTO max_id 
    FROM members;

    -- Generate new member_id in the format 'MEM001', 'MEM002', etc.
    SET next_id = CONCAT('MEM', LPAD(max_id + 1, 3, '0'));

    -- Assign the new member_id to the inserting row
    SET NEW.member_id = next_id;

    -- Ensure member_name, member_email, and phone_number match the consumerregistration table
    SELECT first_name, last_name, email, phone_number 
    INTO first_name_val, last_name_val, email_val, phone_val
    FROM consumerregistration
    WHERE consumer_id = NEW.consumer_id;

    -- Set member_name, member_email, and phone_number based on consumerregistration
    SET NEW.member_name = CONCAT(first_name_val, ' ', last_name_val);
    SET NEW.member_email = email_val;
    SET NEW.phone_number = phone_val;
END $$

DELIMITER ;


INSERT INTO members (community_id, consumer_id)
VALUES ('COMM001', 'KRST01CS001');



CREATE TABLE orders (
    order_id VARCHAR(15) PRIMARY KEY,  -- Auto-generated ID
    community_id VARCHAR(15) NOT NULL,  -- References community_id from communities
    product_id VARCHAR(15) NOT NULL,  -- Assuming product_id is provided
    quantity INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    member_id VARCHAR(15) NOT NULL,  -- References member_id from members
    FOREIGN KEY (community_id) REFERENCES communities(community_id),
    FOREIGN KEY (member_id) REFERENCES members(member_id)
);



ALTER TABLE orders ADD COLUMN payment_method VARCHAR(50);
-- Add product_name column to orders table
ALTER TABLE orders ADD COLUMN product_name VARCHAR(100) NOT NULL AFTER product_id;


ALTER TABLE orders 
ADD COLUMN buy_type VARCHAR(20) AFTER product_name,
ADD COLUMN category VARCHAR(50) AFTER buy_type;

-- Trigger for Auto-Generating Order ID
DELIMITER $$

CREATE TRIGGER before_insert_order
BEFORE INSERT ON orders
FOR EACH ROW
BEGIN
    DECLARE max_id INT DEFAULT 0;
    DECLARE next_id VARCHAR(15);

    -- Get the highest numeric part of order_id (e.g., 001 from 'ORD001')
    SELECT IFNULL(MAX(CAST(SUBSTRING(order_id, 4) AS UNSIGNED)), 0) INTO max_id 
    FROM orders;

    -- Generate new order_id in the format 'ORD001', 'ORD002', etc.
    SET next_id = CONCAT('ORD', LPAD(max_id + 1, 3, '0'));

    -- Assign the new order_id to the inserting row
    SET NEW.order_id = next_id;
END $$

DELIMITER ;

ALTER TABLE orders ADD CONSTRAINT fk_product
FOREIGN KEY (product_id) REFERENCES products(product_id);
-- INSERT INTO orders (community_id, product_id, quantity, price, member_id)
-- VALUES ('COMM001', 'PROD001', 2, 19.99, 'MEM001');


CREATE TABLE reviews (
      review_id INT AUTO_INCREMENT PRIMARY KEY,
      farmer_id VARCHAR(15) NOT NULL, -- ID of the farmer being reviewed
      consumer_name VARCHAR(255) NOT NULL, -- Name of the consumer submitting the review
     rating DECIMAL(3, 2) NOT NULL, -- Rating (e.g., 4.5)
    comment TEXT, -- Review comment
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp of the review
    FOREIGN KEY (farmer_id) REFERENCES farmerregistration(farmer_id) ON DELETE CASCADE
    
     );

CREATE TABLE review_images (
    image_id INT AUTO_INCREMENT PRIMARY KEY,
    review_id INT NOT NULL,
    image_url VARCHAR(255) NOT NULL,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (review_id) REFERENCES reviews(review_id) ON DELETE CASCADE
);

-- Ensure the consumer_id column can be NULL temporarily for the trigger to work
ALTER TABLE consumerregistration MODIFY COLUMN consumer_id VARCHAR(15) NULL;

-- Drop the existing trigger if it exists


-- Create a new trigger for ID generation


-- Make consumer_id NOT NULL again
ALTER TABLE consumerregistration MODIFY COLUMN consumer_id VARCHAR(15) NOT NULL;


-- Drop the existing profile trigger if it exists
DROP TRIGGER IF EXISTS after_insert_consumer_registration;

-- Create the new profile creation trigger
DELIMITER $$

CREATE TRIGGER after_insert_consumer_registration
AFTER INSERT ON consumerregistration
FOR EACH ROW
BEGIN
    -- Insert into consumerprofile with the generated consumer_id
    INSERT INTO consumerprofile (
        consumer_id, 
        name, 
        mobile_number, 
        email, 
        address, 
        pincode
    ) VALUES (
        NEW.consumer_id,
        CONCAT(NEW.first_name, ' ', NEW.last_name),
        NEW.phone_number,
        NEW.email,
        'Address not provided yet',  -- Default address
        '000000'                    -- Default pincode
    );
END $$

DELIMITER ;






-- Test insert (should automatically generate order_id)


-- Drop existing trigger first
DROP TRIGGER IF EXISTS before_insert_placeorder;

-- Update the table structure
CREATE TABLE IF NOT EXISTS placeorder (
    id INT AUTO_INCREMENT PRIMARY KEY,  -- Added auto-increment primary key
    order_id VARCHAR(10) UNIQUE,       -- Changed to UNIQUE (not primary)
    consumer_id VARCHAR(15) NOT NULL,
    name VARCHAR(255) NOT NULL,
    mobile_number VARCHAR(15) NOT NULL,
    email VARCHAR(255) NOT NULL,
    address TEXT NOT NULL,
    pincode VARCHAR(10) NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    produce_name VARCHAR(255) NOT NULL,
    quantity INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    status ENUM('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled') NOT NULL DEFAULT 'Pending',
    payment_status ENUM('Pending', 'Paid', 'Failed') NOT NULL DEFAULT 'Pending',
    payment_method ENUM('credit-card', 'upi', 'cash-on-delivery', 'razorpay') NOT NULL DEFAULT 'cash-on-delivery',
    is_self_delivery BOOLEAN NOT NULL DEFAULT FALSE,
    recipient_name VARCHAR(255) DEFAULT NULL,
    recipient_phone VARCHAR(15) DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (consumer_id) REFERENCES consumerprofile(consumer_id)
);

-- Recreate the trigger
DELIMITER $$

CREATE TRIGGER before_insert_placeorder
BEFORE INSERT ON placeorder
FOR EACH ROW
BEGIN
    DECLARE max_id INT DEFAULT 0;
    DECLARE next_id VARCHAR(10);
    
    -- Get the highest numeric part of order_id
    SELECT IFNULL(MAX(CAST(SUBSTRING(order_id, 4) AS UNSIGNED)), 0) INTO max_id 
    FROM placeorder
    WHERE order_id REGEXP '^ORD[0-9]+$';
    
    -- Generate new order_id in the format 'ORD001', 'ORD002', etc.
    SET next_id = CONCAT('ORD', LPAD(max_id + 1, 3, '0'));
    
    -- Assign the new order_id
    SET NEW.order_id = next_id;
END$$

DELIMITER ;

INSERT INTO placeorder (
    consumer_id, name, mobile_number, email,
    produce_name, quantity, amount,
    is_self_delivery, payment_status, payment_method,
    address, pincode
) VALUES (
    'KRST01CS001', 'Test User', '9876543210', 'test@example.com',
    'Test Product', 1, 100.00,
    1, 'Pending', 'cash-on-delivery',
    '123 Test St, Test City, Test State - 560001', '560001'
);

-- Check the result
SELECT * FROM placeorder WHERE consumer_id = 'KRST01CS001';

ALTER TABLE personaldetails CHANGE aadhaar_proof_pdf aadhaar_proof longblob;
ALTER TABLE personaldetails ADD COLUMN bank_proof longblob;
ALTER TABLE farmdetails CHANGE land_ownership_proof_pdf land_ownership_proof longblob;
ALTER TABLE farmdetails CHANGE land_lease_agreement_pdf land_lease_agreement longblob;

ALTER TABLE farmdetails CHANGE certification_pdf certification longblob;

ALTER TABLE farmdetails CHANGE farm_photographs_pdf farm_photographs longblob;

-- Modify personaldetails table to have default values for required fields
ALTER TABLE personaldetails 
MODIFY COLUMN dob DATE NULL,
MODIFY COLUMN gender ENUM('Male', 'Female', 'Other') NULL,
MODIFY COLUMN aadhaar_no VARCHAR(12) NULL,
MODIFY COLUMN residential_address TEXT NULL;

-- Modify farmdetails table to have default values for required fields
ALTER TABLE farmdetails 
MODIFY COLUMN farm_address TEXT NULL,
MODIFY COLUMN farm_size DECIMAL(10,2) NULL DEFAULT 0,
MODIFY COLUMN crops_grown TEXT NULL,
MODIFY COLUMN farming_method VARCHAR(255) NULL,
MODIFY COLUMN soil_type VARCHAR(100) NULL,
MODIFY COLUMN water_sources TEXT NULL,
MODIFY COLUMN farm_equipment TEXT NULL;


DELIMITER $$

CREATE TRIGGER after_farmer_registration
AFTER INSERT ON farmerregistration
FOR EACH ROW
BEGIN
    -- Insert into personaldetails with minimal required fields
    INSERT INTO personaldetails (
        farmer_id, 
        name, 
        email, 
        contact_no
    ) VALUES (
        NEW.farmer_id,
        CONCAT(NEW.first_name, ' ', NEW.last_name),
        NEW.email,
        NEW.phone_number
    );
    
    -- Insert into farmdetails with minimal required fields
    INSERT INTO farmdetails (
        farmer_id,
        email
    ) VALUES (
        NEW.farmer_id,
        NEW.email
    );
END $$

DELIMITER ;





CREATE TABLE IF NOT EXISTS bargain_session_temp (
  consumer_id VARCHAR(50),
  product_id VARCHAR(50),
  quantity INT,
  original_price DECIMAL(10,2)
);

CREATE TABLE bargain_sessions (
  bargain_id int(11) NOT NULL AUTO_INCREMENT,
  consumer_id varchar(20) DEFAULT NULL,
  farmer_id varchar(20) DEFAULT NULL,
  status varchar(20) DEFAULT NULL,
  initiator varchar(20) DEFAULT NULL,
  created_at datetime DEFAULT CURRENT_TIMESTAMP,
  updated_at datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  expires_at datetime DEFAULT NULL,
  PRIMARY KEY (bargain_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
CREATE TABLE bargain_messages (
  message_id int(11) NOT NULL AUTO_INCREMENT,
  bargain_id int(11) NOT NULL,
  sender_role enum('consumer','farmer','system') NOT NULL,
  sender_id varchar(20) DEFAULT NULL,
  message_content text DEFAULT NULL,
  price_suggestion decimal(10,2) DEFAULT NULL,
  message_type enum('text','price_offer','counter_offer','accept','reject','finalize','system') NOT NULL DEFAULT 'text',
  created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (message_id),
  KEY bargain_id (bargain_id),
  CONSTRAINT bargain_messages_ibfk_1 FOREIGN KEY (bargain_id) REFERENCES bargain_sessions (bargain_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE bargain_session_products (
  bsp_id int(11) NOT NULL AUTO_INCREMENT,
  bargain_id int(11) DEFAULT NULL,
  product_id varchar(20) DEFAULT NULL,
  original_price decimal(10,2) DEFAULT NULL,
  quantity decimal(10,2) DEFAULT NULL,
  current_offer decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (bsp_id),
  KEY bargain_id (bargain_id),
  CONSTRAINT bargain_session_products_ibfk_1 FOREIGN KEY (bargain_id) REFERENCES bargain_sessions (bargain_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;



CREATE TABLE bargain_system_notifications (
    notification_id INT(11) NOT NULL AUTO_INCREMENT,
    bargain_id INT(11) NOT NULL,
    notification_type VARCHAR(50) NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (notification_id),
    KEY (bargain_id),
    CONSTRAINT fk_bargain_notification
        FOREIGN KEY (bargain_id) REFERENCES bargain_sessions(bargain_id)
        ON DELETE CASCADE
);



-- Drop existing triggers (run these one by one)
DROP TRIGGER IF EXISTS after_status_change;
DROP TRIGGER IF EXISTS after_price_message;
DROP TRIGGER IF EXISTS update_bargain_status_after_message;

DROP TRIGGER IF EXISTS insert_bargain_order_after_accept_or_reject;

DROP TRIGGER IF EXISTS add_to_cart_after_accept_message;

-- Create a single consolidated trigger
DELIMITER //

CREATE TRIGGER after_insert_bargain_message
AFTER INSERT ON bargain_messages
FOR EACH ROW
BEGIN
  -- Handle accept, reject, and finalize
  IF NEW.message_type = 'accept' THEN
    UPDATE bargain_sessions
    SET status = 'accepted'
    WHERE bargain_id = NEW.bargain_id;

    INSERT INTO bargain_system_notifications (bargain_id, notification_type, content)
    VALUES (NEW.bargain_id, 'accept', CONCAT('Offer accepted by ', NEW.sender_role));

  ELSEIF NEW.message_type = 'reject' THEN
    UPDATE bargain_sessions
    SET status = 'rejected'
    WHERE bargain_id = NEW.bargain_id;

    INSERT INTO bargain_system_notifications (bargain_id, notification_type, content)
    VALUES (NEW.bargain_id, 'reject', CONCAT('Offer rejected by ', NEW.sender_role));

  ELSEIF NEW.message_type = 'finalize' THEN
    UPDATE bargain_sessions
    SET status = 'completed'
    WHERE bargain_id = NEW.bargain_id;
  END IF;

  -- Handle price_offer and counter_offer updates
  IF NEW.message_type IN ('price_offer', 'counter_offer') AND NEW.price_suggestion IS NOT NULL THEN
    UPDATE bargain_session_products
    SET current_offer = NEW.price_suggestion
    WHERE bargain_id = NEW.bargain_id;

    UPDATE bargain_sessions
    SET status = 'countered'
    WHERE bargain_id = NEW.bargain_id;
  END IF;

END;
//

DELIMITER ;




CREATE TABLE bargain_price_history (
  history_id int(11) NOT NULL AUTO_INCREMENT,
  bargain_id int(11) NOT NULL,
  price decimal(10,2) NOT NULL,
  offered_by enum('consumer','farmer') NOT NULL,
  created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (history_id),
  KEY bargain_id (bargain_id),
  CONSTRAINT bargain_price_history_ibfk_1 FOREIGN KEY (bargain_id) REFERENCES bargain_sessions (bargain_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
-- Add Subscription Table
CREATE TABLE subscriptions (
    subscription_id VARCHAR(10) PRIMARY KEY,
    consumer_id VARCHAR(15) NOT NULL,
    subscription_type ENUM('Daily', 'Alternate Days', 'Weekly', 'Monthly') NOT NULL,
    product_id VARCHAR(10) NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    start_date DATE NOT NULL,
    status ENUM('Active', 'Paused', 'Cancelled') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (consumer_id) REFERENCES consumerregistration(consumer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Trigger for Auto-Generating Subscription ID
DELIMITER $$

CREATE TRIGGER before_subscription_insert
BEFORE INSERT ON subscriptions
FOR EACH ROW
BEGIN
    DECLARE new_id INT;
    DECLARE formatted_id VARCHAR(10);
    
    -- Get the numeric part of the last subscription_id and increment it
    SELECT IFNULL(MAX(CAST(SUBSTRING(subscription_id, 4) AS UNSIGNED)), 0) + 1 
    INTO new_id FROM subscriptions;

    -- Format it as SUB001, SUB002, etc.
    SET formatted_id = CONCAT('SUB', LPAD(new_id, 3, '0'));

    -- Assign the formatted ID to the new row
    SET NEW.subscription_id = formatted_id;
END$$


DELIMITER ;





-- Personal Details Table
ALTER TABLE personaldetails 
MODIFY COLUMN profile_photo VARCHAR(255),
MODIFY COLUMN aadhaar_proof VARCHAR(255),
MODIFY COLUMN bank_proof VARCHAR(255);

-- Farm Details Table
ALTER TABLE farmdetails 
MODIFY COLUMN land_ownership_proof VARCHAR(255),
MODIFY COLUMN certification VARCHAR(255),
MODIFY COLUMN land_lease_agreement VARCHAR(255),
MODIFY COLUMN farm_photographs VARCHAR(255);

CREATE TABLE payments (
    payment_id VARCHAR(20) PRIMARY KEY,
    order_id VARCHAR(10) NOT NULL,
    razorpay_order_id VARCHAR(50) NOT NULL,
    razorpay_payment_id VARCHAR(50) NOT NULL,
    razorpay_signature VARCHAR(255) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'INR',
    status ENUM('created', 'captured', 'failed') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES placeorder(order_id)
);

-- Update the placeorder table to make address non-nullable with a default
ALTER TABLE placeorder MODIFY address TEXT NOT NULL;

-- Add pincode field if not exists
ALTER TABLE placeorder ADD COLUMN IF NOT EXISTS pincode VARCHAR(10) NOT NULL;

-- Create payments table if not exists
CREATE TABLE IF NOT EXISTS payments (
    payment_id VARCHAR(20) PRIMARY KEY,
    order_id VARCHAR(10) NOT NULL,
    razorpay_order_id VARCHAR(50) NOT NULL,
    razorpay_payment_id VARCHAR(50) NOT NULL,
    razorpay_signature VARCHAR(255) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'INR',
    status ENUM('created', 'captured', 'failed') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES placeorder(order_id)
);

DROP TRIGGER IF EXISTS before_insert_placeorder;

DELIMITER $$

CREATE TRIGGER before_insert_placeorder
BEFORE INSERT ON placeorder
FOR EACH ROW
BEGIN
    DECLARE max_id INT DEFAULT 0;
    DECLARE next_id VARCHAR(10);
    DECLARE id_num INT;
    
    -- Get the highest numeric part of existing order_id
    SELECT IFNULL(MAX(CAST(SUBSTRING(order_id, 4) AS UNSIGNED)), 0) INTO max_id 
    FROM placeorder
    WHERE order_id REGEXP '^ORD[0-9]+$';
    
    -- Calculate next ID number
    SET id_num = max_id + 1;
    
    -- Format the order ID with leading zeros (ORD001, ORD002, etc.)
    SET next_id = CONCAT('ORD', LPAD(id_num, 3, '0'));
    
    -- Assign the new order_id
    SET NEW.order_id = next_id;
    
    -- Set default status if not provided
    IF NEW.status IS NULL THEN
        SET NEW.status = 'Pending';
    END IF;
    
    -- Set created_at timestamp if not provided
    IF NEW.created_at IS NULL THEN
        SET NEW.created_at = CURRENT_TIMESTAMP;
    END IF;
END$$

DELIMITER ;


-- Add Razorpay fields to placeorder table
ALTER TABLE placeorder 
ADD COLUMN IF NOT EXISTS razorpay_payment_id VARCHAR(50),
ADD COLUMN IF NOT EXISTS razorpay_order_id VARCHAR(50),
ADD COLUMN IF NOT EXISTS razorpay_signature VARCHAR(255);
ALTER TABLE placeorder
MODIFY COLUMN razorpay_payment_id VARCHAR(50) DEFAULT NULL,
MODIFY COLUMN razorpay_order_id VARCHAR(50) DEFAULT NULL,
MODIFY COLUMN razorpay_signature VARCHAR(255) DEFAULT NULL,
ADD COLUMN IF NOT EXISTS notes TEXT DEFAULT NULL;




CREATE TABLE wallet_transactions (
    transaction_id VARCHAR(15) PRIMARY KEY,
    consumer_id VARCHAR(15) NOT NULL,
    transaction_type ENUM('Credit', 'Debit') NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    balance DECIMAL(10,2) NOT NULL,
    description VARCHAR(255),
    payment_method VARCHAR(50),
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (consumer_id) REFERENCES consumerregistration(consumer_id)
);

DELIMITER $$

CREATE TRIGGER before_wallet_transaction_insert
BEFORE INSERT ON wallet_transactions
FOR EACH ROW
BEGIN
    DECLARE new_id INT;
    DECLARE formatted_id VARCHAR(15);
    DECLARE prev_balance DECIMAL(10,2) DEFAULT 0;
    
    -- Get the numeric part of the last transaction_id
    SELECT IFNULL(MAX(CAST(SUBSTRING(transaction_id, 4) AS UNSIGNED)), 0) + 1 
    INTO new_id FROM wallet_transactions;

    -- Get previous balance
    SELECT balance INTO prev_balance 
    FROM wallet_transactions 
    WHERE consumer_id = NEW.consumer_id 
    ORDER BY transaction_date DESC 
    LIMIT 1;

    -- Set default balance if no previous transactions
    IF prev_balance IS NULL THEN
        SET prev_balance = 0;
    END IF;

    -- Calculate new balance
    IF NEW.transaction_type = 'Credit' THEN
        SET NEW.balance = prev_balance + NEW.amount;
    ELSE
        SET NEW.balance = prev_balance - NEW.amount;
    END IF;

    -- Format transaction ID
    SET formatted_id = CONCAT('TXN', LPAD(new_id, 3, '0'));
    SET NEW.transaction_id = formatted_id;
END$$

DELIMITER ;






ALTER TABLE orders ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

CREATE TABLE frozen_orders (
  order_id INT AUTO_INCREMENT PRIMARY KEY,
  community_id VARCHAR(15) NOT NULL,
  member_id VARCHAR(15) NOT NULL,
  order_data TEXT NOT NULL,
  discount_data TEXT NOT NULL,
  total_amount DECIMAL(10, 2) NOT NULL,
  payment_method VARCHAR(50),
  status ENUM('pending', 'completed') DEFAULT 'pending',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  completed_at DATETIME,
  FOREIGN KEY (community_id) REFERENCES communities(community_id),
  FOREIGN KEY (member_id) REFERENCES members(member_id)
);


ALTER TABLE placeorder ADD COLUMN is_community ENUM('yes', 'no') DEFAULT 'no';


ALTER TABLE add_produce ADD COLUMN minimum_quantity INT NOT NULL;
ALTER TABLE add_produce 
MODIFY COLUMN minimum_quantity INT NULL CHECK (minimum_quantity IS NULL OR minimum_quantity >= 0);





CREATE TABLE community_orders (
  order_id INT AUTO_INCREMENT PRIMARY KEY,
  community_id VARCHAR(20) NOT NULL,
  consumer_id VARCHAR(20) NOT NULL,
  name VARCHAR(100) NOT NULL,
  mobile_number VARCHAR(15) NOT NULL,
  email VARCHAR(100) NOT NULL,
  address TEXT NOT NULL,
  pincode VARCHAR(10) NOT NULL,
  status VARCHAR(20) DEFAULT 'Pending',
  payment_method VARCHAR(50) NOT NULL,
  payment_status VARCHAR(20) DEFAULT 'Pending',
  subtotal DECIMAL(10,2) NOT NULL,
  discount_amount DECIMAL(10,2) DEFAULT 0.00,
  total_amount DECIMAL(10,2) NOT NULL,
  order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
  delivery_date DATE,
  delivery_time VARCHAR(50),
  discount_data JSON,
  FOREIGN KEY (community_id) REFERENCES communities(community_id),
  FOREIGN KEY (consumer_id) REFERENCES consumerregistration(consumer_id)
);




ALTER TABLE community_orders 
ADD COLUMN produce_name TEXT NOT NULL AFTER pincode;

ALTER TABLE community_orders

ADD COLUMN quantity INT AFTER produce_name,
ADD COLUMN amount DECIMAL(10,2) AFTER quantity,
ADD COLUMN is_community BOOLEAN DEFAULT TRUE AFTER amount;


-- Add these tables to your database

CREATE TABLE billing_history (
    billing_id VARCHAR(15) PRIMARY KEY,
    consumer_id VARCHAR(15) NOT NULL,
    subscription_type ENUM('Daily', 'Alternate Days', 'Weekly', 'Monthly') NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    billing_date DATE NOT NULL,
    transaction_id VARCHAR(15),
    description VARCHAR(255),
    FOREIGN KEY (consumer_id) REFERENCES consumerregistration(consumer_id),
    FOREIGN KEY (transaction_id) REFERENCES wallet_transactions(transaction_id)
);






-- Trigger for billing_history IDs
DELIMITER $$

CREATE TRIGGER before_billing_history_insert
BEFORE INSERT ON billing_history
FOR EACH ROW
BEGIN
    DECLARE new_id INT;
    DECLARE formatted_id VARCHAR(15);
    
    SELECT IFNULL(MAX(CAST(SUBSTRING(billing_id, 4) AS UNSIGNED)), 0) + 1 
    INTO new_id FROM billing_history;

    SET formatted_id = CONCAT('BIL', LPAD(new_id, 3, '0'));
    SET NEW.billing_id = formatted_id;
END$$

DELIMITER ;

-- Similar triggers for delivery_logs and subscription_logs


CREATE TABLE bargain_orders (
  order_id INT(11) NOT NULL AUTO_INCREMENT,
  bargain_id INT(11) NOT NULL,
  consumer_id VARCHAR(15) NOT NULL,
  consumer_name VARCHAR(100) NOT NULL,
  farmer_id VARCHAR(15) NOT NULL,
  farmer_name VARCHAR(100) NOT NULL,
  product_id VARCHAR(10) NOT NULL,
  product_name VARCHAR(100) NOT NULL,
  product_category VARCHAR(100) NOT NULL,
  quantity DECIMAL(10,2) NOT NULL,
  original_price DECIMAL(10,2) NOT NULL,
  final_price DECIMAL(10,2) NOT NULL,
  total_amount DECIMAL(10,2) NOT NULL,
  status ENUM('accepted', 'rejected', 'pending_payment', 'completed', 'cancelled') NOT NULL DEFAULT 'accepted',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (order_id)
);


DELIMITER //
CREATE TRIGGER insert_bargain_order_after_accept_or_reject 
AFTER INSERT ON bargain_messages FOR EACH ROW
BEGIN
  DECLARE farmerName VARCHAR(100);
  DECLARE consumerName VARCHAR(100);
  DECLARE farmerId VARCHAR(20);
  DECLARE consumerId VARCHAR(20);
  DECLARE final_price DECIMAL(10,2);
  DECLARE quantity DECIMAL(10,2);
  DECLARE productId VARCHAR(10);
  DECLARE productName VARCHAR(100);
  DECLARE productCategory VARCHAR(100);
  DECLARE originalPrice DECIMAL(10,2);
  DECLARE totalAmount DECIMAL(10,2);
  DECLARE orderStatus VARCHAR(20);

  -- Handle both accept and reject cases
  IF NEW.message_type = 'accept' OR NEW.message_type = 'reject' THEN
    -- Set status based on message type
    IF NEW.message_type = 'accept' THEN
      SET orderStatus = 'accepted';
    ELSE
      SET orderStatus = 'rejected';
    END IF;

    -- Get farmer details
    SELECT fr.first_name, bs.farmer_id
    INTO farmerName, farmerId
    FROM bargain_sessions bs
    JOIN farmerregistration fr ON bs.farmer_id = fr.farmer_id
    WHERE bs.bargain_id = NEW.bargain_id;

    -- Get consumer details
    SELECT cr.first_name, bs.consumer_id
    INTO consumerName, consumerId
    FROM bargain_sessions bs
    JOIN consumerregistration cr ON bs.consumer_id = cr.consumer_id
    WHERE bs.bargain_id = NEW.bargain_id;

    -- Get product details
    SELECT bsp.product_id, ap.produce_name, ap.produce_type, bsp.original_price, bsp.quantity
    INTO productId, productName, productCategory, originalPrice, quantity
    FROM bargain_session_products bsp
    JOIN add_produce ap ON bsp.product_id = ap.product_id
    WHERE bsp.bargain_id = NEW.bargain_id
    LIMIT 1;

    -- Set final price (last offered price)
    SET final_price = NEW.price_suggestion;
    SET totalAmount = final_price * quantity;

    -- Insert into bargain_orders
    INSERT INTO bargain_orders (
      bargain_id,
      consumer_id,
      consumer_name,
      farmer_id,
      farmer_name,
      product_id,
      product_name,
      product_category,
      quantity,
      original_price,
      final_price,
      total_amount,
      status
    ) VALUES (
      NEW.bargain_id,
      consumerId,
      consumerName,
      farmerId,
      farmerName,
      productId,
      productName,
      productCategory,
      quantity,
      originalPrice,
      final_price,
      totalAmount,
      orderStatus
    );
  END IF;
END//
DELIMITER ;


CREATE TABLE cart (
    cart_id INT AUTO_INCREMENT PRIMARY KEY,
    consumer_id VARCHAR(20) NOT NULL COMMENT 'e.g., KRST01CS011 (from consumer_registration)',
    farmer_id VARCHAR(20) NOT NULL COMMENT 'e.g., KRST01FR005 (from farmer_registration)',
    product_id VARCHAR(20) NOT NULL COMMENT 'References products table',
    product_name VARCHAR(100) NOT NULL,
    product_category VARCHAR(50) NOT NULL,
    quantity DECIMAL(10,2) NOT NULL,
    price_per_kg DECIMAL(10,2) NOT NULL COMMENT 'Final bargained price',
    total_price DECIMAL(10,2) NOT NULL COMMENT 'price_per_kg * quantity',
    bargain_id INT COMMENT 'Optional: If from a bargain',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (consumer_id) REFERENCES consumerregistration(consumer_id),
    FOREIGN KEY (farmer_id) REFERENCES farmerregistration(farmer_id),
    FOREIGN KEY (product_id) REFERENCES add_produce(product_id),
    CONSTRAINT unique_cart_item UNIQUE (consumer_id, product_id, bargain_id)
);

DELIMITER $$

CREATE TRIGGER add_to_cart_after_accept_message
AFTER INSERT ON bargain_messages
FOR EACH ROW
BEGIN
  DECLARE consumerId VARCHAR(20);
  DECLARE farmerId VARCHAR(20);
  DECLARE productId VARCHAR(20);
  DECLARE productName VARCHAR(100);
  DECLARE productCategory VARCHAR(50);
  DECLARE quantity DECIMAL(10,2);
  DECLARE pricePerKg DECIMAL(10,2);
  DECLARE totalPrice DECIMAL(10,2);

  IF NEW.message_type = 'accept' THEN

    -- Fetch all relevant details for cart
    SELECT 
      bs.consumer_id,
      bs.farmer_id,
      bsp.product_id,
      ap.produce_name,
      ap.produce_type,
      bsp.quantity,
      NEW.price_suggestion
    INTO 
      consumerId,
      farmerId,
      productId,
      productName,
      productCategory,
      quantity,
      pricePerKg
    FROM bargain_sessions bs
    JOIN bargain_session_products bsp ON bs.bargain_id = bsp.bargain_id
    JOIN add_produce ap ON bsp.product_id = ap.product_id
    WHERE bs.bargain_id = NEW.bargain_id
    LIMIT 1;

    SET totalPrice = quantity * pricePerKg;

    -- Insert into cart
    INSERT INTO cart (
      consumer_id,
      farmer_id,
      product_id,
      product_name,
      product_category,
      quantity,
      price_per_kg,
      total_price,
      bargain_id
    ) VALUES (
      consumerId,
      farmerId,
      productId,
      productName,
      productCategory,
      quantity,
      pricePerKg,
      totalPrice,
      NEW.bargain_id
    );

  END IF;
END$$

DELIMITER ;


ALTER TABLE add_produce
ADD COLUMN minimum_price DECIMAL(10,2) NULL CHECK (minimum_price >= 0);