-- Phantom read happens when one transaction executes a query twice (T1 in this case) and
-- it gets different number of rows in the result set. This happens because a second transaction (T2) 
-- insers a new row that matches the WHERE clause of T1's query

-- This can happen in Repeatable Read isolation level

-- The Shared lock and Exclusive lock is released at the end of the transaction

BEGIN TRANSACTION T1

SELECT * 
FROM fashion_collection
WHERE collection_name LIKE 'D%'  -- this is the first read which should get the correct number of rows

WAITFOR DELAY '00:00:10' -- simulate that the transaction has to perform more actions which take ~ 10s

SELECT * 
FROM fashion_collection
WHERE collection_name LIKE 'D%'  -- this is the second read which should get the wrong number of rows

COMMIT TRANSACTION T1
