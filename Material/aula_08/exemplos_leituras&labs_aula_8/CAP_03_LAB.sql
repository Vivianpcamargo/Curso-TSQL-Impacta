-- LABORATÓRIO
USE PEDIDOS

-- 1. Crie os seguintes UDDTs
/*
	TIPO_CODIGO		INT		NOT NULL
	TIPO_ENDERECO		VARCHAR(60)	NULL
	TIPO_FONE		CHAR(14)	NULL
	TIPO_SEXO		CHAR(1)		NOT NULL
	TIPO_ALIQUOTA		NUMERIC(4,2)	NULL
	TIPO_PRAZO		INT		NOT NULL	
*/
-- Resposta:
CREATE TYPE TIPO_CODIGO
FROM INT NOT NULL;

CREATE TYPE TIPO_ENDERECO
FROM VARCHAR(60) NOT NULL;

CREATE TYPE TIPO_FONE
FROM CHAR(14) NOT NULL;

CREATE TYPE TIPO_SEXO
FROM CHAR(1) NOT NULL;

CREATE TYPE TIPO_ALIQUOTA
FROM NUMERIC(4,2) NULL;

CREATE TYPE TIPO_PRAZO
FROM INT NOT NULL;


-- 2. Exiba os UDDTs que você acabou de criar
-- Resposta:
SELECT * FROM SYSTYPES WHERE UID = 1

-- 3. Crie as regras de validação
/*
	R_SEXO			Aceita somente 'F' e 'M'
	R_ALIQUOTA		Números não negativos
    	R_PRAZO			Números no intervalo de 1 até 60
*/
-- Resposta:
GO
CREATE RULE R_SEXO AS @S IN ('F', 'M')
GO
CREATE RULE R_ALIQUOTA AS @A >= 0
GO
CREATE RULE R_PRAZO AS @P BETWEEN 1 AND 60
GO

-- 4. Exiba as regras de validação que você acabou de criar
-- Resposta:
SELECT * FROM SYSOBJECTS WHERE XTYPE = 'R'

-- 5. Associe as regras aos seus UDDTs
/*
    R_SEXO 	ao UDDT TIPO_SEXO
    R_ALIQUOTA  ao UDDT TIPO_ALIQUOTA
    R_PRAZO	ao UDDT TIPO_PRAZO	
*/    
-- Resposta:
EXEC SP_BINDRULE 'R_SEXO', 'TIPO_SEXO'
EXEC SP_BINDRULE 'R_ALIQUOTA', 'TIPO_ALIQUOTA'
EXEC SP_BINDRULE 'R_PRAZO', 'TIPO_PRAZO'

-- 6. Crie os seguintes objetos DEFAULT
/*
	D_SEXO			"M"
	D_ALIQUOTA		0 (ZERO)
	D_PRAZO			1
*/
-- Resposta:
GO
CREATE DEFAULT D_SEXO AS 'M'
GO
CREATE DEFAULT D_ALIQUOTA AS 0
GO
CREATE DEFAULT D_PRAZO AS 1
GO

-- 7. Exiba os DEFAULTs que você acabou de criar
-- Resposta:
SELECT * FROM SYSOBJECTS WHERE XTYPE = 'D'

-- 8. Associe os defaults aos UDDTs
/*
	D_SEXO a TIPO_SEXO
	D_ALIQUOTA a TIPO_ALIQUOTA
	D_PRAZO a TIPO_PRAZO
*/
-- Resposta:
EXEC SP_BINDEFAULT 'D_SEXO', 'TIPO_SEXO'
EXEC SP_BINDEFAULT 'D_ALIQUOTA', 'TIPO_ALIQUOTA'
EXEC SP_BINDEFAULT 'D_PRAZO', 'TIPO_PRAZO'
 
