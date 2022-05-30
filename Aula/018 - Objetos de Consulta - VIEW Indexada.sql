USE SisDep;
-- VIEW INDEXADA (Obter Melhor Performance)
GO
CREATE VIEW vw_ConsultaSimples
WITH SCHEMABINDING
AS
	SELECT
		idMatricula,NomeFuncionario,Admissao,Salario
	FROM dbo.Funcionario;
GO
CREATE UNIQUE CLUSTERED INDEX IX_ConsultaSimples
ON dbo.vw_ConsultaSimples(NomeFuncionario,Admissao);

SELECT * FROM vw_ConsultaSimples
WHERE NomeFuncionario LIKE 'C%';
--------------------------------------------------------
USE SysConVendas;

SELECT * FROM Dados;

EXEC sp_helpindex Dados;

GO
CREATE VIEW vw_PesquisaCidade
WITH SCHEMABINDING
AS
	SELECT
		Pedido,Vendedor,Regiao,Cidade,Produto,Total
	FROM dbo.Dados;
GO

SELECT * FROM vw_PesquisaCidade

CREATE UNIQUE CLUSTERED INDEX UQ_Cidade
ON vw_PesquisaCidade(Pedido,Vendedor,Regiao,Cidade,Produto,Total);

SELECT * FROM vw_PesquisaCidade
WHERE Cidade = 'São Paulo';

SELECT * FROM Dados
WHERE Cidade = 'São Paulo';