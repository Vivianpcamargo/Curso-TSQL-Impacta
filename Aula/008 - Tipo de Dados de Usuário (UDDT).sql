-- Visualizando Tipos de Dados do SQL Server
-- Tabela de Sistema
SELECT * FROM systypes;
-- View de Sistema
SELECT * FROM sys.types;

-- Criando Banco UDDT
CREATE DATABASE UDDT;
GO
USE UDDT;

-- Criando Tipos de Dados Personalizados (UDDT)
CREATE TYPE NomePessoa
FROM varchar(50) NOT NULL;

CREATE TYPE ValorMonetario
FROM decimal(10,2) NOT NULL;

CREATE TYPE OpcaoSN
FROM char(1) NOT NULL;

CREATE TYPE DataRegra
FROM date NULL;

-- Visualizando somente os tipos personalizados
SELECT * FROM systypes WHERE uid = 1;

SELECT * FROM sys.types WHERE schema_id = 1;

-- Criando Regras de Validação
GO
CREATE rule r_ValorMonetario AS @valor >=0;
GO
CREATE rule r_OpcaoSN AS @sn IN('S','N');
GO
CREATE rule r_DataRegra AS @data BETWEEN '2014-1-1' AND getdate();
GO
-- Visualizando regras criadas
SELECT * FROM sysobjects WHERE xtype = 'r';

-- Associando as regras aos tipos criados
EXEC sp_bindrule 'r_ValorMonetario','ValorMonetario';
EXEC sp_bindrule 'r_OpcaoSN','OpcaoSN';
EXEC sp_bindrule 'r_DataRegra','DataRegra';

-- Criando Defaults
GO
CREATE DEFAULT def_SN AS 'S'
GO
CREATE DEFAULT def_DataRegra AS GETDATE();
GO

-- Visualizando defaults
SELECT * FROM sysobjects WHERE xtype = 'd';

-- Associando os defaults aos tipos criados
EXEC sp_bindefault 'def_SN','OpcaoSN';
EXEC sp_bindefault 'def_DataRegra','DataRegra';

-- Criando Sequencial (Identity Personalizado)
CREATE SEQUENCE seq_Registro
	START WITH 1000
	increment BY 10
	minvalue 10
	maxvalue 100000
	cycle -- Indica para retornar ao valor mínimo se o valor máximo for alcançado [cycle / no cycle]
	cache 10 -- Aumentar desempenho dos aplicativos que se comunicarão com o Banco; [cache (nº de valores mantidos no cache) / no cache]

-- visualizando sequências criadas
SELECT * FROM sys.sequences;

-- Utilizando UDDT e sequência criada
CREATE TABLE TabelaUDDT
(
	id				int primary key,
	NomeCliente		NomePessoa,
	StatusAtivo		OpcaoSN,
	cadastroCliente	DataRegra,
);

-- Inserindo Dados
-- OBS: Para utilizarmos a sequência deveremos utilizar a instrução NEXT VALUE FOR
INSERT INTO TabelaUDDT
(id,NomeCliente,StatusAtivo,cadastroCliente)
VALUES
(NEXT VALUE FOR dbo.seq_Registro,'Hélio de Almeida','S','2015-6-6');

SELECT * FROM TabelaUDDT;

-- Testando Defaults
INSERT INTO TabelaUDDT
(id,NomeCliente)
VALUES
(NEXT VALUE FOR dbo.seq_Registro,'Nicolas Fernandes');

SELECT * FROM TabelaUDDT;

-- Testando Regras
-- Status
INSERT INTO TabelaUDDT
(id,NomeCliente,StatusAtivo,cadastroCliente)
VALUES
(NEXT VALUE FOR dbo.seq_Registro,'Rosangela Raquel','X','2015-4-15');

-- Cadastro
INSERT INTO TabelaUDDT
(id,NomeCliente,StatusAtivo,cadastroCliente)
VALUES
(NEXT VALUE FOR dbo.seq_Registro,'Rosangela Raquel','N','2013-7-5');

-- Criando Sinônimos
CREATE SYNONYM TabT FOR dbo.TabelaUDDT;

-- Visualizando Sinônimos criados
SELECT * FROM sys.synonyms

-- Utilizando um Sinônimo
SELECT * FROM TabT;
