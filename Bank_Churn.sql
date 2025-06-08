use Projects

-- View all records from the Bank_Churn table to understand the dataset structure
SELECT * FROM Bank_Churn;


-- Calculate overall churn rate:

----------------------------EXPLANATION------------------------------------------
-- 1. Count total customers
-- 2. Count customers who exited (churned)
-- 3. Calculate churn rate as a percentage of total customers
--------------------------------------------------------------------------------

SELECT 
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS Churned_Customers,
    ROUND(100.0 * SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END)/COUNT(*), 2) AS Churn_Rate_Percent
FROM Bank_Churn;


-- Compare churn rate between genders:

----------------------------EXPLANATION------------------------------------------
-- For each gender:
--   - Count total customers
--   - Count churned customers
--   - Calculate churn percentage
--------------------------------------------------------------------------------

SELECT Gender, 
       COUNT(*) AS Total,
       SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS Churned,
       ROUND(100.0 * SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END)/COUNT(*), 2) AS Churn_Percentage
FROM Bank_Churn
GROUP BY Gender;


-- Analyze the impact of having a credit card on churn:

----------------------------EXPLANATION------------------------------------------
-- Group by credit card ownership flag
-- Calculate total customers, churned customers, and churn rate for each group
--------------------------------------------------------------------------------

SELECT 
    HasCrCard,
    COUNT(*) AS Total,
    SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS Churned,
    ROUND(100.0 * SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END)/COUNT(*), 2) AS Churn_Rate
FROM Bank_Churn
GROUP BY HasCrCard;


-- Compare bank balance statistics between churned and retained customers:

----------------------------EXPLANATION------------------------------------------
-- Calculate average, minimum, and maximum balance for each group (Exited=0 or 1)
--------------------------------------------------------------------------------

SELECT 
    Exited,
    ROUND(AVG(Balance), 2) AS Avg_Balance,
    ROUND(MIN(Balance), 2) AS Min_Balance,
    ROUND(MAX(Balance), 2) AS Max_Balance
FROM Bank_Churn
GROUP BY Exited;


-- Compare churn rates for active vs inactive members:

----------------------------EXPLANATION------------------------------------------
-- Group by IsActiveMember flag
-- Calculate total customers, churned customers, and churn rate per group
--------------------------------------------------------------------------------

SELECT 
    IsActiveMember,
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS Churned,
    ROUND(100.0 * SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END)/COUNT(*), 2) AS Churn_Rate
FROM Bank_Churn
GROUP BY IsActiveMember;


-- Identify top 5 customers with highest estimated salary in each Geography:

----------------------------EXPLANATION------------------------------------------
-- Use ROW_NUMBER window function partitioned by Geography, ordered by salary descending
-- Filter to keep only top 5 per Geography
--------------------------------------------------------------------------------

SELECT * FROM (
    SELECT 
        CustomerId, 
        Surname, 
        Geography, 
        EstimatedSalary,
        ROW_NUMBER() OVER(PARTITION BY Geography ORDER BY EstimatedSalary DESC) AS rn
    FROM Bank_Churn
) AS ranked
WHERE rn <= 5;


-- Analyze churn propensity by number of products held by customers:

----------------------------EXPLANATION------------------------------------------
-- For each number of products:
--   - Count customers
--   - Count churned customers
--   - Calculate churn rate
-- Sort by churn rate descending to find product groups with highest churn
--------------------------------------------------------------------------------

SELECT 
    NumOfProducts,
    COUNT(*) AS Product_Group_Size,
    SUM(Exited) AS Product_Group_Churned,
    ROUND(1.0 * SUM(Exited) / COUNT(*), 2) AS Churn_Rate
FROM Bank_Churn
GROUP BY NumOfProducts
ORDER BY Churn_Rate DESC;


-- Identify top 3 customers with highest balance within each Geography:

----------------------------EXPLANATION------------------------------------------
-- Use RANK window function partitioned by Geography, ordered by balance descending
-- Filter to keep ranks 1 to 3 per Geography
--------------------------------------------------------------------------------

SELECT *
FROM (
    SELECT 
        CustomerId,
        Surname,
        Geography,
        Balance,
        RANK() OVER(PARTITION BY Geography ORDER BY Balance DESC) AS rank_in_country
    FROM Bank_Churn
) ranked
WHERE rank_in_country <= 3;


-- Calculate churn rate by credit score bucket:

----------------------------EXPLANATION------------------------------------------
-- Create bands: Very Low (<500), Low (500-650), Medium (651-750), High (>750)
-- For each band:
--   - Count total customers
--   - Count churned customers
--   - Calculate churn rate percentage
-- Order by churn rate descending to identify riskier score bands
--------------------------------------------------------------------------------

SELECT 
    CreditScore_Band,
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS Churned,
    ROUND(100.0 * SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) * 1.0 / COUNT(*), 2) AS Churn_Rate
