SELECT * FROM [dbo].[01_Toyota_Branches]


SELECT * FROM [dbo].[02_Toyota_Employees]


SELECT * FROM [dbo].[03_Toyota_Sales]


SELECT * FROM [dbo].[04_Toyota_Prices_Inventory]



SELECT * FROM [dbo].[05_Toyota_Reviews_Returns]

UPDATE [dbo].[05_Toyota_Reviews_Returns] SET Would_Recommend = 0 
WHERE Would_Recommend IS NULL


SELECT Would_Recommend FROM [dbo].[05_Toyota_Reviews_Returns]

SELECT 
    [Model],
    [Category],
    COUNT([Transaction_ID]) AS Total_Units_Sold,
    SUM([Total_With_VAT]) AS Total_Revenue,
    SUM(CAST([Base_Price] AS BIGINT)) AS Total_Base_Cost,
    SUM([Total_With_VAT]) - SUM(CAST([Base_Price] AS BIGINT)) AS Net_Profit,
    -- Profit Margin Percentage
    ROUND(
        (SUM([Total_With_VAT]) - SUM(CAST([Base_Price] AS BIGINT))) / 
        NULLIF(SUM([Total_With_VAT]), 0) * 100, 2
    ) AS Profit_Margin_Percentage
FROM [dbo].[03_Toyota_Sales]
WHERE [Transaction_Status] = 'Completed'
GROUP BY [Model], [Category]
ORDER BY Net_Profit DESC;


WITH Yearly_Financials AS (
    SELECT 
        [Year],
        SUM([Total_With_VAT]) AS Current_Year_Revenue,
        SUM([Total_With_VAT]) - SUM(CAST([Base_Price] AS BIGINT)) AS Current_Year_Profit
    FROM [dbo].[03_Toyota_Sales]
    WHERE [Transaction_Status] = 'Completed'
    GROUP BY [Year]
),
Growth_Calculation AS (
    SELECT 
        [Year],
        Current_Year_Revenue,
        LAG(Current_Year_Revenue) OVER (ORDER BY [Year]) AS Previous_Year_Revenue,
        Current_Year_Profit,
        LAG(Current_Year_Profit) OVER (ORDER BY [Year]) AS Previous_Year_Profit
    FROM Yearly_Financials
)
SELECT 
    [Year],
    Current_Year_Revenue,
    Current_Year_Profit,
    -- Revenue Growth Percentage
    ROUND(
        (Current_Year_Revenue - Previous_Year_Revenue) / 
        NULLIF(Previous_Year_Revenue, 0) * 100, 2
    ) AS Revenue_Growth_Percentage,
    -- Profit Growth Percentage
    ROUND(
        (Current_Year_Profit - Previous_Year_Profit) / 
        NULLIF(Previous_Year_Profit, 0) * 100, 2
    ) AS Profit_Growth_Percentage
FROM Growth_Calculation;



WITH Yearly_Financials AS (
    SELECT 
        [Year],
        SUM([Total_With_VAT]) AS Current_Year_Revenue,
        SUM([Total_With_VAT]) - SUM(CAST([Base_Price] AS BIGINT)) AS Current_Year_Profit
    FROM [dbo].[03_Toyota_Sales]
    WHERE [Transaction_Status] = 'Completed'
    GROUP BY [Year]
),
Growth_Calculation AS (
    SELECT 
        [Year],
        Current_Year_Revenue,
        LAG(Current_Year_Revenue) OVER (ORDER BY [Year]) AS Previous_Year_Revenue,
        Current_Year_Profit,
        LAG(Current_Year_Profit) OVER (ORDER BY [Year]) AS Previous_Year_Profit
    FROM Yearly_Financials
)
SELECT 
    [Year],
    Current_Year_Revenue,
    Current_Year_Profit,
    -- Revenue Growth Percentage
    ROUND(
        (Current_Year_Revenue - Previous_Year_Revenue) / 
        NULLIF(Previous_Year_Revenue, 0) * 100, 2
    ) AS Revenue_Growth_Percentage,
    -- Profit Growth Percentage
    ROUND(
        (Current_Year_Profit - Previous_Year_Profit) / 
        NULLIF(Previous_Year_Profit, 0) * 100, 2
    ) AS Profit_Growth_Percentage
FROM Growth_Calculation;


SELECT TOP 5
    [Model],
    COUNT([Transaction_ID]) AS Total_Units_Sold,
    SUM([Total_With_VAT]) AS Total_Revenue,
    SUM([Total_With_VAT]) - SUM(CAST([Base_Price] AS BIGINT)) AS Total_Net_Profit
FROM [dbo].[03_Toyota_Sales]
WHERE [Transaction_Status] = 'Completed'
GROUP BY [Model]
ORDER BY Total_Units_Sold DESC;



