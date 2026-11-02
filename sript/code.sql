use Anylises;

--Section : 1. DatabaseExploration


-- List all tables in the database using INFORMATION_SCHEMA.TABLES.
select * from information_schema.tables;

--List all columns of each table with their data types using INFORMATION_SCHEMA.COLUMNS.
select * from information_schema.columns

-- How many rows does each table have?
select count(*) from dbo.dim_customers;
select count(*) from dbo.dim_products;
select count(*) from dbo.fact_sales;

-- Which columns are shared keys between tables (the join columns)
select product_key, customer_key from dbo.fact_sales;
select customer_key from dbo.dim_customers;
select product_key from dbo.dim_products;

-- Are there any NULLs in key columns (product_key, customer_key)?
select product_key, customer_key from dbo.fact_sales where customer_key is null or product_key is null;
select customer_key from dbo.dim_customers where customer_key is null;
select product_key from dbo.dim_products where product_key is null;

-- Are there duplicate keys in the dimension tables?
select customer_key from dbo.dim_customers group by customer_key having count(*)>1 ;
select product_key from dbo.dim_products group by product_key having count(*)>1 ;







--Section : 2. DimensionExploration


-- Which countries do customers come from?
select distinct country from dbo.dim_customers;

-- What are the distinct values of marital_status and gender?
select distinct marital_status from dbo.dim_customers;

-- What are all the distinct categories, subcategories and product lines?
select distinct category from dbo.dim_products;
select distinct subcategory from dbo.dim_products;
select distinct product_line from dbo.dim_products;

-- Show the hierarchy of category, subcategory and product_name.
select distinct category , subcategory , product_name from dbo.dim_products;


--How many distinct products are in each category and subcategory?
select  category , subcategory , count(*) from dbo.dim_products group by category , subcategory;

-- Are there any products or customers with missing or "n/a" values in descriptive columns?
select product_key from dim_products where category is null or category = 'n/a';
select product_key from dim_products where subcategory is null or subcategory = 'n/a';
select product_key from dim_products where product_line is null or product_line = 'n/a';
select customer_key from dim_customers where country is null or country = 'n/a';
select customer_key from dim_customers where gender is null or gender = 'n/a';
select customer_key from dim_customers where birthdate is null;








-- Section : 3. DateExploration


--What are the first and last order_date in fact_sales?
select min(order_date) , max(order_date) from dbo.fact_sales;

-- How many years and months of sales data are available?
select datediff(year,min(order_date) , max(order_date)) from dbo.fact_sales;
select datediff(MONTH,min(order_date) , max(order_date)) from dbo.fact_sales;

-- Who is the youngest and the oldest customer (from birthdate), and what are their ages?
select min(birthdate) , max(birthdate) from dbo.dim_customers;
select datediff(year,min(birthdate),getdate()) , datediff(year,max(birthdate),getdate())  from dbo.dim_customers;

--  What is the earliest and latest customer create_date?
select min(create_date), max(create_date) from dbo.dim_customers;

-- What is the earliest product start_date?
select min(start_date) from dbo.dim_products;

--What is the average number of days between order_date and shipping_date? Between order_date and due_date?
select avg(datediff(day,order_date,shipping_date))from dbo.fact_sales;
select avg(datediff(day,order_date,due_date))from dbo.fact_sales;

-- Are there orders where shipping_date is later than due_date (late shipments)?
select order_number from dbo.fact_sales where shipping_date > due_date;







-- section : 4. MeasureExploration (Big Numbers)


-- Total sales amount.
select sum(sales_amount) from dbo.fact_sales;

-- Total quantity sold.
select sum(quantity) from dbo.fact_sales;

--Average selling price.
select avg(price) from dbo.fact_sales;

-- Total number of orders (distinct order_number).
select count(distinct order_number) from dbo.fact_sales;

-- Total number of products and total number of customers.
select count(*) from dbo.dim_customers;
select count(*) from dbo.dim_products;

-- How many customers actually placed an order?
select count (customer_key) from dbo.dim_customers where customer_key  in  (select distinct customer_key from dbo.fact_sales);

-- Build one report that shows all key metrics in a single result set (using UNION ALL: measure_name, measure_value).
select 'TotalAmount' as measure_name , sum(sales_amount) as measure_value from dbo.fact_sales
union all 
select'TotalQuntity' ,  sum(quantity) from dbo.fact_sales
union all
select 'AvgSellingPrice',avg(price) from dbo.fact_sales
union all
select 'TotalOrders',count(distinct order_number) from dbo.fact_sales
union all
select 'TotalProducts',count(*) from dbo.dim_customers
union all
select 'TotalCustomers' , count(*) from dbo.dim_products
union all
select 'OrderdCustomers',count (customer_key) from dbo.dim_customers where customer_key  in  (select distinct customer_key from dbo.fact_sales);







-- section : 5. Magnitude Analysis


-- Total customers by country.
select country , count(customer_key) from dbo.dim_customers hii  group by country ;

-- Total customers by gender
select gender , count(customer_key) from dbo.dim_customers hii  group by gender ;

