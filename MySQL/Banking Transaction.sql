create database Banking_Transactions;
use Banking_Transactions;

create table Bank ( 
Transaction_Id        VARCHAR(15)   NOT NULL,
    Customer_Id           VARCHAR(12)   NOT NULL,
    Transaction_Date      DATE          NOT NULL,
    Transaction_Time      TIME          NOT NULL,
    Account_Type          VARCHAR(20)   NOT NULL,
    Transaction_Type      VARCHAR(20)   NOT NULL,
    Transaction_Amount    DECIMAL(15,2) NOT NULL,
    Transaction_Direction VARCHAR(10)   NOT NULL,
    Account_Balance       DECIMAL(15,2) NOT NULL,
    Merchant_Category     VARCHAR(30)   NOT NULL,
    State                 VARCHAR(30)   NOT NULL,
    Credit_Score          SMALLINT      NOT NULL,
    Has_Loan              TINYINT       NOT NULL,
    Loan_Type             VARCHAR(20)   NULL,
    Emi_Amount            DECIMAL(12,2) NOT NULL,
    Transaction_Status    VARCHAR(15)   NOT NULL,
    Channel               VARCHAR(20)   NOT NULL,
    Kyc_Status            VARCHAR(15)   NOT NULL,
    Is_Fraud              TINYINT       NOT NULL,
    Transaction_Hour      TINYINT       NOT NULL,
    Year 				  year  		not null,
    Month_Name 			  varchar(50)   not null,
    PRIMARY KEY (transaction_id)
);

show variables like 'secure_file_priv';

load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Clean_Banking_Transactions.csv"
into table Bank
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows
(Transaction_Id, Customer_Id, @Transaction_Date, Transaction_Time, Account_Type,
 Transaction_Type, Transaction_Amount, Transaction_Direction, Account_Balance,
 Merchant_Category, State, Credit_Score, Has_Loan, @Loan_Type, Emi_Amount,
 Transaction_Status, Channel, Kyc_Status, Is_Fraud, Transaction_Hour, Year, Month_Name)
SET Transaction_Date = STR_TO_DATE(@Transaction_Date, '%d-%m-%Y'),
    Loan_Type        = NULLIF(@Loan_Type, '');
    
select * from bank;

# Total transactions
select count(*) as Total_Transactions
from Bank;

# Total value (INR)
select concat( round(sum(Transaction_Amount) / 10000000,2),'M') as Total_Amount
from Bank;

# Successful value
select concat( round(sum(Transaction_Amount) / 10000000,2),'M') as Total_Amount
from Bank
where Transaction_Status = 'Success';

# Success rate
select count(*) as Total_Trans, sum(Transaction_Status = 'Success') as Success_Trans, 
		round(sum(Transaction_Status = 'Success') * 100.0 / count(*),2 ) as Success_Rate_Pct
        from Bank;
        
# Failure / reversal / pending rate
SELECT
    COUNT(*) AS total_txn,
    ROUND(SUM(Transaction_Status = 'Failed')   * 100.0 / COUNT(*), 2) AS failure_rate_pct,
    ROUND(SUM(Transaction_Status = 'Reversed') * 100.0 / COUNT(*), 2) AS reversal_rate_pct,
    ROUND(SUM(Transaction_Status = 'Pending')  * 100.0 / COUNT(*), 2) AS pending_rate_pct
FROM Bank;

SELECT
    Transaction_Status,
    COUNT(*) AS txn_count,
    ROUND(SUM(Transaction_Amount) / 10000000, 2) AS value_in_crore,
    ROUND(SUM(Transaction_Amount) * 100.0 / SUM(SUM(Transaction_Amount)) OVER (), 2) AS pct_of_value
FROM Bank
GROUP BY Transaction_Status;

# Fraud count
select sum(Is_Fraud) as Total_Frauds
from Bank
where Is_Fraud = '1';

# Fraud rate (count)
select count(*) as Total_Trans, sum(Is_Fraud) as Fraud_Count, round(sum(Is_Fraud) * 100.0 / count(*),2) as Fraud_Count_Pct
from Bank;

