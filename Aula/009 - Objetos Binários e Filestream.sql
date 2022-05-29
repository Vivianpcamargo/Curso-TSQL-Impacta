-------------------------------------------------------------------------------------------
-- Dados Binários
USE RecursosAdicionais;

CREATE TABLE tblDocsClientes(
	idDoc			int		identity	primary key,
	descricao		varchar(50),
	documento		varbinary(Max)
);

-- Inserção de um arquivo binário
-- Single_Blob - Utilizado para codificação de leitura binária para arquivos
-- EX:
-- XML (Codificação de Esquema)
-- TXT (Codificação ASCII)
-- PDF (Codificação Binária)
INSERT INTO tblDocsClientes(descricao,documento)
SELECT 'Planilha Excel', BulkColumn
FROM OPENROWSET (BULK 'C:\Dados\03 - Documentos de Clientes.xlsx', Single_Blob) AS ARQ;

SELECT * FROM tblDocsClientes;


-- Atualização 
UPDATE tblDocsClientes 
SET DOCUMENTO =  (
SELECT * FROM OPENROWSET(BULK 'C:\Dados\Arquivo.xlsx', Single_Blob) AS ARQ) 
WHERE idDoc = 1;

-- FILETABLE

-- Passo 1: Habilitar FILESTREAM no SQL Server Configuration Manager

-- Passo 2: Habilitar FILESTREAM no Servidor

EXEC sp_configure filestream_access_level, 2
RECONFIGURE;

-- Passo 3: Banco de Dados com Grupo de Arquivos
CREATE DATABASE Banco_Filestream 
ON PRIMARY (
	NAME = FG_Filestream_PRIMARY, 
	FILENAME = 'C:\DADOS\Filestream_DATA.mdf'), 
	FILEGROUP FG_Filestream_FS 
	CONTAINS FILESTREAM (
		NAME = Filestream_ARQ, 
		FILENAME='C:\DADOS\Filestream_ARQ') 
	LOG ON (
		NAME = Filestream_log, 
		FILENAME = 'C:\DADOS\Filestream_log.ldf') 
		WITH FILESTREAM (NON_TRANSACTED_ACCESS = FULL, 
		DIRECTORY_NAME = N'Filestream_ARQ');

-- Passo 4: Verificar Options - FileStream - Directory Name (Propriedades do Banco)

-- Passo 5: Criar FileTable
USE Banco_Filestream;

CREATE TABLE FT_Documento AS FileTable
	WITH 
	(
		FileTable_Directory = 'Filestream_ARQ',
		FileTable_Collate_Filename = database_default
	); 

SELECT * FROM FT_Documento;
