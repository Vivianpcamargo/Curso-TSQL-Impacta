-- Visualizando triggers
SELECT name
FROM sys.triggers

--Trigger DML

USE PEDIDOS

GO

CREATE TABLE EMPREGADOS_HIST_SALARIO
( NUM_MOVTO			INT IDENTITY,
  CODFUN		    INT,
  DATA_ALTERACAO	DATETIME,
  SALARIO_ANTIGO 	NUMERIC(12,2),	
  SALARIO_NOVO		NUMERIC(12,2),
  CONSTRAINT PK_EMPREGADOS_HIST_SALARIO
    PRIMARY KEY (NUM_MOVTO) )
GO

--Vejamos o procedimento de criação do trigger: 

CREATE TRIGGER TRG_EMPREGADOS_HIST_SALARIO ON TB_EMPREGADO
   FOR UPDATE
AS BEGIN
DECLARE @CODFUN INT, @SALARIO_ANTIGO FLOAT, @SALARIO_NOVO FLOAT;

-- Ler os dados antigos
SELECT @SALARIO_ANTIGO = SALARIO FROM DELETED;
-- Ler os dados novos
SELECT @CODFUN = CODFUN, @SALARIO_NOVO = SALARIO FROM INSERTED;
-- Se houver alteração de salário
IF @SALARIO_ANTIGO <> @SALARIO_NOVO
   -- Inserir dados na tabela de histórico
   INSERT INTO EMPREGADOS_HIST_SALARIO
  (CODFUN, DATA_ALTERACAO, SALARIO_ANTIGO, SALARIO_NOVO)
   VALUES
  (@CODFUN, GETDATE(), @SALARIO_ANTIGO, @SALARIO_NOVO) 	

END

GO
-- Testar
UPDATE TB_EMPREGADO SET SALARIO = SALARIO * 1.2
WHERE CODFUN = 3
--
SELECT * FROM EMPREGADOS_HIST_SALARIO 
-- Observar que foi inserido na tabela o registro referente à alteração efetuada


-- Alterar o salário "em lote"
UPDATE TB_EMPREGADO SET SALARIO = SALARIO * 1.2
WHERE CODFUN IN (4,5,7)
-- Conferir se foram gerados os históricos para os 3 funcionários
SELECT * FROM EMPREGADOS_HIST_SALARIO 


-- Ler os dados antigos
SELECT @SALARIO_ANTIGO = SALARIO FROM DELETED;
-- Ler os dados novos
SELECT @CODFUN = CODFUN, @SALARIO_NOVO = SALARIO FROM INSERTED;

GO

ALTER TRIGGER TRG_EMPREGADOS_HIST_SALARIO ON TB_EMPREGADO
   FOR UPDATE
AS BEGIN
   INSERT INTO EMPREGADOS_HIST_SALARIO
  (CODFUN, DATA_ALTERACAO, SALARIO_ANTIGO, SALARIO_NOVO)
   SELECT I.CODFUN, GETDATE(), D.SALARIO, I.SALARIO
   FROM INSERTED I JOIN DELETED D ON I.CODFUN = D.CODFUN
   WHERE I.SALARIO <> D.SALARIO
END
GO

-- Testar
DELETE FROM EMPREGADOS_HIST_SALARIO 

UPDATE TB_EMPREGADO SET SALARIO = SALARIO * 1.2
WHERE CODFUN IN (4,5,7)
--
SELECT * FROM EMPREGADOS_HIST_SALARIO 

GO

CREATE TRIGGER TRG_CORRIGE_VLR_TOTAL ON TB_ITENSPEDIDO
   FOR DELETE, INSERT, UPDATE
AS BEGIN
-- Se o trigger foi executado por DELETE
IF NOT EXISTS( SELECT * FROM INSERTED )
   UPDATE TB_PEDIDO
   SET VLR_TOTAL = (SELECT SUM( PR_UNITARIO * QUANTIDADE *
                                ( 1 - DESCONTO/100 ) )
                    FROM TB_ITENSPEDIDO
                    WHERE NUM_PEDIDO = P.NUM_PEDIDO)
   FROM TB_PEDIDO P JOIN DELETED D
        ON P.NUM_PEDIDO = D.NUM_PEDIDO
-- Se o trigger foi executado por INSERT ou UPDATE
ELSE
   UPDATE TB_PEDIDO
   SET VLR_TOTAL = (SELECT SUM( PR_UNITARIO * QUANTIDADE *
                                ( 1 - DESCONTO/100 ) )
                    FROM TB_ITENSPEDIDO
                    WHERE NUM_PEDIDO = P.NUM_PEDIDO)
   FROM TB_PEDIDO P JOIN INSERTED I
        ON P.NUM_PEDIDO = I.NUM_PEDIDO
END

GO

-- Testar
SELECT * FROM TB_PEDIDO WHERE NUM_PEDIDO = 1000
-- Pedido 1000 -> VLR_TOTAL = 380
SELECT * FROM TB_ITENSPEDIDO WHERE NUM_PEDIDO = 1000
-- Possui um único item com PR_UNITARIO = 1
UPDATE TB_ITENSPEDIDO SET PR_UNITARIO = 2
WHERE NUM_PEDIDO = 1000
--
SELECT * FROM TB_PEDIDO WHERE NUM_PEDIDO = 1000
-- VLR_TOTAL = 760

