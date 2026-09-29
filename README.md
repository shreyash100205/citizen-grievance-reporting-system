# Citizen Grievance Data Management & Reporting System

MySQL + Excel / Google Sheets project: a complaint tracker with automatic data-quality checks, SLA tracking and management reports for a fictional municipal corporation.

> **Note:** All data is randomly generated sample data. No real citizens or complaints.

## Files
| File | What it is |
|---|---|
| `Project2_Grievance_System.xlsx` | Tracker with drop-downs, conditional formatting, Data_Quality sheet, reports and dashboard |
| `Project2_Grievance_System.sql` | MySQL 8.0+ script: schema with keys, staging table, validation/load, rejected-records table, 8 queries |

## How it works
1. Raw complaints are loaded into a staging table exactly as entered.
2. Validation moves bad rows to `rejected_complaints` with the reason; good rows go to `complaints`.
3. SQL and Excel reports use only valid rows.

## Results (sample data, report date 29-Sep-2026)
- 406 rows entered -> 383 valid, 23 rejected (6 duplicate IDs, 5 missing wards, 4 missing categories, 8 date errors)
- 284 resolved, 99 pending, 85 overdue
- Average resolution 4.8 days; 70.4% of resolved complaints within deadline (High 2 days, Medium 5, Low 10)

## Skills shown
SQL: primary/foreign keys, staging tables, JOIN, GROUP BY, CASE, DATEDIFF, window function (ROW_NUMBER).
Excel / Sheets: Data Validation, Conditional Formatting, COUNTIFS, AVERAGEIFS, INDEX/MATCH, dashboards.

## How to run the SQL
```sql
CREATE DATABASE grievance_db;
USE grievance_db;
SOURCE Project2_Grievance_System.sql;
```
