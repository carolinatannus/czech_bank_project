# Czech Bank Project
 
Status: In progress

## Objective

Scenario: You are working as an analyst for a bank. The bank offers services to the private sector. The services include managing accounts and offering loans. The bank stores information about the clients, including accounts held, transactions over the last few months, loans granted, cards issued and others. The bank managers hope to improve their understanding of customers and seek specific actions to improve services. Your goal is to:

- Identify the good clients to whom we can other services
- Identify the bad clients that have to watch carefully to minimize the losses
  
## Technologies 

  - SQL

## Project Description

  In this project I used the data released for the PKDD’99 Discovery Challenge, containing real anonymized Czech bank transactions, account info, and loan records, shared by Ironhack Education Team.
  As mentioned in the Ironhack Github file, the database stores the following relations:
  
  1) Account: each one of the 4500 records describes static characteristics of an account
  2) Client: each one of the 5369 records describes characteristics of a client
  3) Disposition: each one of the 5369 records relates a client with an account
  4) Order: each one of the 6471 records describes details of a payment order
  5) Transaction: each one of the 1056320 records describes a transaction on an account
  6) Loan: each one of the 682 records describes a loan granted for a given account
  7) Credit Card: each one of the 892 records describes a credit card issued to an account
  8) District: each one of the 77 records describes demographic characteristics of a district

  The database and general orientation can be found through this link: <https://github.com/ironhack-edu/data_case_study_2>

## Steps
  
  In order to go through the mentioned dataset, I followed the steps below:
  
  1) Accessing database
  > In this case, using MySQL
  
  2) Understanding database
  > Reading the extended case study to get a grasp on available information
  
  3) Defining 'good' and 'bad' customers
  > For this exercise, I am considering a simple, rather naive concept of good and bad clients for a bank: good clients have a positive balance and loans paid on time (or no loans whatsoever), and bad clients have a negative balance and loans in debt
  
  4) Selecting variables
  > At first I am dealing with the 'district' and 'loan' tables to understand if there is any correlation between a district variable (eg: average salary) and the rate of unpaid loans versus total loans given

## Conclusion
 
#### Simply put, there does not seem to be a correlation between district variables (listed below) and the debt ratio of each district. Nevertheless, the districts Bruntal and Opava both have a debt ratio (rate of unpaid loans versus total loans given) bigger than the rest of their region.

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

## Contact
  
  If you have any questions or comments, please let me know!
  
  https://www.linkedin.com/in/carolinatannus/
  
