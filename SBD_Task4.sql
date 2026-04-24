-- 1
customers(
  customer_id PK,
  name,
  phone,
  discount
)

employees(
  employee_id PK,
  name
)

services(
  service_id PK,
  name,
  price
)

reservations(
  reservation_id PK,
  reservation_date,
  customer_id FK,
  employee_id FK,
  service_id FK
)

shifts(
  shift_id PK,
  employee_id FK,
  shift_date,
)

-- 2.
-- Prepare the database
-- customer table
CREATE TABLE customers (
    customer_id NUMBER PRIMARY KEY,
    name VARCHAR2(50),
    phone VARCHAR2(20),
    discount NUMBER
);

-- employees table
CREATE TABLE employees (
    employee_id NUMBER PRIMARY KEY,
    name VARCHAR2(50),
    salary NUMBER
);

INSERT INTO employees VALUES (1, 'Anna', 0);
INSERT INTO employees VALUES (2, 'Ben', 0);
INSERT INTO employees VALUES (3, 'Clara', 0);

-- services table
CREATE TABLE services (
    service_id NUMBER PRIMARY KEY,
    name VARCHAR2(50),
    price NUMBER
);

INSERT INTO services VALUES (1, 'Haircut', 50);
INSERT INTO services VALUES (2, 'Coloring', 100);
INSERT INTO services VALUES (3, 'Styling', 70);

-- reservation table
CREATE TABLE reservations (
  reservation_id NUMBER PRIMARY KEY,
  reservation_date DATE,
  customer_id NUMBER,
  employee_id NUMBER,
  service_id NUMBER
);

-- shirts table
CREATE TABLE shifts (
    shift_id NUMBER PRIMARY KEY,
    employee_id NUMBER,
    shift_date DATE
);

INSERT INTO shifts VALUES (1, 1, TO_DATE('2026-04-23', 'YYYY-MM-DD'));
INSERT INTO shifts VALUES (2, 2, TO_DATE('2026-04-23', 'YYYY-MM-DD'));
INSERT INTO shifts VALUES (3, 3, TO_DATE('2026-01-23', 'YYYY-MM-DD'));

-- 2.1

CREATE OR REPLACE PROCEDURE insert_customer (
    p_customer_id IN NUMBER,
    p_name        IN VARCHAR2,
    p_phone       IN VARCHAR2
)
AS
BEGIN
    INSERT INTO customers
    VALUES (p_customer_id, p_name, p_phone, 0);
END;
/

-- test procedure
EXECUTE Insert_customer(1, 'Alice', '123456');
EXECUTE insert_customer(2, 'Bob', '222');
EXECUTE insert_customer(3, 'Tom', '333');

-- 2.2

CREATE OR REPLACE PROCEDURE make_reservation(
    p_reservation_id IN NUMBER,
    p_date           IN DATE,
    p_customer_id    IN NUMBER,
    p_employee_id    IN NUMBER,
    p_service_id     IN NUMBER
)
AS
BEGIN
    INSERT INTO reservations
    VALUES(p_reservation_id, p_date, p_customer_id, p_employee_id, p_service_id);
END;
/

-- test procedure
-- customer 1
EXECUTE make_reservation(1, TO_DATE('2026-04-23', 'YYYY-MM-DD'), 1, 1, 1);
EXECUTE make_reservation(2, TO_DATE('2026-01-23', 'YYYY-MM-DD'), 1, 1, 1);

-- customer 2
EXECUTE make_reservation(3, TO_DATE('2025-01-23', 'YYYY-MM-DD'), 2, 1, 1);

-- customer 3
EXECUTE make_reservation(4, TO_DATE('2020-01-23', 'YYYY-MM-DD'), 3, 1, 1);

-- 2.3
CREATE OR REPLACE PROCEDURE count_customer_visits(
    p_customer_id IN NUMBER
)
AS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM reservations
    WHERE customer_id = p_customer_id
      AND reservation_date >= ADD_MONTHS(SYSDATE, -24);

    DBMS_OUTPUT.PUT_LINE('Number of visits: ' || v_count);
END;
/

-- test procedure
EXECUTE count_customer_visits(1);
EXECUTE count_customer_visits(2);

-- 2.4
CREATE OR REPLACE PROCEDURE give_discount(
    p_customer_id IN NUMBER,
    p_discount    IN NUMBER
)
AS
BEGIN
    UPDATE customers
    SET discount = p_discount
    WHERE customer_id = p_customer_id;
END;
/

-- test procedure
EXECUTE give_discount(1, 0.2);

