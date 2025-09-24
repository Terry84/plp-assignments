-- ecommerce_schema.sql
-- E-commerce database schema
-- MySQL / InnoDB dialect

-- Drop existing DB if present (idempotent)
DROP DATABASE IF EXISTS ecommerce_db;
CREATE DATABASE ecommerce_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ecommerce_db;

-- Temporarily disable FK checks while creating/dropping tables
SET FOREIGN_KEY_CHECKS = 0;

-- Drop tables if they exist (safe order)
DROP TABLE IF EXISTS review;
DROP TABLE IF EXISTS order_item;
DROP TABLE IF EXISTS payment;
DROP TABLE IF EXISTS shipment;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS product_image;
DROP TABLE IF EXISTS product_category;
DROP TABLE IF EXISTS category;
DROP TABLE IF EXISTS inventory;
DROP TABLE IF EXISTS supplier_product;
DROP TABLE IF EXISTS supplier;
DROP TABLE IF EXISTS product;
DROP TABLE IF EXISTS address;
DROP TABLE IF EXISTS customer;

SET FOREIGN_KEY_CHECKS = 1;

-- =================================================
-- Customers (users)
-- =================================================
CREATE TABLE customer (
  customer_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  phone VARCHAR(30),
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE = InnoDB;

-- =================================================
-- Addresses (one customer can have many addresses)
-- =================================================
CREATE TABLE address (
  address_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  customer_id INT UNSIGNED NOT NULL,
  label VARCHAR(50) DEFAULT 'home', -- e.g., home, work
  line1 VARCHAR(255) NOT NULL,
  line2 VARCHAR(255),
  city VARCHAR(100) NOT NULL,
  state VARCHAR(100),
  postal_code VARCHAR(30),
  country VARCHAR(100) NOT NULL,
  is_default BOOLEAN NOT NULL DEFAULT FALSE,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB;

-- =================================================
-- Categories (product categorization)
-- =================================================
CREATE TABLE category (
  category_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  description TEXT,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE = InnoDB;

-- =================================================
-- Suppliers
-- =================================================
CREATE TABLE supplier (
  supplier_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  contact_email VARCHAR(255),
  contact_phone VARCHAR(50),
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE = InnoDB;

-- =================================================
-- Products
-- =================================================
CREATE TABLE product (
  product_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  sku VARCHAR(64) NOT NULL UNIQUE,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  weight DECIMAL(8,3) DEFAULT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE = InnoDB;

-- =================================================
-- Many-to-many: product <-> category
-- =================================================
CREATE TABLE product_category (
  product_id INT UNSIGNED NOT NULL,
  category_id INT UNSIGNED NOT NULL,
  PRIMARY KEY (product_id, category_id),
  FOREIGN KEY (product_id) REFERENCES product(product_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (category_id) REFERENCES category(category_id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
) ENGINE = InnoDB;

-- =================================================
-- Product images (one product -> many images)
-- =================================================
CREATE TABLE product_image (
  image_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  product_id INT UNSIGNED NOT NULL,
  url VARCHAR(1000) NOT NULL,
  alt_text VARCHAR(255),
  sort_order INT UNSIGNED DEFAULT 0,
  uploaded_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (product_id) REFERENCES product(product_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB;

-- =================================================
-- Inventory (one row per product per supplier/warehouse; simple model)
-- =================================================
CREATE TABLE inventory (
  inventory_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  product_id INT UNSIGNED NOT NULL,
  supplier_id INT UNSIGNED,
  quantity INT NOT NULL DEFAULT 0,
  reserved INT NOT NULL DEFAULT 0, -- reserved for orders
  last_restocked DATETIME,
  FOREIGN KEY (product_id) REFERENCES product(product_id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  FOREIGN KEY (supplier_id) REFERENCES supplier(supplier_id)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  UNIQUE KEY uq_product_supplier (product_id, supplier_id)
) ENGINE = InnoDB;

-- =================================================
-- Supplier <-> Product (many-to-many) for supplier catalog info
-- =================================================
CREATE TABLE supplier_product (
  supplier_id INT UNSIGNED NOT NULL,
  product_id INT UNSIGNED NOT NULL,
  supplier_sku VARCHAR(128),
  cost_price DECIMAL(10,2) DEFAULT NULL,
  lead_time_days INT DEFAULT NULL,
  PRIMARY KEY (supplier_id, product_id),
  FOREIGN KEY (supplier_id) REFERENCES supplier(supplier_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (product_id) REFERENCES product(product_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB;

-- =================================================
-- Orders (one-to-many: customer -> orders)
-- =================================================
CREATE TABLE orders (
  order_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  order_number VARCHAR(50) NOT NULL UNIQUE,
  customer_id INT UNSIGNED NOT NULL,
  shipping_address_id INT UNSIGNED,
  billing_address_id INT UNSIGNED,
  status ENUM('pending','processing','shipped','delivered','cancelled','returned') NOT NULL DEFAULT 'pending',
  subtotal DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  shipping DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  tax DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  total DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  placed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  FOREIGN KEY (shipping_address_id) REFERENCES address(address_id)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  FOREIGN KEY (billing_address_id) REFERENCES address(address_id)
    ON DELETE SET NULL
    ON UPDATE CASCADE
) ENGINE = InnoDB;

-- =================================================
-- Order items (many-to-many between orders and products with payload)
-- =================================================
CREATE TABLE order_item (
  order_item_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  order_id BIGINT UNSIGNED NOT NULL,
  product_id INT UNSIGNED NOT NULL,
  sku VARCHAR(64) NOT NULL,
  product_name VARCHAR(255) NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  quantity INT UNSIGNED NOT NULL DEFAULT 1,
  line_total DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders(order_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (product_id) REFERENCES product(product_id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
) ENGINE = InnoDB;

-- =================================================
-- Payments (one-to-one-ish with orders; an order may have many payments but typically one)
-- =================================================
CREATE TABLE payment (
  payment_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  order_id BIGINT UNSIGNED NOT NULL,
  provider ENUM('stripe','paypal','card','bank_transfer','cash_on_delivery') NOT NULL,
  provider_payment_id VARCHAR(255),
  amount DECIMAL(10,2) NOT NULL,
  currency CHAR(3) NOT NULL DEFAULT 'USD',
  status ENUM('pending','authorized','paid','failed','refunded') NOT NULL DEFAULT 'pending',
  paid_at DATETIME,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (order_id) REFERENCES orders(order_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB;

-- =================================================
-- Shipments
-- =================================================
CREATE TABLE shipment (
  shipment_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  order_id BIGINT UNSIGNED NOT NULL,
  shipped_at DATETIME,
  delivered_at DATETIME,
  carrier VARCHAR(100),
  tracking_number VARCHAR(200),
  status ENUM('label_created','in_transit','delivered','exception') DEFAULT 'label_created',
  FOREIGN KEY (order_id) REFERENCES orders(order_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB;

-- =================================================
-- Product reviews (customer -> product, one customer can review a product once)
-- =================================================
CREATE TABLE review (
  review_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  product_id INT UNSIGNED NOT NULL,
  customer_id INT UNSIGNED NOT NULL,
  rating TINYINT UNSIGNED NOT NULL CHECK (rating >= 1 AND rating <= 5),
  title VARCHAR(255),
  body TEXT,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_product_customer (product_id, customer_id),
  FOREIGN KEY (product_id) REFERENCES product(product_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB;

-- =================================================
-- Useful indexes for typical queries
-- =================================================
CREATE INDEX idx_product_name ON product(name);
CREATE INDEX idx_inventory_product ON inventory(product_id);
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orderitem_order ON order_item(order_id);
CREATE INDEX idx_category_name ON category(name);

-- =================================================
-- Example views or stored metadata (optional)
-- =================================================
-- (Left out to keep schema file focused on tables/relationships)

-- End of schema
