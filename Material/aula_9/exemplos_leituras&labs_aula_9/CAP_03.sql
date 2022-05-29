SELECT * FROM SYSTYPES

SELECT * FROM SYSOBJECTS

SELECT * FROM SYSCOMMENTS


-- UDDT - User Defined Data Types
-- Criar banco de dados de teste
CREATE DATABASE TESTE_UDDT
-- Colocar em uso
USE TESTE_UDDT

-- 1o. Passo: Criar os UDDTs
CREATE TYPE TYPE_NOME_PESSOA 
FROM VARCHAR(40) NOT NULL;

CREATE TYPE TYPE_NOME_EMPRESA 
FROM VARCHAR(60) NOT NULL;

CREATE TYPE TYPE_PRECO 
FROM NUMERIC(12,2) NOT NULL;

CREATE TYPE TYPE_SN 
FROM CHAR(1) NULL;

CREATE TYPE TYPE_DATA_MOVTO 
FROM DATETIME NULL;

-- Exibir os UDDTs que acabamos de criar
SELECT * FROM SYSTYPES WHERE UID = 1

-- 2o. Passo: Criar regras de validação
GO
CREATE RULE R_PRECOS  AS @PRECO >= 0
GO
CREATE RULE R_SN AS @SN IN ('S','N')
GO
CREATE RULE R_DATA_MOVTO AS @DT <= GETDATE()
GO
-- Exibir as regras que você acabou de criar (SYSOBJECTS)
SELECT * FROM SYSOBJECTS WHERE XTYPE = 'R'
-- OU
SELECT R.NAME, C.TEXT
FROM SYSOBJECTS R JOIN SYSCOMMENTS C ON C.ID = R.ID 
WHERE XTYPE = 'R'

-- 3o. Passo: Associar as regras de validação
--            aos UDDTs
EXEC SP_BINDRULE 'R_PRECOS','TYPE_PRECO'
EXEC SP_BINDRULE 'R_SN','TYPE_SN'
EXEC SP_BINDRULE 'R_DATA_MOVTO','TYPE_DATA_MOVTO'
-- Observe a coluna DOMAIN da SYSTYPES
SELECT * FROM SYSTYPES WHERE UID = 1

-- 4o. Passo: Criação de DEFAULTS
GO
CREATE DEFAULT DEF_SN AS 'S'
GO
CREATE DEFAULT DEF_DATA_MOVTO AS GETDATE()
GO
-- Exibir os DEFAULTS que você acabou de criar (SYSOBJECTS)
SELECT * FROM SYSOBJECTS WHERE XTYPE = 'D'
-- OU
SELECT R.NAME, C.TEXT
FROM SYSOBJECTS R JOIN SYSCOMMENTS C ON C.ID = R.ID 
WHERE XTYPE = 'D'

-- 5o. Passo: Associar os DEFAULTS aos UDDTs
EXEC SP_BINDEFAULT 'DEF_SN', 'TYPE_SN'
EXEC SP_BINDEFAULT 'DEF_DATA_MOVTO', 'TYPE_DATA_MOVTO'
-- Observe a coluna TDEFAULT da SYSTYPES
SELECT * FROM SYSTYPES WHERE UID = 1

 
-- Mostra todas as características dos UDDTs
SELECT UT.NAME AS NOME_UDDT, 
       T.NAME AS BUILD_IN_BASE, 
       UT.LENGTH AS TAMANHO, 
       UT.XPREC AS PRECISAO,
       UT.XSCALE AS DECIMAIS, 
       R.NAME AS REGRA_VALID, 
       D.NAME AS [DEFAULT], 
       RT.TEXT AS CREATE_RULE,
       DT.TEXT AS CREATE_DEFAULT
FROM SYSTYPES UT JOIN SYSTYPES T ON UT.XTYPE = T.XUSERTYPE 
     LEFT JOIN SYSOBJECTS R ON UT.DOMAIN = R.ID
     LEFT JOIN SYSOBJECTS D ON UT.TDEFAULT = D.ID
     LEFT JOIN SYSCOMMENTS RT ON R.ID = RT.ID
     LEFT JOIN SYSCOMMENTS DT ON D.ID = DT.ID
WHERE UT.UID = 1


