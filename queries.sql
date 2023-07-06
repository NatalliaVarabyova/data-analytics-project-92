/* Step 4. Counting the total number of customers using the aggregate function 'count' */
SELECT
    COUNT(customer_id) AS customers_count
FROM customers;

/* Step 5.1. Looking for the top 10 sellers. For that we need to join the table 'employees'  with
the table 'sales' and the table sales with the table 'products' */
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS name,
    -- combining first_name and last_name into one line
    COUNT(s.sales_id) AS operations,
    -- counting how many operations were done
    SUM(s.quantity * p.price) AS income
    -- looking for the total income for all of the operations for every single seller
FROM employees e
LEFT JOIN sales s
    ON e.employee_id = s.sales_person_id
LEFT JOIN products p
    ON s.product_id = p.product_id
GROUP BY CONCAT(e.first_name, ' ', e.last_name)
ORDER BY SUM(s.quantity * p.price) DESC NULLS LAST
LIMIT 10;

/* Step 5.2. Looking for the sellers with average income that is less then total average income.
For that we need to join the table 'employees' with the table 'sales' and the table sales with
the table 'products'*/
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS name,
    -- combining first_name and last_name into one line
    ROUND(AVG(s.quantity * p.price), 0) AS average_income
    -- looking for the average income for every single seller
FROM employees e
LEFT JOIN sales s
    ON e.employee_id = s.sales_person_id
LEFT JOIN products p
    ON s.product_id = p.product_id
GROUP BY CONCAT(e.first_name, ' ', e.last_name)
HAVING ROUND(AVG(s.quantity * p.price), 0) <
    (
     SELECT
        ROUND(AVG(s.quantity * p.price), 0)
    FROM sales s
    -- comparing the average income of each seller with the total average income
    LEFT JOIN products p
        ON s.product_id = p.product_id
     )
ORDER BY average_income;

/* Step 5.3. Looking for total income for every seller and every day of week. For that we need
to join the table 'employees' with the table 'sales' and the table sales with the table 'products' */
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS name,
    -- combine first_name and last_name into one line
    TO_CHAR(s.sale_date, 'day') AS weekday,
    -- finding out a day of week
    ROUND(SUM(s.quantity * p.price), 0) AS income
    -- looking for the total income for every seller
FROM employees e
LEFT JOIN sales s
    ON e.employee_id = s.sales_person_id
LEFT JOIN products p
    ON s.product_id = p.product_id
GROUP BY
    TO_CHAR(sale_date, 'ID'),
    -- finding out the weekday number where the day of the week as Monday (1) to Sunday (7)
    TO_CHAR(s.sale_date, 'day'),
    CONCAT(e.first_name, ' ', e.last_name)
HAVING ROUND(SUM(s.quantity * p.price), 0) IS NOT NULL
ORDER BY
    TO_CHAR(sale_date, 'ID'),
    name;

/* Step 6.1. Looking for the number of customers of different age groups.*/
SELECT
    CASE
        WHEN age BETWEEN 16 AND 25 THEN '16-25'
	    WHEN age BETWEEN 26 AND 40 THEN '26-40'
	    WHEN age > 40 THEN '40+'
	    ELSE '0-16'
    END AS age_category,
    -- Dividing customers into age groups
    COUNT(customer_id) AS count
    -- Counting the number of customers in itch group
FROM customers c
GROUP BY age_category
ORDER BY age_category;
 
/* Step 6.2. Looking for the income from customers and their number per month.*/
SELECT
    TO_CHAR(s.sale_date, 'YYYY-MM') AS date,
    -- finding out a month of year
    COUNT(distinct c.customer_id) AS total_customers,
    -- counting the number of unique customers
    SUM(s.quantity * p.price) AS income
    -- looking for the total income from all customer per month
FROM customers AS c
    LEFT JOIN sales AS s
        ON c.customer_id = s.customer_id
    INNER JOIN products AS p
        ON p.product_id = s.product_id
GROUP BY TO_CHAR(s.sale_date, 'YYYY-MM')
ORDER BY TO_CHAR(s.sale_date, 'YYYY-MM');

/* Step 6.3. Looking foк the first customer's purchase with discont*/
WITH tab AS (
    SELECT
        CONCAT(c.first_name, ' ', c.last_name) AS customer,
        s.sale_date,
        CONCAT(e.first_name, ' ', e.last_name) AS seller,
        ROW_NUMBER() OVER (PARTITION BY CONCAT(c.first_name, ' ', c.last_name) ORDER BY sale_date) AS rn
    FROM customers AS c
    LEFT JOIN sales s
        ON c.customer_id = s.customer_id
    INNER JOIN products p 
        ON p.product_id = s.product_id
    INNER JOIN employees e
        ON e.employee_id = s.sales_person_id
    WHERE price = 0
    ORDER BY c.customer_id, s.sale_date
)

SELECT
    customer,
    sale_date,
    seller
FROM tab
WHERE rn = 1;
-- choosing the first customer's purchese with discount price