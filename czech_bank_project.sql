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
    , ROUND((d.A12 + d.A13)/2, 2) AS avg_unemployment_rate
    , d.A14 AS entrepreneur_per_1000
    , ROUND((d.A15 + d.A16)/2) AS avg_crimes
FROM loan l
JOIN account a
ON a.account_id = l.account_id
JOIN district d
ON d.A1 = a.district_id
GROUP BY 1, 2, 3, 8, 9, 10, 11
HAVING unpaid_loans > 2;

-- Could there be a relationship between detb ratio and avg_salary?
SELECT d.A2 AS district_name
	, d.A3 AS district_region
    , COUNT(l.account_id) AS current_loans
    , COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) AS unpaid_loans
    , COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) / COUNT(l.account_id) AS debt_ratio
    , AVG((COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) / COUNT(l.account_id))) OVER(PARTITION BY d.A3) AS avg_region_debt_ratio
    , d.A11 AS avg_salary
FROM loan l
JOIN account a
ON a.account_id = l.account_id
JOIN district d
ON d.A1 = a.district_id
GROUP BY 1, 2, 7
HAVING unpaid_loans > 2
ORDER BY avg_salary;

-- What about debt ratio and unemployment rate?
SELECT d.A2 AS district_name
	, d.A3 AS district_region
    , COUNT(l.account_id) AS current_loans
    , COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) AS unpaid_loans
    , COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) / COUNT(l.account_id) AS debt_ratio
    , AVG((COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) / COUNT(l.account_id))) OVER(PARTITION BY d.A3) AS avg_region_debt_ratio
    , ROUND((d.A12 + d.A13)/2, 2) AS avg_unemployment_rate
FROM loan l
JOIN account a
ON a.account_id = l.account_id
JOIN district d
ON d.A1 = a.district_id
GROUP BY 1, 2, 7
HAVING unpaid_loans > 2
ORDER BY avg_unemployment_rate;

-- Maybe debt ratio and entrepreneur per 1000?
SELECT d.A2 AS district_name
	, d.A3 AS district_region
    , COUNT(l.account_id) AS current_loans
    , COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) AS unpaid_loans
    , COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) / COUNT(l.account_id) AS debt_ratio
    , AVG((COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) / COUNT(l.account_id))) OVER(PARTITION BY d.A3) AS avg_region_debt_ratio
    , d.A14 AS entrepreneur_per_1000
FROM loan l
JOIN account a
ON a.account_id = l.account_id
JOIN district d
ON d.A1 = a.district_id
GROUP BY 1, 2, 7
HAVING unpaid_loans > 2
ORDER BY entrepreneur_per_1000;

-- Or debt ratio and total crimes?

SELECT d.A2 AS district_name
	, d.A3 AS district_region
    , COUNT(l.account_id) AS current_loans
    , COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) AS unpaid_loans
    , COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) / COUNT(l.account_id) AS debt_ratio
    , AVG((COUNT(CASE WHEN l.status IN ('B', 'D') THEN 0 ELSE NULL END) / COUNT(l.account_id))) OVER(PARTITION BY d.A3) AS avg_region_debt_ratio
    , ROUND((d.A15 + d.A16)/2) AS avg_crimes
FROM loan l
JOIN account a
ON a.account_id = l.account_id
JOIN district d
ON d.A1 = a.district_id
GROUP BY 1, 2, 7
HAVING unpaid_loans > 2
ORDER BY avg_crimes;
