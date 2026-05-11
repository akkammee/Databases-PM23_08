USE ShopInventory;
GO

-- 1. ????????? ????????? ??????????
CREATE OR ALTER PROCEDURE sp_CalculatePaymentForBuyer
    @BuyerID INT,
    @Month INT,
    @Year INT,
    @TotalPayment MONEY OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT @TotalPayment = SUM(TotalAmount)
    FROM Sales
    WHERE CPID = @BuyerID 
      AND MONTH(SaleDate) = @Month 
      AND YEAR(SaleDate) = @Year;
    IF @TotalPayment IS NULL SET @TotalPayment = 0;
END;
GO

-- 2. ????????? ???????? ????????? (?????? ??? ????)
CREATE OR ALTER PROCEDURE sp_CalculateAllBuyersMonthly
    @Month INT,
    @Year INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @CurrentBuyerID INT;
    DECLARE @BuyerName NVARCHAR(200);
    DECLARE @CalculatedSum MONEY;

    DECLARE buyer_cursor CURSOR FOR 
    SELECT CPID, FullName FROM Counterparties;

    OPEN buyer_cursor;
    FETCH NEXT FROM buyer_cursor INTO @CurrentBuyerID, @BuyerName;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC sp_CalculatePaymentForBuyer 
            @BuyerID = @CurrentBuyerID, 
            @Month = @Month, 
            @Year = @Year, 
            @TotalPayment = @CalculatedSum OUTPUT;
        
        PRINT N'????????: ' + @BuyerName + N' | ?????????? ????: ' + CAST(@CalculatedSum AS NVARCHAR(20)) + N' ???';
        
        FETCH NEXT FROM buyer_cursor INTO @CurrentBuyerID, @BuyerName;
    END;

    CLOSE buyer_cursor;
    DEALLOCATE buyer_cursor;
END;
GO
-- ?????? ??? ?????? 2026 ????
EXEC sp_CalculateAllBuyersMonthly 5, 2026;
