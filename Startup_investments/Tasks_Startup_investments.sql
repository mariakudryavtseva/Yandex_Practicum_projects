-- Исследование данных об инвестиции венчурных фондов в компании-стартапы.

--Task 1

SELECT COUNT(*)
FROM company
WHERE status = 'closed';

--Task 2

SELECT funding_total
FROM company
WHERE category_code = 'news' AND
      country_code = 'USA'
ORDER BY funding_total DESC;

--Task 3

SELECT SUM(price_amount)
FROM acquisition
WHERE term_code = 'cash' AND EXTRACT(YEAR FROM acquired_at) BETWEEN '2011' AND '2013';     

--Task 4

SELECT first_name, last_name, twitter_username
FROM people
WHERE twitter_username LIKE 'Silver%';

--Task 5

SELECT *
FROM people
WHERE twitter_username LIKE '%money%' AND last_name LIKE 'K%';

--Task 6

SELECT country_code,
       SUM(funding_total) as sum_fund
FROM company
GROUP BY country_code
ORDER BY sum_fund DESC;

 --Task 7

 SELECT CAST(created_at AS date) AS create_date,
       MAX(funding_total),
       MIN(funding_total)
FROM company
GROUP BY create_date
HAVING MIN(funding_total) != 0 AND MIN(funding_total) != MAX(funding_total);

 --Task 8

 SELECT *,
       CASE
           WHEN invested_companies < 20 THEN 'low_activity'
           WHEN invested_companies >= 20 AND invested_companies < 100 THEN 'middle_activity'
           WHEN invested_companies >= 100 THEN 'high_activity'
       END
FROM fund;

--Task 9

SELECT 
       (CASE
           WHEN invested_companies < 20 THEN 'low_activity'
           WHEN invested_companies >= 20 AND invested_companies < 100 THEN 'middle_activity'
           WHEN invested_companies >= 100 THEN 'high_activity'
       END) AS category,
       ROUND(AVG(investment_rounds)) as average
FROM fund
GROUP BY category
ORDER BY average;

--Task 10

SELECT country_code,
       MIN(invested_companies),
       MAX(invested_companies),
       AVG(invested_companies) as average
FROM fund
WHERE EXTRACT(YEAR FROM CAST(founded_at AS date)) BETWEEN '2010' AND '2012'
GROUP BY country_code
HAVING MIN(invested_companies) != 0
ORDER BY average DESC
LIMIT 10;

--Task 11

SELECT p.first_name,
       p.last_name,
       e.instituition
FROM people as p
LEFT OUTER JOIN education AS e ON p.id = e.person_id;

--Task 12

SELECT p_ed.name,
       COUNT(DISTINCT p_ed.instituition) as count
FROM (SELECT *
    FROM education AS e
    INNER JOIN people AS p ON e.person_id = p.id
    INNER JOIN company AS c ON p.company_id = c.id) AS p_ed
GROUP BY p_ed.name
ORDER BY count DESC
LIMIT 5;

--Task 13

SELECT c.name
FROM (SELECT *
      FROM company 
      WHERE status = 'closed') AS c
INNER JOIN
      (SELECT funding_round.company_id, count(*) cnt
       FROM funding_round
       WHERE is_first_round = 1 AND
       is_last_round = 1 GROUP BY funding_round.company_id) AS f ON c.id = f.company_id;

--Task 14

SELECT p.id
FROM people AS p
WHERE p.company_id IN (SELECT c.id
FROM (SELECT *
      FROM company 
      WHERE status = 'closed') AS c
INNER JOIN
      (SELECT funding_round.company_id, count(*) cnt
       FROM funding_round
       WHERE is_first_round = 1 AND
       is_last_round = 1 GROUP BY funding_round.company_id) AS f ON c.id = f.company_id);

--Task 15

SELECT p.id, e.instituition 
FROM people AS p
INNER JOIN education e ON e.person_id = p.id
WHERE p.company_id IN (
    SELECT 
        c.id
    FROM (
        SELECT *
        FROM company 
        WHERE status = 'closed') AS c
    INNER JOIN
      (SELECT funding_round.company_id, count(*) cnt
       FROM funding_round
       WHERE is_first_round = 1 AND
       is_last_round = 1 GROUP BY funding_round.company_id) AS f ON c.id = f.company_id);

--Task 16

SELECT p.id, COUNT(e.instituition) 
FROM people AS p
INNER JOIN education e ON e.person_id = p.id
WHERE p.company_id IN (
    SELECT 
        c.id
    FROM (
        SELECT *
        FROM company 
        WHERE status = 'closed') AS c
    INNER JOIN
      (SELECT funding_round.company_id, count(*) cnt
       FROM funding_round
       WHERE is_first_round = 1 AND
       is_last_round = 1 GROUP BY funding_round.company_id) AS f ON c.id = f.company_id) 
GROUP BY p.id;

