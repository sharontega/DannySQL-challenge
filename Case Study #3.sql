---------------
#----CASE STUDY #1: DANNY'S DINER--
------------------
#Author:sharon omovie
#tool used: mysql workbench
----------------------

# A.Customer Journey
select s.*,p.*
from subscriptions s
join plans p
on s.plan_id=p.plan_id;


#B. Data Analysis Questions

#1. How many customers has Foodie-Fi ever had?
select count(distinct customer_id)
from subscriptions;

#2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
select  month(start_date) month_date,count(customer_id) count
from subscriptions
where plan_id= 0
group by month(start_date)
order by month_date;

#3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
select s.start_date,p.plan_name,count(p.plan_id)
from subscriptions s
join plans p
on s.plan_id=p.plan_id
where year(start_date)>2020
group by p.plan_id
order by p.plan_name;

#4.What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
select count(customer_id) churned_customer,round(count(customer_id)/(select(count(distinct customer_id))from subscriptions)*100, 1) churned_percent
from subscriptions s
join plans p
on s.plan_id=p.plan_id
where p.plan_name= 'churn';

#5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
WITH next_plan_cte AS
  (SELECT *,
          lead(plan_id, 1) over(PARTITION BY customer_id
                                ORDER BY start_date) AS next_plan
   FROM subscriptions),
     churners AS
  (SELECT *
   FROM next_plan_cte
   WHERE next_plan=4
     AND plan_id=0)
SELECT count(customer_id) AS 'churn after trial count',
       round(100 *count(customer_id)/
               (SELECT count(DISTINCT customer_id) AS 'distinct customers'
                FROM subscriptions), 2) AS 'churn percentage'
FROM churners;

#6. What is the number and percentage of customer plans after their initial free trial?
WITH previous_plan_cte AS
  (SELECT *,
          lag(plan_id, 1) over(PARTITION BY customer_id
                               ORDER BY start_date) AS previous_plan
   FROM subscriptions
   JOIN plans USING (plan_id))
SELECT plan_name,
       count(customer_id) customer_count,
       round(100 *count(DISTINCT customer_id) /
               (SELECT count(DISTINCT customer_id) AS 'distinct customers'
                FROM subscriptions), 2) AS 'customer percentage'
FROM previous_plan_cte
WHERE previous_plan=0
GROUP BY plan_name ;

#7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
WITH latest_plan_cte AS
  (SELECT *,
          row_number() over(PARTITION BY customer_id
                            ORDER BY start_date DESC) AS latest_plan
   FROM subscriptions
   JOIN plans USING (plan_id)
   WHERE start_date <='2020-12-31' )
SELECT plan_id,
       plan_name,
       count(customer_id) AS customer_count,
       round(100*count(customer_id) /
               (SELECT COUNT(DISTINCT customer_id)
                FROM subscriptions), 2) AS percentage_breakdown
FROM latest_plan_cte
WHERE latest_plan = 1
GROUP BY plan_id
ORDER BY plan_id;

#8. How many customers have upgraded to an annual plan in 2020?
select count(distinct customer_id) unique_customer
from subscriptions
where plan_id=3 and year(start_date)=2020;


#9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
WITH trial_plan_cte AS
  (SELECT *,
          first_value(start_date) over(PARTITION BY customer_id
                                       ORDER BY start_date) AS trial_plan_start_date
   FROM subscriptions)
SELECT round(avg(datediff(start_date, trial_plan_start_date)), 2)AS avg_conversion_days
FROM trial_plan_cte
WHERE plan_id =3;


#10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
WITH next_plan_cte AS
  (SELECT *,
          lead(start_date, 1) over(PARTITION BY customer_id
                                   ORDER BY start_date) AS next_plan_start_date,
          lead(plan_id, 1) over(PARTITION BY customer_id
                                ORDER BY start_date) AS next_plan
   FROM subscriptions),
     window_details_cte AS
  (SELECT *,
          datediff(next_plan_start_date, start_date) AS days,
          round(datediff(next_plan_start_date, start_date)/30) AS window_30_days
   FROM next_plan_cte
   WHERE next_plan=3)
SELECT window_30_days,
       count(*) AS customer_count
FROM window_details_cte
GROUP BY window_30_days
ORDER BY window_30_days;


#11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
WITH next_plan_cte AS
  (SELECT *,
          lead(plan_id, 1) over(PARTITION BY customer_id
                                ORDER BY start_date) AS next_plan
   FROM subscriptions)
SELECT count(*) AS downgrade_count
FROM next_plan_cte
WHERE plan_id=2
  AND next_plan=1
  AND year(start_date);