-- T2 insers a new row that matches the WHERE clause of T1's query

BEGIN TRANSACTION T2

INSERT INTO fashion_collection
VALUES ('DD',35);	-- this is the insert which changes the row count of the query result in T1 

COMMIT TRANSACTION T2

DELETE 
FROM fashion_collection
WHERE collection_name = 'DD'; -- this performs an undo on the changes