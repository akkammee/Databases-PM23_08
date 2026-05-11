/* Лабораторна робота №2: Написання SQL-запитів
   Предметна область: Облік товарів
*/

USE ShopInventory;
GO

-- 1. SELECT з однієї таблиці, сортування та умови AND/OR
-- Знайти всі товари, де ціна продажу > 20 або термін придатності > 100 днів, сортувати за ціною
SELECT ProductName, SellingPrice, StorageLifeDays
FROM Products
WHERE SellingPrice > 20 OR StorageLifeDays > 100
ORDER BY SellingPrice DESC;

-- 2. SELECT з обчислюваним полем
-- Розрахунок прибутку з кожної одиниці товару (Назва, Ціна закупівлі, Ціна продажу, Прибуток)
SELECT 
    ProductName, 
    PurchasePrice, 
    SellingPrice, 
    (SellingPrice - PurchasePrice) AS ProfitPerUnit
FROM Products;

-- 3. SELECT на базі кількох таблиць (Inner Join) та умови
-- Вивести товари разом з назвами їхніх категорій для категорії 'Продовольчі товари'
SELECT p.ProductName, c.CategoryName, p.SellingPrice
FROM Products p
JOIN Categories c ON p.CategoryID = c.CategoryID
WHERE c.CategoryName = N'Продовольчі товари' AND p.SellingPrice > 0;

-- 4. SELECT з типом поєднання Outer Join
-- Вивести всі категорії та кількість товарів у них (навіть якщо товарів немає)
SELECT c.CategoryName, COUNT(p.ProductID) AS TotalProducts
FROM Categories c
LEFT OUTER JOIN Products p ON c.CategoryID = p.CategoryID
GROUP BY c.CategoryName;

-- 5. Використання операторів LIKE, BETWEEN, IN
-- Пошук товарів, де назва починається на 'М', ціна між 10 і 100, і одиниця виміру 'л' або 'шт'
SELECT * FROM Products
WHERE ProductName LIKE N'М%' 
  AND SellingPrice BETWEEN 10 AND 100 
  AND Unit IN (N'л', N'шт');

-- 6. Підсумовування та групування (Aggregate functions)
-- Загальна вартість усіх товарів на складі за ціною закупівлі для кожної категорії
SELECT CategoryID, SUM(PurchasePrice) AS CategoryTotalValue
FROM Products
GROUP BY CategoryID;

-- 7. UPDATE на базі однієї таблиці
-- Збільшити термін придатності на 10 днів для всіх товарів, де він менше 30
UPDATE Products
SET StorageLifeDays = StorageLifeDays + 10
WHERE StorageLifeDays < 30;

-- 8. DELETE вибраних записів
-- Видалити товари, назва яких містить слово 'Тест' (якщо такі створювались)
DELETE FROM Products 
WHERE ProductName LIKE N'%Тест%';

-- 9. Складний запит (Підзапит у частині WHERE)
-- Знайти товари, ціна яких вища за середню ціну по всій базі
SELECT ProductName, SellingPrice
FROM Products
WHERE SellingPrice > (SELECT AVG(SellingPrice) FROM Products);
