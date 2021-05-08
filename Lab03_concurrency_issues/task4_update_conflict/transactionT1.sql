--Snapshot isolation avoids most locking and blocking by using row versioning. 
--When data is modified, the committed versions of affected rows are copied to tempdb and given version numbers. 
--This operation is called copy on write and is used for all inserts, updates and deletes using this technique. 
--When another session reads the same data, the committed version of the data as of the time the reading transaction began is returned.

--By avoiding most locking, this approach can greatly increase concurrency at a lower cost than transactional isolation.
--Of course, “There ain’t no such thing as a free lunch!” and snapshot isolation has a hidden cost: increased usage of tempdb. 

-- in order to be able to replicate the update conflict we need to allow snapshots 
-- this is called explicit snapshot isolation
ALTER DATABASE clothes_company_DB SET ALLOW_SNAPSHOT_ISOLATION ON
-- this does not change anything by itself, but it gives permissions to do so.
-- in order to change we must use SET TRANSACTION ISOLATION LEVEL SNAPSHOT (as we'll use in T2)

USE clothes_company_DB

SET TRANSACTION ISOLATION LEVEL SNAPSHOT
SET LOCK_TIMEOUT 10000;

BEGIN TRANSACTION T1

UPDATE production_factories 
SET factory_location='UPDATE' 
WHERE pid=50;

WAITFOR DELAY '00:00:10'
COMMIT TRANSACTION T2

-- undo the changes
ALTER DATABASE clothes_company_DB SET ALLOW_SNAPSHOT_ISOLATION OFF
UPDATE production_factories 
SET factory_location='UNDO' 
WHERE pid=50;