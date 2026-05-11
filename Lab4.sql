/* ЛАБОРАТОРНА РОБОТА №4
   Тема: Створення тригерів у СУБД
   Варіант: №8 (Контроль залишків та аудит)
*/

USE ShopInventory;
GO

-----------------------------------------------------------
-- 1. ПІДГОТОВКА ТАБЛИЦЬ ТА ВИПРАВЛЕННЯ NULL
-----------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Products') AND name = 'UCR')
BEGIN
    ALTER TABLE Products ADD 
        UCR NVARCHAR(100) DEFAULT SUSER_NAME(), 
        DCR DATETIME DEFAULT GETDATE(),        
        ULC NVARCHAR(100),                     
        DLC DATETIME,                          
        StockQuantity INT DEFAULT 100; 
END
GO

-- Наводимо порядок у даних (замість NULL ставимо реальні значення)
UPDATE Products SET StockQuantity = 100 WHERE StockQuantity IS NULL;
UPDATE Products SET UCR = SUSER_NAME(), DCR = GETDATE() WHERE UCR IS NULL;
GO

-----------------------------------------------------------
-- 2. ТРИГЕР АУДИТУ (БЕЗ РЕКУРСІЇ)
-----------------------------------------------------------
CREATE OR ALTER TRIGGER tr_Products_UpdateAudit
ON Products
AFTER UPDATE
AS
BEGIN
    -- КРИТИЧНО: Перевірка рівня вкладеності. 
    -- Якщо тригер викликаний іншим тригером (або самим собою), зупиняємо роботу.
    IF (TRIGGER_NESTLEVEL() > 1) RETURN;

    SET NOCOUNT ON;
    
    UPDATE Products
    SET ULC = SUSER_NAME(), 
        DLC = GETDATE()
    FROM Products p
    INNER JOIN inserted i ON p.ProductID = i.ProductID;
END;
GO

-----------------------------------------------------------
-- 3. ТРИГЕР ВАРІАНТУ №8 (КОНТРОЛЬ ЗАЛИШКІВ)
-----------------------------------------------------------
CREATE OR ALTER TRIGGER tr_Sales_CheckStockAndAutoReduce
ON Sales
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Перевірка, чи не продаємо ми більше, ніж є
    IF EXISTS (
        SELECT 1 FROM Products p
        INNER JOIN inserted i ON p.ProductID = i.ProductID
        WHERE p.StockQuantity < i.Quantity
    )
    BEGIN
        RAISERROR (N'ПОМИЛКА: Недостатньо товару на складі!', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- Автоматичне зменшення залишку після продажу
    UPDATE p
    SET p.StockQuantity = p.StockQuantity - i.Quantity
    FROM Products p
    INNER JOIN inserted i ON p.ProductID = i.ProductID;
END;
GO

-----------------------------------------------------------
-- ТЕПЕР ПЕРЕВІРКА БУДЕ ПРАЦЮВАТИ БЕЗ ПОМИЛОК
-----------------------------------------------------------
SELECT ProductID, ProductName, UCR, DCR, ULC, DLC, StockQuantity FROM Products;