use master;
go
CREATE DATABASE FINAL04;
go
use FINAL04;

CREATE TABLE table_log
(
    log_id NUMERIC IDENTITY(1,1) PRIMARY KEY,
    event_data XML,
    username SYSNAME
);

SELECT * FROM table_log;

go
CREATE OR ALTER TRIGGER trg_table_changes
ON DATABASE
FOR
    CREATE_TABLE,
    ALTER_TABLE,
    DROP_TABLE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO table_log
    (
        event_data,
        username
    )
    VALUES
    (
        EVENTDATA(),
        SYSTEM_USER
    );
END;
go

CREATE TABLE warehouse
(
    warehouse_id NUMERIC IDENTITY(1,1) PRIMARY KEY,
    warehouse_address VARCHAR(256),
    warehouse_city VARCHAR(64),
    warehouse_state VARCHAR(64),
    warehouse_phone VARCHAR(32),
);

INSERT INTO warehouse VALUES ('test', 'Indianapolis', 'Indiana', '555-555-5555');
INSERT INTO warehouse VALUES ('test', 'Buffalo', 'New York', '555-555-5555');
INSERT INTO warehouse VALUES ('test', 'San Diego', 'California', '555-555-5555');

CREATE TABLE warehouse_audit
(
    warehouse_change_id NUMERIC IDENTITY(1,1) PRIMARY KEY,
    warehouse_id NUMERIC,
    warehouse_address VARCHAR(256),
    warehouse_city VARCHAR(64),
    warehouse_state VARCHAR(64),
    warehouse_phone VARCHAR(32),
    update_time DATETIME,
    operation VARCHAR(3),
);

go
CREATE OR ALTER TRIGGER trg_warehouse_audit
ON warehouse
AFTER INSERT, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO warehouse_audit
    (
        warehouse_id,
        warehouse_address,
        warehouse_city,
        warehouse_state,
        warehouse_phone,
        update_time,
        operation
    )
    SELECT
        i.warehouse_id,
        i.warehouse_address,
        i.warehouse_city,
        i.warehouse_state,
        i.warehouse_phone,
        GETDATE(),
        'INS'
    FROM
        inserted i
    UNION ALL
    SELECT
        d.warehouse_id,
        d.warehouse_address,
        d.warehouse_city,
        d.warehouse_state,
        d.warehouse_phone,
        GETDATE(),
        'DEL'
    FROM
        deleted d;
END;
go

CREATE TABLE office
(
    office_id NUMERIC,
    office_address VARCHAR(256),
    office_city VARCHAR(64),
    office_state VARCHAR(64),
    office_phone VARCHAR(32),
    office_department VARCHAR(64),
    PRIMARY KEY (office_id)
);

INSERT INTO office VALUES (01, '1234 Northwest Road', 'Chicago', 'Illinois', '312-555-1384', 'Midwest Regional OFfice');

CREATE TABLE store
(
    store_id NUMERIC,
    store_address VARCHAR(256),
    store_city VARCHAR(64),
    store_state VARCHAR(64),
    store_phone VARCHAR(32),
    PRIMARY KEY (store_id)
);

INSERT INTO store VALUES (01, '1234 West Street', 'Brownsburg', 'Indiana', '317-555-1234');
INSERT INTO store VALUES (02, '5678 East Road', 'Indianapolis', 'Indiana', '317-555-5678');
INSERT INTO store VALUES (03, '555 North Boulevard', 'Carmel', 'Indiana', '317-555-9876');

CREATE TABLE product
(
    product_id NUMERIC,
    product_name VARCHAR(256),
    product_brand VARCHAR(256),
    product_price DECIMAL,
    PRIMARY KEY (product_id)
);

INSERT INTO product VALUES (01, 'SR2600', 'Ibanez', 1599.99);
INSERT INTO product VALUES (02, 'SE Custom 24', 'PRS', 899.00);
INSERT INTO product VALUES (03, 'Les Paul Classic', 'Gibson', 1999.00);
INSERT INTO product VALUES (04, 'S1070PBZ', 'Ibanez', 1399.99);
INSERT INTO product VALUES (05, 'Katana-100 MkII', 'Boss', 369.99);
INSERT INTO product VALUES (06, 'Boogie Mark Five', 'Mesa', 1599.00);
INSERT INTO product VALUES (07, 'GSR200SMCNB', 'Ibanez', 249.99);
INSERT INTO product VALUES (08, 'Scarlett 2i2', 'Focusrite', 169.99);
INSERT INTO product VALUES (09, 'AT2020', 'Audio-Technica', 99.00);
INSERT INTO product VALUES (10, 'TS9 Tube Screamer', 'Ibanez', 99.99);

