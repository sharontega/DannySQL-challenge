---------------
#----CASE STUDY #1: DANNY'S DINER--
------------------
#Author:sharon omovie
#tool used: mysql workbench
----------------------

#A.Customer Nodes Exploration

#1. How many unique nodes are there on the Data Bank system?
select count( distinct node_id) unique_node
from customer_nodes;

#2. What is the number of nodes per region?
select region_id,count(node_id)
from customer_nodes
group by region_id
order by region_id;

#3. How many customers are allocated to each region?
select region_id,count(distinct customer_id) customer_count
from customer_nodes
group by region_id
order by region_id;

#4. How many days on average are customers reallocated to a different node?
select avg(datediff(end_date,start_date))
from customer_nodes
where year(end_date)<= 2020;

#B. Customer Transactions 

#1. What is the unique count and total amount for each transaction type?
select count(txn_type) unique_count, sum(txn_amount),txn_type total_amount
from customer_transactions
group by txn_type;

#2. What is the average total historical deposit counts and amounts for all customers?#
with s as(
select customer_id,sum(txn_amount) amount, count(txn_type) con
from customer_transactions
where txn_type= 'deposit'
group by customer_id
)
select round(avg(amount)) average_amount, round(avg(con)) average_count, customer_id
from s
group by customer_id;

#3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
with s as(select customer_id, sum(if(txn_type='deposit',1,0)) deposite,
sum(if(txn_type='purchase',1,0)) purchase, sum(if(txn_type='withdrawal',1,0)) withdrawal,month(txn_date) mont
from customer_transactions
group by customer_id,mont)
select count(distinct customer_id), mont
from s
WHERE deposite>1
  AND (purchase = 1
       OR withdrawal = 1)
group by mont;

#4. What is the closing balance for each customer at the end of the month?
with a as(
select customer_id,txn_amount,txn_type,month(txn_date) month_date,
(case when txn_type='deposit' then txn_amount
else -txn_amount
end)net
from customer_transactions
group by customer_id,month_date)
select customer_id, month_date, net, sum(net) over (partition by customer_id 
ORDER BY month_date ROWS BETWEEN UNBOUNDED preceding AND CURRENT ROW) closing
from a;