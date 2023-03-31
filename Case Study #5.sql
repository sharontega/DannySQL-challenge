---------------
#----CASE STUDY #1: DANNY'S DINER--
------------------
#Author:sharon omovie
#tool used: mysql workbench
----------------------

#A. Data Cleansing Steps

alter table weekly_sales
modify column week_date date;

alter table weekly_sales
add week_number int;

update weekly_sales
set week_number =extract(week from week_date);
    
alter table weekly_sales
add month_number int;

update weekly_sales
set month_number=month(week_date);

alter table weekly_sales
add calender_year int;

update weekly_sales
set calender_year=year(week_date);

alter table weekly_sales
add age_band varchar(25);

update weekly_sales
set age_band=(case
when right(segment,1)= 1 then "young Adult"
when right(segment,1)=2 then "Middle Aged"
when right (segment,1) in (3,4) then "Retirees"
else "unknown"
end );


alter table weekly_sales
add demographis varchar(25);

update weekly_sales
set demographis = (case
when left(segment,1)="c" then "couples"
when left(segment,1)="f" then "families"
else "unkown"
end);


alter table weekly_sales
add avg_transaction int;

update weekly_sales
set avg_transaction=round(sales/transactions,2);

#B. Data Exploration

#1. What day of the week is used for each week_date value?
select distinct dayname(week_date)
from weekly_sales;

#2. What range of week numbers are missing from the dataset?
select distinct week_number
from weekly_sales
order by week_number;

#3. How many total transactions were there for each year in the dataset?
select year(week_date)year_date,sum(transactions) sum
from weekly_sales
group by year(week_date)
order by 1 desc;

#4. What is the total sales for each region for each month?
select region,monthname(week_date),sum(sales)
from weekly_sales
group by region,monthname(week_date)
order by 1,2;

#5. What is the total count of transactions for each platform
select platform,count(transactions) count
from weekly_sales
group by 1;

#6. What is the percentage of sales for Retail vs Shopify for each month?
select count(platform) count,age_band,demographis
from weekly_sales
where platform="retail"
group by 2,3
order by 1 desc;

#7. What is the percentage of sales by demographic for each year in the dataset?
select round(sum(sales)/sum(transactions),2) as av_trac,calender_year,platform
from weekly_sales
group by 3,2;
