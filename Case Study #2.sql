---------------
#----CASE STUDY #1: DANNY'S DINER--
------------------
#Author:sharon omovie
#tool used: mysql workbench
----------------------
#cleaning customers order table
update customer_orders
set exclusions = null where exclusions='';

update customer_orders
set exclusions = null where exclusions='null';

update customer_orders
set extras = null where extras='';

update customer_orders
set extras = null where extras='null';

#cleaning runner_orders 
update runner_orders
set pickup_time = null where pickup_time='null';

update runner_orders
set distance = null where distance='null';

update runner_orders
set cancellation = null where cancellation='null';

update runner_orders
set cancellation = null where cancellation='';

update runner_orders
set duration = null where duration='null';

alter table runner_orders
modify column pickup_time datetime null;

# A.Pizza Metrics

#1.How many pizzas were ordered?
select count(order_id) as total_order
from customer_orders;

#2. How many unique customer orders were made?
select count(distinct(order_id)) unique_id
from customer_orders;

#3. How many successful orders were delivered by each runner?
select runner_id,count(runner_id) orders_delivered
from runner_orders
where cancellation is null
group by runner_id;

#4. How many of each type of pizza was delivered?
select c.pizza_id,count(c.pizza_id) count
from customer_orders as c
join runner_orders r
on c.order_id=r.order_id
where r.cancellation is null
group by c.pizza_id;

#5. How many Vegetarian and Meatlovers were ordered by each customer?
select c.customer_id, p.pizza_name,count(p.pizza_name)
from customer_orders c
join pizza_names p
on c.pizza_id=p.pizza_id
group by c.customer_id,p.pizza_name;

#6. What was the maximum number of pizzas delivered in a single order?
select order_id,count(order_id) as count
from customer_orders
group by order_id
order by count desc
limit 1;

#7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
select customer_id,
sum(case
when exclusions is null and extras is null then 1
else 0
end) as no_change_pizza,
sum(case
when exclusions is not null or extras is not null then 1
else 0
end) as change_pizza
from customer_orders
group by customer_id;

#8.How many pizzas were delivered that had both exclusions and extras?
select c.customer_id,c.exclusions,c.extras
from customer_orders c
join runner_orders r
on c.order_id=r.order_id
where (c.exclusions and c.extras is not null) and r.cancellation is null;

#9. What was the total volume of pizzas ordered for each hour of the day?
select extract(hour from order_time) hou,count(order_id)
from customer_orders
group by hou;

#10. What was the volume of orders for each day of the week?
select dayname(order_time)dayofweek ,count(order_id)number_of_pizza
from customer_orders
group by dayofweek;

# B. Runner and Customer Experience

#1.1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
select week(registration_date) week_of_registration,count(runner_id) count
from runners
group by week_of_registration;

#2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
select runner_id,round(avg(minute(pickup_time))) average_minute
from runner_orders
WHERE cancellation IS NULL
group by runner_id;

#3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
with c as(
select count(c.order_id) count,timestampdiff(minute, order_time,pickup_time) a
from customer_orders c
join runner_orders r
on c.order_id=r.order_id
where cancellation is null
group by c.order_id) select *from c
group by count;


#4. What was the average distance travelled for each customer?
select c.customer_id,round(avg(r.distance))
from runner_orders r
join customer_orders c
on r.order_id=c.order_id
group by c.customer_id;

#5. What was the difference between the longest and shortest delivery times for all orders?
SELECT MIN(duration) minimum_duration,
       MAX(duration) AS maximum_duration,
       MAX(duration) - MIN(duration) AS maximum_difference
FROM runner_orders;


#6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
select runner_id,order_id,round(distance*60/duration) speed
from runner_orders
where cancellation is null;

#7. What is the successful delivery percentage for each runner?
SELECT runner_id,
       COUNT(pickup_time) AS delivered_orders,
       COUNT(*) AS total_orders,
       ROUND(100 * COUNT(pickup_time) / COUNT(*)) AS delivery_success_percentage
FROM runner_orders
GROUP BY runner_id
ORDER BY runner_id;
