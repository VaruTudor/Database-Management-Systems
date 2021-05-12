
-------------------------------------------------
-- this proceduce is used to insert a record into the clients table
SELECT * FROM clients

GO
CREATE OR ALTER PROCEDURE usp_InsertClientsRecord
	(@age INT,
	@first_name VARCHAR(50),
	@last_name VARCHAR(50))
AS
BEGIN
	INSERT INTO clients (age,first_name,last_name)
	VALUES (@age, @first_name, @last_name)
END

--EXEC usp_InsertClientsRecord @age=22,@first_name='a',@last_name='b';
--delete from clients where age=22


-------------------------------------------------
-- this proceduce is used to insert a record into the product table
SELECT * FROM product

GO
CREATE OR ALTER PROCEDURE usp_InsertProductRecord
	(@product_name VARCHAR(50),
	@price INT)
AS
BEGIN
	INSERT INTO product(product_name,price)
	VALUES (@product_name, @price)
END

--EXEC usp_InsertProductRecord @product_name='a',@price=5;
--delete from product where product_name='a';


-------------------------------------------------------------------
--create a stored procedure that inserts data in tables that are in a m:n relationship; 
--if one insert fails, all the operations performed by the procedure must be rolled back
GO
CREATE OR ALTER PROCEDURE usp_InsertClientsProductRecordRollbackAll
	-- the first three parameters will insert into clients and the last two in product
	(@age INT,
	@first_name VARCHAR(50),
	@last_name VARCHAR(50),
	@product_name VARCHAR(50),
	@price INT)
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
	DECLARE @path varchar(200);DECLARE @errorMessage varchar(200); DECLARE @clientInserted varchar(200); DECLARE @productInserted varchar(200);
	SET @path='C:\Users\Tudor\Desktop\D\faculta\SemIV\DB\Labs\Lab03_concurrency_issues\logFiles\logTask1.txt';
	SET @clientInserted = 'client for insert: ' + CAST(@age AS VARCHAR) + ',' + @first_name + ',' + @last_name;
	SET @productInserted = 'product for inser: ' + @product_name + ',' + CAST(@price AS VARCHAR);



	-- Step 3: Log to file and try insert
	EXEC usp_WriteToFile @FilePath=@path,@Text='Begin Test{';
	BEGIN TRANSACTION;

	BEGIN TRY
		-- we try both inserts and log
		EXEC usp_WriteToFile @FilePath=@path,@Text=@clientInserted;		-- log the client
		EXEC usp_InsertClientsRecord @age=@age,@first_name=@first_name,@last_name=@last_name;
		EXEC usp_WriteToFile @FilePath=@path,@Text=@productInserted;	-- log the product
		EXEC usp_InsertProductRecord @product_name=@product_name,@price=@price;
		EXEC usp_WriteToFile @FilePath=@path,@Text='Both inserts passed';
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		-- at least one fails, we log and rollback
		EXEC usp_WriteToFile @FilePath=@path,@Text='At least one insert failed';
		SET @errorMessage=ERROR_MESSAGE();
		EXEC usp_WriteToFile @FilePath=@path,@Text=@errorMessage;
		ROLLBACK TRANSACTION;
	END CATCH
	EXEC usp_WriteToFile @FilePath=@path,@Text='}End Test';

	-- Step 4: Disable Ole Automation Procedures
	EXEC sp_configure 'show advanced options', 1;
	RECONFIGURE;
	EXEC sp_configure 'Ole Automation Procedures', 0;
	RECONFIGURE;
END

EXEC usp_InsertClientsProductRecordRollbackAll @age=22,@first_name='a',@last_name='b',@product_name='a',@price=5;
EXEC usp_InsertClientsProductRecordRollbackAll @age=22,@first_name='a',@last_name='b',@product_name='a',@price=5;
delete from product where product_name='a';
delete from clients where age=22