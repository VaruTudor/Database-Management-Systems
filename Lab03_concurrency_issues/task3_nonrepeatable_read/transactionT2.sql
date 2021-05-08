 --T2 updates that data in between the first and second read of transaction one

 BEGIN TRANSACTION T2

UPDATE fashion_collection
SET production_factory_id=45
WHERE collection_name='Drop it'  -- this is the update which changes the data

COMMIT TRANSACTION T2

UPDATE fashion_collection
SET production_factory_id=40
WHERE collection_name='Drop it'  -- this is the update which changes the data back