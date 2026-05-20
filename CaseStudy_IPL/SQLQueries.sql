
--Q1 Find total spending on players for each team
SELECT Team,SUM(Price_in_cr) AS Total_Spending
FROM  IPLPlayers 
GROUP BY Team
ORDER BY Total_Spending DESC

--Q2 find top 3 highest paid(all_rounders) across all teams

SELECT top 3 Player ,Team,Price_in_cr
FROM IPLPlayers
WHERE Role ='All-rounder'
ORDER BY Price_in_cr DESC
  

--Q3 Find the highest player in each team
SELECT Team,Player,Price_in_cr
FROM (SELECT   Player,Price_in_cr,Team , DENSE_RANK()OVER(PARTITION BY Team ORDER BY Price_in_cr DESC) AS Rate
FROM IPLPlayers) AS Y
WHERE Rate=1
ORDER BY Price_in_cr DESC


--Q4 Rank players by their  price within each team and list the top 2 for every team

SELECT Team,Player,Price_in_cr, Rate
FROM (SELECT   Player,Price_in_cr,Team , DENSE_RANK()OVER(PARTITION BY Team ORDER BY Price_in_cr DESC) AS Rate
FROM IPLPlayers) AS Y
WHERE Rate <=2
ORDER BY Team,Price_in_cr DESC

--Q5 find the most expensive player for each team along with the secound for each team 

WITH TAB AS (SELECT Team,Player,Price_in_cr, Rate
FROM (SELECT   Player,Price_in_cr,Team , ROW_NUMBER()OVER(PARTITION BY Team ORDER BY Price_in_cr DESC) AS Rate
FROM IPLPlayers) AS Y
WHERE Rate <=2)
SELECT Team ,MIN(CASE WHEN Rate=1 then Player end )as player_1 ,MIN(CASE WHEN Rate=1 then Price_in_cr end ) price_1,
			MAX(CASE WHEN Rate=2 then Player end )AS player_2, MAX(CASE WHEN Rate=2 then Price_in_cr end) as price_2
FROM TAB
GROUP BY Team






--Q6 calculate the % contribution of each player's to their team's total spending
WITH TAB2 AS (SELECT Player,Price_in_cr,Team, SUM(Price_in_cr)OVER(PARTITION BY Team) AS total_spending
FROM IPLPlayers)
SELECT *,CAST((100.0*Price_in_cr/total_spending)AS decimal(10,2))
FROM TAB2





--27 Classify players as 'High', 'Medium', or 'Low' priced based on the following rules:
-- High: Price › R15 crore
--Medium: Price between 75 crore and R15 crore
-- Low: Price < R5 crore
--and find out the number of players in each bracket


WITH class AS ( SELECT Team,Price_in_cr, CASE WHEN Price_in_cr > 15  THEN 'high'
	   WHEN Price_in_cr BETWEEN 5 AND 15 THEN 'medium' 
	   WHEN Price_in_cr<5 THEN 'Low' end as  rating	   
FROM IPLPlayers) 
SELECT Team,rating,count(*) as total_num
FROM class
GROUP BY Team,rating
ORDER BY Team,total_num DESC



--Q8 Find the average price of Indian players and compare it with overseas players using a subquery:

WITH Indian AS (SELECT  avg(Price_in_cr) avg_ind
FROM IPLPlayers
WHERE Type LIKE 'Indian%'
),
Overseas AS(SELECT  avg(Price_in_cr)avg_overseas
FROM IPLPlayers
WHERE Type LIKE 'Overseas%')
SELECT *
FROM Indian,Overseas



--09 Identify players who earn more than the average price in their team:

WITH idt AS (SELECT  Player,Price_in_cr,Team ,AVG(Price_in_cr)OVER(PARTITION BY Team) AS avg_ind
FROM IPLPlayers)
SELECT Team,Player,Price_in_cr
FROM idt
WHERE Price_in_cr>avg_ind

--Q10 For each role, find the most expensive player and their price using a correlated subquery


SELECT *
FROM(SELECT Player,Role,Price_in_cr,MAX(Price_in_cr)OVER(PARTITION BY Role ) highest_rate
FROM IPLPlayers) AS T
WHERE Price_in_cr=highest_rate