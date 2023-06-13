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
 ORDER BY income DESC NULLS LAST
 LIMIT 10;

-- Step 5.2. Looking for the sellers with average income that is less then total average income.
-- For that we need to join the table 'employees' with the table 'sales' and the table sales with
-- the table 'products'
select
       concat(e.first_name, ' ', e.last_name) as name,
       -- combining first_name and last_name into one line
       round(avg(s.quantity * p.price), 0) as average_income
       -- looking for the average income for every single seller
  from employees e
  left join sales s
    on e.employee_id = s.sales_person_id
  left join products p
    on s.product_id = p.product_id
 group by concat(e.first_name, ' ', e.last_name)
having round(avg(s.quantity * p.price), 0) < (select
       round(avg(s.quantity * p.price), 0)
       from sales s
       -- comparing the average income of each seller with the total average income
       left join products p
       on s.product_id = p.product_id)
 order by average_income;

-- Step 5.3. Looking for total income for every seller and every day of week. For that we need
-- to join the table 'employees' with the table 'sales' and the table sales with the table 'products'
 select
      concat(e.first_name, ' ', e.last_name) as name,
      -- combine first_name and last_name into one line
      to_char(s.sale_date, 'day') as weekday,
      -- finding out a day of week
      round(sum(s.quantity * p.price), 0) as income
      -- looking for the total income for every seller
 from employees e
 left join sales s
   on e.employee_id = s.sales_person_id
 left join products p
   on s.product_id = p.product_id
group by
      to_char(s.sale_date, 'day'),
      concat(e.first_name, ' ', e.last_name),
      extract(isodow from s.sale_date)
      -- looking for the weekday number where the day of the week as Monday (1) to Sunday (7)
order by
      extract(isodow from s.sale_date),
      name;

/* Step 6.1. Looking for the number of customers of different age groups.*/
SELECT
       CASE
	         WHEN age BETWEEN 16 AND 25 THEN '16-25'
	         WHEN age BETWEEN 26 AND 40 THEN '26-40'
	         WHEN age > 40 THEN '40+'
       END AS age_category,
       -- Dividing customers into age groups
       COUNT(customer_id) AS count
       -- Counting the number of customers in itch group
  FROM customers c
 GROUP BY age_category
 ORDER BY age_category;