CREATE TABLE customer
(
    customer_id NUMERIC,
    customer_fname VARCHAR(32),
    customer_lname VARCHAR(32),
    customer_address VARCHAR(256),
    customer_city VARCHAR(64),
    customer_state VARCHAR(64),
    customer_email VARCHAR(64),
    customer_phone VARCHAR(32),
    PRIMARY KEY (customer_id)
);

INSERT INTO customer VALUES (01, 'Eric', 'Sanders', '1234 New Street', 'Brownsburg', 'Indiana', 'esanders@gmail.com', '317-555-5615');
INSERT INTO customer VALUES (02, 'Ashley', 'Sanders', '4538 Old Road', 'Avon', 'Indiana', 'asanders@yahoo.com', '317-555-4891');
INSERT INTO customer VALUES (03, 'Morgan', 'West', '8455 West Parkway', 'Carmel', 'Indiana', 'mwest@gmail.com', '317-555-4558');
INSERT INTO customer VALUES (04, 'Christian', 'Smith', '8438 Green Drive', 'Fishers', 'Indiana', 'csmith@gmail.com', '317-555-4448');
INSERT INTO customer VALUES (05, 'Robert', 'Green', '1838 Book Lane', 'Indianapolis', 'Indiana', 'rgreen@yahoo.com', '317-555-8217');

