CREATE TABLE dbo.SalesData
(
    CustomerID     int             NOT NULL,
    [Name]          nvarchar(100)   NOT NULL,
    Age             tinyint         NULL,
    City            nvarchar(100)   NULL,
    PurchaseAmount  decimal(18, 2)   NOT NULL,
    PurchaseDate    date            NOT NULL
);

;WITH Numbers AS
(
    SELECT TOP (10000)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS CustomerID
    FROM sys.all_objects AS a
    CROSS JOIN sys.all_objects AS b
)
INSERT INTO dbo.SalesData
(
    CustomerID,
    [Name],
    Age,
    City,
    PurchaseAmount,
    PurchaseDate
)
SELECT
    n.CustomerID,
    v.[Name],
    CONVERT(tinyint, 18 + (ABS(CONVERT(bigint, CHECKSUM(NEWID()))) % 63)),
    c.City,
    CONVERT(decimal(18, 2),
        10.00 + (ABS(CONVERT(bigint, CHECKSUM(NEWID()))) % 499001) / 100.0),
    DATEADD
    (
        day,
        -(ABS(CONVERT(bigint, CHECKSUM(NEWID()))) % 1826),
        CONVERT(date, GETDATE())
    )
FROM Numbers AS n
CROSS APPLY
(
    SELECT TOP (1) [Name]
    FROM (VALUES
        (N'Ava'), (N'Liam'), (N'Emma'), (N'Noah'),
        (N'Olivia'), (N'James'), (N'Sophia'), (N'William')
    ) AS Names([Name])
    ORDER BY NEWID()
) AS v
CROSS APPLY
(
    SELECT TOP (1) City
    FROM (VALUES
        (N'New York'), (N'Chicago'), (N'Dallas'), (N'Seattle'),
        (N'Austin'), (N'Boston'), (N'Denver'), (N'Atlanta')
    ) AS Cities(City)
    ORDER BY NEWID()
) AS c;



---TOTAL SALES PER CITY---
SELECT
    City,
    SUM(PurchaseAmount) AS TotalSales
FROM dbo.SalesData
GROUP BY City
ORDER BY TotalSales DESC;


---TOP 5 CITIES BY REVANUE---
SELECT TOP (5)
    City,
    SUM(PurchaseAmount) AS TotalRevenue
FROM dbo.SalesData
GROUP BY City
ORDER BY TotalRevenue DESC;

---customers with purchases above average---
SELECT
    CustomerID,
    [Name],
    Age,
    City,
    PurchaseAmount,
    PurchaseDate
FROM dbo.SalesData
WHERE PurchaseAmount >
(
    SELECT AVG(PurchaseAmount)
    FROM dbo.SalesData
)
ORDER BY PurchaseAmount DESC;