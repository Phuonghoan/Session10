-- Tạo bảng products
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    price NUMERIC(10,2),
    last_modified TIMESTAMP
);

-- Tạo function update_last_modified()
CREATE OR REPLACE FUNCTION update_last_modified()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.last_modified := NOW();
    RETURN NEW;
END;
$$;

-- Tạo trigger trg_update_last_modified
CREATE TRIGGER trg_update_last_modified
BEFORE UPDATE ON products
FOR EACH ROW
EXECUTE FUNCTION update_last_modified();

-- Chèn dữ liệu mẫu
INSERT INTO products (name, price, last_modified) VALUES
('Laptop Dell', 15000000, NOW()),
('iPhone 13', 12000000, NOW()),
('Ban phim co', 1200000, NOW());

-- Kiểm tra dữ liệu ban đầu
SELECT * FROM products;

-- UPDATE 1 bản ghi để kiểm tra trigger
UPDATE products
SET price = 15500000
WHERE id = 1;

-- Kiểm tra lại last_modified
SELECT * FROM products WHERE id = 1;

-- UPDATE nhiều bản ghi để kiểm tra trigger
UPDATE products
SET price = price * 1.10
WHERE id IN (2, 3);

-- Kiểm tra lại
SELECT * FROM products;