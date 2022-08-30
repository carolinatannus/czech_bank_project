/* Case study: Guide to the Financial Data Set

Scenario
You are working as an analyst for a bank. The bank offers services to the private sector. The services include managing accounts, offering loans, etc.

Objective
The bank stores information about the clients, including accounts held, transactions over the last few months, loans granted, cards issued, etc. The bank managers hope to improve their understanding of customers and seek specific actions to improve services.

Tasks
Identify the good clients to whom we can other services
Identify the bad clients that have to watch carefully to minimize the losses

More details: <https://github.com/ironhack-edu/data_case_study_2>
*/

/*
Good clients: positive balance, paid loan or no loan needed
Bad clients: negative balance, unpaid or unnaproved loan
*/

USE bank;

-- Which districts have more loans in progress?
SELECT d.A2 AS district_name
    , COUNT(l.account_id) AS current_loans
FROM loan l
JOIN account a
ON a.account_id = l.account_id
JOIN district d
ON d.A1 = a.district_id
GROUP BY 1
ORDER BY current_loans DESC;

-- What are the populations of these districts?
SELECT d.A2 AS district_name
    , d.A4 AS population
    , COUNT(l.account_id) AS current_loans
FROM loan l
JOIN account a
ON a.account_id = l.account_id
JOIN district d
ON d.A1 = a.district_id
GROUP BY 1, 2
ORDER BY current_loans DESC;

-- Which districts have the highest loan in progress / population ratio?
SELECT d.A2 AS district_name
    , d.A4 AS population
    , COUNT(l.account_id) AS current_loans
    , (COUNT(l.account_id) / d.A4) AS ratio
FROM loan l
JOIN account a
ON a.account_id = l.account_id
JOIN district d
ON d.A1 = a.district_id
GROUP BY 1, 2
ORDER BY ratio DESC
LIMIT 5;

-- In general, what is the ratio between unpaid loans from total loans per district?
SELECT AVG(debt_ratio) AS avg_debt_ratio
FROM (SELECT d.A2 AS district_name
    , COUNT(l.account_id) AS current_loans
    , COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) AS unpaid_loans
    , COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) / COUNT(l.account_id) AS debt_ratio
FROM loan l
JOIN account a
ON a.account_id = l.account_id
JOIN district d
ON d.A1 = a.district_id
GROUP BY 1) sub1;

-- Which districts are above this average?
CREATE TEMPORARY TABLE avg_debt_ratio 
(SELECT AVG(debt_ratio) AS avg_debt_ratio
FROM (SELECT d.A2 AS district_name
    , COUNT(l.account_id) AS current_loans
    , COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) AS unpaid_loans
    , COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) / COUNT(l.account_id) AS debt_ratio
FROM loan l
JOIN account a
ON a.account_id = l.account_id
JOIN district d
ON d.A1 = a.district_id
GROUP BY 1) sub1);

SELECT d.A2 AS district_name
    , COUNT(l.account_id) AS current_loans
    , COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) AS unpaid_loans
    , COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) / COUNT(l.account_id) AS debt_ratio
FROM loan l
JOIN account a
ON a.account_id = l.account_id
JOIN district d
ON d.A1 = a.district_id
GROUP BY 1
HAVING debt_ratio > (SELECT * FROM avg_debt_ratio) AND unpaid_loans > 2 -- disconsider low quantities of loans
ORDER BY current_loans DESC, debt_ratio DESC;

-- Now let's add the debt ratio information to the district table and look for possible patterns
SELECT d.A2 AS district_name
	, d.A3 AS district_region
    , d.A4 AS inhabitants
    , COUNT(l.account_id) AS current_loans
    , COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) AS unpaid_loans
    , COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) / COUNT(l.account_id) AS debt_ratio
    , AVG((COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) / COUNT(l.account_id))) OVER(PARTITION BY d.A3) AS avg_region_debt_ratio
    , d.A11 AS avg_salary
    , ROUND(AVG(d.A12 + d.A13), 2) AS avg_unemployment_rate
    , d.A14 AS entrepreneur_per_1000
    , ROUND(AVG(d.A15 + d.A16)/2) AS avg_crimes
FROM loan l
JOIN account a
ON a.account_id = l.account_id
JOIN district d
ON d.A1 = a.district_id
GROUP BY 1, 2, 3, 8, 10
HAVING unpaid_loans > 2;

