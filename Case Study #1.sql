---------------
#----CASE STUDY #1: DANNY'S DINER--
------------------
#Author:sharon omovie
#tool used: mysql workbench
----------------------

#1. what is the total ammount each customer spent at the restuarant? 
select s.customer_id, sum(m.price)
from sales s
join menu m
on s.product_id=m.product_id
group by s.customer_id;

#2.how many days has each customer visited the restuarant
select customer_id,count(distinct order_date)
from sales
group by customer_id;

#3. what was the first item from the menu purchased by each customer
select s.customer_id,m.product_name
from sales s
join menu m
on s.product_id=m.product_id
group by customer_id;

#4. what is the most purchased item on the menu and how many times it was purchased
select  m.product_name,count(m.product_id) order_count
from sales s
join menu m
on s.product_id=m.product_id
group by s.product_id
order by  count(s.product_id) desc
limit 1;

#5.which item was the most popular for each customer
with tmp as
(
 select customer_id, s.product_id,count(s.product_id) as count,m.product_name
 from sales s
 join menu m
on s.product_id=m.product_id
 group by customer_id,product_id
 )
 select customer_id, count,product_name
 from tmp
 order by count desc,customer_id desc
 limit 5;
 
 
 

#6. which item was purchased first after they became a memeber
select s.customer_id,s.order_date,m.join_date,product_name
from sales s
join members m
on s.customer_id=m.customer_id
join menu mm
on s.product_id=mm.product_id
where s.order_date>=m.join_date
group by s.customer_id;


select s.customer_id,s.order_date,m.join_date,s.product_id,mm.product_name
from sales s
join members m
on s.customer_id=m.customer_id
join menu mm
on s.product_id=mm.product_id
where s.order_date<m.join_date
order by customer_id;

#8. what is the total items and amount spent fo each customer before becoming a member
select s.customer_id,count(s.product_id),sum(mm.price)
from sales s
join members m
on s.customer_id=m.customer_id
join menu mm
on s.product_id=mm.product_id
where s.order_date<m.join_date
group by s.customer_id;


#9. if each spent $1 equates 10 points ans sushi has a 2x point multiplier. hpow many points each customer have
with te as
(
select s.customer_id,m.price,m.product_name,
case
when m.product_id=1
 then price *20
 else price *10
 end as points
from sales s
join menu m
on s.product_id=m.product_id
)
select customer_id,product_name,sum(points) points
from te
group by customer_id;






/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
-- 2. How many days has each customer visited the restaurant?
-- 3. What was the first item from the menu purchased by each customer?
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- 5. Which item was the most popular for each customer?
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
 
