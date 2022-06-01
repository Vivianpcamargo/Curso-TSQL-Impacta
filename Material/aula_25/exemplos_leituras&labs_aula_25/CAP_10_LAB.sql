--LABORATÓRIO
----------------------------------------------------
-- Laboratório A
-- 1. Crie trigger para TB_PRODUTO que seja executado sempre
-- que ocorrer alteração de registro. Devem ser inseridos dados
-- na tabela de histórico se houver alteração de PRECO_VENDA

CREATE TABLE PRODUTOS_HIST_PRECO
( NUM_MOVTO			INT IDENTITY,
  ID_PRODUTO		    INT,
  DATA_ALTERACAO	DATETIME,
  PRECO_ANTIGO	NUMERIC(12,4),	
  PRECO_NOVO		NUMERIC(12,4),
  CONSTRAINT PK_PRODUTOS_HIST_PRECO
    PRIMARY KEY (NUM_MOVTO) )
GO
--------------------------------------------------------------------

CREATE TRIGGER TRG_PRODUTOS_HIST_PRECO ON TB_PRODUTO
   FOR UPDATE
AS BEGIN
INSERT INTO PRODUTOS_HIST_PRECO
(ID_PRODUTO, DATA_ALTERACAO, PRECO_ANTIGO, PRECO_NOVO)
SELECT I.ID_PRODUTO, GETDATE(), D.PRECO_VENDA, I.PRECO_VENDA
FROM INSERTED I JOIN DELETED D ON I.ID_PRODUTO = D.ID_PRODUTO	
WHERE I.PRECO_VENDA<> D.PRECO_VENDA
END

--- TESTANDO
DELETE PRODUTOS_HIST_PRECO

UPDATE TB_PRODUTO SET PRECO_VENDA = PRECO_VENDA * 1.5
WHERE COD_TIPO = 2
--
SELECT * FROM PRODUTOS_HIST_PRECO

-----------------------------------------------------


--  2. Crie um trigger que corrija o estoque (campo QTD_REAL da tabela TB_PRODUTO) toda vez que um item de pedido for incluído, alterado ou excluído. 
GO
CREATE TRIGGER TRG_ITENSPEDIDO_CORRIGE_ESTOQUE ON TB_ITENSPEDIDO
   FOR DELETE, INSERT, UPDATE
AS BEGIN
--  .SE o trigger foi executado por "culpa" de DELETE
--      .Somar em TB_PRODUTO.QTD_REAL a QUANTIDADE do
--       item que foi deletado
IF NOT EXISTS(SELECT * FROM INSERTED)
   UPDATE TB_PRODUTO
   SET QTD_REAL = P.QTD_REAL + D.QUANTIDADE
   FROM TB_PRODUTO P 
        JOIN DELETED D ON P.ID_PRODUTO = D.ID_PRODUTO
--  .SE o trigger foi executado por "culpa" de INSERT
--      .Subtrair de PRODUTOS.QTD_REAL a QUANTIDADE do
--       item que foi inserido
ELSE IF NOT EXISTS(SELECT * FROM DELETED)
   UPDATE TB_PRODUTO
   SET QTD_REAL = P.QTD_REAL - I.QUANTIDADE
   FROM TB_PRODUTO P 
        JOIN INSERTED I ON P.ID_PRODUTO = I.ID_PRODUTO    
--  .SE o trigger foi executado por "culpa" de UPDATE
--      .Somar em PRODUTOS.QTD_REAL o valor resultante
--       de (DELETED.QUANTIDADE - INSERTED.QUANTIDADE)
ELSE
   UPDATE TB_PRODUTO
   SET QTD_REAL = P.QTD_REAL + ( D.QUANTIDADE - I.QUANTIDADE )
   FROM TB_PRODUTO P 
        JOIN INSERTED I ON P.ID_PRODUTO = I.ID_PRODUTO    
        JOIN DELETED D ON P.ID_PRODUTO = D.ID_PRODUTO
END

------------------------------------------------------
-- 3. Crie um trigger de DDL para o banco de dados PEDIDOS
--    que registre na tabela criada a seguir todos os eventos CREATE, ALTER 
--    e DROP executados no nível do banco de dados.

GO
CREATE TABLE TAB_LOG_BANCO
(
	ID				INT IDENTITY PRIMARY KEY,
    EventType		VARCHAR(100),
	PostTime		VARCHAR(50),
	UserName		VARCHAR(100),
	ObjectType		VARCHAR(100),
	ObjectName		VARCHAR(300),
    CommandText		Text 
)

GO
CREATE TRIGGER TRG_LOG_BANCO 
   ON  DATABASE
   FOR DDL_DATABASE_LEVEL_EVENTS
AS BEGIN
DECLARE @DATA XML;
-- Recupera todas as informaçõe sobre o motivo da
-- execução do trigger
SET @DATA = EVENTDATA();

