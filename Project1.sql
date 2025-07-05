--PART 1 (Maintaing Data)

-- View data in Customer table
SELECT * FROM Customer;

-- Insert new grape flavor product into table
INSERT INTO Product (
  ProductID, 
  ProductCode,
  ProductName,
  Size,
  Variety,
  Price,
  Status
)
Values (
  17,
  'MWPRA20',
  'Mineral Water',
  20,
  'Grape',
  '1.79',
  'ACTIVE'
)

-- Sort Orders table
SELECT * FROM Orders
ORDER BY CreationDate DESC;

-- Find null values in Customer table
SELECT * FROM Customer
WHERE FirstName IS NULL OR
LastName IS NULL OR 
Email IS NULL OR
Phone IS NULL;

-- Remove null values from customer table
SELECT FirstName,
  LastName,
  Email,
  Phone
  FROM Customer 
  WHERE Email IS NOT NULL AND 
  Phone IS NOT NULL;

  -- Insert new customer into Customer table
INSERT INTO Customer (
  CustomerID,
  FirstName,
  LastName,
  Email,
  Phone,
  Address,
  City,
  State,
  Zipcode
)
VALUES (
  1100,
  "Jane",
  "Paterson",
  "jane.paterson@gmail.com",
  "(912)459-2910",
  "4029 Park Street",
  "Kansas City",
  "MO",
  "64161"
)

--PART 2 (Exploring Sales Data)

-- Find how many products sold
SELECT
COUNT (DISTINCT ProductID) as TotalUniqueProducts,
SUM(Quantity) as TotalQuantity
From OrderItem 

-- Determine which items are discontinued
SELECT *
FROM Product
WHERE STATUS = 'Discontinued'

-- Determine which sales people made no sales
SELECT
Salesperson.SalespersonID,
FirstName,
LastName
FROM Salesperson
LEFT OUTER JOIN Orders
ON Salesperson.SalespersonID=
Orders.SalespersonID
WHERE Orders.SalespersonID IS NULL;

-- Find top product size sold
SELECT Size,
SUM(Quantity) as TotalQuantity
FROM OrderItem
LEFT OUTER JOIN Product
ON OrderItem.ProductID = Product.ProductID
GROUP BY Size
ORDER BY TotalQuantity DESC

-- Find top 3 items sold
SELECT Variety, 
Size,
SUM(Quantity) as TotalQuantity
From OrderItem
LEFT OUTER JOIN Product
ON OrderItem.ProductID = Product.ProductID
Group By Product.ProductID
ORDER BY TotalQuantity DESC
Limit 3

-- Find sales by month and year
SELECT 
MONTHNAME (CreationDate) as MonthName,
Year (CreationDate) as OrderYear,
Count (Orders.OrderID) as TotalOrders, 
SUM (TotalDue) as TotalAmount
FROM Orders
LEFT OUTER JOIN OrderItem
ON Orders.OrderID = OrderItem.OrderID
Group By MonthName, OrderYear
ORDER BY OrderYear, MONTH(CreationDate)

-- Find average daily sales
SELECT 
SUM(Quantity) /
COUNT(DISTINCT CreationDate) as AverageDailySales
FROM Orders
LEFT OUTER JOIN OrderItem
ON Orders.OrderID = OrderItem.OrderID;

--PART 3 (Exploring Customer Data)

-- Find top customers
Select 
FirstName, 
LastName, 
COUNT (Distinct Orders.OrderID) as TotalOrders,
SUM (Quantity) as TotalQuantity,
SUM (TotalDue) as TotalAmount
FROM Orders
LEFT OUTER JOIN OrderItem 
ON Orders.OrderID = OrderItem.OrderID
LEFT OUTER JOIN Customer
ON Orders.CustomerID = Customer.CustomerID
GROUP BY Customer.CustomerID
ORDER BY TotalAmount DESC

-- Find infrequent customers
SELECT Customer.CustomerID,
  FirstName,
  LastName,
  COUNT(Distinct OrderID) as TotalOrders
FROM Orders
LEFT OUTER JOIN Customer
ON Orders.CustomerID = Customer.CustomerID
GROUP BY Orders.CustomerID
HAVING COUNT(Distinct OrderID)=1

-- Determine top customer state
SELECT 
State,
Sum (TotalDue) as TotalSold
FROM Orders
LEFT OUTER JOIN OrderItem 
ON Orders.OrderID = OrderItem.OrderID
LEFT OUTER JOIN Customer
ON Orders.CustomerID = Customer.CustomerID
Group BY State
ORDER BY TotalSold DESC
Limit 1

-- Determine what products sold together
SELECT a.ProductID as ProductID1,
  b.ProductID as ProductID2,
  COUNT (*) as TimesPurchased
FROM OrderItem as a
INNER JOIN OrderItem b
On a.OrderID = b.OrderID
AND a.ProductID < b.ProductID
GROUP BY a.ProductID, b.ProductID
Order BY TimesPurchased DESC

-- Determine new customers
SELECT
FirstName,
LastName,
COUNT (DISTINCT OrderID) as TotalOrders
FROM Customer
LEFT OUTER JOIN Orders
ON Customer.CustomerID = Orders.CustomerID
GROUP BY Customer.CustomerID
HAVING TotalOrders = 0