WITH Yearly_Profit AS (
    SELECT 
        [Year],
        SUM([Total_With_VAT]) - SUM(CAST([Base_Price] AS BIGINT)) AS Total_Net_Profit
    FROM [dbo].[03_Toyota_Sales]
    WHERE [Transaction_Status] = 'Completed'
    GROUP BY [Year]
),
Profit_With_Lag AS (
    SELECT 
        [Year],
        Total_Net_Profit,
        LAG(Total_Net_Profit) OVER (ORDER BY [Year]) AS Previous_Year_Profit
    FROM Yearly_Profit
)
SELECT 
    [Year],
    Total_Net_Profit AS Current_Year_Profit,
    Previous_Year_Profit,
    ROUND(
        (Total_Net_Profit - Previous_Year_Profit) / NULLIF(Previous_Year_Profit, 0) * 100, 2
    ) AS Profit_Growth_Percentage
FROM Profit_With_Lag;




SELECT TOP 5
    [Model],
    SUM([Total_With_VAT]) AS Total_Revenue,
    COUNT([Transaction_ID]) AS Total_Units_Sold
FROM [dbo].[03_Toyota_Sales]
WHERE [Transaction_Status] = 'Completed'
GROUP BY [Model]
ORDER BY Total_Revenue DESC;



SELECT 
    [City],
    [Region],
    COUNT([Transaction_ID]) AS Total_Orders,
    SUM([Total_With_VAT]) AS Total_Sales_Revenue,
    ROUND(
        (SUM([Total_With_VAT]) - SUM(CAST([Base_Price] AS BIGINT))) / NULLIF(SUM([Total_With_VAT]), 0) * 100, 2
    ) AS Branch_Profit_Margin_Percentage
FROM [dbo].[03_Toyota_Sales]
WHERE [Transaction_Status] = 'Completed'
GROUP BY [City], [Region]
ORDER BY Total_Sales_Revenue DESC;

SELECT 
    [Customer_Type],
    [Payment_Method],
    COUNT([Transaction_ID]) AS Transaction_Count,
    SUM([Total_With_VAT]) AS Total_Revenue,
    ROUND(
        SUM([Total_With_VAT]) * 100.0 / SUM(SUM([Total_With_VAT])) OVER(), 2
    ) AS Revenue_Contribution_Percentage
FROM [dbo].[03_Toyota_Sales]
WHERE [Transaction_Status] = 'Completed'
GROUP BY [Customer_Type], [Payment_Method]
ORDER BY Total_Revenue DESC;


SELECT 
    [Model],
    [Stock_Status],
    SUM([Available_Stock]) AS Total_Available_Units,
    SUM(CAST([Available_Stock] AS BIGINT) * CAST([Import_Cost] AS BIGINT)) AS Total_Inventory_Value_Cost,
    AVG([Days_of_Supply]) AS Avg_Days_of_Supply
FROM [dbo].[04_Toyota_Prices_Inventory]
GROUP BY [Model], [Stock_Status]
ORDER BY Total_Available_Units DESC;


SELECT 
    [Department],
    [Position],
    [Gender],
    COUNT([Employee_ID]) AS Total_Employees,
    AVG([Age]) AS Avg_Age,
    AVG(CAST([Monthly_Salary] AS INT)) AS Avg_Monthly_Salary,
    AVG(CAST([Years_of_Experience] AS INT)) AS Avg_Years_of_Experience
FROM [dbo].[02_Toyota_Employees]
WHERE [Employment_Status] = 'Active'
GROUP BY [Department], [Position], [Gender]
ORDER BY Total_Employees DESC;



SELECT 
    [Model],
    COUNT([Review_ID]) AS Total_Reviews,
    AVG(CAST([Overall_Rating] AS DECIMAL(3,2))) AS Avg_Overall_Rating,
    AVG(CAST([Car_Quality_Rating] AS DECIMAL(3,2))) AS Avg_Quality_Rating,
    AVG(CAST([Customer_Service_Rating] AS DECIMAL(3,2))) AS Avg_Customer_Service_Rating,
    AVG(CAST([Price_Rating] AS DECIMAL(3,2))) AS Avg_Price_Rating
FROM [dbo].[05_Toyota_Reviews_Returns]
GROUP BY [Model]
ORDER BY Avg_Overall_Rating DESC;


SELECT 
    [Model],
    COUNT([Review_ID]) AS Total_Transactions,
    SUM(CASE WHEN [Returned] = 1 THEN 1 ELSE 0 END) AS Total_Returned_Units,
    -- Return Rate Percentage
    ROUND(
        SUM(CASE WHEN [Returned] = 1 THEN 1.0 ELSE 0.0 END) / NULLIF(COUNT([Review_ID]), 0) * 100, 2
    ) AS Return_Rate_Percentage,
    SUM(CAST([Refund_Amount] AS BIGINT)) AS Total_Refunded_Cash
FROM [dbo].[05_Toyota_Reviews_Returns]
GROUP BY [Model]
ORDER BY Total_Refunded_Cash DESC;
















































































































































































































































