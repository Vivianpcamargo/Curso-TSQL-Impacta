USE PEDIDOS
-- 1. Gerar uma cópia da tabela TB_EMPREGADO chamada EMP_TEMP
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='EMP_TEMP' AND XTYPE='U')
	DROP TABLE EMP_TEMP

SELECT * INTO EMP_TEMP FROM TB_EMPREGADO; 
-- Testando
SELECT * FROM EMP_TEMP;

-- 2. Exclui o funcionário de código 3 de EMP_TEMP
DELETE FROM EMP_TEMP WHERE COD_CARGO = 3;

-- 3. Altera os salários de EMP_TEMP dos funcionários do departamento 2
UPDATE EMP_TEMP SET SALARIO *= 1.2
WHERE COD_DEPTO = 2

-- 4. Habilita a inserção de dados no campo identidade
SET IDENTITY_INSERT EMP_TEMP ON;

----------------------------------------------------------------
-- 5. Faz com que a tabela EMP_TEMP fique igual à tabela TB_EMPREGADO
MERGE EMP_TEMP AS ET    -- Tabela alvo
USING TB_EMPREGADO AS E   -- Tabela fonte
ON ET.CODFUN = E.CODFUN -- Condição de comparação
-- Quando o registro existir nas duas tabelas e o SALARIO for diferente
WHEN MATCHED AND E.SALARIO <> ET.SALARIO THEN
     -- Alterar o campo salário de EMP_TEMP
     UPDATE SET ET.SALARIO = E.SALARIO
-- Quando o registro não existir em EMP_TEMP     
WHEN NOT MATCHED THEN
     -- Insere o registro em EMP_TEMP
     INSERT (CODFUN,NOME,COD_DEPTO,COD_CARGO,DATA_ADMISSAO, DATA_NASCIMENTO, 
             SALARIO, NUM_DEPEND, SINDICALIZADO, OBS, FOTO)     
     VALUES (CODFUN,NOME,COD_DEPTO,COD_CARGO,DATA_ADMISSAO, DATA_NASCIMENTO, 
             SALARIO, NUM_DEPEND, SINDICALIZADO, OBS, FOTO)
-- Quando existir o código na tabela alvo e não existir
-- na tabela fonte             
WHEN NOT MATCHED BY SOURCE THEN
     DELETE
OUTPUT 
  INSERTED.CODFUN, DELETED.CODFUN, DELETED.SALARIO AS SALARIO_ANTIGO,
  INSERTED.SALARIO AS SALARIO_NOVO, $ACTION AS ACAO_EXECUTADA ;             
----------------------------------------------------------------
           
-- Desabilita a inserção de dados no campo identidade                         
SET IDENTITY_INSERT EMP_TEMP OFF;


IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='EMP_TEMP' AND XTYPE='U')
	DROP TABLE EMP_TEMP

SELECT * INTO EMP_TEMP FROM TB_EMPREGADO;
-- Testando
SELECT * FROM EMP_TEMP;

-- 2. Exclui o funcionário de código 3, 5 E 7 de EMP_TEMP
DELETE FROM EMP_TEMP WHERE COD_CARGO IN (3,5,7);

-- 3. Altera os salários de EMP_TEMP dos funcionários do departamento 2
UPDATE EMP_TEMP SET SALARIO *= 1.2
WHERE COD_DEPTO = 2

-- 5. Gera uma cópia da tabela TB_EMPREGADO chamada EMP_TEMP
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='EMP_TEMP' AND XTYPE='U')
	DROP TABLE EMP_TEMP

SELECT * INTO EMP_TEMP FROM TB_EMPREGADO; 


INSERT INTO EMP_TEMP 
(NOME, COD_DEPTO, COD_CARGO, SALARIO, DATA_ADMISSAO)
VALUES ('MARIA ANTONIA',1,2,2000,GETDATE()),
       ('ANTONIA MARIA',2,1,3000,GETDATE());


-- 6. Comando MERGE

