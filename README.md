# Laptop Price Analysis with SQL

SQL data-cleaning and exploratory-analysis exercises on a dataset of 1,300+
laptops. The project examines specifications and price, and prepares features
such as screen pixel density and price categories.

## Repository guide

| File | Purpose |
| --- | --- |
| `laptopData.csv` | Source laptop dataset |
| `laptop-sql-data-cleaning.sql` | Backups, null handling, type conversion and specification cleanup |
| `LaptopEDA.sql` | Univariate, bivariate and feature-engineering analysis |

## Analysis workflow

1. Import `laptopData.csv` into a disposable local database as `laptopdata`.
2. Review schema references: the cleaning script uses `sql_cx_live` in some queries.
3. Run the cleaning statements in `laptop-sql-data-cleaning.sql` in order.
4. Work through `LaptopEDA.sql` to inspect distributions and relationships.

The scripts include `ALTER`, `UPDATE` and `DELETE` statements. Use a copy of the
dataset and retain the backup table created by the cleaning script.

## Questions explored

- How are laptop prices distributed, and where are potential outliers?
- How do brands, device types and specifications relate to price?
- How can raw RAM, storage, display and weight fields be standardized?
- How can pixel density and price categories support deeper analysis?

## SQL compatibility

The cleaning work uses MySQL-style syntax. The EDA file also contains
`PERCENTILE_CONT ... WITHIN GROUP`, which is not supported as written in MySQL.
Adapt those percentile exercises to your database engine. These are exploratory
SQL exercises rather than a single portable migration script.

## Skills demonstrated

Data inspection, data cleaning, type conversion, grouping, window-function
exploration and feature engineering. Numerical findings should be reproduced
from the queries; no unverified performance or business-impact claims are made.