-- Total products by category.
select category, count(*) from dbo.dim_products group by category;

-- Average cost per category.
select category , avg(cost) from dbo.dim_products group by category;

-- Total revenue per category.
select p.category , sum(s.sales_amount) from dbo.fact_sales as s left join dbo.dim_products as p on s.product_key = p.product_key group by p.category;

-- Total revenue per customer
select customer_key , sum(sales_amount) from dbo.fact_sales group by customer_key;

-- Distribution of sold items across countries.
select c.country , sum(s.quantity) from dbo.fact_sales as s left join dbo.dim_customers as c on s.customer_key = c.customer_key group by c.country;


-- Average sales amount per order by country.
select c.country , avg(s.sales_amount) from dbo.fact_sales as s left join dbo.dim_customers as c on s.customer_key = c.customer_key group by c.country;







-- section : 6. Ranking Analysis


-- Top 5 products by revenue.
select top (5) p.product_name , sum(s.sales_amount) from dbo.fact_sales as s left join dbo.dim_products as p on s.product_key = p.product_key group by product_name order by  sum(s.sales_amount) desc;

-- Bottom 5 worst-performing products by revenue.
select top (5) p.product_name , sum(s.sales_amount) from dbo.fact_sales as s left join dbo.dim_products as p on s.product_key = p.product_key group by product_name order by  sum(s.sales_amount) asc;

-- Top 5 subcategories by revenue.
select top (5) p.subcategory , sum(s.sales_amount) from dbo.fact_sales as s left join dbo.dim_products as p on s.product_key = p.product_key group by p.subcategory order by  sum(s.sales_amount) desc;

-- Top 10 customers by revenue.
select top (10) customer_key , sum(sales_amount) from dbo.fact_sales group by customer_key order by sum(sales_amount)  desc;

-- 3 customers with the fewest orders.
select top (3) customer_key , count(order_number) from dbo.fact_sales group by customer_key order by count(order_number) asc;

-- Rank products by revenue within each category (RANK, DENSE_RANK,ROW_NUMBER).
select  p.category , sum(s.sales_amount) , dense_rank() over (order by  sum(s.sales_amount) desc) as rank from dbo.fact_sales as s left join dbo.dim_products as p on s.product_key = p.product_key group by p.category;

-- Top 3 products in each category (using window functions, not TOP)
with cte as (select  p.category , p.product_name , sum (s.sales_amount) as  sum , row_number() over (partition by p.category  order by  sum (s.sales_amount) desc ) as rank from dbo.fact_sales as s left join dbo.dim_products as p on s.product_key = p.product_key group by p.category , p.product_name) select * from cte where rank <= 3;

-- Top 1 customer in each country
with cte as (select c.country , c.customer_key , sum (s.sales_amount) as sum, row_number() over(partition by c.country order by sum (s.sales_amount) desc) as rank from dbo.fact_sales as s left join dbo.dim_customers as c on s.customer_key = c.customer_key group by c.country , c.customer_key) select * from cte where rank = 1;







-- section : 7. Change OverTime (Trends)


-- Total sales, customer count and quantity per year.
select datetrunc(year,order_date) , sum (sales_amount) , count (distinct customer_key ) , sum(quantity)from dbo.fact_sales group by datetrunc(year,order_date) order by datetrunc(year,order_date)  asc;

-- Total sales per month (across all years) to see seasonality
select concat(cast(year(order_date)as varchar) ,' ',datename(month,order_date)),sum(sales_amount) from dbo.fact_sales group by year(order_date) , datename(month,order_date) order by year(order_date) ,  datename(month,order_date) asc;

-- Total sales per year-month using DATETRUNC / FORMAT / DATEPART.
select datetrunc(month,order_date) ,sum(sales_amount) from dbo.fact_sales group by datetrunc(month,order_date) order by datetrunc(month,order_date) asc;

-- Number of new customers per month (using create_date).
select datetrunc(month,create_date) ,count(customer_key) from dbo.dim_customers group by datetrunc(month,create_date);

-- Running total of sales over time.
select datetrunc(month,order_date) ,sum(sales_amount) , sum(sum(sales_amount)) over  (order by datetrunc(month,order_date)) from dbo.fact_sales group by datetrunc(month,order_date);

-- Moving average of price over time
select datetrunc(month,order_date), avg (sum(sales_amount)) over  (order by datetrunc(month,order_date) rows between 1 preceding  and 1 following )  from dbo.fact_sales group by datetrunc(month,order_date);

-- Month-over-month growth in sales.
with cte as (select concat(cast(year(order_date)as varchar) ,' ',datename(month,order_date)) as months,sum(sales_amount) as TotalSales from dbo.fact_sales group by year(order_date) , datename(month,order_date) ,  datename(month,order_date) ) select * , lag(TotalSales) over (order by months) as PriviouMonthSales , TotalSales - lag(TotalSales) over (order by months) as SalesDiff  from cte;

