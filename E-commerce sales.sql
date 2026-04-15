#  Section 1: The "Who" (Demographics & Loyalty)
# 1 Age Group Analysis: Which age brackets (e.g., 18-25, 26-40, etc.) purchase the most items?
select case 
when age between 18 and 24 then  '18-24 (grn z)'
when age between 25 and 34 then '25-34(Milennial)'
when age between 35 and 44 then '35-44(Gen x)'
when age between 45 and 54 then '45-54 (Genn boomer)'
when age >54 then '55+(senior)'
else 'unknown'
end as Age_group ,
count(*) as Total_orders , 
sum(Purchase_Amount_USD) as Total_revenue ,
round(avg(Purchase_Amount_USD),2) as avg_spent_per_order_in_USD
from salary.consumer_bh
group by Age_group 
order by Total_orders desc ;
# 2 Gender Split: What is the percentage of total purchases made by Male vs. Female customers?
select Gender, count(*) as Total_orders ,
sum(Purchase_Amount_USD) As Total_revenue ,
round(count(*) * 100.0 / (select count(*) from salary.consumer_bh )
,2) as percentage_of_orders ,
round(sum(Purchase_Amount_USD) * 100.0 /(select sum( Purchase_Amount_USD) from salary.consumer_bh),2 ) as percentage_of_revenue 
from salary.consumer_bh
group by Gender ;
# 3 Location Heatmap: Which Location (State) has the highest concentration of customers?
select Location as state ,
count(Purchase_Amount_USD) as Total_customers ,
sum(Purchase_Amount_USD) as Totao_Revenue ,
round(sum(Purchase_Amount_USD) / count(Customer_ID),2) as avg_transaction_value ,
round(count(*) *100.0 / (select count(*) from salary.consumer_bh) ,2) as Market_share_percentage 
from salary.consumer_bh
group by Location
order by  Total_customers desc ;
# 4 Loyalty benchmarking: Based on Previous_Purchases, who are the most loyal customers (top 5% or 10%)?
WITH Ranked_Customers AS (
    SELECT 
        Customer_ID,
        Previous_Purchases,
        Purchase_Amount_USD,
        PERCENT_RANK() OVER (ORDER BY Previous_Purchases ASC) AS loyalty_percentile
    FROM salary.consumer_bh
)
SELECT 
    Customer_ID,
    Previous_Purchases,
    Purchase_Amount_USD,
    CASE 
        WHEN loyalty_percentile >= 0.95 THEN 'Top 5% (platinum)'
        WHEN loyalty_percentile >= 0.90 THEN 'Top 10% (gold)'
        ELSE 'standard'
    END AS Loyalty_rank
FROM Ranked_Customers
WHERE loyalty_percentile >= 0.90
ORDER BY Previous_Purchases DESC
limit 10 
# 5 Subscription Status: What percentage of total customers are currently "Subscribers" vs. "Non-Subscribers"?

SELECT 
    Subscription_Status, 
    COUNT(*) AS Total_Customers,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM salary.consumer_bh), 2) AS Percentage
FROM salary.consumer_bh
GROUP BY Subscription_Status;
# Section 2: The "What" (Product & Visual Trends)
# 6 Category Revenue: Which Category (Clothing, Accessories, etc.) generates the highest total income?
SELECT * FROM salary.consumer_bh;
SELECT 
    Category, 
    COUNT(*) AS Total_Items_Sold,
    SUM(Purchase_Amount_USD) AS Total_Revenue,
    ROUND(AVG(Purchase_Amount_USD), 2) AS Avg_Item_Price,
    ROUND(SUM(Purchase_Amount_USD) * 100.0 / (SELECT SUM(Purchase_Amount_USD) FROM salary.consumer_bh), 2) AS Revenue_Contribution_Pct
FROM salary.consumer_bh
GROUP BY Category
ORDER BY Total_Revenue DESC;

# 7 Item Popularity: Within each category, which specific Item_Purchased is the #1 bestseller?
WITH Item_Counts AS (
    -- Step 1: Count how many times each item was purchased per category
    SELECT 
        Category, 
        Item_Purchased, 
        COUNT(*) AS Total_Sold
    FROM salary.consumer_bh
    GROUP BY Category, Item_Purchased
),
Ranked_Items AS (
    -- Step 2: Rank the items within each category
    SELECT 
        Category, 
        Item_Purchased, 
        Total_Sold,
        ROW_NUMBER() OVER (PARTITION BY Category ORDER BY Total_Sold DESC) as rank_num
    FROM Item_Counts
)
-- Step 3: Select only the #1 item for each category
SELECT Category, Item_Purchased, Total_Sold
FROM Ranked_Items
WHERE rank_num = 1;
# 8 Size Popularity: Which Size (S, M, L, XL) is the most frequently ordered across all categories?
SELECT 
    Size, 
    COUNT(*) AS Total_Orders,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM salary.consumer_bh), 2) AS Percentage_of_Total
