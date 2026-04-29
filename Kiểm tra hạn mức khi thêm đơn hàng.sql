-- Tạo bảng customers
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    credit_limit NUMERIC(15,2)
);

-- Tạo bảng orders
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(id),
    order_amount NUMERIC(15,2)
);

-- Tạo function check_credit_limit()
CREATE OR REPLACE FUNCTION check_credit_limit()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_credit_limit NUMERIC(15,2);
    v_total_orders NUMERIC(15,2);
BEGIN
    SELECT credit_limit
    INTO v_credit_limit
    FROM customers
    WHERE id = NEW.customer_id;

    IF v_credit_limit IS NULL THEN
        RAISE EXCEPTION 'Customer % does not exist', NEW.customer_id;
    END IF;

    SELECT COALESCE(SUM(order_amount), 0)
    INTO v_total_orders
    FROM orders
    WHERE customer_id = NEW.customer_id;

    IF v_total_orders + NEW.order_amount > v_credit_limit THEN
        RAISE EXCEPTION 'Credit limit exceeded for customer %', NEW.customer_id;
    END IF;

    RETURN NEW;
END;
$$;

-- Tạo trigger trg_check_credit
CREATE TRIGGER trg_check_credit
BEFORE INSERT ON orders
FOR EACH ROW
EXECUTE FUNCTION check_credit_limit();

-- Chèn dữ liệu mẫu vào customers
INSERT INTO customers (name, credit_limit) VALUES
('Nguyen Van A', 1000000),
('Tran Thi B', 2000000),
('Le Van C', 1500000);

-- Chèn các đơn hàng hợp lệ
INSERT INTO orders (customer_id, order_amount) VALUES
(1, 300000),
(1, 200000),
(2, 500000),
(3, 1000000);

-- Thử trường hợp vượt hạn mức
-- Khách hàng 1 hiện đã có 500000, thêm 600000 sẽ vượt 1000000
INSERT INTO orders (customer_id, order_amount) VALUES
(1, 600000);

-- Kiểm tra dữ liệu
SELECT * FROM customers;
SELECT * FROM orders;