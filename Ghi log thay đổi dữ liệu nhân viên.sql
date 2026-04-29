-- Tạo bảng employees
CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    position VARCHAR(100),
    salary NUMERIC(10,2)
);

-- Tạo bảng employees_log
CREATE TABLE employees_log (
    log_id SERIAL PRIMARY KEY,
    employee_id INT,
    operation VARCHAR(10),
    old_data JSONB,
    new_data JSONB,
    change_time TIMESTAMP DEFAULT NOW()
);

-- Tạo function trigger
CREATE OR REPLACE FUNCTION log_employee_changes()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO employees_log(employee_id, operation, old_data, new_data, change_time)
        VALUES (
            NEW.id,
            TG_OP,
            NULL,
            to_jsonb(NEW),
            NOW()
        );
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO employees_log(employee_id, operation, old_data, new_data, change_time)
        VALUES (
            NEW.id,
            TG_OP,
            to_jsonb(OLD),
            to_jsonb(NEW),
            NOW()
        );
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO employees_log(employee_id, operation, old_data, new_data, change_time)
        VALUES (
            OLD.id,
            TG_OP,
            to_jsonb(OLD),
            NULL,
            NOW()
        );
        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$;

-- Tạo trigger gắn với bảng employees
CREATE TRIGGER trg_log_employee_changes
AFTER INSERT OR UPDATE OR DELETE
ON employees
FOR EACH ROW
EXECUTE FUNCTION log_employee_changes();

-- Thực hành: chèn dữ liệu
INSERT INTO employees(name, position, salary)
VALUES
('Nguyen Van A', 'Developer', 15000000),
('Tran Thi B', 'Tester', 12000000);

-- Cập nhật dữ liệu
UPDATE employees
SET salary = 17000000
WHERE id = 1;

-- Xóa dữ liệu
DELETE FROM employees
WHERE id = 2;

-- Kiểm tra log
SELECT * FROM employees_log
ORDER BY log_id;