CREATE TABLE employee
(
    emp_id NUMERIC,
    emp_fname VARCHAR(32),
    emp_lname VARCHAR(32),
    emp_DOB DATE,
    emp_hire_date DATE,
    emp_job_title VARCHAR(32),
    warehouse_id NUMERIC NULL,
    office_id NUMERIC NULL,
    store_id NUMERIC NULL,
    PRIMARY KEY (emp_id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouse(warehouse_id),
    FOREIGN KEY (office_id) REFERENCES office(office_id),
    FOREIGN KEY (store_id) REFERENCES store(store_id)
);

INSERT INTO employee VALUES (01, 'John', 'Martin', '04/18/1960', '05/21/2000', 'Regional Manager', NULL, '01', NULL);
INSERT INTO employee VALUES (07, 'Sarah', 'Ericson', '03/11/1983', '03/30/2001', 'Store Manager', NULL, NULL, '02');

CREATE TABLE truck
(
    truck_id NUMERIC,
    truck_vin VARCHAR(32),
    truck_plate VARCHAR(32),
    truck_make VARCHAR(32),
    truck_model VARCHAR(32),
    truck_year VARCHAR(32),
    warehouse_id NUMERIC,
    PRIMARY KEY (truck_id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouse(warehouse_id)
);

INSERT INTO truck VALUES (01, 'ADCKN54325DBVDE', 'ABC123', 'Peterbuilt', '385', '1996', 875589);
INSERT INTO truck VALUES (02, 'DKNEIDNDF53258O', 'DEF456', 'Kenworth', 'W900B', '1983', 875592);
INSERT INTO truck VALUES (03, 'IDNVIER754699DV', 'UHF843', 'Volvo', 'WG42T', '1990', 875611);
INSERT INTO truck VALUES (04, 'QJSNVOEL4531896', 'DCE556', 'Peterbuilt', '362', '1985', 875595);

CREATE TABLE warehouse_route
(
    route_id NUMERIC,
    warehouse_id NUMERIC,
    store_id  NUMERIC,
    PRIMARY KEY (route_id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouse(warehouse_id),
    FOREIGN KEY (store_id) REFERENCES store(store_id)
);

CREATE TABLE transaction_invoice
(
    store_id NUMERIC,
    customer_id NUMERIC,
    product_id NUMERIC,
    date_time DATE,
    quantity NUMERIC,
    PRIMARY KEY (store_id, customer_id, product_id, date_time),
    FOREIGN KEY (store_id) REFERENCES store(store_id),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (product_id) REFERENCES product(product_id)
);

INSERT INTO transaction_invoice VALUES (01, 01, 09, '05/16/19', 3);
INSERT INTO transaction_invoice VALUES (01, 02, 08, '04/08/19', 2);
INSERT INTO transaction_invoice VALUES (02, 03, 01, '03/14/18', 1);
INSERT INTO transaction_invoice VALUES (02, 04, 05, '10/15/17', 1);
INSERT INTO transaction_invoice VALUES (03, 05, 10, '11/25/20', 5);

CREATE TABLE store_inventory
(
    store_id NUMERIC,
    product_id NUMERIC,
    store_QOH NUMERIC,
    PRIMARY KEY (store_id, product_id),
    FOREIGN KEY (store_id) REFERENCES store(store_id),
    FOREIGN KEY (product_id) REFERENCES product(product_id)
);

CREATE TABLE warehouse_inventory
(
    warehouse_id NUMERIC,
    product_id NUMERIC,
    warehouse_QOH NUMERIC,
    PRIMARY KEY (warehouse_id, product_id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouse(warehouse_id),
    FOREIGN KEY (product_id) REFERENCES product(product_id)
);

INSERT INTO warehouse_inventory VALUES (875695, 08, 147);
INSERT INTO warehouse_inventory VALUES (875696, 08, 221);
INSERT INTO warehouse_inventory VALUES (875697, 08, 500);

INSERT INTO warehouse_inventory VALUES (875695, 01, 227);
INSERT INTO warehouse_inventory VALUES (875696, 01, 189);
INSERT INTO warehouse_inventory VALUES (875697, 01, 463);

go
CREATE OR ALTER PROCEDURE populateWarehouse (@amount INT = 1)
AS
BEGIN
SET NOCOUNT ON

    DECLARE @i INT = 0

    WHILE @i < @amount
    BEGIN
        INSERT INTO warehouse VALUES
        (
            SUBSTRING(CONVERT(VARCHAR(64), NEWID()), 1, 16),
            SUBSTRING(CONVERT(VARCHAR(64), NEWID()), 1, 16),
            SUBSTRING(CONVERT(VARCHAR(64), NEWID()), 1, 16),
            SUBSTRING(CONVERT(VARCHAR(64), NEWID()), 1, 16)
        );

        SET @i = @i +1;
    END;
END;
go

EXEC populateWarehouse 100;


SELECT * FROM store WHERE store_state = 'Indiana';

SELECT * FROM employee
WHERE ABS((DATEDIFF(year, CONVERT(date, GETDATE()), emp_hire_date))) >= 20
ORDER BY emp_hire_date;

SELECT * FROM truck
WHERE truck_make = 'Peterbuilt' AND truck_year < 2000
ORDER BY truck_year;

SELECT COUNT(*) AS Customers_in_Indiana FROM customer
WHERE customer_state = 'Indiana';

SELECT product_id, product_name, product_brand, product_price AS original_price,product_price * .9 AS discounted_price
FROM product
WHERE product_price BETWEEN 1000 and 2000
ORDER BY product_price;

SELECT t.store_id, t.customer_id, t.product_id, t.date_time, t.quantity, SUM(t.quantity * p.product_price) AS invoice_amt
FROM transaction_invoice t
INNER JOIN product p ON p.product_id = t.product_id
GROUP BY t.store_id, t.customer_id, t.product_id, t.date_time, t.quantity
HAVING t.store_id = 01
ORDER BY invoice_amt DESC;

SELECT t.store_id, t.customer_id, t.product_id, t.date_time, t.quantity, c.customer_fname, c.customer_lname
FROM transaction_invoice t
INNER JOIN customer c ON c.customer_id = t.customer_id
ORDER BY t.customer_id;

SELECT * FROM customer
WHERE customer_id IN
(SELECT customer_id FROM transaction_invoice WHERE product_id = 08)
ORDER BY customer_id;

SELECT COALESCE(CONVERT(VARCHAR, warehouse_id), 'all_warehouses') AS warehouse_id, SUM(warehouse_QOH) AS quantity
FROM warehouse_inventory
WHERE product_id = 08
GROUP BY ROLLUP (warehouse_id);

SELECT COALESCE(CONVERT(VARCHAR, warehouse_id), 'all_warehouses') AS warehouse_id,
COALESCE(CONVERT(VARCHAR, product_id), 'all_products') as product_id, 
SUM(warehouse_QOH) AS quantity
FROM warehouse_inventory
WHERE product_id = 08 OR product_id = 01
GROUP BY CUBE (warehouse_id, product_id)
ORDER BY warehouse_id, product_id;