-- Non repreatable read happens when one transaction reads the same data twice (T1 in this case) and
-- another transaction (T2) updates that data in between the first and second read of transaction one

-- This can happen in Read Committed which is also the default isolation level

-- The Shared lock is released as soon as the SELECT is performed

BEGIN TRANSACTION T1

SELECT * 
FROM fashion_collection
WHERE collection_name='Drop it'  -- this is the first read which should get the correct data

WAITFOR DELAY '00:00:10' -- simulate that the transaction has to perform more actions which take ~ 10s

SELECT * 
FROM fashion_collection
WHERE collection_name='Drop it'  -- this is the second read which should get the dirty data

COMMIT TRANSACTION T1