-- TESTANDO
CREATE TABLE PRODUTOS
( COD_PROD		INT IDENTITY,
  DESCRICAO		VARCHAR(80),
  PRECO_CUSTO	TYPE_PRECO,
  PRECO_VENDA	TYPE_PRECO,
  DATA_CADASTRO TYPE_DATA_MOVTO,
  SN_ATIVO		TYPE_SN,
  CONSTRAINT PK_PRODUTOS PRIMARY KEY (COD_PROD) )
--
-- Vai gerar os valores de SN_ATIVO e DATA_CADASTRO
-- porque estes UDDTs possuem valor default
INSERT INTO PRODUTOS
( DESCRICAO, PRECO_CUSTO, PRECO_VENDA )
VALUES( 'TESTE 1', 1, 2 )
--
SELECT * FROM PRODUTOS
-- VAI DAR ERRO -> Preço NEGATIVO
INSERT INTO PRODUTOS
( DESCRICAO, PRECO_CUSTO, PRECO_VENDA )
VALUES( 'TESTE 2', -1, 2 )

-- SEQUENCE
-- Criando uma SEQUENCE
GO
CREATE SEQUENCE SEQ_ALUNO;
-- OU
GO

DROP SEQUENCE  SEQ_ALUNO

GO

CREATE SEQUENCE SEQ_ALUNO
START WITH 1000
INCREMENT BY 10
MINVALUE 10
MAXVALUE 10000
CYCLE  CACHE 10;

GO
CREATE TABLE T_ALUNO 
(COD_ALUNO		INT,
NOM_ALUNO		VARCHAR(50) )
GO

INSERT INTO T_ALUNO (COD_ALUNO, NOM_ALUNO)
VALUES (NEXT VALUE FOR DBO.SEQ_ALUNO, 'TESTE');


SELECT * FROM sys.sequences 

--- Sinônimos
CREATE SYNONYM TAB_ALUNO FOR DBO.T_ALUNO;

SELECT * FROM TAB_ALUNO;

GO
CREATE FUNCTION dbo.Fun_teste (@valor int)
RETURNS int
WITH EXECUTE AS CALLER
AS
BEGIN
IF @valor % 12 <> 0
BEGIN
    SET @valor +=  12 - (@valor % 12)
END
RETURN(@valor);
END;
GO

SELECT dbo.Fun_teste(10)
GO
CREATE SYNONYM FUN_TESTE_EXEMPLO FOR DBO.Fun_teste;
GO
SELECT dbo.FUN_TESTE_EXEMPLO(10)

--Campos Binários
--Criação da tabela
GO
CREATE TABLE TB_CLIENTE_DOCUMENTO(
ID_DOC		INT	IDENTITY PRIMARY KEY,
DESCRICAO		VARCHAR(50),
DOCUMENTO		VARBINARY(MAX) )				
GO

USE PEDIDOS
GO

--Inserção de um arquivo binário
Insert Into TB_CLIENTE_DOCUMENTO(DESCRICAO, DOCUMENTO)
   Select 'Planilha Excel', BulkColumn 
   from Openrowset (Bulk 'C:\DADOS\PESSOA.XLS', Single_Blob) as Image


--Consulta da tabela
SELECT * FROM TB_CLIENTE_DOCUMENTO

--Atualizando um campo binário
-- Atualização
UPDATE TB_CLIENTE_DOCUMENTO SET DOCUMENTO = 
	(SELECT * from Openrowset(Bulk 'C:\DADOS\PESSOA.XLS', Single_Blob) as Arq) 
where ID_DOC = 1

-- Opções avançadas e utilização de comandos shell
EXEC sp_configure 'show advanced options', 1;  
GO  
RECONFIGURE;  
GO
EXEC sp_configure 'xp_cmdshell',1  
GO  
RECONFIGURE;  
GO

-- Retrieve utilizando BCP
Declare @sql varchar(500)
SET @sql = 'BCP "SELECT DOCUMENTO FROM PEDIDOS.DBO.TB_CLIENTE_DOCUMENTO where ID_DOC = 1" QUERYOUT C:\dados\PESSOA1.XLS -SINSTRUTOR -T -N'
EXEC master.dbo.xp_CmdShell @sql

--Onde:
--S--> Nome do Servidor
--T--> Autenticação do Windows