-- Could there be a relationship between debt ratio and avg_salary?
SELECT d.A2 AS district_name
	, d.A3 AS district_region
    , COUNT(l.account_id) AS current_loans
    , COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) AS unpaid_loans
    , COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) / COUNT(l.account_id) AS debt_ratio
    , AVG((COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) / COUNT(l.account_id))) OVER(PARTITION BY d.A3) AS avg_region_debt_ratio
    , d.A11 AS avg_salary
    , (d.A11 / (COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) / COUNT(l.account_id))) AS avgsalary_debt_ratio
FROM loan l
JOIN account a
ON a.account_id = l.account_id
JOIN district d
ON d.A1 = a.district_id
GROUP BY 1, 2, 7
HAVING unpaid_loans > 2
ORDER BY avg_salary;
-- At first there does not seem to be a relation between these variables

-- What about debt ratio and unemployment rate in 95'?
SELECT d.A2 AS district_name
	, d.A3 AS district_region
    , COUNT(l.account_id) AS current_loans
    , COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) AS unpaid_loans
    , COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) / COUNT(l.account_id) AS debt_ratio
    , AVG((COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) / COUNT(l.account_id))) OVER(PARTITION BY d.A3) AS avg_region_debt_ratio
    , ROUND(AVG(d.A12), 2) AS unemployment_rate_95
	, (ROUND(AVG(d.A12), 2) / (COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) / COUNT(l.account_id))) AS unemp95_debt_rate
FROM loan l
JOIN account a
ON a.account_id = l.account_id
JOIN district d
ON d.A1 = a.district_id
GROUP BY 1, 2
HAVING unpaid_loans > 2
ORDER BY unemployment_rate_95;
-- At first there does not seem to be a relation between these variables

-- What about debt ratio and unemployment rate in 96'?
SELECT d.A2 AS district_name
	, d.A3 AS district_region
    , COUNT(l.account_id) AS current_loans
    , COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) AS unpaid_loans
    , COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) / COUNT(l.account_id) AS debt_ratio
    , AVG((COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) / COUNT(l.account_id))) OVER(PARTITION BY d.A3) AS avg_region_debt_ratio
    , ROUND(AVG(d.A13), 2) AS unemployment_rate_96
	, (ROUND(AVG(d.A13), 2) / (COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) / COUNT(l.account_id))) AS unemp96_debt_rate
FROM loan l
JOIN account a
ON a.account_id = l.account_id
JOIN district d
ON d.A1 = a.district_id
GROUP BY 1, 2
HAVING unpaid_loans > 2
ORDER BY unemployment_rate_96;
-- At first there does not seem to be a relation between these variables

-- Maybe debt ratio and entrepreneur per 1000?
SELECT d.A2 AS district_name
	, d.A3 AS district_region
    , COUNT(l.account_id) AS current_loans
    , COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) AS unpaid_loans
    , COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) / COUNT(l.account_id) AS debt_ratio
    , AVG((COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) / COUNT(l.account_id))) OVER(PARTITION BY d.A3) AS avg_region_debt_ratio
    , d.A14 AS entrepreneur_per_1000
    , (d.A14 / COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) / COUNT(l.account_id)) AS entrepreneur_debt_ratio
FROM loan l
JOIN account a
ON a.account_id = l.account_id
JOIN district d
ON d.A1 = a.district_id
GROUP BY 1, 2, 7
HAVING unpaid_loans > 2
ORDER BY entrepreneur_per_1000;
-- At first there does not seem to be a relation between these variables

-- Or debt ratio and total crimes?

SELECT d.A2 AS district_name
	, d.A3 AS district_region
    , COUNT(l.account_id) AS current_loans
    , COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) AS unpaid_loans
    , COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) / COUNT(l.account_id) AS debt_ratio
    , AVG((COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) / COUNT(l.account_id))) OVER(PARTITION BY d.A3) AS avg_region_debt_ratio
    , ROUND(AVG(d.A15 + d.A16)/2) AS avg_crimes
    , (ROUND(AVG(d.A15 + d.A16)/2) / COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) / COUNT(l.account_id)) AS crimes_debt_ratio
FROM loan l
JOIN account a
ON a.account_id = l.account_id
JOIN district d
ON d.A1 = a.district_id
GROUP BY 1, 2
HAVING unpaid_loans > 2
ORDER BY avg_crimes;
-- At first there does not seem to be a relation between these variables

-- Could there be any relationship between the number of municipalities of different sizes and the debt ratio?