FROM (
    SELECT *,
        CASE 
            WHEN CreditScore < 500 THEN 'Very Low'
            WHEN CreditScore BETWEEN 500 AND 650 THEN 'Low'
            WHEN CreditScore BETWEEN 651 AND 750 THEN 'Medium'
            ELSE 'High' 
        END AS CreditScore_Band
    FROM Bank_Churn
) AS scored_customers
GROUP BY CreditScore_Band
ORDER BY Churn_Rate DESC;


-- Analyze churn by age group cohorts:

----------------------------EXPLANATION------------------------------------------
-- Define age brackets: 18-30, 31-45, 46-60, 60+
-- For each age bracket:
--   - Count total customers
--   - Count churned customers
--   - Calculate churn rate
--   - Rank age brackets by churn volume (number of churned customers)
--------------------------------------------------------------------------------

WITH AgeGroups AS (
    SELECT *,
           CASE 
               WHEN Age BETWEEN 18 AND 30 THEN '18-30'
               WHEN Age BETWEEN 31 AND 45 THEN '31-45'
               WHEN Age BETWEEN 46 AND 60 THEN '46-60'
               ELSE '60+'
           END AS Age_Bracket
    FROM Bank_Churn
)
SELECT 
    Age_Bracket,
    COUNT(*) AS Total,
    SUM(Exited) AS Churned,
    ROUND(100.0 * SUM(Exited) / COUNT(*), 2) AS Churn_Rate,
    RANK() OVER(ORDER BY SUM(Exited) DESC) AS Risk_Rank
FROM AgeGroups
GROUP BY Age_Bracket;


--Build Lifetime Value (LTV) Estimate by Simulating a Net Balance Tenure Score

----------------------------EXPLANATION------------------------------------------
-- Estimate customer LTV by multiplying balance and tenure
-- Divide customers into 5 bands using NTILE on estimated LTV
-- For each band, calculate average LTV and churn rate
-- Sort by LTV bands to identify which segments churn more
--------------------------------------------------------------------------------

WITH TenureBalance AS (
    SELECT 
        CustomerId,
        Tenure,
        Balance,
        Balance * Tenure AS Approx_Lifetime_Value,
        Exited
    FROM Bank_Churn
),
PercentileBand AS (
    SELECT *,
           NTILE(5) OVER (ORDER BY Approx_Lifetime_Value DESC) AS LTV_Band
    FROM TenureBalance
)
SELECT 
    LTV_Band,
    COUNT(*) AS Customers,
    ROUND(AVG(Approx_Lifetime_Value), 2) AS Avg_LTV,
    ROUND(100.0 * SUM(Exited) * 1.0 / COUNT(*), 2) AS Churn_Rate
FROM PercentileBand
GROUP BY LTV_Band
ORDER BY LTV_Band DESC;


--Customers who didn’t churn but have same profile as churners

----------------------------EXPLANATION------------------------------------------
-- Identify churner profiles based on geography, gender, product count, and activity status
-- Find non-churned customers with identical profiles
-- Useful for targeting high-risk customers who haven’t churned yet
--------------------------------------------------------------------------------


WITH Churner_Profile AS (
    SELECT DISTINCT Geography, Gender, NumOfProducts, IsActiveMember
    FROM Bank_Churn
    WHERE Exited = 1
),
HighRiskLookalikes AS (
    SELECT c.*
    FROM Bank_Churn c
    JOIN Churner_Profile p
      ON c.Geography = p.Geography
     AND c.Gender = p.Gender
     AND c.NumOfProducts = p.NumOfProducts
     AND c.IsActiveMember = p.IsActiveMember
    WHERE c.Exited = 0
)
SELECT * 
FROM HighRiskLookalikes
ORDER BY Balance DESC;


--Cumulative Churn Tracking Over Tenure

----------------------------EXPLANATION------------------------------------------
-- Track total and churned customers across increasing tenure values
-- Calculate cumulative totals and cumulative churn rate over tenure
-- Highlights how churn builds up over customer lifecycle
--------------------------------------------------------------------------------

WITH TenureChurn AS (
    SELECT 
        Tenure,
        COUNT(*) AS Total_Customers,
        SUM(Exited) AS Churned_Customers
    FROM Bank_Churn
    GROUP BY Tenure
),
Cumulative AS (
    SELECT 
        Tenure,
        SUM(Total_Customers) OVER (ORDER BY Tenure) AS Cum_Customers,
        SUM(Churned_Customers) OVER (ORDER BY Tenure) AS Cum_Churned,
        ROUND(100.0 * SUM(Churned_Customers) OVER (ORDER BY Tenure) * 1.0 / 
              SUM(Total_Customers) OVER (ORDER BY Tenure), 2) AS Cum_Churn_Rate
    FROM TenureChurn
)
SELECT * FROM Cumulative;


