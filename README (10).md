# Banking Transaction Analytics

An end-to-end data analytics project that analyses **550,000 banking transactions** from **79,916 customers** (January 2019 to January 2024). The project moves from initial exploration in **Excel and Python**, to solving business problems with **MySQL** queries, to an interactive **Power BI** dashboard that makes the results easy to understand so businesses can make better decisions.

![Tools](https://img.shields.io/badge/Excel-217346?logo=microsoftexcel&logoColor=white)
![Tools](https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=white)
![Tools](https://img.shields.io/badge/MySQL-4479A1?logo=mysql&logoColor=white)
![Tools](https://img.shields.io/badge/Power%20BI-F2C811?logo=powerbi&logoColor=black)

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Workflow](#workflow)
3. [Dataset](#dataset)
4. [Dashboard](#dashboard)
5. [DAX Measures](#dax-measures)
6. [Key Insights](#key-insights)
7. [Recommendations](#recommendations)
8. [Project Structure](#project-structure)
9. [How to Run](#how-to-run)
10. [Limitations](#limitations)
11. [Future Enhancements](#future-enhancements)
12. [Author](#author)

---

## Project Overview

Banks generate large volumes of transaction data, but raw tables do not show where growth, risk and customer value sit. This project answers questions such as:

- How many transactions are processed, and what is their total value?
- Which payment types drive volume, and which drive value?
- How reliable are payments (success, failure, reversal)?
- Where is fraud concentrated?
- Which channels, states and account types generate the most activity?
- How are loans and KYC compliance distributed across customers?

## Workflow

| Stage | Tool | Purpose |
|---|---|---|
| 1. Initial analysis | Excel and Python | Explore the dataset, understand its structure and check data quality |
| 2. Business problem solving | MySQL | Write SQL queries to answer business questions |
| 3. Reporting | Power BI | Build an interactive dashboard that is easy to understand and supports decision-making |

## Dataset

- **Source:** MySQL database `Banking_Transactions`, table `bank`
- **Size:** 550,000 rows and 23 columns, one row per transaction
- **Period:** 1 January 2019 to 1 January 2024
- **Currency:** amounts are treated as Indian rupees (₹)

| Group | Columns |
|---|---|
| Transaction | `Transaction_Id`, `Transaction_Date`, `Transaction_Time`, `Transaction_Hour`, `Year`, `Month_Name`, `Transaction_Type`, `Transaction_Amount`, `Transaction_Direction`, `Transaction_Status`, `Channel`, `Merchant_Category`, `Is_Fraud` |
| Customer and account | `Customer_Id`, `Account_Type`, `Account_Balance`, `State`, `Credit_Score`, `Kyc_Status` |
| Loan | `Has_Loan`, `Loan_Type`, `Loan_Category`, `Emi_Amount` |

**Coverage:** 5 account types, 10 transaction types, 6 channels, 15 merchant categories, 10 states.

## Dashboard

The Power BI report has three pages, each with a KPI strip (Total Transactions, Total Transaction Amount, Successful Transactions, Fraud Transactions, Success Rate, Fraud Rate) and four slicers (Account Type, KYC Status, Loan Category, Loan Type).

| Page | What it shows |
|---|---|
| **Transaction Trends** | Amount by transaction type, transactions by KYC status, Debit vs Credit amount, transactions and amount by year |
| **Customer Insights** | Customers by channel, total vs unique customers, unique customers by state, customers by account type |
| **Financial Performance** | Transactions by account type, transactions by merchant category, customers by loan category, transactions by month |

< Add dashboard screenshots here, for example:
Page 1

<img width="1317" height="725" alt="Page_1" src="https://github.com/user-attachments/assets/2ce9e8b8-62fd-4c4a-8aea-fc4d8380f599" />

Page 2

<img width="1316" height="723" alt="Page_2" src="https://github.com/user-attachments/assets/7803fe1b-3076-4d7a-9abd-0262b3f2999b" />

Page 3

<img width="1318" height="726" alt="Page_3" src="https://github.com/user-attachments/assets/f1e07991-28bd-44c4-be44-5e5c46f4a26a" />

-->

## DAX Measures

| Measure | Logic |
|---|---|
| `Total_Transactions` | `DISTINCTCOUNT('banking_transactions bank'[Transaction_Id])` |
| `Total_Trans_Amt` | `SUM('banking_transactions bank'[Transaction_Amount])` |
| `Successful_Transactions` | `CALCULATE([Total_Transactions], 'banking_transactions bank'[Transaction_Status] = "Success")` |
| `Success_Rate` | `DIVIDE([Successful_Transactions], [Total_Transactions], 0)` |
| `Fraud_Transactions` | `CALCULATE([Total_Transactions], 'banking_transactions bank'[Is_Fraud] = 1)` |
| `Fraud_Rate` | `DIVIDE([Fraud_Transactions], [Total_Transactions], 0)` |
| `Total_customers` | `COUNT('banking_transactions bank'[Customer_Id])` |
| `Unique_Customers` | `DISTINCTCOUNT('banking_transactions bank'[Customer_Id])` |

## Key Insights

- **Scale:** 550,000 transactions worth ₹16.45 billion. The average transaction is ₹29,907 but the median is only ₹2,036, so a small number of very large payments drives total value.
- **Reliability:** 92.04% of transactions succeed; 3.98% fail, 2.00% are reversed and 1.97% are pending.
- **Fraud:** 4,873 transactions (0.886%) are flagged as fraud, worth ₹582.1 million (3.54% of value).
- **RTGS drives value and risk:** it is 6.0% of transactions but 54.0% of value, with a fraud rate of 1.85%, about twice the overall rate. It accounts for 66% of fraud value.
- **UPI drives volume:** 28.0% of transactions but only 1.3% of value.
- **Channels:** the mobile app handles 37.9% of transactions and reaches 92.7% of customers.
- **Geography:** Maharashtra, Karnataka and Tamil Nadu account for 45.0% of transactions.
- **KYC gap:** 12.1% of transactions (about ₹2.03 billion) come from customers with Pending or Expired KYC.
- **Stable trend:** transaction volume and value are flat from 2019 to 2023 (about 110,000 transactions and ₹3.3 billion per year).

## Recommendations

1. Strengthen fraud controls for high-value RTGS and Cheque payments.
2. Run a KYC re-verification campaign for Pending and Expired customers.
3. Protect uptime for UPI and the mobile app, which carry the most volume.
4. Investigate failed and reversed payments (about 6% of transactions, roughly ₹1.0 billion).
5. Target growth in under-penetrated states such as Punjab, UP and Rajasthan.
6. Make `Loan_Type` mandatory when a loan flag is set to remove "Unknown Loan Type" records.

## Project Structure

> Adjust this to match your repository.

```
Banking-Transaction-Analytics/
├── data/                  # Dataset or sample data
├── excel/                 # Excel analysis files
├── python/                # Python notebooks and scripts for initial analysis
├── sql/                   # MySQL queries used to solve business problems
├── powerbi/
│   └── Banking_Transaction_Analytics.pbix
├── images/                # Dashboard screenshots
├── report/                # Project report
└── README.md
```

## How to Run

1. **Clone the repository**
   ```bash
   git clone https://github.com/<your-username>/<your-repo>.git
   ```
2. **Set up the database:** create a MySQL database named `Banking_Transactions` and load the `bank` table.
3. **Run the analysis:** open the Excel files and Python notebooks for the initial analysis, then run the queries in the `sql/` folder.
4. **Open the dashboard:** open `Banking_Transaction_Analytics.pbix` in Power BI Desktop.
5. **Update the connection:** if your MySQL server is not on `localhost`, go to *Transform data → Data source settings* and update the server and database name, then click *Refresh*. The MySQL connector for Power BI must be installed.

## Limitations

- The data shows very uniform patterns across hours, years and segments, which suggests it may be simulated. Treat findings as a demonstration of method rather than a real institution.
- 2024 contains only 295 records from 1 January, so it should not be compared with full years.
- Transaction amounts are highly skewed (maximum ₹10 million), so read averages alongside medians.
- `Total_customers` counts rows, not people. Use `Unique_Customers` for a head count.
- Fraud analysis uses the `Is_Fraud` label in the source data; no fraud model was built.

## Future Enhancements

- Add a dedicated date table and time-intelligence measures (year-on-year, month-on-month).
- Add fraud analysis by hour, amount band and customer segment, with a drill-through page.
- Add a credit-risk view combining credit score, EMI and account balance.
- Schedule data refresh and publish to Power BI Service with row-level security.

## Author

**[Sarthak Gedam]**
[LinkedIn](www.linkedin.com/in/sarthak-gedam-ab6a4b292) | [GitHub](https://github.com/your-username) | [Email](sarthakgedam38@gmail.com)
