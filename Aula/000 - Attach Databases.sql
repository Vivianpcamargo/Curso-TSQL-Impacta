/*
|-----------------------------------------------------------------------------------------
| * * INSTALLING DATABASES * *					      
| WARNING: Keep files on directory C:\DATABASES Connected SA Account
| Note if the folder has administrator privileges
| Script by H�lio de Almeida										                           
| Create: 2010/1/20 - Modified: 2015/4/21							   
|-----------------------------------------------------------------------------------------
*/

------------------------------------------------------------------------------------------------		
		EXEC SP_ATTACH_DB 
			@DBNAME ='SisDep',
			@FILENAME1 = 'C:\DATABASES\SisDep.mdf',
			@FILENAME2 = 'C:\DATABASES\SisDep_log.ldf';
------------------------------------------------------------------------------------------------		
		EXEC SP_ATTACH_DB 
			@DBNAME ='Clientes',
			@FILENAME1 = 'C:\DATABASES\clientes.mdf',
			@FILENAME2 = 'C:\DATABASES\clientes_log.ldf';

------------------------------------------------------------------------------------------------			
		EXEC SP_ATTACH_DB 
			@DBNAME ='SeguroVeiculo',
			@FILENAME1 = 'C:\DATABASES\SeguroVeiculo.mdf',
			@FILENAME2 = 'C:\DATABASES\SeguroVeiculo_log.ldf';
------------------------------------------------------------------------------------------------
		EXEC SP_ATTACH_DB 
			@DBNAME ='SysConVendas',
			@FILENAME1 = 'C:\DATABASES\SysConVendas.mdf',
			@FILENAME2 = 'C:\DATABASES\SysConVendas_log.ldf';
------------------------------------------------------------------------------------------------
		EXEC SP_ATTACH_DB 
			@DBNAME ='Consorcio',
			@FILENAME1 = 'C:\DATABASES\Consorcio.mdf',
			@FILENAME2 = 'C:\DATABASES\Consorcio_log.ldf';
------------------------------------------------------------------------------------------------	
		PRINT 'DATABASE IS READY NOW...'

------------------------------------------------------------------------------------------------
-- This code is SQL Módulo II For
------------------------------------------------------------------------------------------------
GO
CREATE DATABASE RecursosAdicionais;
GO
USE RecursosAdicionais;
-- Tabela para exemplicificar IDENTITY
CREATE TABLE Instrutores
(
	id					int			identity(10,5)
	Constraint	PK_Instrutores_id PRIMARY KEY(id)
	,nomeInstrutor		varchar(50)
);
GO
-- Tabela para Exemplificar MERGE
CREATE TABLE Base1
(
	id			int		primary key,
	produto		varchar(50),
	valor		smallmoney
);
GO
CREATE TABLE Base2
(
	id			int		primary key,
	produto		varchar(50),
	valor		smallmoney
);

INSERT INTO Base1
(id,produto,valor)
VALUES
(1,'Mouse',55),
(2,'Impressora',375),
(5,'Teclado',80),
(7,'Pen Drive',16),
(8,'HD Externo',200),
(10,'Office 2013',570),
(12,'Windows 8.1',230);

INSERT INTO Base2
(id,produto,valor)
VALUES
(1,'Mouse',77),
(5,'Teclado',100),
(7,'Pen Drive',16),
(10,'Office 2010',570),
(12,'Windows 8.1',230),
(15,'Notebook',1870);