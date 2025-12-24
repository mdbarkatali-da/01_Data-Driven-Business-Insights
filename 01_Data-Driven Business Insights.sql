use myntra

select * from dbo.sales_data


-- 1. Calculate the total revenue (after applying 15 Percent discount) grouped by each product.

alter table sales_data add discount int

update  sales_data
set discount=15


select
	s.Item,
	sum(s.Amount) as total_sell_amount,
	sum(s.Amount*s.discount/100) as Discount_Amount,
	sum(s.Amount)-sum(s.Amount*s.discount/100) as total_revenue_after_applying_Discount
from
	sales_data as s
group by
	s.Item



-- 2. Display the SaleDate in the format DD-MM-YYYY.

select 
s.Date_of_Purchase,
FORMAT(s.date_of_purchase,'dd-MM-yyyy') as 'DD-MM-YYYY' 
from
	sales_data as s


-- 3. Find customers whose total spending is above the average customer spend.


select
	distinct s.Customer_Name,
	s.Amount
from
	sales_data as s
where 
	s.Amount>(select avg(sales_data.Amount) from sales_data)
order by s.Amount


-- 4. Calculate the month-over-month sales growth percentage for the year 2015.

with cte as (
select
	format(s.Date_of_Purchase,'yyyy-MM') as month,
	sum(s.Amount) as sales_amount,
	LAG(sum(s.Amount)) over( order by format(s.Date_of_Purchase,'yyyy-MM')) as pre_amount,
	sum(s.Amount)-LAG(sum(s.Amount)) over( order by format(s.Date_of_Purchase,'yyyy-MM')) as sale_growth_decline
from
	sales_data as s
where 
	DATEPART(year,s.date_of_purchase)=2015
group by 
	format(s.Date_of_Purchase,'yyyy-MM')
)
select
	*,
	(cte.sales_amount-cte.pre_amount)/cte.pre_amount*100 as percentag_growth
from
	cte
	

-- 5. Show total sales per category along with the percentage contribution of each category to overall sales.
with cte as(
select
	s.Category,
	sum(s.Amount) as total_amount
from
	sales_data as s
group by
	s.Category
)
select
*,
cte.total_amount*100/SUM(cte.total_amount) over () as percentage_share
from
cte 


--6. List all customers who made at least one purchase in the last 3000 days.

select
	*
from
	sales_data as s
where 
	s.Date_of_Purchase>=DATEADD(day,-3000,getdate()) 


--7. Calculate the number of months each customer has been associated (since their join date).


select
	s.Customer_Name,
	DATEDIFF(MONTH,MIN(s.date_of_purchase),GETDATE()) as month_assc
from
	sales_data as s
group by
	s.Customer_Name
order by month_assc desc


-- 8. For each product category, find the top 3 best-selling products based on total revenue.

with cte as (
select
	s.Category,
	s.Item,
	sum(s.Amount) as total_amount
from
	sales_data as s
group by
	s.Category,
	s.Item
), cte2 as(
select
	*,
	dense_rank() over (partition by cte.category order by cte.total_amount desc) as top_3
from
	cte
)
select
	*
from
	cte2
where
	cte2.top_3<=3


-- 9. List customers who have not made any purchases in the last 6 months.

select
	*
from
	sales_data as s
where
	s.Customer_Name not in 
	(select	distinct sales_data.Customer_Name from sales_data
	where sales_data.Date_of_Purchase>=DATEADD(month,-160,getdate()))

--10. Calculate the average sale per customer per month for the year 2014.

select
	month(s.Date_of_Purchase) as month,
	s.Customer_Name,
	avg(s.Amount) as avg_amount
from
	sales_data as s
where
	year(s.Date_of_Purchase)=2014
group by
	s.Customer_Name,
	month(s.Date_of_Purchase)

--11. For each customer, calculate their percentage contribution to the total company revenue.

with cte as (
select
	s.Customer_Name,
	sum(s.Amount) as revenue
from
	sales_data as s
group by
	s.Customer_Name
)
select
	*,
	cte.revenue*100/SUM(revenue) over() as percenatge_share
from
	cte
order by 
	percenatge_share desc


-- 12. Find the average discount percentage given in each product category.

select
	s.Category,
	s.Item,
	avg(s.discount) as avg_disc
from
	sales_data as s
group by
	s.Category,
	s.Item


--13. Show gross revenue, discount loss, and net revenue per category.

select
	s.Category,
	sum(s.Amount) as gross_revenue,
	sum(s.Amount*s.discount/100) as discount_loss,
	sum(s.Amount)-sum(s.Amount*s.discount/100)  as total_revenue
from
	sales_data as s
group by
	s.Category


--14. Identify the day in the last 1 year that had the highest total sales.

with cte as(
select
	s.Date_of_Purchase,
	sum(s.Amount) as revenue
from
	sales_data as s
where
	s.Date_of_Purchase>=DATEADD(year,-1,getdate())
group by
	s.Date_of_Purchase
)
select
	*
from
	cte
where
	revenue=(select max(cte.revenue) from cte)



-- 15. Calculate the customers who have made more than 5 purchases.


select
	s.Customer_Name,
	count(s.Item) as 'total_purchase'
from
	sales_data as s
group by
	s.Customer_Name
having 
	count(s.Item)>5
order by
	total_purchase desc




-- 16. Calculate the percentage of customers who have made more than 5 purchases.

WITH customer_purchases AS (
    SELECT
        s.Customer_Name,
        COUNT(s.Item) AS total_purchase
    FROM
        sales_data AS s
    GROUP BY
        s.Customer_Name
)
SELECT
    COUNT(CASE WHEN total_purchase > 5 THEN 1 END) * 100.0 / COUNT(*) AS percentage_of_customers_over_5_purchases
FROM
    customer_purchases;