SET IDENTITY_INSERT EMP_TEMP ON
-- Faz com que a tabela EMP_TEMP fique igual à tabela TB_EMPREGADO
MERGE EMP_TEMP AS ET    -- Tabela alvo
USING TB_EMPREGADO AS E   -- Tabela fonte
ON ET.CODFUN = E.CODFUN -- Condição de comparação
-- Quando o registro existir nas duas tabelas e o SALARIO for diferente...
WHEN MATCHED AND E.SALARIO <> ET.SALARIO THEN
     -- ...Alterar o campo salário de EMP_TEMP
     UPDATE SET ET.SALARIO = E.SALARIO
-- Quando o registro não existir em EMP_TEMP...     
WHEN NOT MATCHED THEN
     -- ...Inserir o registro em EMP_TEMP
     INSERT (CODFUN,NOME,COD_DEPTO,COD_CARGO,DATA_ADMISSAO, DATA_NASCIMENTO, 
             SALARIO, NUM_DEPEND, SINDICALIZADO, OBS, FOTO)     
     VALUES (CODFUN,NOME,COD_DEPTO,COD_CARGO,DATA_ADMISSAO, DATA_NASCIMENTO, 
             SALARIO, NUM_DEPEND, SINDICALIZADO, OBS, FOTO);
 
-- Desabilita a inserção de dados no campo identidade
SET IDENTITY_INSERT EMP_TEMP OFF;

--7. MERGE com OUTPUT

-- Cria a tabela EMP_TEMP
IF OBJECT_ID('EMP_TEMP','U') IS NOT NULL
   DROP TABLE EMP_TEMP;

SELECT * INTO EMP_TEMP FROM TB_EMPREGADO; 
-- Testando
SELECT * FROM EMP_TEMP;
GO

-- Exclui os funcionários de código 3, 5 e 7 de EMP_TEMP
DELETE FROM EMP_TEMP WHERE COD_CARGO IN (3,5,7);
-- Altera os salários de EMP_TEMP dos funcionários do depto. 2
UPDATE EMP_TEMP SET SALARIO *= 1.2
WHERE COD_DEPTO = 2

INSERT INTO EMP_TEMP 
(NOME, COD_DEPTO, COD_CARGO, SALARIO, DATA_ADMISSAO)
VALUES ('MARIA ANTONIA',1,2,2000,GETDATE()),
       ('ANTONIA MARIA',2,1,3000,GETDATE());

SET IDENTITY_INSERT EMP_TEMP ON

-- Faz com que a tabela EMP_TEMP fique igual à tabela TB_EMPREGADO
MERGE EMP_TEMP AS ET    -- Tabela alvo
USING TB_EMPREGADO AS E   -- Tabela fonte
ON ET.CODFUN = E.CODFUN -- Condição de comparação
-- Quando o registro existir nas duas tabelas e o SALARIO for diferente...
WHEN MATCHED AND E.SALARIO <> ET.SALARIO THEN
     -- ...Alterar o campo salário de EMP_TEMP
     UPDATE SET ET.SALARIO = E.SALARIO
-- Quando o registro não existir em EMP_TEMP...     
WHEN NOT MATCHED THEN
     -- ...Inserir o registro em EMP_TEMP
     INSERT (CODFUN,NOME,COD_DEPTO,COD_CARGO,DATA_ADMISSAO, DATA_NASCIMENTO, 
             SALARIO, NUM_DEPEND, SINDICALIZADO, OBS, FOTO)     
     VALUES (CODFUN,NOME,COD_DEPTO,COD_CARGO,DATA_ADMISSAO, DATA_NASCIMENTO, 
             SALARIO, NUM_DEPEND, SINDICALIZADO, OBS, FOTO)
WHEN NOT MATCHED BY SOURCE THEN
     -- Excluir o que existe na tabela alvo mas não existe 
     -- na tabela fonte
     DELETE
OUTPUT $ACTION AS [Ação], INSERTED.CODFUN AS [Código Após], 
       DELETED.CODFUN AS [Código Antes], 
       INSERTED.NOME AS [Nome Após], 
       DELETED.NOME AS [Nome Antes], 
       INSERTED.SALARIO AS [Salário Após], 
       DELETED.SALARIO AS [Salário Antes];
-- Desabilita a inserção de dados no campo identidade

SET IDENTITY_INSERT EMP_TEMP OFF;
