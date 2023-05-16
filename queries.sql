select
      count(customer_id) as customers_count
from customers;

select
      concat(e.first_name, ' ', e.last_name) as name,
      count(s.sales_id) as operations,
      sum(s.quantity * p.price) as income
 from employees e
 left join sales s
   on e.employee_id = s.sales_person_id
 left join products p
   on s.product_id = p.product_id
group by concat(e.first_name, ' ', e.last_name)
order by income desc nulls last
limit 10;

select
       concat(e.first_name, ' ', e.last_name) as name,
       round(avg(s.quantity * p.price), 0) as average_income
  from employees e
  left join sales s
    on e.employee_id = s.sales_person_id
  left join products p
    on s.product_id = p.product_id
 group by concat(e.first_name, ' ', e.last_name)
having round(avg(s.quantity * p.price), 0) < (select
       round(avg(s.quantity * p.price), 0)
       from sales s
       left join products p
       on s.product_id = p.product_id)
 order by average_income;
 
select
      concat(e.first_name, ' ', e.last_name) as name,
      to_char(s.sale_date, 'day') as weekday,
      round(sum(s.quantity * p.price), 0) as income
 from employees e
 left join sales s
   on e.employee_id = s.sales_person_id
 left join products p
   on s.product_id = p.product_id
group by
      to_char(s.sale_date, 'day'),
      concat(e.first_name, ' ', e.last_name),
      extract(isodow from s.sale_date)
order by
      extract(isodow from s.sale_date),
      name;
