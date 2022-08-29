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

USE bank;

-- In which districts do clients ask for loans the most?
SELECT d.A2 AS district_name
    , COUNT(l.account_id) AS current_loans
FROM loan l
JOIN account a
ON a.account_id = l.account_id
JOIN district d
ON d.A1 = a.district_id
GROUP BY 1
ORDER BY current_loans DESC;

-- What are the populations in these districts?
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

-- Which districts have the highest loan / population ratio?
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

-- Now which districts are above this average?
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