SELECT d.A2 AS district_name
	, d.A3 AS district_region
    , d.A4 AS inhabitants
	, d.A5 AS number_mun_less_499
    , d.A6 AS number_mun_bet500_1999
    , d.A7 AS number_mun_bet2000_9999
    , d.A8 AS number_mun_more_10000
    , COUNT(l.account_id) AS current_loans
    , COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) AS unpaid_loans
    , COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) / COUNT(l.account_id) AS debt_ratio
    , AVG((COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) / COUNT(l.account_id))) OVER(PARTITION BY d.A3) AS avg_region_debt_ratio
FROM loan l
JOIN account a
ON a.account_id = l.account_id
JOIN district d
ON d.A1 = a.district_id
GROUP BY 1, 2, 3, 4, 5, 6, 7
HAVING unpaid_loans > 2;

-- Municipalities with under 499 inhabitants?

SELECT d.A2 AS district_name
	, d.A3 AS district_region
    , d.A4 AS inhabitants
	, d.A5 AS number_mun_less_499
    , (d.A5 / COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) / COUNT(l.account_id)) AS mun1_debt_ratio
    , COUNT(l.account_id) AS current_loans
    , COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) AS unpaid_loans
    , COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) / COUNT(l.account_id) AS debt_ratio
    , AVG((COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) / COUNT(l.account_id))) OVER(PARTITION BY d.A3) AS avg_region_debt_ratio
FROM loan l
JOIN account a
ON a.account_id = l.account_id
JOIN district d
ON d.A1 = a.district_id
GROUP BY 1, 2, 3, 4
HAVING unpaid_loans > 2 AND number_mun_less_499 > 0;

-- Municipalities with between 500 and 1999 inhabitants?

SELECT d.A2 AS district_name
	, d.A3 AS district_region
    , d.A4 AS inhabitants
    , d.A6 AS number_mun_bet500_1999
    , (d.A6 / COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) / COUNT(l.account_id)) AS mun2_debt_ratio
    , COUNT(l.account_id) AS current_loans
    , COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) AS unpaid_loans
    , COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) / COUNT(l.account_id) AS debt_ratio
    , AVG((COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) / COUNT(l.account_id))) OVER(PARTITION BY d.A3) AS avg_region_debt_ratio
FROM loan l
JOIN account a
ON a.account_id = l.account_id
JOIN district d
ON d.A1 = a.district_id
GROUP BY 1, 2, 3, 4
HAVING unpaid_loans > 2 AND number_mun_bet500_1999 > 0;

-- Municipalities between 2000 and 9999 inhabitants?

SELECT d.A2 AS district_name
	, d.A3 AS district_region
    , d.A4 AS inhabitants
    , d.A7 AS number_mun_bet2000_9999
    , (d.A7 / COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) / COUNT(l.account_id)) AS mun3_debt_ratio
    , COUNT(l.account_id) AS current_loans
    , COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) AS unpaid_loans
    , COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) / COUNT(l.account_id) AS debt_ratio
    , AVG((COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) / COUNT(l.account_id))) OVER(PARTITION BY d.A3) AS avg_region_debt_ratio
FROM loan l
JOIN account a
ON a.account_id = l.account_id
JOIN district d
ON d.A1 = a.district_id
GROUP BY 1, 2, 3, 4
HAVING unpaid_loans > 2 AND number_mun_bet2000_9999 > 0;

-- Municipalities with more than 10000 inhabitants?

SELECT d.A2 AS district_name
	, d.A3 AS district_region
    , d.A4 AS inhabitants
    , d.A8 AS number_mun_more_10000
    , (d.A8 / COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) / COUNT(l.account_id)) AS mun4_debt_ratio
    , COUNT(l.account_id) AS current_loans
    , COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) AS unpaid_loans
    , COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) / COUNT(l.account_id) AS debt_ratio
    , AVG((COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) / COUNT(l.account_id))) OVER(PARTITION BY d.A3) AS avg_region_debt_ratio
FROM loan l
JOIN account a
ON a.account_id = l.account_id
JOIN district d
ON d.A1 = a.district_id
GROUP BY 1, 2, 3, 4
HAVING unpaid_loans > 2;

/* Simply put, there does not seem to be a correlation between district variables (listed below) and the debt ratio of each district.

District variables:
- number of municipalities with under 499 inhabitants
- number of municipalities between 500 and 1999 inhabitants
- number of municipalities between 2000 and 9999 inhabitants
- number of municipalities with over 10000 inhabitants
- average salary
- unemployment rate '95
- unemployment rate '96
- number of entrepreneurs per 1000 inhabitants
- number of commited crimes

Nevertheless, Bruntal and Opava both have a debt ratio bigger than the rest of their region.
*/

