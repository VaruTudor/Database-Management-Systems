SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE usp_WriteToFile
@FilePath	VARCHAR(200),
@Text		VARCHAR(1000)
AS
BEGIN
	-- Write Text File
	DECLARE @OLE INT
	DECLARE @FileID INT
	EXECUTE sp_OACreate 'Scripting.FileSystemObject', @OLE OUT
	EXECUTE sp_OAMethod @OLE, 'OpenTextFile', @FileID OUT, @FilePath, 8, 1 --8 is for append, 2 is to write
	EXECUTE sp_OAMethod @FileID, 'WriteLine', Null, @Text
	EXECUTE sp_OADestroy @FileID
	EXECUTE sp_OADestroy @OLE
END