ALTER TABLE TB_CLIENTE
ADD SN_ATIVO CHAR(1) NOT NULL DEFAULT 'S'

GO
CREATE TRIGGER TRG_CLIENTES_DESATIVA ON TB_CLIENTE
  INSTEAD OF DELETE
AS BEGIN
UPDATE TB_CLIENTE SET SN_ATIVO = 'N'
FROM TB_CLIENTE C JOIN DELETED D ON C.CODCLI = D.CODCLI
END
GO

-- TESTAR
SELECT CODCLI, NOME, SN_ATIVO FROM TB_CLIENTE
--
DELETE FROM TB_CLIENTE WHERE CODCLI IN (4,7,11)
--
SELECT CODCLI, NOME, SN_ATIVO FROM TB_CLIENTE

-- Trigger DDL
GO
CREATE TRIGGER TRG_LOG_BANCO 
   ON  DATABASE
   FOR DDL_DATABASE_LEVEL_EVENTS
AS BEGIN
DECLARE @DATA XML, @MSG VARCHAR(5000);
-- Recupera todas as informações sobre o motivo da
-- execução do trigger
SET @DATA = EVENTDATA();
-- Extrai uma informação específica da variável XML
SET @MSG = @DATA.value('(/EVENT_INSTANCE/EventType)[1]',
                        'Varchar(100)');
PRINT @MSG;

SET @MSG = @DATA.value('(/EVENT_INSTANCE/ObjectType)[1]',
                        'Varchar(100)');
PRINT @MSG;

SET @MSG = @DATA.value('(/EVENT_INSTANCE/ObjectName)[1]',
                        'Varchar(100)');
PRINT @MSG;

SET @MSG = @DATA.value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]',
                        'Varchar(4000)');
PRINT @MSG;
END
GO

---- TESTAR
CREATE TABLE TESTE ( COD INT, NOME VARCHAR(30) )
GO
ALTER TABLE TESTE ADD E_MAIL VARCHAR(100)
GO
DROP TABLE TESTE
GO

ALTER TRIGGER TRG_LOG_SERVER 
   ON  ALL SERVER
   FOR CREATE_DATABASE, DROP_DATABASE, ALTER_DATABASE, DDL_DATABASE_LEVEL_EVENTS
AS BEGIN
DECLARE @DATA XML;
-- Recupera todas as informações sobre o motivo da
-- execução do trigger
SET @DATA = EVENTDATA();
-- Extrai uma informação específica da variável XML
SET @MSG = @DATA.value('(/EVENT_INSTANCE/EventType)[1]',
                        'Varchar(100)');
PRINT @MSG;

SET @MSG = @DATA.value('(/EVENT_INSTANCE/ObjectType)[1]',
                        'Varchar(100)');
PRINT @MSG;

SET @MSG = @DATA.value('(/EVENT_INSTANCE/ObjectName)[1]',
                        'Varchar(100)');
PRINT @MSG;

SET @MSG = @DATA.value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]',
                        'Varchar(4000)');
PRINT @MSG;
END
GO

-- TESTAR
CREATE DATABASE TESTE_TRIGGER
GO
USE TESTE_TRIGGER
GO
CREATE TABLE TESTE (C1 INT, C2 VARCHAR(30))
GO
DROP DATABASE TESTE_TRIGGER
GO

-- Trigger de logon

CREATE LOGIN Adm_Impacta WITH PASSWORD = 'Imp@ct@12'

GO
CREATE TRIGGER TRG_Bloqueio_SSMS
ON ALL SERVER
FOR LOGON
AS
BEGIN

	IF (ORIGINAL_LOGIN() LIKE 'Adm_%') AND 
		APP_NAME() LIKE 'Microsoft SQL Server Management Studio%'
		ROLLBACK
END
GO
--Criação de uma tabela para receber os registros de auditoria

CREATE TABLE dbo.DBA_AuditLogin(
	idPK				int		IDENTITY,
	Data				datetime,
	ProcID				int,
	LoginID				varchar(128),
	NomeHost			varchar(128),
	App					varchar(128),
	SchemaAutenticacao	varchar(128),
	Protocolo			varchar(128),
	IPcliente			varchar(30),
	IPservidor			varchar(30),
	xmlConectInfo		xml
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

--Criação de um trigger de logon


CREATE TRIGGER DBA_AuditLogin on all server
for logon
as
insert master.dbo.DBA_AutitLogin
select getdate(),@@spid,s.login_name,s.[host_name],
s.program_name,c.auth_scheme,c.net_transport,
c.client_net_address,c.local_net_address,eventdata()
from sys.dm_exec_sessions s join sys.dm_exec_connections c
on s.session_id = c.session_id
where s.session_id = @@spid
GO

select * from dbo.DBA_AuditLogin

--  Habilitando e desabilitando aninhamento
Exec SP_Configure 'Nested Triggers', 0

Exec SP_Configure 'Nested Triggers', 1



