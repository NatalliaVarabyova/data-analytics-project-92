-- Step 4. Counting the total number of customers using the aggregate function 'count'
select
      count(customer_id) as customers_count
from customers;

-- Step 5.1. Looking for the top 10 sellers. For that we need to join the table 'employees'
-- with the table 'sales' and the table sales with the table 'products'
select
      concat(e.first_name, ' ', e.last_name) as name,
      -- combining first_name and last_name into one line
      count(s.sales_id) as operations,
      -- counting how many operations were done
      sum(s.quantity * p.price) as income
      -- looking for the total income for all of the operations for every single seller
 from employees e
 left join sales s
   on e.employee_id = s.sales_person_id
 left join products p
   on s.product_id = p.product_id
group by concat(e.first_name, ' ', e.last_name)
order by income desc nulls last
limit 10;

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