---FILETABLE

-- Enable Filestream
EXEC sp_configure filestream_access_level, 2
RECONFIGURE
GO

--A criação do banco deve possuir um FILEGROUP com acesso para o FILESTREAM
-- Create Database
CREATE DATABASE Banco_Filestream
ON PRIMARY
(Name = FG_Filestream_PRIMARY,
FILENAME = 'C:\DADOS\Filestream_DATA.mdf'),
FILEGROUP FG_Filestream_FS CONTAINS FILESTREAM
(NAME = Filestream_ARQ,
FILENAME='C:\DADOS\Filestream_ARQ')
LOG ON
(Name = Filestream_log,
FILENAME = 'C:\DADOS\Filestream_log.ldf')
WITH FILESTREAM (NON_TRANSACTED_ACCESS = FULL,
DIRECTORY_NAME = N'Filestream_ARQ');
GO


--No exemplo abaixo o banco de dados já foi criado e será adicionado ao FILEGROUP com o comando ALTER DATABASE:
USE MASTER

DROP DATABASE  BANCO_FILESTREAM
GO

--Criando o banco de dados
CREATE DATABASE Banco_Filestream
ON PRIMARY
(Name = FG_Filestream_PRIMARY,
FILENAME = 'C:\DADOS\Filestream_DATA.mdf')
LOG ON
(Name = Filestream_log,
FILENAME = 'C:\DADOS\Filestream_log.ldf')
GO

--Adicionando FILEGROUP
ALTER DATABASE Banco_Filestream ADD FILEGROUP FG_Filestream_FS CONTAINS FILESTREAM

--Adicionando arquivos
ALTER DATABASE Banco_Filestream ADD FILE
(NAME = Filestream_ARQ,FILENAME='C:\DADOS\Filestream_ARQ')
TO FILEGROUP FG_Filestream_FS


--Abaixo um exemplo de criação de tabela FILETABLE:
USE BANCO_FILESTREAM
GO
CREATE TABLE FT_Documento AS FileTable 
--OU
CREATE TABLE FT_Documento AS FileTable 
    WITH ( 
          FileTable_Directory = 'Filestream_ARQ', 
          FileTable_Collate_Filename = database_default 
         ); 
GO

--Inserção de um arquivo binário
Insert Into FT_Documento (name, file_stream)
   Select 'Planilha Excel', BulkColumn 
   from Openrowset (Bulk 'C:\DADOS\PESSOA.XLS', Single_Blob) as Image

INSERT INTO FT_Documento (name,is_directory,is_archive)  values
('Arquivos WORD' , 1 ,0)


SELECT * FROM FT_Documento;

SELECT FileTableRootPath('FT_Documento')  [Caminho]


SELECT Tab.Name as Nome,
IIF(Tab.is_directory=1,'Diretório','Arquivo') as Tipo,
Tab.file_type as Extensao,
Tab.cached_file_size/1024.0 as Tamanho_KB,
Tab.creation_time as Data_Criacao,
Tab.file_stream.GetFileNamespacePath(1,0) as Caminho,
ISNULL(Doc.file_stream.GetFileNamespacePath(1,0),'Root Directory') [Parent Path]
FROM FT_Documento as Tab
LEFT JOIN FT_Documento as Doc
ON Tab.path_locator.GetAncestor(1) = Doc.path_locator


-- Atualizando arquivos
UPDATE FT_Documento SET file_stream  = 
	(SELECT * from Openrowset(Bulk 'C:\DADOS\ArqTXT.txt', Single_Blob) as Arq) 
where name ='Planilha Excel'

-- Colunas computadas
USE PEDIDOS
GO
SELECT 
NOME, DATA_NASCIMENTO,
FLOOR(CAST(GETDATE()-DATA_NASCIMENTO  AS FLOAT)/365.25) AS IDADE
FROM TB_EMPREGADO

--Criação da coluna calculada
ALTER TABLE TB_EMPREGADO 
ADD IDADE AS 
FLOOR(CAST(GETDATE()-DATA_NASCIMENTO  AS FLOAT)/365.25)

--A mesma consulta utilizando a coluna calculada Idade
SELECT 
NOME, DATA_NASCIMENTO,IDADE
FROM TB_EMPREGADO
