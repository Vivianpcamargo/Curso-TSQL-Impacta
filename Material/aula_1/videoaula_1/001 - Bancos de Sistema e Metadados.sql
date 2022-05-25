/*
	Metadados são dados que compõem toda a estrutura de um banco de dados. Eles ficam armazenados em
	tabelas de sistema.
	Podem ser obtidos através da leitura de:
	> Tabelas
	> Views
	> Functions
	> Procedures
*/

-- Visualizando metadados de uma view
SELECT * FROM sys.objects;
-- Observe a coluna Type (ver página 24 da apostila)

-- Tabelas de sistema
SELECT * FROM SYSOBJECTS;

-- Tabelas de usuários
USE SisDep;
SELECT * FROM SYSOBJECTS WHERE xtype = 'U';
--Chaves primárias
SELECT * FROM SYSOBJECTS WHERE xtype = 'PK';
--Constraints UNIQUE
SELECT * FROM SYSOBJECTS WHERE xtype = 'UQ';
-- Retornar todas as colunas de todas as tabelas
SELECT * FROM SYSCOLUMNS;
--Retornar o nome de uma tabela e suas colunas, bem como o tipo de dados
SELECT
	T1.name		AS Tabela
	,T2.name	AS Coluna
	,T3.name	AS [Tipo de Dado]
FROM SYSOBJECTS T1,SYSCOLUMNS T2,SYSTYPES T3
WHERE 
	T1.id = T2.id AND T3.xtype = T2.xtype 
	AND T1.xtype =  'U' AND T2.name <> 'sysname'
ORDER BY 1,2;
-- Views de Catálogo (Do Banco Em Uso)
SELECT * FROM SYS.tables;
SELECT * FROM SYS.columns;
SELECT * FROM SYS.types;
SELECT * FROM SYS.indexes;
SELECT * FROM SYS.identity_columns;
SELECT * FROM sys.key_constraints;
-- Procedures de Catálogo
EXEC sp_tables;
EXEC sp_columns Funcionario;
EXEC sp_pkeys Funcionario;
EXEC sp_helpindex Funcionario;
EXEC sp_helpconstraint Funcionario;
EXEC sp_help Funcionario;
EXEC sp_spaceused Funcionario;
EXEC sp_helpuser;
EXEC sp_helplogins;
EXEC sp_helpserver;
EXEC sp_helpdb SisDep;
EXEC sp_helpfile;
EXEC sp_helplanguage;
-- Funções de Catálogo
SELECT DB_NAME();
SELECT OBJECT_ID('Funcionario');
SELECT OBJECT_NAME(277576027);

