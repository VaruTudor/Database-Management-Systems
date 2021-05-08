-- T2 update conflict
USE clothes_company_DB

SET TRANSACTION ISOLATION LEVEL SNAPSHOT 
SET LOCK_TIMEOUT 10000;

BEGIN TRANSACTION T1

-- now when trying to update the same resource that T1 has updated and obtained a lock 
UPDATE production_factories 
SET factory_location='UPDATE_CONFLICT' 
WHERE pid=50
WAITFOR DELAY '00:00:10'
COMMIT TRANSACTION T2