-- Dirty Read
-- A dirty read happens when one transaction is permitted to read data that has been modified by another transaction that 
-- has not yet been committed. In most cases this would not cause a problem. However, if the first transaction is rolled back after
-- the second rads the data, the second transaction has dirty data that does not exist anymore

-- Transaction 1

SELECT * FROM fashion_collection

BEGIN TRAN T1

UPDATE fashion_collection
SET production_factory_id=35
WHERE collection_name='Drop it'

WAITFOR DELAY '00:00:10'
ROLLBACK TRAN T1