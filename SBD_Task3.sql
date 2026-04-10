SET TERMOUT ON
PROMPT Building demonstration tables.  Please wait.
SET TERMOUT OFF

DROP TABLE EMP;
DROP TABLE DEPT;
DROP TABLE BONUS;
DROP TABLE SALGRADE;
DROP TABLE DUMMY;

CREATE TABLE EMP
       (EMPNO NUMBER(4) NOT NULL,
        ENAME VARCHAR2(10),
        JOB VARCHAR2(9),
        MGR NUMBER(4),
        HIREDATE DATE,
        SAL NUMBER(7, 2),
        COMM NUMBER(7, 2),
        DEPTNO NUMBER(2));

INSERT INTO EMP VALUES
        (7369, 'SMITH',  'CLERK',     7902,
        TO_DATE('17-MAR-1980', 'DD-MON-YYYY'),  800, NULL, 20);
INSERT INTO EMP VALUES
        (7499, 'ALLEN',  'SALESMAN',  7698,
        TO_DATE('20-MAR-1981', 'DD-MON-YYYY'), 1600,  300, 30);
INSERT INTO EMP VALUES
        (7521, 'WARD',   'SALESMAN',  7698,
        TO_DATE('22-MAR-1981', 'DD-MON-YYYY'), 1250,  500, 30);
INSERT INTO EMP VALUES
        (7566, 'JONES',  'MANAGER',   7839,
        TO_DATE('2-MAR-1981', 'DD-MON-YYYY'),  2975, NULL, 20);
INSERT INTO EMP VALUES
        (7654, 'MARTIN', 'SALESMAN',  7698,
        TO_DATE('28-MAR-1981', 'DD-MON-YYYY'), 1250, 1400, 30);
INSERT INTO EMP VALUES
        (7698, 'BLAKE',  'MANAGER',   7839,
        TO_DATE('1-MAR-1981', 'DD-MON-YYYY'),  2850, NULL, 30);
INSERT INTO EMP VALUES
        (7782, 'CLARK',  'MANAGER',   7839,
        TO_DATE('9-MAR-1981', 'DD-MON-YYYY'),  2450, NULL, 10);
INSERT INTO EMP VALUES
        (7788, 'SCOTT',  'ANALYST',   7566,
        TO_DATE('09-MAR-1982', 'DD-MON-YYYY'), 3000, NULL, 20);
INSERT INTO EMP VALUES
        (7839, 'KING',   'PRESIDENT', NULL,
        TO_DATE('17-MAR-1981', 'DD-MON-YYYY'), 5000, NULL, 10);
INSERT INTO EMP VALUES
        (7844, 'TURNER', 'SALESMAN',  7698,
        TO_DATE('8-MAR-1981', 'DD-MON-YYYY'),  1500,    0, 30);
INSERT INTO EMP VALUES
        (7876, 'ADAMS',  'CLERK',     7788,
        TO_DATE('12-MAR-1983', 'DD-MON-YYYY'), 1100, NULL, 20);
INSERT INTO EMP VALUES
        (7900, 'JAMES',  'CLERK',     7698,
        TO_DATE('3-MAR-1981', 'DD-MON-YYYY'),   950, NULL, 30);
INSERT INTO EMP VALUES
        (7902, 'FORD',   'ANALYST',   7566,
        TO_DATE('3-MAR-1981', 'DD-MON-YYYY'),  3000, NULL, 20);
INSERT INTO EMP VALUES
        (7934, 'MILLER', 'CLERK',     7782,
        TO_DATE('23-MAR-1982', 'DD-MON-YYYY'), 1300, NULL, 10);

CREATE TABLE DEPT
       (DEPTNO NUMBER(2),
        DNAME VARCHAR2(14),
        LOC VARCHAR2(13) );

INSERT INTO DEPT VALUES (10, 'ACCOUNTING', 'NEW YORK');
INSERT INTO DEPT VALUES (20, 'RESEARCH',   'DALLAS');
INSERT INTO DEPT VALUES (30, 'SALES',      'CHICAGO');
INSERT INTO DEPT VALUES (40, 'OPERATIONS', 'BOSTON');

CREATE TABLE BONUS
        (ENAME VARCHAR2(10),
         JOB   VARCHAR2(9),
         SAL   NUMBER,
         COMM  NUMBER);

CREATE TABLE SALGRADE
        (GRADE NUMBER,
         LOSAL NUMBER,
         HISAL NUMBER);

INSERT INTO SALGRADE VALUES (1,  700, 1200);
INSERT INTO SALGRADE VALUES (2, 1201, 1400);
INSERT INTO SALGRADE VALUES (3, 1401, 2000);
INSERT INTO SALGRADE VALUES (4, 2001, 3000);
INSERT INTO SALGRADE VALUES (5, 3001, 9999);

CREATE TABLE DUMMY
        (DUMMY NUMBER);

INSERT INTO DUMMY VALUES (0);

COMMIT;

SET TERMOUT ON
PROMPT Demonstration table build is complete.

SELECT *
FROM EMP;

SELECT *
FROM DEPT;

SELECT *
FROM BONUS;

SELECT *
FROM SALGRADE;

SELECT *
FROM DUMMY;

-- 1
CREATE VIEW loc_summary AS
SELECT d.loc,
       COUNT(DISTINCT d.deptno) AS dept_count,
       COUNT(e.empno) AS emp_count
FROM dept d
LEFT JOIN emp e
  ON d.deptno = e.deptno
GROUP BY d.loc;

SELECT *
FROM loc_summary;

-- 2
INSERT INTO EMP (EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO)
VALUES (8000, USER, 'CLERK', 7782, SYSDATE, 1300, NULL, 10);