--Task 17

WITH
count_all AS (SELECT p.id, COUNT(e.instituition) as count
FROM people AS p
INNER JOIN education e ON e.person_id = p.id
WHERE p.company_id IN (
    SELECT 
        c.id
    FROM (
        SELECT *
        FROM company 
        WHERE status = 'closed') AS c
    INNER JOIN
      (SELECT funding_round.company_id, count(*) cnt
       FROM funding_round
       WHERE is_first_round = 1 AND
       is_last_round = 1 GROUP BY funding_round.company_id) AS f ON c.id = f.company_id) 
GROUP BY p.id)

SELECT AVG(count)
FROM count_all;

--Task 18

WITH face AS (SELECT e.person_id, count(*) as count
FROM education AS e
INNER JOIN people AS p ON e.person_id = p.id
INNER JOIN company AS c ON p.company_id = c.id
WHERE c.name = 'Facebook'
GROUP BY e.person_id)

SELECT AVG(count)
FROM face;

--Task 19

SELECT f.name AS name_of_fund,
       c.name AS name_of_company,
       fr.raised_amount AS amount
FROM fund AS f
INNER JOIN investment AS i ON f.id = i.fund_id
INNER JOIN funding_round AS fr ON i.funding_round_id = fr.id
INNER JOIN company AS c ON fr.company_id = c.id
WHERE c.milestones > 6 AND EXTRACT(YEAR FROM fr.funded_at) BETWEEN '2012' AND '2013';

--Task 20

SELECT c.name AS acquiring_company,
       a.price_amount AS price,
       c1.name AS acquired_company,
       c1.funding_total AS funding_total,
       a.acquired_at AS acquired_date,
       ROUND( a.price_amount / c1.funding_total) AS ratio
FROM acquisition AS a
LEFT OUTER JOIN company AS c ON a.acquiring_company_id = c.id
LEFT OUTER JOIN company AS c1 ON a.acquired_company_id = c1.id
WHERE a.price_amount > 0 AND c1.funding_total > 0
ORDER BY price DESC
LIMIT 10;

--Task 21

SELECT c.name,
       EXTRACT(MONTH FROM CAST(f.funded_at AS date)) AS month
FROM company AS c
INNER JOIN funding_round AS f ON c.id = f.company_id
WHERE c.category_code = 'social' AND EXTRACT(YEAR FROM CAST(f.funded_at AS date)) BETWEEN '2010' AND '2013';

--Task 22

WITH s_1 AS (
    SELECT 
        EXTRACT(MONTH FROM CAST(funded_at AS date)) as month,
        COUNT(DISTINCT f.name) as total_count
    FROM funding_round AS fr
        INNER JOIN investment AS i ON fr.id = i.funding_round_id
        INNER JOIN fund AS f ON i.fund_id = f.id
    WHERE 
        f.country_code = 'USA' AND 
        EXTRACT(YEAR FROM CAST(funded_at AS date)) BETWEEN '2010' AND '2013'
    GROUP BY month
),
s_2 AS (
    SELECT 
        EXTRACT(MONTH FROM CAST(a.acquired_at AS date)) as month,
        COUNT( a.acquired_company_id) AS acquired_count,
        SUM(a.price_amount) as sum
    FROM acquisition AS a 
    WHERE EXTRACT(YEAR FROM CAST(a.acquired_at AS date)) BETWEEN '2010' AND '2013'
    GROUP BY month
)

SELECT 
    s_1.month, 
    s_1.total_count, 
    s_2.acquired_count, 
    s_2.sum
FROM
    s_1
LEFT JOIN s_2 ON s_1.month = s_2.month
ORDER BY month;

--Task 23

WITH t_1 AS (SELECT c.country_code,
       AVG(c.funding_total) AS year_2011
FROM company AS c
WHERE EXTRACT(YEAR FROM CAST(founded_at AS date)) = '2011'
GROUP BY c.country_code),

t_2 AS (SELECT c.country_code,
       AVG(c.funding_total) AS year_2012
FROM company AS c
WHERE EXTRACT(YEAR FROM CAST(founded_at AS date)) = '2012'
GROUP BY c.country_code),

t_3 AS (SELECT c.country_code,
       AVG(c.funding_total) AS year_2013
FROM company AS c
WHERE EXTRACT(YEAR FROM CAST(founded_at AS date)) = '2013'
GROUP BY c.country_code)

SELECT t_1.country_code,
       t_1.year_2011,
       t_2.year_2012,
       t_3.year_2013
FROM t_1
LEFT JOIN t_2 ON t_1.country_code = t_2.country_code
LEFT JOIN t_3 ON t_2.country_code = t_3.country_code
WHERE t_1.year_2011 IS NOT NULL AND t_2.year_2012 IS NOT NULL AND t_3.year_2013 IS NOT NULL
ORDER BY t_1.year_2011 DESC;




