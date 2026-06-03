--Q1 1. List the top 10 customers by total sales amount. Show CustomerID, full name, and total sales.

SELECT  distinct top 10 c.ID as cust_id,CONCAT(FirstName,LastName) as  names,sum(Price)over(partition by c.ID ) as total_sales
FROM Customer c
join Sales s
on s.CustomerID = c.ID
order by total_sales desc

--Q2. Show total sales per month for the year 2023, ordered by month.

select MONTH(OrderDate) as month_name , sum(Price) as total_sales
from Sales
where YEAR(OrderDate)=2023
group by MONTH(OrderDate)
order by MONTH(OrderDate)  asc


--Q3. Find out the products that have never been sold

select p.ProductID,ProductName 
from Products p
left join Sales s
on p.ProductID = s.ProductID
where  Quantity is null


--Q4. Find how many new customers were acquired in 2022

select  count( distinct( cust_id))
from (select c.id as cust_id,OrderDate , rank()over(partition by c.id order by c.id ,OrderDate)rnk
from Customer c
join Sales s
on c.ID =s.CustomerID) tab
where rnk =1 and YEAR(OrderDate)=2022


--Q5. Calculate the profit margin (Profit / Sales) percentage for each category..

select Category,cast(100.0*total_Profit/total_sales as decimal(10,2)) as profit_margin
from(select distinct Category, sum(s.Price)over(partition by Category)total_sales,sum(Profit)over(partition by Category)total_Profit
from Products p
join Sales s
on s.ProductID= p.ProductID) tab


--Q6. For each category, show date-wise sales and a running total of sales over time.

select distinct Category ,OrderDate,sum(s.Price)over(partition by Category order by OrderDate) total_sales
from Products p
join Sales s
on s.ProductID= p.ProductID
order by Category,OrderDate asc

--07 •Get the most recent order (by OrderDate) for every customer.

select distinct  c.ID cust_id ,max(OrderDate)over(partition by c.ID )
from Customer c
join Sales s
on c.ID = s.CustomerID
order by c.ID asc

--Group by group


select distinct  c.ID cust_id ,max(OrderDate)
from Customer c
join Sales s
on c.ID = s.CustomerID
group by c.ID
order by c.ID asc

--Q8. Classify customers based on their total sale. Show CustomerID, name, total sales:
--Platinum - TotalSales ≥ 15,000
--Gold - 10,000 to < 15,000
--Silver - 5,000 to < 10,000
--Bronze - < 5,000

select * , case when rate > 15000 then 'Platinum' 
                when  rate between 10000 and 15000 then 'Gold'
                when  rate between 5000  and 10000  then 'Silver' else 'Bronze'end as 'Classify'
from(select distinct c.id as cust_id ,CONCAT(FirstName,' ',LastName) as cust_name ,sum(Price)over(partition by  c.id) rate
from Customer c
join Sales s
on c.ID = s.CustomerID) tab

--Q9. For each category, find the product with the highest total sales. If ties exist, show all tied products..

select *
from (select  * , dense_rank()over(partition by category order by total desc ) rn
from (select  distinct category,productName,sum(s.price)over(partition by productName) total
from Products p
join Sales s
on p.ProductID = s.ProductID  )tab)tab2
where  rn =1

--Q10. Actúal vs Target sales by category & year

with tab as (select category ,targetSales,left(year,4) as yeaar
from targetSales
unpivot ( targetSales for year in ( [2020_Sales],
                    [2021_Sales]  ,
                    [2022_Sales],
                    [2023_Sales] ) )fian)
select distinct t.category,yeaar,targetSales,sum(s.price)over(partition by t.category,year(s.orderDate)  ) Actúal_sales
from tab t
join Products p
on t.Category = p.Category
join Sales s
on t.yeaar = year(s.orderDate) and p.ProductID =s.ProductID
order by category,yeaar
