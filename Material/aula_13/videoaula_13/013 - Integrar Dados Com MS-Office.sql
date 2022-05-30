IF(EXISTS(SELECT Name FROM master.dbo.sysdatabases WHERE name = 'DadosExternos'))
	BEGIN
		USE master;
		DROP DATABASE DadosExternos;
	END
GO
CREATE DATABASE DadosExternos
GO
USE DadosExternos;

CREATE TABLE Pedidos
(
	id			int				PRIMARY KEY,
	Produto		nvarchar(100)	NOT NULL,
	DataPedido	date			NOT NULL,
	Quantidade	smallint		NOT NULL,
	PrecoUnit	decimal(9,2)	NOT NULL
);
GO
CREATE TABLE Clientes
(
	id					int				PRIMARY KEY,
	NomeCliente			nvarchar(50),
	CadastroCliente		date
);
INSERT INTO Clientes
(id,NomeCliente,CadastroCliente)
VALUES
(10,'Ana','2015-1-5'),
(20,'Carlos','2015-2-10'),
(30,'Eduardo','2015-3-3'),
(40,'Fernanda','2015-4-15'),
(50,'Mariana','2015-5-20');
GO
CREATE TABLE Produtos
(
	codProduto			int		primary key,
	descricaoProduto	nvarchar(100),
	precoProduto		smallmoney,
	qtdeEstoque			int
);

-- Habilitar visibilidade das opções avançadas
EXEC sp_configure 'show advanced option','1';
RECONFIGURE;
-- Habilitar a função OPENROWSET
EXEC sp_configure 'Ad Hoc Distributed Queries','1';
RECONFIGURE;

-- Importar Dados de um arquivo Excel
-- C:\DADOS\Pedidos.xlsx

-- Habilitar Allow InProcess (Server Objects - Linked Server - Providers)
INSERT INTO Pedidos
SELECT * FROM OPENROWSET
	(
		'Microsoft.ACE.OLEDB.12.0',
		'Excel 12.0;Database=C:\Dados\Pedidos.xlsx',
		'SELECT * FROM [Dados$]'
	);

SELECT * FROM Pedidos;

-- Exportar Dados para um arquivo Excel
INSERT INTO OPENROWSET
	(
		'Microsoft.ACE.OLEDB.12.0',
		'Excel 12.0;Database=C:\Dados\Clientes.xlsx',
		'SELECT * FROM [Dados$]'
	)
SELECT * FROM Clientes;

-- Consultar dados de um arquivo Excel
SELECT * FROM OPENROWSET
	(
		'Microsoft.ACE.OLEDB.12.0',
		'Excel 12.0;Database=C:\Dados\Medicamentos.xlsx;HDR=YES',
		'SELECT * FROM [Base$] where qtde > 100'
	);

-- Consultar dados de um Banco Access
SELECT * FROM OPENROWSET
	(
	'Microsoft.ACE.OLEDB.12.0',
	'C:\Dados\Controle Operacional.accdb';'admin';'',DADOS
	);
SELECT * INTO #teste
FROM OPENROWSET
	(
	'Microsoft.ACE.OLEDB.12.0',
	'C:\Dados\Controle Operacional.accdb';'admin';'',DADOS
	);