INSERT INTO TAB_LOG_BANCO
( EventType, PostTime, UserName, ObjectType, ObjectName,
  CommandText )
VALUES
( @DATA.value('(/EVENT_INSTANCE/EventType)[1]', 'Varchar(100)'),
  @DATA.value('(/EVENT_INSTANCE/PostTime)[1]', 'Varchar(100)'),
  @DATA.value('(/EVENT_INSTANCE/UserName)[1]', 'Varchar(100)'),
  @DATA.value('(/EVENT_INSTANCE/ObjectType)[1]', 'Varchar(100)'),
  @DATA.value('(/EVENT_INSTANCE/ObjectName)[1]', 'Varchar(200)'),
  @DATA.value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]', 
                      'Varchar(8000)') )
END
GO
---- TESTANDO
CREATE TABLE TESTE ( COD INT, NOME VARCHAR(30) )
GO
ALTER TABLE TESTE ADD E_MAIL VARCHAR(100)
GO
DROP TABLE TESTE
GO
--
SELECT * FROM TAB_LOG_BANCO
-------------------------------------------------------

-- 4. Crie um trigger de DDL para o banco de dados PEDIDOS
--  que registre na tabela criada a seguir todos os eventos CREATE,
--  ALTER e DROP executados no nível do banco de dados.
GO
USE MASTER

GO
CREATE TABLE TAB_LOG_SERVER
(
	ID			INT IDENTITY PRIMARY KEY,
	DatabaseName	VARCHAR(100),
	EventType		VARCHAR(100),
	PostTime		VARCHAR(50),
	UserName		VARCHAR(100),
	ObjectType		VARCHAR(100),
	ObjectName		VARCHAR(300),
	CommandText		VARCHAR(max) 
)

GO
USE MASTER

GO
CREATE TRIGGER TRG_LOG_SERVER 
   ON  ALL SERVER
   FOR CREATE_DATABASE, DROP_DATABASE, ALTER_DATABASE,   
       DDL_DATABASE_LEVEL_EVENTS
AS BEGIN
DECLARE @DATA XML;
-- Recupera todas as informaçõe sobre o motivo da
-- execução do trigger
SET @DATA = EVENTDATA();

INSERT INTO TAB_LOG_SERVER
(DatabaseName, EventType, PostTime, UserName, ObjectType, ObjectName,
  CommandText )
VALUES
( @DATA.value('(/EVENT_INSTANCE/DatabaseName)[1]', 'Varchar(100)'),
  @DATA.value('(/EVENT_INSTANCE/EventType)[1]', 'Varchar(100)'),
  @DATA.value('(/EVENT_INSTANCE/PostTime)[1]', 'Varchar(100)'),
  @DATA.value('(/EVENT_INSTANCE/UserName)[1]', 'Varchar(100)'),
  @DATA.value('(/EVENT_INSTANCE/ObjectType)[1]', 'Varchar(100)'),
  @DATA.value('(/EVENT_INSTANCE/ObjectName)[1]', 'Varchar(200)'),
  @DATA.value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]', 
                      'Varchar(8000)') )
END
GO
-- TESTANDO
CREATE DATABASE TESTE_TRIGGER
GO
USE TESTE_TRIGGER

GO
CREATE TABLE TESTE (C1 INT, C2 VARCHAR(30))
GO
USE MASTER

GO
DROP DATABASE TESTE_TRIGGER
GO
SELECT * FROM TAB_LOG_SERVER
--
-- 5.Crie um trigger de logon para bloqueio de acesso de usuários não administrativos e gravação de auditoria para acesso ao servidor. Utilize a tabela:
GO
CREATE TABLE DBA_AutitLogin(
	idPK int IDENTITY(1,1),
	Data datetime ,
	ProcID int ,
	LoginID varchar(128) ,
	NomeHost varchar(128) ,
	App varchar(128) ,
	SchemaAutenticacao varchar(128) ,
	Protocolo varchar(128) ,
	IPcliente varchar(30) ,
	IPservidor varchar(30) ,
	xmlConectInfo xml 
)
GO
CREATE TRIGGER DBA_AuditLogin on all server
for logon
as
insert master.dbo.DBA_AutitLogin 
	(Data , ProcID, LoginID, NomeHost, App,SchemaAutenticacao,Protocolo,
	IPcliente,IPservidor,xmlConectInfo)
select getdate(),@@spid,s.login_name,s.[host_name],
s.program_name,c.auth_scheme,c.net_transport,
c.client_net_address,c.local_net_address,eventdata()
from sys.dm_exec_sessions s join sys.dm_exec_connections c
on s.session_id = c.session_id
where s.session_id = @@spid
GO


-- Teste
select * from DBA_AutitLogin
