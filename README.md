# Bank Churn Analysis Project

A comprehensive SQL-based analysis of customer churn behavior using the Bank Churn dataset. This project explores the patterns, trends, and risk segments that influence customer retention and defection using structured queries and statistical techniques.

---

## Objective

To identify key customer attributes influencing churn, evaluate churn rates across demographics and behaviors, and surface high-risk customers to guide strategic interventions.

---

##  Dataset

**Table Name:** `Bank_Churn`  
**Key Columns:**  
- `CustomerId`, `Surname`, `CreditScore`, `Geography`, `Gender`, `Age`, `Tenure`, `Balance`, `NumOfProducts`, `HasCrCard`, `IsActiveMember`, `EstimatedSalary`, `Exited`

---

## Key Analysis Performed

### 1. **Calculate Overall Churn Rate**
- Counts total customers and churned ones.
- Computes churn rate (%) for the entire dataset.

### 2. **Churn Rate by Gender**
- Segments churn behavior by gender.
- Evaluates gender-based differences in customer retention.

### 3. **Impact of Credit Card Ownership on Churn**
- Groups customers by `HasCrCard`.
- Checks if credit card holders are more/less likely to churn.

### 4. **Compare Bank Balance Statistics Between Churned and Retained**
- Compares avg, min, max balances between churned and retained customers.

### 5. **Compare Churn Rates for Active vs Inactive Members**
- Groups by `IsActiveMember`.
- Determines how customer engagement affects churn.

### 6. **Top 5 Customers with Highest Estimated Salary in Each Geography**
- Uses `ROW_NUMBER()` to rank top 5 earners per region.

### 7. **Churn Rate by Number of Products**
- Analyzes if more products = higher or lower churn risk.

### 8. **Top 3 Customers with Highest Balance in Each Geography**
- Uses `RANK()` to identify top savers in each country.

### 9. **Churn Rate by Credit Score Bucket**
- Buckets customers into score bands (Very Low to High).
- Examines churn per segment.

### 10. **Churn by Age Group Cohorts**
- Categorizes into age brackets (18–30, etc.).
- Calculates churn % and prioritizes high-risk age groups.

### 11. **Build Lifetime Value (LTV) Estimate**
- Estimates LTV = Balance × Tenure.
- Buckets into 5 percentile bands and calculates churn.

### 12. **Lookalike Customers to Churners**
- Finds non-churned customers with same profile as churned ones.

### 13. **Cumulative Churn Tracking Over Tenure**
- Tracks how churn accumulates as tenure increases.

### 14. **Tiered Loyalty Classification**
- Classifies customers by balance and tenure.
- Calculates churn risk for each loyalty tier.

### 15. **Churn Anomaly Score Using Z-Scores**
- Uses z-scores on age and balance to find abnormal churners.

### 16. **Compare Churn Across Geographies vs Global Average**
- Measures regional deviation from global churn rate.

### 17. **Churn Behavior by Tenure vs Peer Group**
- Classifies churners as "sticky savers", "unexpected churn", or "normal".

---

## Insights and Applications

- Identify target groups for churn prevention campaigns.
- Develop personalized retention strategies for high LTV customers.
- Optimize geographic resource allocation based on churn risk.
- Apply anomaly detection to uncover unexpected behavior.