# Fraud value rate
select round(sum(Transaction_Amount) / 10000000, 2) as Total_Value_crore,
	   round(sum(case when Is_Fraud = 1 then Transaction_Amount else 0 end) / 10000000,2) as Fraud_Value_Crore,
	   round(sum(case when Is_Fraud = 1 then Transaction_Amount else 0 end) * 100.0 
       / sum(Transaction_Amount), 2) as Fraud_Value_Rate_Pct
       from Bank;
       
# Avg ticket size (fraud vs genuine)
WITH ranked AS (
    SELECT
        Is_Fraud,
        Transaction_Amount,
        ROW_NUMBER() OVER (PARTITION BY Is_Fraud ORDER BY Transaction_Amount) AS rn,
        COUNT(*)     OVER (PARTITION BY Is_Fraud) AS cnt
    FROM Bank
)
SELECT
    Is_Fraud,
    ROUND(AVG(Transaction_Amount), 2) AS median_ticket
FROM ranked
WHERE rn IN (FLOOR((cnt + 1) / 2), CEIL((cnt + 1) / 2))
GROUP BY Is_Fraud;

# Debit-to-credit ratio Debit count ÷ Credit count

select sum(Transaction_Direction = 'Debit') as Debit_Count,
       sum(Transaction_Direction = 'Credit') as Credit_Count,
       round(sum(Transaction_Direction = 'Debit') /  sum(Transaction_Direction = 'Credit'),2) as Debit_to_Credit_Ratio
       from Bank;

# Which channel has the highest failure rate, and is the gap versus the lowest channel large enough to matter?
select Channel, count(*) as Total_Trans, sum(Transaction_Status = 'Failed') as Failed_Trans,
				round(sum(Transaction_Status = 'Failed') * 100.0 / count(*), 2 ) as Failure_Rate_Pct
                from Bank 
                group by Channel
                order by Failure_Rate_Pct desc;
                
# How many successful transactions were made by customers with Expired KYC, by state and by year? (Compliance wants this for ticket T-13.)
select State, Year, count(*) as Successfull_Expired_Kyc_Trans
from Bank
where Transaction_Status = 'Success' and Kyc_Status = 'Expired'
group by State, Year
order by State, Year;

# For each year, rank the transaction types by fraud value using RANK() OVER (PARTITION BY ...), and show whether the top type changes over time.
with Yearly as (
select Year, Transaction_Type, count(*) as Fraud_Count, sum(Transaction_Amount) as Fraud_Value
from Bank 
where Is_Fraud = 1 and Transaction_Date < '2024-01-01'
group by Year, Transaction_Type
)
select Year, Transaction_Type, round(Fraud_Value / 1000000, 2) as Fraud_Value_Crore, 
round(Fraud_Value * 100.0 / sum(Fraud_Value) over (partition by Year), 1 ) as Pct_of_Year_Fraud_Value,
rank() over (partition by Year order by Fraud_Value desc) as Value_Rank
from Yearly
order by Year, Value_Rank;

select Account_Type, count(Customer_Id) as Total_Customers
from bank
group by Account_Type
order by Total_Customers desc;

select * from Bank;

select Transaction_Type, round(sum(Transaction_Amount) / 1000000,2) as Total_Amount
from Bank
group by Transaction_Type
order by Total_Amount desc;

select Merchant_Category, round(sum(Account_Balance),2) as Account_Balace
from Bank
group by Merchant_Category
order by Account_Balance desc;

select Loan_Type, round( sum(Emi_Amount) / 1000000,2) as Emi_Amount
from Bank
group by Loan_Type
order by Emi_Amount desc;

alter table Bank add column Loan_Category varchar(20);

update Bank set Loan_Category = 
case when Has_Loan = 0 then 'No Loan'
when Loan_Type is null or Loan_Type in ('', 'None') then 'Unknown Loan Type'
else Loan_Type
end;