-- 9. Crie as tabelas
/*
	PESSOAS
	
	COD_PESSOA	TIPO_CODIGO	autonumeração	chave primária
	NOME		VARCHAR(30)
	ENDERECO	TIPO_ENDERECO
	SEXO		TIPO_SEXO
	------------------------------------------------------------------------
*/
-- Resposta:
CREATE TABLE PESSOAS
( COD_PESSOA		TIPO_CODIGO	IDENTITY 	PRIMARY KEY,
  NOME			VARCHAR(30),
  ENDERECO		TIPO_ENDERECO,
  SEXO			TIPO_SEXO )
-- Crie tabela Contas
/*	
	CONTAS

	COD_CONTA	TIPO_CODIGO	autonumeração	chave primária
	VALOR		NUMERIC(10,2)
	QTD_PARCELAS	TIPO_PRAZO
	PORC_MULTA	TIPO_ALIQUOTA
*/
-- Resposta: 
CREATE TABLE CONTAS
( COD_CONTA		TIPO_CODIGO  	IDENTITY 	PRIMARY KEY,
  VALOR			NUMERIC(10,2),
  QTD_PARCELAS		TIPO_PRAZO,
  PORC_MULTA		TIPO_ALIQUOTA )
 
-- 11. Insira 5 registros na tabela PESSOAS
-- Resposta:
INSERT INTO PESSOAS VALUES ('MAGNO', 'RUA A','M')
INSERT INTO PESSOAS VALUES ('PEDRO', 'RUA B','M')
INSERT INTO PESSOAS VALUES ('SONIA', 'RUA C','F')
INSERT INTO PESSOAS VALUES ('LUIZA', 'RUA D','F')
INSERT INTO PESSOAS VALUES ('JULIO', 'RUA E','M')

-- 12. Exiba os registros da tabela PESSOAS
-- Resposta: 
SELECT * FROM PESSOAS

--13. Crie a tabela Funcionario, seguindo o modelo adiante:
/*
Funcionario
COD_FUNC		TIPO_CODIGO    	chave primária,
NOME			VARCHAR(30)
ENDERECO		VARCHAR(80)
SEXO			TIPO_SEXO 
*/

CREATE TABLE FUNCIONARIO (
COD_FUNC		TIPO_CODIGO    	PRIMARY KEY,
NOME			VARCHAR(30),
ENDERECO		VARCHAR(80),
SEXO			TIPO_SEXO )

--14. Crie um sinônimo de nome tb_Funcionario para a tabela FUNCIONARIO. 
CREATE SYNONYM TB_FUNCIONARIO FOR DBO.FUNCIONARIO 

--15. Crie uma SEQUENCE de nome SQ_FUNCIONARIO, que inicie em 100 com incremento 2.
CREATE SEQUENCE SQ_FUNCIONARIO
START WITH 100
INCREMENT BY 1;

--16.Insira um registro na tabela FUNCIONARIO utilizando a SEQUENCE SQ_FUNCIONARIO e o sinônimo Funcionario.
INSERT INTO TB_FUNCIONARIO (COD_FUNC , NOME , ENDERECO ,SEXO)
VALUES (NEXT VALUE FOR DBO.SQ_FUNCIONARIO, 'ANTONIO DA SILVA', 'AV PAULISTA, 1009' , 'M');


---A – Trabalhando com objetos binários

/*1. Crie a tabela TB_Documento com as características:
- ID_DOCUMENTO inteiro  auto numerável e chave primária
- Descrição do documento – Texto livre com até 100 caracteres
- Data do Cadastro – Deve possuir valor padrão (Data e Hora do servidor)
- Documento – Campo binário 
*/
GO
CREATE TABLE TB_Documento 
(
ID_DOCUMENTO	INT		IDENTITY PRIMARY KEY,
DESCRICAO		VARCHAR(100),
DATA_CADASTRO	DATETIME DEFAULT (GETDATE()),
Documento		VARBINARY(MAX) 
)

GO
--2. Insira 2 documentos na tabela TB_DOCUMENTO