FROM salary.consumer_bh
GROUP BY Size
ORDER BY Total_Orders DESC;

# 9 Color Preferences: Which specific Color is most "in demand" by customers?
SELECT 
    Color, 
    COUNT(*) AS Total_Orders,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM salary.consumer_bh), 2) AS Percentage_of_Total
FROM salary.consumer_bh
GROUP BY Color
ORDER BY Total_Orders DESC;
# 10 Seasonal Trends: Which Season (Winter, Summer, Fall, Spring) sees the highest volume of sales?

# Section 3: The "How" (Logistics & Payments)

# 11 Shipping Preferences: What is the most popular Shipping_Type (Free Shipping, Express, Store Pickup)
SELECT Shipping_Type, 
       COUNT(*) AS Total_Usage
FROM  salary.consumer_bh
GROUP BY Shipping_Type
ORDER BY Total_Usage DESC
# 12 Payment Methods: Which Payment_Method (Bank Transfer, Credit Card, etc.) is used most often?
SELECT Payment_Method, 
       COUNT(*) AS Usage_Count
FROM  salary.consumer_bh
GROUP BY Payment_Method
ORDER BY Usage_Count DESC
# 13 Purchase Frequency: Based on the Frequency_of_Purchases column, how often do customers typically return (Monthly, Quarterly, Annually)?
SELECT Frequency_of_Purchases, 
       COUNT(*) AS Total_Customers,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM salary.consumer_bh), 2) AS Percentage
FROM salary.consumer_bh
GROUP BY Frequency_of_Purchases
ORDER BY Total_Customers DESC;
# Section 4: The "Why" (Business Insights & Profits)
# 14 Review Ratings: What is the average Review_Rating for each Category? (Finding the "Best" and "Worst" rated products).
SELECT Category, 
       ROUND(AVG(Review_Rating), 2) AS Average_Rating,
       COUNT(*) AS Total_Reviews
FROM salary.consumer_bh
GROUP BY Category
ORDER BY Average_Rating DESC
# 15 Promo Code Impact: Does using a Promo_Code_Used actually lead to a higher Purchase_Amount_USD per transaction?
SELECT Promo_Code_Used, 
       COUNT(*) AS Transaction_Count,
       ROUND(AVG(Purchase_Amount_USD), 2) AS Avg_Transaction_Value,
       ROUND(SUM(Purchase_Amount_USD), 2) AS Total_Revenue
FROM salary.consumer_bh
GROUP BY Promo_Code_Used;
# 16 The Subscriber Gap: Do Subscribers actually spend more on average than Non-Subscribers?
SELECT Subscription_Status, 
       COUNT(*) AS Total_Customers,
       ROUND(AVG(Purchase_Amount_USD), 2) AS Avg_Spent_Per_Order,
       ROUND(SUM(Purchase_Amount_USD), 2) AS Total_Revenue_Contribution
FROM salary.consumer_bh
GROUP BY Subscription_Status;
# 17 Shipping vs. Loyalty: Do customers who use "Free Shipping" have a higher number of Previous_Purchases than those who don't?
SELECT Shipping_Type, 
       COUNT(*) AS Customer_Count,
       ROUND(AVG(Previous_Purchases), 1) AS Avg_Past_Purchases
FROM salary.consumer_bh
WHERE Shipping_Type IN ('Free Shipping', 'Standard', 'Express', 'Next Day Air') -- Adjust based on your actual categories
GROUP BY Shipping_Type
ORDER BY Avg_Past_Purchases DESC;
# 18 Discount Revenue: What percentage of total revenue comes from transactions where a Discount_Applied was "Yes"?
SELECT 
    SUM(CASE WHEN Discount_Applied = 'Yes' THEN Purchase_Amount_USD ELSE 0 END) AS Discounted_Revenue,
    SUM(Purchase_Amount_USD) AS Total_Revenue,
    ROUND(100.0 * SUM(CASE WHEN Discount_Applied = 'Yes' THEN Purchase_Amount_USD ELSE 0 END) / 
          SUM(Purchase_Amount_USD), 2) AS Discount_Revenue_Percentage
FROM salary.consumer_bh;