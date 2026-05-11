/* ЛАБОРАТОРНА РОБОТА №5
   Тема: Адміністрування БД (Користувачі, Ролі, Привілеї)
*/

USE ShopInventory;
GO

-----------------------------------------------------------
-- 1. СТВОРЕННЯ КОРИСТУВАЧІВ (Пункти 1-2)
-----------------------------------------------------------
-- Створюємо логіни для сервера
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'ManagerUser')
    CREATE LOGIN ManagerUser WITH PASSWORD = 'Password123!';
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'CashierUser')
    CREATE LOGIN CashierUser WITH PASSWORD = 'Password123!';

-- Створюємо користувачів у самій базі ShopInventory
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'ManagerUser')
    CREATE USER ManagerUser FOR LOGIN ManagerUser;
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'CashierUser')
    CREATE USER CashierUser FOR LOGIN CashierUser;
GO

-----------------------------------------------------------
-- 2. СТВОРЕННЯ РОЛЕЙ (Пункти 3-4)
-----------------------------------------------------------
-- Роль для повного керування товарами
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'InventoryManagerRole' AND type = 'R')
    CREATE ROLE InventoryManagerRole;

-- Надаємо привілеї ролі (SELECT, INSERT, UPDATE, DELETE на товари)
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Products TO InventoryManagerRole;
GRANT SELECT ON dbo.Categories TO InventoryManagerRole;
GO

-----------------------------------------------------------
-- 3. ПРИЗНАЧЕННЯ РОЛЕЙ ТА ПРИВІЛЕЇВ (Пункти 5-7)
-----------------------------------------------------------
-- Призначаємо роль користувачу ManagerUser
ALTER ROLE InventoryManagerRole ADD MEMBER ManagerUser;

-- Надаємо персональний привілей Касиру (тільки перегляд та додавання продажів)
GRANT SELECT, INSERT ON dbo.Sales TO CashierUser;
GRANT SELECT ON dbo.Products TO CashierUser;

-- Перевірка збереження здатності (демонстрація відкликання):
-- Відкликаємо привілей, який був наданий персонально
REVOKE INSERT ON dbo.Sales FROM CashierUser;

-- Відкликаємо роль у менеджера (пункт 7 методички)
ALTER ROLE InventoryManagerRole DROP MEMBER ManagerUser;
GO

-----------------------------------------------------------
-- 4. ВИДАЛЕННЯ (Пункт 8)
-----------------------------------------------------------
-- Спочатку видаляємо користувачів з бази, потім роль
/* DROP USER CashierUser;
DROP USER ManagerUser;
DROP ROLE InventoryManagerRole;
*/

-- Контрольний запит для звіту (показує список користувачів у базі)
SELECT name as [Database_User], type_desc 
FROM sys.database_principals 
WHERE type IN ('S', 'U', 'R') AND name NOT LIKE '##%';