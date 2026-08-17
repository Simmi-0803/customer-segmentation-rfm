CREATE DATABASE retail_segmentation;
USE retail_segmentation;
CREATE TABLE retail (
    Invoice VARCHAR(20),
    StockCode VARCHAR(20),
    Description VARCHAR(255),
    Quantity INT,
    InvoiceDate DATETIME,
    Price DECIMAL(10,2),
    CustomerID INT,
    Country VARCHAR(100),
    is_cancellation VARCHAR(10),
    Revenue DECIMAL(12,2)
);
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/retail_clean.csv'
INTO TABLE retail
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Invoice, StockCode, Description, Quantity, InvoiceDate, Price, CustomerID, Country, is_cancellation, Revenue);
SELECT COUNT(*) FROM retail;
SHOW WARNINGS;
SELECT * FROM retail LIMIT 10;
SELECT MIN(InvoiceDate), MAX(InvoiceDate) FROM retail;
SELECT COUNT(DISTINCT CustomerID) FROM retail;
WITH reference AS (
    SELECT DATE_ADD(MAX(InvoiceDate), INTERVAL 1 DAY) AS ref_date
    FROM retail
)
SELECT
    r.CustomerID,
    DATEDIFF((SELECT ref_date FROM reference), MAX(r.InvoiceDate)) AS Recency,
    COUNT(DISTINCT r.Invoice) AS Frequency,
    ROUND(SUM(r.Revenue), 2) AS Monetary
FROM retail r
GROUP BY r.CustomerID
ORDER BY Monetary DESC
LIMIT 20;
CREATE TABLE rfm AS
WITH reference AS (
    SELECT DATE_ADD(MAX(InvoiceDate), INTERVAL 1 DAY) AS ref_date
    FROM retail
)
SELECT
    r.CustomerID,
    DATEDIFF((SELECT ref_date FROM reference), MAX(r.InvoiceDate)) AS Recency,
    COUNT(DISTINCT r.Invoice) AS Frequency,
    ROUND(SUM(r.Revenue), 2) AS Monetary
FROM retail r
GROUP BY r.CustomerID;
SELECT COUNT(*) FROM rfm;
SELECT COUNT(*) FROM rfm WHERE Monetary <= 0;
SELECT 
    MIN(Recency) AS min_r, MAX(Recency) AS max_r, ROUND(AVG(Recency),1) AS avg_r,
    MIN(Frequency) AS min_f, MAX(Frequency) AS max_f, ROUND(AVG(Frequency),1) AS avg_f,
    MIN(Monetary) AS min_m, MAX(Monetary) AS max_m, ROUND(AVG(Monetary),2) AS avg_m
FROM rfm;