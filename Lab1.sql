/* Лабораторна робота №1
   Предметна область: Облік товарів (Варіант №8)
   Виконав: [Твоє Прізвище]
*/

-- 1. Створення бази даних
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'ShopInventory')
BEGIN
    CREATE DATABASE ShopInventory;
END
GO

USE ShopInventory;
GO

-- 2. Створення послідовностей (SEQUENCES) для сурогатних ключів
-- Це вимога пункту 2 завдання (використання SEQUENCE)
CREATE SEQUENCE Seq_CounterpartyID START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE Seq_ProdID START WITH 1 INCREMENT BY 1;
GO

-- 3. Створення таблиць з обмеженнями цілісності

-- Таблиця категорій (Довідник)
CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY IDENTITY(1,1), -- Приклад IDENTITY
    CategoryName NVARCHAR(100) NOT NULL UNIQUE -- Унікальність назви
);

-- Таблиця контрагентів (Постачальники та Покупці)
CREATE TABLE Counterparties (
    CPID INT PRIMARY KEY DEFAULT (NEXT VALUE FOR Seq_CounterpartyID), -- Використання SEQUENCE
    FullName NVARCHAR(200) NOT NULL,
    Address NVARCHAR(MAX),
    -- Обмеження CHECK для перевірки допустимих значень
    CPCategory NVARCHAR(50) CHECK (CPCategory IN (N'Постачальник', N'Покупець')),
    DiscountPercent DECIMAL(5,2) DEFAULT 0
);

-- Таблиця товарів
CREATE TABLE Products (
    ProductID INT PRIMARY KEY DEFAULT (NEXT VALUE FOR Seq_ProdID), -- Використання SEQUENCE
    CategoryID INT NOT NULL,
    ProductName NVARCHAR(200) NOT NULL,
    Unit NVARCHAR(20) NOT NULL, -- одиниці виміру (кг, шт, л)
    PurchasePrice MONEY NOT NULL CHECK (PurchasePrice >= 0), -- Валідація ціни
    SellingPrice MONEY NOT NULL CHECK (SellingPrice > 0),    -- Продажна ціна має бути > 0
    StorageLifeDays INT CHECK (StorageLifeDays > 0),         -- Термін придатності
    
    -- Зовнішній ключ (Foreign Key) для зв'язку з категоріями
    CONSTRAINT FK_Products_Categories FOREIGN KEY (CategoryID) 
    REFERENCES Categories(CategoryID) ON DELETE CASCADE
);
GO

-- 4. Наповнення даними (DML операції)
-- Це вимога пункту 3 завдання (введення записів)

-- Додаємо категорії
INSERT INTO Categories (CategoryName) VALUES (N'Продовольчі товари'), (N'Побутова хімія'), (N'Напої');

-- Додаємо контрагентів
INSERT INTO Counterparties (FullName, CPCategory, DiscountPercent) 
VALUES (N'ТОВ "Свіжість"', N'Постачальник', 5.0),
       (N'ПП "Кошик"', N'Покупець', 0.0);

-- Додаємо товари (зв'язуємо з категоріями)
INSERT INTO Products (CategoryID, ProductName, Unit, PurchasePrice, SellingPrice, StorageLifeDays)
VALUES (1, N'Хліб білий', N'шт', 12.00, 18.50, 3),
       (1, N'Молоко 2.5%', N'л', 25.00, 34.00, 7),
       (2, N'Мило рідке', N'шт', 45.00, 68.00, 365),
       (3, N'Вода мінеральна', N'л', 8.50, 15.00, 180);
GO

-- 5. Перевірка цілісності (запити для звіту)
SELECT * FROM Categories;
SELECT * FROM Counterparties;
SELECT * FROM Products;
