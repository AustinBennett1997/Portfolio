/*******************************

US Fictional Regional Sales Data

*******************************/

-- Checking each table for correct structure
SELECT *
FROM Regional_Sales..Sales_Order_Sheet -- check

SELECT *
FROM Regional_Sales..Customers_Sheet -- check

SELECT *
FROM Regional_Sales..Products_Sheet

SELECT *
FROM Regional_Sales..Regions_Sheet -- check

SELECT *
FROM Regional_Sales..Sales_Team_Sheet

SELECT *
FROM Regional_Sales..Store_Locations_Sheet -- check


-- Showing the total orders and total unit price per region per year
-- Will use this query to display in a stacked bar chart the total amount sold per region per year
SELECT sales.OrderDate, region.Region, SUM(sales.[Order Quantity]) AS TotalOrders, 
	   SUM(sales.[Unit Profit]) AS TotalProfit
FROM Regional_Sales..Sales_Order_Sheet sales
JOIN Regional_Sales..Store_Locations_Sheet store
ON sales._StoreID  = store._StoreID
JOIN Regional_Sales..Regions_Sheet region
ON region.StateCode = store.StateCode
GROUP BY OrderDate, Region
ORDER BY OrderDate, TotalOrders DESC


-- Query to display the top customers by date
-- Will use this query to show the top 5 customers filtered by total amount bought and date
SELECT sales.OrderDate, sales._CustomerID, customer.[Customer Names], 
	   SUM(sales.[Unit Profit]) AS TotalAmountBought
FROM Regional_Sales..Sales_Order_Sheet sales
JOIN Regional_Sales..Customers_Sheet customer
ON sales._CustomerID = customer._CustomerID
GROUP BY OrderDate, customer.[Customer Names], sales._CustomerID
ORDER BY TotalAmountBought DESC


-- Top performing products over time
-- Will use this query to in a ribbon chart to show the top products filtered by date
SELECT sales.OrderDate, prod.[Product Name], SUM(sales.[Order Quantity]) AS TotalQuantitySold
FROM Regional_Sales..Sales_Order_Sheet sales
JOIN Regional_Sales..Products_Sheet prod
ON sales._ProductID = prod._ProductID
GROUP BY [Product Name], sales.OrderDate
ORDER BY TotalQuantitySold DESC


-- Sales by Team
-- Will use this query in a bar chary to show the performing teams
SELECT sales.OrderDate, team.[Sales Team], SUM(sales.[Order Quantity]) AS TotalQuantity, 
	   SUM(sales.[Unit Profit]) AS TotalProfit
FROM Regional_Sales..Sales_Order_Sheet sales
JOIN Regional_Sales..Sales_Team_Sheet team
ON sales._SalesTeamID = team._SalesTeamID
GROUP BY [Sales Team], sales.OrderDate
ORDER BY TotalQuantity DESC


-- Sales by Channel
-- Will use this query in a pie chart to show the performing channels
SELECT OrderDate, [Sales Channel], SUM([Unit Profit]) AS TotalProfit
FROM Regional_Sales..Sales_Order_Sheet
GROUP BY OrderDate, [Sales Channel]
ORDER BY OrderDate, TotalProfit DESC


-- Seeing the total amount of warehouse for next query
SELECT COUNT(DISTINCT(WarehouseCode))
FROM Regional_Sales..Sales_Order_Sheet 
-- Shipping logistics
-- Will use this query to show the difference in shipping and processing times
SELECT OrderDate, WarehouseCode, DaysInProcess, DaysInTransit
FROM Regional_Sales..Sales_Order_Sheet
ORDER BY OrderDate


-- Sales By State
SELECT sales.OrderDate, CONCAT(store.[City Name], ', ', store.State) AS CityState, store._StoreID, store.Latitude, store.Longitude, sales.[Unit Profit]
FROM Regional_Sales..Store_Locations_Sheet store
JOIN Regional_Sales..Sales_Order_Sheet sales
ON store._StoreID = sales._StoreID
--
SELECT store.State, SUM(sales.[Unit Profit]) AS TotalProfit
FROM Regional_Sales..Store_Locations_Sheet store
JOIN Regional_Sales..Sales_Order_Sheet sales
ON store._StoreID = sales._StoreID
GROUP BY store.State
ORDER BY TotalProfit

