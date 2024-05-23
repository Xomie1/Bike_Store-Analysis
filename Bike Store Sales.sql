--Check for missing values
Select *
from dbo.Sales$
where Date is null or Customer_Age is null or Country is null or State is null or Product_Category is null;
--Decide whether to remove records with missing values or impute them based on the context.
--NO MISSING DATA

--Validate Data Types:
--Ensure that each column has the correct data type. For example, dates should be in a date format, customer age should be an integer, etc.
Select 
	Cast(Date as int) as Date, 
	CAST(Customer_Age AS int) as Customer_Age, 
	CAST(Profit AS int) as Profit,
	CAST(Cost AS int) as Cost, 
	CAST(Order_Quantity AS int) as Order_Quantity,
	CAST(Customer_Gender AS int) as Customer_Gender,
	CAST(Country AS VARCHAR(50)) AS Country,
    CAST(State AS VARCHAR(50)) AS State,
    CAST(Product_category AS VARCHAR(50)) AS Product_category
from dbo.Sales$

--Standardize Text Fields:
--Standardize text fields to ensure consistency, such as converting all country names to uppercase.
Update Sales$
set 
	Country = Upper( Country),
	State = Upper(State),
	Product_Category = Upper(Product_Category);
--================================================================================
-- Remove duplicate

--Delete from Sales$
--where (date, Customer_Age, Customer_Gender, Country, State, Product_Category) in
--	(Select date, Customer_Age, Customer_Gender, Country, State, Product_Category
--	from (
--	select date, Customer_Age, Customer_Gender, Country, State, Product_Category, COUNT(*)
--	from Sales$
--	group by date, Customer_Age, Customer_Gender, Country, State, Product_Category
--	having count(*) > 1
--	) as duplicates
--);

--Add an identifier
ALTER TABLE Sales$ ADD id INT IDENTITY(1,1) PRIMARY KEY;

WITH duplicates_cte AS (
    SELECT
        id,
        ROW_NUMBER() OVER (
            PARTITION BY Date, Customer_Age, Customer_Gender, Country, State, Product_category 
            ORDER BY id
        ) AS row_num
    FROM Sales$
)
DELETE FROM Sales$
WHERE id IN (
    SELECT id
    FROM duplicates_cte
    WHERE row_num > 1
);

--convert month names to numbers:

Update Sales$
Set Month = CASE Month
    WHEN 'January' THEN 1
    WHEN 'February' THEN 2
    WHEN 'March' THEN 3
    WHEN 'April' THEN 4
    WHEN 'May' THEN 5
    WHEN 'June' THEN 6
    WHEN 'July' THEN 7
    WHEN 'August' THEN 8
    WHEN 'September' THEN 9
    WHEN 'October' THEN 10
    WHEN 'November' THEN 11
    WHEN 'December' THEN 12
    ELSE NULL
END;

--========================================================================
--Group age into categories
Update Sales$
Set Age_Group = CASE	
	when Customer_Age between 0 and 17 then '0-17'
	when Customer_Age between 18 and 25 then '18-25'
	when Customer_Age between 26 and 35 then '26-35'
	when Customer_Age between 36 and 45 then '36-45'
	when Customer_Age between 46 and 55 then '46-55'
	when Customer_Age between 56 and 65 then '56-65'
	Else '65+'
end;

select *
from Sales$
--=======================================================================================================================
--Data Analysis Using SQL

--Sales Trends:
--What are the monthly sales trends over the past year?
--Which months have the highest sales?
Select CONCAT(Year, '-', Right('0' + CAST(Month AS VARCHAR), 2)) AS YearMonth,
count(*) as Total_sales
from Sales$
GROUP BY
    Year, Month
ORDER BY
    Year, Month;


--Customer Demographics:
--What is the age distribution of customers purchasing bikes?
Select
	Customer_Age,
	count(*) as Num_Customers
from Sales$
Group by Customer_Age
order by Customer_Age;

--Which age groups are the most frequent buyers?
Select Age_group, count(*) as Total_Sales
from Sales$
group by Age_Group
order by Total_Sales desc;

--How does bike purchasing behavior differ between genders?
Select Customer_Gender, count(*) as Total_Sales
from Sales$
group by Customer_Gender
order by Total_Sales desc;

--Geographical Analysis:
--Which countries have the highest sales?
Select Country, count(*) as Total_sales
from Sales$
group by Country
order by Total_sales desc;

--How do sales vary by state within a specific country?
Select State, count(*) as Total_sales
from Sales$
group by State
order by Total_sales desc;

--Product Analysis:
--Which product categories are the most popular among different age groups?
Select Age_group, Product_Category, count(*) as Total_Sales 
from Sales$
group by Age_group, Product_Category
order by Total_Sales desc;
--How do product category preferences vary by gender?
Select Customer_Gender, Product_Category, count(*) as Total_Sales 
from Sales$
group by Customer_Gender, Product_Category
order by Total_Sales desc;