--Tiered Loyalty Classification with Risk Overlay

----------------------------EXPLANATION------------------------------------------
-- Classify customers into loyalty tiers based on tenure and balance
-- Calculate churn rate for each loyalty tier
-- Helps assess churn risk across customer loyalty segments
--------------------------------------------------------------------------------

WITH LoyaltyTier AS (
    SELECT *,
        CASE 
            WHEN Tenure >= 8 AND Balance > 100000 THEN 'Platinum'
            WHEN Tenure >= 5 THEN 'Gold'
            WHEN Tenure BETWEEN 2 AND 4 THEN 'Silver'
            ELSE 'Bronze'
        END AS Loyalty_Tier
    FROM Bank_Churn
),
TierRisk AS (
    SELECT 
        Loyalty_Tier,
        COUNT(*) AS Total_Customers,
        ROUND(100.0 * SUM(Exited) * 1.0 / COUNT(*), 2) AS Tier_Churn_Rate
    FROM LoyaltyTier
    GROUP BY Loyalty_Tier
)
SELECT *
FROM TierRisk
ORDER BY Tier_Churn_Rate DESC;


--Churn Anomaly Score: Composite score using z-scores

----------------------------EXPLANATION------------------------------------------
-- Calculate z-scores for age and balance of churned customers
-- Combine absolute z-scores to form an anomaly score
-- Identify churned customers with unusual behavior
--------------------------------------------------------------------------------

WITH Stats AS (
    SELECT 
        AVG(Age) AS Avg_Age,
        STDEV(Age) AS SD_Age,
        AVG(Balance) AS Avg_Balance,
        STDEV(Balance) AS SD_Balance
    FROM Bank_Churn
),
Scored AS (
    SELECT c.CustomerId, Age, Balance, Exited,
        ROUND((Age - s.Avg_Age) / NULLIF(s.SD_Age, 0), 2) AS Z_Age,
        ROUND((Balance - s.Avg_Balance) / NULLIF(s.SD_Balance, 0), 2) AS Z_Balance,
        ABS(ROUND((Age - s.Avg_Age) / NULLIF(s.SD_Age, 0), 2)) + 
        ABS(ROUND((Balance - s.Avg_Balance) / NULLIF(s.SD_Balance, 0), 2)) AS Anomaly_Score
    FROM Bank_Churn c
    CROSS JOIN Stats s
    WHERE Exited = 1
)
SELECT top 10 *
FROM Scored
ORDER BY Anomaly_Score DESC

--Compare churn across geographies vs. global average

----------------------------EXPLANATION------------------------------------------
-- Calculate churn rate for each region and the global churn rate
-- Measure variance of each region from the global average
-- Sort regions by deviation to find outliers in churn behavior
--------------------------------------------------------------------------------

WITH CountryChurn AS (
    SELECT Geography,
           COUNT(*) AS Total_Customers,
           SUM(Exited) AS Churned,
           ROUND(100.0 * SUM(Exited) * 1.0 / COUNT(*), 2) AS Churn_Rate
    FROM Bank_Churn
    GROUP BY Geography
),
GlobalChurn AS (
    SELECT 
        ROUND(100.0 * SUM(Exited) * 1.0 / COUNT(*), 2) AS Global_Churn_Rate
    FROM Bank_Churn
)
SELECT 
    cc.Geography,
    cc.Total_Customers,
    cc.Churn_Rate,
    gc.Global_Churn_Rate,
    ROUND(cc.Churn_Rate - gc.Global_Churn_Rate, 2) AS Variance_From_Global
FROM CountryChurn cc
JOIN GlobalChurn gc ON 1=1
ORDER BY Variance_From_Global DESC;


-- Churn behavior by tenure vs peer group 

----------------------------EXPLANATION------------------------------------------
-- Compute average churn rate for each tenure group
-- Compare individual churn behavior against group average
-- Classify customers as unexpected churn, sticky saver, or normal
--------------------------------------------------------------------------------

SELECT 
    c.CustomerId,
    c.Tenure,
    c.Balance,
    c.Exited,
    peer.Avg_Peer_Churn,
    CASE 
        WHEN c.Exited = 1 AND peer.Avg_Peer_Churn < 20 THEN 'Unexpected Churn'
        WHEN c.Exited = 0 AND peer.Avg_Peer_Churn > 40 THEN 'Sticky Saver'
        ELSE 'Normal'
    END AS Churn_Behavior
FROM Bank_Churn c
JOIN (
    SELECT 
        Tenure,
        ROUND(100.0 * SUM(Exited) * 1.0 / COUNT(*), 2) AS Avg_Peer_Churn
    FROM Bank_Churn
    GROUP BY Tenure
) AS peer
ON c.Tenure = peer.Tenure;
