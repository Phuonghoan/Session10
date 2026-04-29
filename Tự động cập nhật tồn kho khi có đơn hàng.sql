-- Tạo bảng products
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    stock INT
);

-- Tạo bảng orders
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    product_id INT REFERENCES products(id),
    quantity INT
);

-- Function trigger cập nhật tồn kho
CREATE OR REPLACE FUNCTION update_product_stock()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE products
        SET stock = stock - NEW.quantity
        WHERE id = NEW.product_id;
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        -- Hoàn lại số lượng cũ
        UPDATE products
        SET stock = stock + OLD.quantity
        WHERE id = OLD.product_id;

        -- Trừ số lượng mới
        UPDATE products
        SET stock = stock - NEW.quantity
        WHERE id = NEW.product_id;
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        UPDATE products
        SET stock = stock + OLD.quantity
        WHERE id = OLD.product_id;
        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$;

-- Tạo trigger gắn với bảng orders
CREATE TRIGGER trg_update_product_stock
AFTER INSERT OR UPDATE OR DELETE
ON orders
FOR EACH ROW
EXECUTE FUNCTION update_product_stock();

-- Dữ liệu mẫu products
INSERT INTO products(name, stock) VALUES
('Laptop Dell', 10),
('iPhone 15', 20),
('Ban phim co', 15);

-- Thực hành INSERT đơn hàng
INSERT INTO orders(product_id, quantity)
VALUES (1, 2);

-- Kiểm tra tồn kho sau INSERT
SELECT * FROM products;

-- Thực hành UPDATE đơn hàng
UPDATE orders
SET quantity = 4
WHERE id = 1;

-- Kiểm tra tồn kho sau UPDATE
SELECT * FROM products;

-- Thực hành DELETE đơn hàng
DELETE FROM orders
WHERE id = 1;

-- Kiểm tra tồn kho sau DELETE
SELECT * FROM products;