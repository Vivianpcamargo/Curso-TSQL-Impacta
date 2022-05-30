-- Usuário A
USE SISDEP;
-- Atualização na tabela funcionários
BEGIN TRAN TR01;
	UPDATE FUNCIONARIO
	SET Salario += 100
	WHERE Salario <= 1500;
-- Usuário A ainda não confirmou a transação
COMMIT;
ROLLBACK;
-- Ir até a janela Usuário B e tentar selecionar dados da tabela funcionario

-- Customizando nível de bloqueio
-- (Nível de Linha) Default
BEGIN TRAN TR02;
	UPDATE FUNCIONARIO WITH(ROWLOCK)
	SET Salario += 100
	WHERE idMatricula IN(1000,1025,1040);
-- Usuário A ainda não confirmou a transação
COMMIT;
-- Ir até a janela usuário B e executar o select with readpast (97 linhas)
-- Confirmar transação
-- (Nível de Tabela)
BEGIN TRAN TR03;
	UPDATE FUNCIONARIO WITH(TABLOCK)
	SET Salario += 100
	WHERE idMatricula IN(1000,1025,1040);
-- Ir até a janela usuário B e executar o select ReadPast e NoLock
-- Confirmar transação
COMMIT;
-- Configurando TimeOut (nesta Seção)
-- Unidade de Tempo (Milisegundos)
DBCC USEROPTIONS;
SET LOCK_TIMEOUT 5000; -- 5 segundos

-- Executar novamente a transação TR03
-- Ir até a janela usuário B e configurar timeout

-- visualizando bloqueios Pelo nome do objeto
SELECT * FROM sys.dm_tran_locks
WHERE resource_associated_entity_id = OBJECT_ID('Funcionario')

-- visualizando bloqueios por transação
select * from sys.dm_tran_locks
where request_owner_type = 'transaction';

-- Executar a transação TR02 (Usuário A) e TR04 (Usuário B)
COMMIT

-- Executar a transação TR01 e TR03

-- Visualizando transações ativas nesta seção
SELECT @@TRANCOUNT;
-- Visualizando Active Monitor
-- CTRL + ALT + A

-- Visualizando Report All Transactions
