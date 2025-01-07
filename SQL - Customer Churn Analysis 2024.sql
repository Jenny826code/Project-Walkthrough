/* Customer Churn Analysis */

--Query 1: Monthly Churn Rate with Customer Retention Trend
WITH customer_activity AS (
    SELECT 
        customer_id,
        DATE_TRUNC('month', last_active_date) AS last_active_month,
        churn_status
    FROM customers
)
SELECT 
    last_active_month,
    COUNT(CASE WHEN churn_status = 'Yes' THEN 1 END) * 100.0 / COUNT(*) AS churn_rate,
    COUNT(CASE WHEN churn_status = 'No' THEN 1 END) * 100.0 / COUNT(*) AS retention_rate
FROM 
    customer_activity
GROUP BY 
    last_active_month
ORDER BY 
    last_active_month;

--Query 2: Churn Probability by Activity Metrics
WITH customer_metrics AS (
    SELECT 
        c.customer_id,
        COUNT(DISTINCT t.transaction_id) AS total_transactions,
        COUNT(DISTINCT s.ticket_id) AS unresolved_tickets,
        DATEDIFF('day', c.signup_date, c.last_active_date) AS days_active,
        c.churn_status
    FROM 
        customers c
    LEFT JOIN 
        transactions t ON c.customer_id = t.customer_id
    LEFT JOIN 
        support_tickets s ON c.customer_id = s.customer_id AND s.resolution_time IS NULL
    GROUP BY 
        c.customer_id, c.signup_date, c.last_active_date, c.churn_status
)
SELECT 
    churn_status,
    AVG(total_transactions) AS avg_transactions,
    AVG(unresolved_tickets) AS avg_unresolved_tickets,
    AVG(days_active) AS avg_days_active
FROM 
    customer_metrics
GROUP BY 
    churn_status;

--Query 3: Segmenting Customers with Churn Likelihood
WITH customer_segments AS (
    SELECT 
        customer_id,
        CASE 
            WHEN COUNT(transaction_id) >= 10 THEN 'High Activity'
            WHEN COUNT(transaction_id) BETWEEN 5 AND 9 THEN 'Medium Activity'
            ELSE 'Low Activity'
        END AS activity_level,
        AVG(amount) AS avg_transaction_amount,
        churn_status
    FROM 
        transactions
    JOIN 
        customers ON transactions.customer_id = customers.customer_id
    GROUP BY 
        customer_id, churn_status
)
SELECT 
    activity_level,
    AVG(avg_transaction_amount) AS avg_amount,
    COUNT(CASE WHEN churn_status = 'Yes' THEN 1 END) * 100.0 / COUNT(*) AS churn_rate
FROM 
    customer_segments
GROUP BY 
    activity_level;