CREATE VIEW person_use_view AS
SELECT e.empno,
       e.ename,
       e.job,
       e.mgr,
       e.hiredate,
       e.sal,
       e.comm,
       e.deptno,
       d.dname,
       d.loc,
       s.grade
FROM emp e
LEFT JOIN dept d
  ON e.deptno = d.deptno
LEFT JOIN salgrade s
  ON e.sal BETWEEN s.losal AND s.hisal
WHERE e.ename = USER;

SELECT *
FROM person_use_view;

-- 3
CREATE VIEW my_tables_info AS
SELECT t.table_name,
       COUNT(c.column_name) AS column_count,
       t.num_rows AS row_count
FROM user_tables t
JOIN user_tab_columns c
  ON t.table_name = c.table_name
GROUP BY t.table_name, t.num_rows;

SELECT *
FROM my_tables_info;

-- 4
-- Roles: Sales, Manager, Customer Service

-- View for Sales
-- required views: v_sales_products, v_sales_clients, v_sales_transactions
CREATE VIEW v_sales_products AS
SELECT p.product_id,
       p.name,
       p.price
FROM products p;

CREATE VIEW v_sales_clients AS
SELECT c.client_id,
       c.name,
       c.surname,
       c.address
FROM clients c;

CREATE VIEW v_sales_transactions AS
SELECT s.sales_id,
       s.client_id,
       s.product_id,
       s.quantity,
       s.date,
       s.emp_id
FROM sales s;

-- View for Manager
-- required views: v_manager_employees, v_manager_sales_summary
CREATE VIEW v_manager_employees AS
SELECT e.emp_id,
       e.name,
       e.surname,
       e.birth_date,
       e.address,
       em.start_date,
       em.position,
       em.end_date,
       em.salary
FROM employees e
JOIN employment em
  ON e.emp_id = em.emp_id;

CREATE VIEW v_manager_sales_summary AS
SELECT e.emp_id,
       e.name,
       e.surname,
       p.product_id,
       p.name AS product_name,
       SUM(s.quantity) AS total_quantity_sold,
       SUM(s.quantity * p.price) AS total_revenue
FROM sales s
JOIN employees e
  ON s.emp_id = e.emp_id
JOIN products p
  ON s.product_id = p.product_id
GROUP BY e.emp_id,
         e.name,
         e.surname,
         p.product_id,
         p.name;

-- View for Customer Service
-- required views: v_cs_client_orders
CREATE VIEW v_cs_client_orders AS
SELECT s.sales_id,
       c.client_id,
       c.name AS client_name,
       c.surname AS client_surname,
       p.product_id,
       p.name AS product_name,
       s.quantity,
       s.date,
       e.emp_id,
       e.name AS employee_name,
       e.surname AS employee_surname
FROM sales s
JOIN clients c
  ON s.client_id = c.client_id
JOIN products p
  ON s.product_id = p.product_id
JOIN employees e
  ON s.emp_id = e.emp_id;

-- 5
-- The transaction should be executed at the SERIALIZABLE isolation level
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SELECT available_seats
FROM Flights
WHERE flight_id = :flight_id;

UPDATE Flights
SET available_seats = available_seats - :requested_seats
WHERE flight_id = :flight_id
  AND available_seats >= :requested_seats;

INSERT INTO Reservations (reservation_id, flight_id, customer_id, seats_reserved)
VALUES (:reservation_id, :flight_id, :customer_id, :requested_seats);

COMMIT;

-- If there are not enough seats, execute:
ROLLBACK;

-- 6
-- The transaction should be executed at the SERIALIZABLE isolation level
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SELECT balance
FROM Accounts
WHERE account_no = :from_account;

SELECT balance
FROM Accounts
WHERE account_no = :to_account;

UPDATE Accounts
SET balance = balance - :amount
WHERE account_no = :from_account
  AND balance >= :amount;

UPDATE Accounts
SET balance = balance + :amount
WHERE account_no = :to_account;

COMMIT;

-- If one of the accounts does not exist or the balance is insufficient, execute:
ROLLBACK;

-- 7
-- In a customer orders database, using table clusters can improve performance.
-- Tables like Customers, Orders, and Order_Items are often joined using keys such as customer_id or order_id. 
-- Clustering stores related rows together physically, reducing disk I/O and speeding up joins.
-- However, clusters are not suitable if tables are rarely joined or if there are many insert operations.
-- Therefore, clusters are useful in this case when queries frequently join these tables.

-- 8
CREATE TABLE customers (
    customer_id NUMBER(6) PRIMARY KEY,
    name        VARCHAR2(30) NOT NULL,
    surname     VARCHAR2(30) NOT NULL,
    address     VARCHAR2(100)
);

CREATE TABLE products (
    product_id  NUMBER(6) PRIMARY KEY,
    name        VARCHAR2(50) NOT NULL,
    price       NUMBER(10,2) NOT NULL,
    CONSTRAINT chk_product_price CHECK (price > 0)
);

CREATE TABLE orders (
    order_id     NUMBER(6) PRIMARY KEY,
    customer_id  NUMBER(6) NOT NULL,
    order_date   DATE NOT NULL,
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON DELETE CASCADE
);

CREATE TABLE order_items (
    order_id     NUMBER(6) NOT NULL,
    product_id   NUMBER(6) NOT NULL,
    quantity     NUMBER(6) NOT NULL,
    CONSTRAINT pk_order_items PRIMARY KEY (order_id, product_id),
    CONSTRAINT chk_order_items_quantity CHECK (quantity > 0),
    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_order_items_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);
