-- Transaction 2

-- This will read correct data as the isolation level is read commited, which is default as
-- it will wait to get the lock. So we change it to read uncommitted to show the
-- dirty read behaviour

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRAN T2

SELECT * 
FROM fashion_collection
WHERE collection_name='Drop it'

COMMIT TRAN T2