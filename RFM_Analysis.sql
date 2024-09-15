
Create database RFM_Data;

Use RFM_Data;


--- ALL columns overview
select * from INFORMATION_SCHEMA.COLUMNS;



---- Table details
select * from RFM_Table




--- Recency
SELECT customerid, 
       DATEDIFF(DAY,recent_purchase, GETDATE()) as days  
  FROM 
  (
  SELECT customerid, MAX(purchasedate) recent_purchase
      FROM rfm_table
  GROUP BY customerid
  )r


SELECT * , NTILE(5) Over(order by days desc) AS Category_Recency
 FROM
(
SELECT customerid, 
       DATEDIFF(DAY,recent_purchase, GETDATE()) as days  
  FROM 
  (
  SELECT customerid, MAX(purchasedate) recent_purchase
      FROM rfm_table
  GROUP BY customerid
  )r
)X;



---- Frequency 
SELECT customerid, COUNT(orderid) as no_of_orders 
     FROM rfm_table
  GROUP BY customerid
  ORDER BY no_of_orders desc;



SELECT * , dense_rank() Over(order by no_of_orders) AS Category_Frequency
 FROM
(
SELECT customerid, COUNT(orderid) as no_of_orders
     FROM rfm_table
  GROUP BY customerid
)Y;




----- Monetary 
SELECT customerid, Round(SUM(TransactionAmount),2) as total_value
     FROM rfm_table
  GROUP BY customerid
  ORDER BY total_value desc;



SELECT * , NTILE(5) Over(order by total_value) AS Category_Monetary
 FROM
(
SELECT customerid, Round(SUM(TransactionAmount),2) as total_value
     FROM rfm_table
  GROUP BY customerid
)Z;




----- RFM
SELECT * , NTILE(5) Over(order by days desc) AS Category_Recency
 FROM
(
SELECT customerid, 
       DATEDIFF(DAY,recent_purchase, GETDATE()) as days  
  FROM 
  (
  SELECT customerid, MAX(purchasedate) recent_purchase
      FROM rfm_table
  GROUP BY customerid
  )r
)X;



SELECT * , dense_rank() Over(order by no_of_orders) AS Category_Frequency
 FROM
(
SELECT customerid, COUNT(orderid) as no_of_orders
     FROM rfm_table
  GROUP BY customerid
)Y;



SELECT * , NTILE(5) Over(order by total_value) AS Category_Monetary
 FROM
(
SELECT customerid, Round(SUM(TransactionAmount),2) as total_value
     FROM rfm_table
  GROUP BY customerid
)Z;





----
with cte1 as 
(
SELECT * , NTILE(5) Over(order by days desc) AS Category_Recency
 FROM
(
SELECT customerid, 
       DATEDIFF(DAY,recent_purchase, GETDATE()) as days  
  FROM 
  (
  SELECT customerid, MAX(purchasedate) recent_purchase
      FROM rfm_table
  GROUP BY customerid
  )r
)X
),


cte2 as 
(
SELECT * , dense_rank() Over(order by no_of_orders) AS Category_Frequency
 FROM
(
SELECT customerid, COUNT(orderid) as no_of_orders
     FROM rfm_table
  GROUP BY customerid
)Y
),


cte3 as 
(
SELECT * , NTILE(5) Over(order by total_value) AS Category_Monetary
 FROM
(
SELECT customerid, Round(SUM(TransactionAmount),2) as total_value
     FROM rfm_table
  GROUP BY customerid
)Z
)


select c1.CustomerID, c1.days, c1.Category_Recency,
       c2.no_of_orders, c2.Category_Frequency,
	   c3.total_value, c3.Category_Monetary,
	   0.2*c1.Category_Recency+0.4*c2.Category_Frequency+0.4*c3.Category_Monetary as rfm_score
	   into #rfm
     from cte1 c1 inner join cte2 c2 on c1.CustomerID = c2.CustomerID
	              inner join cte3 c3 on c1.CustomerID = c3.CustomerID



select * from #rfm
order by rfm_score desc



