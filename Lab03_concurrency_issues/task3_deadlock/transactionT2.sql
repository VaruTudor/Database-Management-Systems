BEGIN TRAN T2

UPDATE product -- assume gets exclusive lock
SET price=55
WHERE code=103;

UPDATE product
SET price=55
WHERE code=100;

COMMIT TRAN T2