-- 1. Категорії товарів
CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY IDENTITY(1,1),
    CategoryName NVARCHAR(100) NOT NULL UNIQUE
);

-- 2. Контрагенти (Постачальники та Покупці)
CREATE TABLE Counterparties (
    CPID INT PRIMARY KEY DEFAULT (NEXT VALUE FOR Seq_CounterpartyID),
    FullName NVARCHAR(200) NOT NULL,
    Address NVARCHAR(MAX),
    CPCategory NVARCHAR(50) CHECK (CPCategory IN ('Постачальник', 'Покупець')),
    DiscountPercent DECIMAL(5,2) DEFAULT 0
);

-- 3. Товари
CREATE TABLE Products (
    ProductID INT PRIMARY KEY DEFAULT (NEXT VALUE FOR Seq_ProdID),
    CategoryID INT FOREIGN KEY REFERENCES Categories(CategoryID),
    ProductName NVARCHAR(200) NOT NULL,
    Unit NVARCHAR(20) NOT NULL,           -- кг, шт, літри
    PurchasePrice MONEY NOT NULL,         -- ціна закупки
    SellingPrice MONEY NOT NULL,          -- ціна продажу
    StorageLifeDays INT CHECK (StorageLifeDays > 0)
);