-- Which month has the highest sales in each year?
with cte as (select concat(cast(year(order_date) as varchar),'  ', datename(month,order_date)) months , sum(sales_amount) TotalSeles , row_number() over(partition by  year(order_date) order  by sum(sales_amount) desc)as rank from dbo.fact_sales group by year(order_date) , datename(month,order_date)) select * from cte where rank = 1;







-- section : 8. Cumulative Analysis


-- Running total of sales by month
select datetrunc(month,order_date) , sum(sales_amount) , sum(sum(sales_amount))  over(order by datetrunc(month,order_date) )from dbo.fact_sales group by datetrunc(month,order_date);

-- Running total of sales per year, resetting each year
select year(order_date), datename(month,order_date), sum(sales_amount) , sum(sum(sales_amount))  over(partition by year(order_date) order by  year(order_date),datename(month,order_date) )from dbo.fact_sales group by year(order_date),datename(month,order_date);

-- Cumulative average price over time.
select datetrunc(month,order_date), avg (sum(sales_amount)) over  (order by datetrunc(month,order_date) rows between unbounded preceding  and 1 following )  from dbo.fact_sales group by datetrunc(month,order_date);

--  Year-to-date (YTD) sales for each month
select year(order_date), datename(month,order_date), sum(sales_amount) , sum(sum(sales_amount))  over(partition by year(order_date) order by  year(order_date),datename(month,order_date) )from dbo.fact_sales group by year(order_date),datename(month,order_date);

--  Cumulative number of new customers over time
select datetrunc(month,create_date) ,count(customer_key) from dbo.dim_customers group by datetrunc(month,create_date);







-- section : 9. Performance Analysis


-- Yearly sales for each product compared to that product's average sales.
select datetrunc(month,order_date) , product_key , sum (sales_amount) , avg (sales_amount) , sum(sales_amount) - avg(sales_amount) from dbo.fact_sales group by datetrunc(month,order_date) , product_key order by  1,2;

-- Yearly sales for each product compared to the previous year (LAG), with the difference and a flag: Increase / Decrease / No Change.
with cte as (select product_key  ,  datetrunc(month,order_date) as months, sum(sales_amount) as TotalSales from dbo.fact_sales group by product_key ,  datetrunc(month,order_date) ) select * , lag(TotalSales) over (partition by  product_key order by months) , TotalSales -  lag(TotalSales) over (partition by  product_key order by months) ,case  when TotalSales -  lag(TotalSales) over (partition by  product_key order by months) < 0 then 'decress' when TotalSales -  lag(TotalSales) over (partition by  product_key order by months) > 0 then 'incress' else 'nochange'end from cte order by 1,2;

-- Month-over-month change in total sales.
select datetrunc(month,order_date) , sum(sales_amount) , lag(sum(sales_amount)) over (order by datetrunc(month,order_date) ) ,  sum(sales_amount) - lag(sum(sales_amount)) over (order by datetrunc(month,order_date) ) from dbo.fact_sales group by datetrunc(month,order_date);

-- Percentage change year-over-year per category.
select p.category , datetrunc(year,s.order_date), sum (s.sales_amount) , round(((cast(sum (s.sales_amount) as float) - lag( sum (s.sales_amount)) over (partition by p.category order by datetrunc(year,s.order_date))) /lag( sum (s.sales_amount)) over (partition by p.category order by datetrunc(year,s.order_date))) * 100,2) from dbo.fact_sales as s left join dbo.dim_products as p on s.product_key = p.product_key group by p.category , datetrunc(year,s.order_date) order by 1,2;

-- Which products are consistently growing year after year?
select * from (select * , lag(t.years) over (partition by product_key order by t.years) as pyx from (select product_key , datetrunc(year,order_date) as years , sum (sales_amount) TotalSales, lag(sum(sales_amount)) over (partition by product_key order by datetrunc(year,order_date)) as py, case when sum (sales_amount) - lag(sum(sales_amount)) over (partition by product_key order by datetrunc(year,order_date)) < 0 then 'decress' when  sum (sales_amount) - lag(sum(sales_amount)) over (partition by product_key order by datetrunc(year,order_date)) >  0 then 'incress' else 'nochange'end casee from dbo.fact_sales group by product_key , datetrunc(year,order_date) )t where t.casee = 'incress'  )x where x.pyx is not null and datediff(year,x.pyx,x.years) = 1order by  1,2 ;

-- Compare each customer's yearly spending vs their own average
select *  , avg (t.TotalSales) over (partition by t.customer_key) , t.TotalSales - avg (t.TotalSales) over (partition by t.customer_key) from (select customer_key , datetrunc(year,order_date) as months ,sum(sales_amount) TotalSales from dbo.fact_sales group by customer_key , datetrunc(year,order_date) )t order by 1,2;

-- Compare each product's sales to the best-selling product (FIRST_VALUE or MAXOVER).
select t.product_key, t.TotalSales, max(t.TotalSales) over() , t.TotalSales-   max(t.TotalSales) over()from (select product_key , sum(sales_amount) as TotalSales from dbo.fact_sales group by product_key)t order by t.product_key asc, t.TotalSales desc;







-- section : 10. Part-to-Whole Analysis


--