Insert Into TB_Documento(DESCRICAO, DOCUMENTO)
	Select 'Planilha Excel', BulkColumn 
	from Openrowset (Bulk 'C:\DADOS\PESSOA.XLS', Single_Blob) as Image

Insert Into TB_Documento(DESCRICAO, DOCUMENTO)
	Select 'Arquivo Texto', BulkColumn 
	from Openrowset (Bulk 'C:\DADOS\ArqTXT.txt', Single_Blob) as Image

--3. Consulte a tabela TB_DOCUMENTO.
SELECT * FROM TB_Documento

--Habilitando FILETABLE
-- No SQL Server Management Studio execute o comando:
-- Enable Filestream
EXEC sp_configure filestream_access_level, 2
RECONFIGURE

--6. Para criar um banco com FILESTREAM execute o comando abaixo:
CREATE DATABASE Banco_LAB3
ON PRIMARY
(Name = FG_Filestream_PRIMARY,
FILENAME = 'C:\DADOS\LAB_Filestream_DATA3.mdf'),
FILEGROUP FG_Filestream_FS CONTAINS FILESTREAM
(NAME = Filestream_ARQ,
FILENAME='C:\DADOS\LAB_Filestream_ARQ3')
LOG ON
(Name = Filestream_log,
FILENAME = 'C:\DADOS\LAB_Filestream_log3.ldf')
WITH FILESTREAM (NON_TRANSACTED_ACCESS = FULL,
DIRECTORY_NAME = N'Filestream_ARQ3');
GO

--C- Inserindo e visualizando arquivos 
--1.Coloque o banco BANCO_LAB3 em uso;
USE BANCO_LAB3

--2.Crie uma tabela FILETABLE de nome FT_Documento;
CREATE TABLE FT_Documento AS FileTable 

--3.Insira 2 documentos nesta tabela;
Insert Into FT_Documento (name, file_stream)
   Select 'Planilha Excel', BulkColumn 
   from Openrowset (Bulk 'C:\DADOS\PESSOA.XLS', Single_Blob) as Image

Insert Into FT_Documento(name, file_stream)
	Select 'Arquivo Texto', BulkColumn 
	from Openrowset (Bulk 'C:\DADOS\ArqTXT.txt', Single_Blob) as Image

--5. Visualize os documentos com comando TSQL.
SELECT * FROM FT_Documento

--OU

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


--Laboratório 3

---A – Trabalhando com Colunas computadas

--1.Coloque o banco PEDIDOS em uso;
USE PEDIDOS

/*2.Crie a tabela TB_FUNC_IDADE  com os campos:

- Id_funcionario		inteiro, auto numerável e chave primária
- Nome do funcionário	alfanumérico com 50 caracteres
- Data de Nascimento	Campo data
- Idade 				Campo calculado
*/
GO
CREATE TABLE TB_FUNC_IDADE 
(
Id_funcionario		INT		IDENTITY	PRIMARY KEY,	
FUNCIONARIO			VARCHAR(50) , 
Data_Nascimento		DATETIME,
Idade 				AS CAST(FLOOR(CAST(GETDATE()- data_nascimento AS FLOAT)/365.25) AS INT )
)
GO
--3. Insira os dados da tabela de empregados para a tabela TB_FUNC_IDADE;
INSERT INTO TB_FUNC_IDADE
SELECT NOME, DATA_NASCIMENTO FROM TB_EMPREGADO

--4. Consulte as informações e verifique o campo calculado.
SELECT * FROM TB_FUNC_IDADE

/*5. Adicione o campo VLR_ITEM na tabela TB_ITENSPEDIDO, com o cálculo abaixo:

PR_UNITARIO * QUANTIDADE * (1 - DESCONTO /100)*/

ALTER TABLE TB_ITENSPEDIDO ADD
	VLR_ITEM AS PR_UNITARIO * QUANTIDADE * (1 - DESCONTO /100)


--6. Faça uma consulta na tabela e verifique o resultado.

SELECT * FROM TB_ITENSPEDIDO