-- 2.5
CREATE OR REPLACE PROCEDURE prepare_receipt(
    p_reservation_id IN NUMBER
)
AS
    v_customer_name customers.name%TYPE;
    v_employee_name employees.name%TYPE;
    v_service_name  services.name%TYPE;
    v_price         services.price%TYPE;
    v_discount      customers.discount%TYPE;
    v_final_price   NUMBER;
BEGIN
    SELECT c.name,
           e.name,
           s.name,
           s.price,
           NVL(c.discount, 0),
           s.price * (1 - NVL(c.discount, 0))
    INTO v_customer_name,
         v_employee_name,
         v_service_name,
         v_price,
         v_discount,
         v_final_price
    FROM reservations r
    JOIN customers c ON r.customer_id = c.customer_id
    JOIN employees e ON r.employee_id = e.employee_id
    JOIN services s ON r.service_id = s.service_id
    WHERE r.reservation_id = p_reservation_id;

    DBMS_OUTPUT.PUT_LINE('Receipt');
    DBMS_OUTPUT.PUT_LINE('Customer: ' || v_customer_name);
    DBMS_OUTPUT.PUT_LINE('Hairdresser: ' || v_employee_name);
    DBMS_OUTPUT.PUT_LINE('Service: ' || v_service_name);
    DBMS_OUTPUT.PUT_LINE('Price: ' || v_price);
    DBMS_OUTPUT.PUT_LINE('Discount: ' || v_discount);
    DBMS_OUTPUT.PUT_LINE('Final price: ' || v_final_price);
END;
/

-- test procedure
EXECUTE prepare_receipt(1);

-- 2.6
CREATE OR REPLACE PROCEDURE calculate_salaries
AS
BEGIN
    UPDATE employees e
    SET salary = (
        SELECT NVL(SUM(s.price), 0)
        FROM reservations r
        JOIN services s ON r.service_id = s.service_id
        WHERE r.employee_id = e.employee_id
    );
END;
/

-- test procedure
EXECUTE calculate_salaries;

-- 2.7
CREATE OR REPLACE PROCEDURE replace_sick_hairdresser(
    p_sick_employee_id IN NUMBER
)
AS
BEGIN
    FOR r IN (
        SELECT reservation_id,
               reservation_date
        FROM reservations
        WHERE employee_id = p_sick_employee_id
    )
    LOOP
        UPDATE reservations
        SET employee_id = (
            SELECT MIN(employee_id)
            FROM shifts
            WHERE shift_date = r.reservation_date
              AND employee_id <> p_sick_employee_id
        )
        WHERE reservation_id = r.reservation_id;
    END LOOP;
END;
/

-- test procedure
EXECUTE replace_sick_hairdresser(1);

-- 3.1 check customer exists in reservations
CREATE OR REPLACE TRIGGER check_reservation_customer
BEFORE INSERT OR UPDATE OF customer_id ON reservations
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM customers
    WHERE customer_id = :NEW.customer_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Customer does not exist');
    END IF;
END;
/

-- 3.2 check employee exists in reservations
CREATE OR REPLACE TRIGGER check_reservation_employee
BEFORE INSERT OR UPDATE OF employee_id ON reservations
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM employees
    WHERE employee_id = :NEW.employee_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Employee does not exist');
    END IF;
END;
/

-- 3.3 check service exists in reservations
CREATE OR REPLACE TRIGGER check_reservation_service
BEFORE INSERT OR UPDATE OF service_id ON reservations
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM services
    WHERE service_id = :NEW.service_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Service does not exist');
    END IF;
END;
/

-- 3.4 check employee exists in shifts
CREATE OR REPLACE TRIGGER check_shift_employee
BEFORE INSERT OR UPDATE OF employee_id ON shifts
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM employees
    WHERE employee_id = :NEW.employee_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Employee does not exist');
    END IF;
END;
/

-- 3.5 do not delete customer with reservations
CREATE OR REPLACE TRIGGER no_delete_customer
BEFORE DELETE ON customers
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM reservations
    WHERE customer_id = :OLD.customer_id;

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Cannot delete customer with reservations');
    END IF;
END;
/

-- 3.6 do not delete employee with reservations or shifts
CREATE OR REPLACE TRIGGER no_delete_employee
BEFORE DELETE ON employees
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM reservations
    WHERE employee_id = :OLD.employee_id;

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20006, 'Cannot delete employee with reservations');
    END IF;

    SELECT COUNT(*)
    INTO v_count
    FROM shifts
    WHERE employee_id = :OLD.employee_id;

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20007, 'Cannot delete employee with shifts');
    END IF;
END;
/

-- 3.7 do not delete service with reservations
CREATE OR REPLACE TRIGGER no_delete_service
BEFORE DELETE ON services
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM reservations
    WHERE service_id = :OLD.service_id;

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20008, 'Cannot delete service with reservations');
    END IF;
END;
/
