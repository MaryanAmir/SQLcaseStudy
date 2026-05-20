--Q1 Identify matches played between two specific teams (e.g., India and South Africa) in 2024 and their result!

SELECT * ,YEAR(MatchDate) as date_year
FROM T20I
WHERE ( Team1='India' and Team2='South Africa') or ( Team1='South Africa' and Team2='India') 

--Q2 Find the team with the highest number of wins in 2024 and the total matches it won.
SELECT TOP 1 Winner , count(*) AS total_matches 
FROM T20I
GROUP BY Winner
ORDER BY total_matches DESC



--Q3 Rank the teams based on the total number of wins in 2024

SELECT Winner,count(Winner) as total_wins , RANK()OVER(ORDER BY count(Winner) DESC ) AS Rate
FROM T20I
WHERE YEAR(MatchDate)='2024'
GROUP BY Winner


--Q4. Which team had the highest avarage winning margin (in runs), and what was the average margin
 
WITH TAB AS (SELECT Winner,Margin ,CAST(LEFT(Margin, CHARINDEX(' ',Margin ))AS INT) AS IND_RUN
  FROM T20I
  WHERE YEAR(MatchDate)=2024 AND Margin LIKE '%runs')
SELECT   TOP 1 Winner ,AVG(IND_RUN) AS AVG_Margin
FROM TAB 
GROUP BY Winner
ORDER BY AVG_Margin   DESC
 
--Q4. Which team had the highest avarage winning margin (in wickets), and what was the average margin
 
WITH TAB AS (SELECT Winner,Margin ,CAST(LEFT(Margin, CHARINDEX(' ',Margin ))AS INT) AS IND_RUN
  FROM T20I
  WHERE YEAR(MatchDate)=2024 AND Margin LIKE '%wickets')
SELECT   TOP 1 Winner,AVG(IND_RUN) AS AVG_Margin
FROM TAB 
GROUP BY Winner
ORDER BY AVG_Margin   DESC
 


--Q5 List all matches where the winning Margin was greater than the average margin across all matches.

 WITH RSAS AS (SELECT * , CAST(lEFT(Margin, CHARINDEX(' ', Margin)) AS int) AS INT_MARGIN
FROM T20I  )
SELECT Team1,Team2,Winner
FROM RSAS
WHERE  INT_MARGIN >(SELECT avg(INT_MARGIN) FROM RSAS)
 

--Q6 Find the team with the Most wins when chasing a target (wins by wickets)

WITH CTEE AS (SELECT Winner ,count(*) total ,
                        RANK()OVER(ORDER BY count(*) DESC ) RATE
FROM T20I
WHERE Margin LIKE '%wickets' AND Winner NOT IN ('tied','no result')
Group by Winner)
SELECT *
FROM CTEE
WHERE RATE =1
 


--Q7 Head-to-head record between two selected teams (evg., England vs Australia).
DECLARE @A VARCHAR(25) ='England'
DECLARE @B VARCHAR(25) ='Australia'

SELECT Winner, COUNT(*)AS TOTAL
FROM T20I
WHERE (Team1 = @A AND Team2= @B) OR (Team2 = @A AND Team1= @B)
GROUP BY Winner

--Q8 Identify the month  with the highest number of T201 Matches played.
SELECT *
FROM (SELECT Team1
FROM T20I
union 
SELECT Team1
FROM T20I) AS BB


--Q9 For each team, find how many matches they played in 2024 and their win percentage.
 
WITH TWO AS (select Team1 AS TEAM , Winner AS WIN
from T20I WHERE Team1 NOT IN ('no result','tied')  
UNION 
select Team2 AS TEAM  , Winner AS WIN
from T20I WHERE Team2 NOT IN ('no result','tied')  
)  ,
tab5 as (select Winner ,COUNT(*) PER FROM T20I GROUP BY Winner  )
SELECT TWO.TEAM, COUNT(*) as matches ,PER , CAST(100.0*PER/COUNT(*) AS decimal(5,2))
FROM TWO
LEFT JOIN tab5
ON TWO.TEAM =tab5.Winner
GROUP BY TWO.TEAM,PER
order by TEAM



 
--Q10 Identify the most successful team at each ground (teaM with Most wins per ground)
 


WITH TAqB AS (SELECT Ground,Winner,count(*)wins ,DENSE_RANK()OVER(PARTITION BY Ground ORDER BY COUNT(*) DESC) RATE
FROM T20I
WHERE Winner NOT IN ('no result','tied')
GROUP BY Ground,Winner )
SELECT Ground,Winner,wins
FROM TAqB
WHERE  RATE=1
order by Ground

SELECT *
FROM T20I