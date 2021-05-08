--create a stored procedure that inserts data in tables that are in a m:n relationship; if an insert fails, try to recover as much as possible from the entire operation:
--for example, if the user wants to add a book and its authors, succeeds creating the authors, but fails with the book, the authors should remain in the database
GO
CREATE OR ALTER PROCEDURE usp_InsertClientsProductRecordRollbackFailed
	-- the first three parameters will insert into clients and the last two in product
	(@age INT = 0,
	@first_name VARCHAR(50) = NULL,
	@last_name VARCHAR(50) = NULL,
	@product_name VARCHAR(50) = NULL,
	@price INT = 0)
AS
BEGIN
	-- Step 1: Validation
	-- check for null or 0
	IF (ISNULL(@age,0) = 0)
	BEGIN
		RAISERROR('@age cannot be null or 0',18,0)
		RETURN
	END
	IF (ISNULL(@price,0) = 0)
	BEGIN
		RAISERROR('@price cannot be null or 0',18,0)
		RETURN
	END

	-- check for null or ''
	IF (ISNULL(@first_name,'') = '')
	BEGIN
		RAISERROR('@first_name cannot be null or empty',18,0)
		RETURN
	END
	IF (ISNULL(@last_name,'') = '')
	BEGIN
		RAISERROR('@last_name cannot be null or empty',18,0)
		RETURN
	END
	IF (ISNULL(@product_name,'') = '')
	BEGIN
		RAISERROR('@product_name cannot be null or empty',18,0)
		RETURN
	END




	-- Step 2: Enable Ole Automation Procedures (we need this to be able to log the result to a file)
	EXEC sp_configure 'show advanced options', 1;
	RECONFIGURE;
	EXEC sp_configure 'Ole Automation Procedures', 1;
	RECONFIGURE;

	-- varialbe declarations
	DECLARE @path varchar(200);DECLARE @errorMessage varchar(200); DECLARE @errorMessage2 varchar(200); DECLARE @clientInserted varchar(200); DECLARE @productInserted varchar(200);
	SET @path='C:\Users\Tudor\Desktop\D\faculta\SemIV\DB\Labs\Asignment3\logFiles\logTask2.txt';
	SET @clientInserted = 'client for insert: ' + CAST(@age AS VARCHAR) + ',' + @first_name + ',' + @last_name;
	SET @productInserted = 'product for inser: ' + @product_name + ',' + CAST(@price AS VARCHAR);



	-- Step 3: Log to file and try insert
	EXEC usp_WriteToFile @FilePath=@path,@Text='Begin Test{';
	EXEC usp_WriteToFile @FilePath=@path,@Text=@clientInserted;		-- log the client
	EXEC usp_WriteToFile @FilePath=@path,@Text=@productInserted;	-- log the product
	BEGIN TRANSACTION;

	BEGIN TRY
		-- try to insert the client
		EXEC usp_InsertClientsRecord @age=@age,@first_name=@first_name,@last_name=@last_name;
	END TRY
	BEGIN CATCH
		-- try to insert product
		BEGIN TRY
			SET @errorMessage2=ERROR_MESSAGE();
			EXEC usp_InsertProductRecord @product_name=@product_name,@price=@price;
			EXEC usp_WriteToFile @FilePath=@path,@Text='Only product insert passed';
			SET @errorMessage=ERROR_MESSAGE();
			EXEC usp_WriteToFile @FilePath=@path,@Text=@errorMessage;
			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			-- both client and product insert fail
			EXEC usp_WriteToFile @FilePath=@path,@Text='Both inserts failed';
			SET @errorMessage=ERROR_MESSAGE();
			EXEC usp_WriteToFile @FilePath=@path,@Text=@errorMessage2;
			EXEC usp_WriteToFile @FilePath=@path,@Text=@errorMessage;
			ROLLBACK TRANSACTION;
		END CATCH
	END CATCH
		
	-- if there is an active transaction left, it means that client insert succeeded
	IF @@TRANCOUNT > 0
		BEGIN TRY
			-- try to insert product
			EXEC usp_InsertProductRecord @product_name=@product_name,@price=@price;
			EXEC usp_WriteToFile @FilePath=@path,@Text='Both inserts passed';
			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			-- product insert fails
			EXEC usp_WriteToFile @FilePath=@path,@Text='Only client inserts passed';
			SET @errorMessage=ERROR_MESSAGE();
			EXEC usp_WriteToFile @FilePath=@path,@Text=@errorMessage;
			COMMIT TRANSACTION
		END CATCH
		
	EXEC usp_WriteToFile @FilePath=@path,@Text='}End Test';

	-- Step 4: Disable Ole Automation Procedures
	EXEC sp_configure 'show advanced options', 1;
	RECONFIGURE;
	EXEC sp_configure 'Ole Automation Procedures', 0;
	RECONFIGURE;
END


-- TEST CASE
--Validation Error
EXEC usp_InsertClientsProductRecordRollbackFailed @age=22,@first_name='a',@last_name='b',@product_name='',@price=5;
--Both Pass
EXEC usp_InsertClientsProductRecordRollbackFailed @age=22,@first_name='a',@last_name='b',@product_name='a',@price=5;
SELECT * FROM clients;
SELECT * FROM product;
--Client Fails
EXEC usp_InsertClientsProductRecordRollbackFailed @age=22,@first_name='a',@last_name='b',@product_name='a',@price=5;
SELECT * FROM clients;
SELECT * FROM product;
--Product Fails
EXEC usp_InsertClientsProductRecordRollbackFailed @age=67,@first_name='a',@last_name='b',@product_name='a',@price=-1;
SELECT * FROM clients;
SELECT * FROM product;
--BothFail
EXEC usp_InsertClientsProductRecordRollbackFailed @age=67,@first_name='a',@last_name='b',@product_name='a',@price=-1;
SELECT * FROM clients;
SELECT * FROM product;

delete from product where product_name='a';
delete from clients where age=22 OR age=67