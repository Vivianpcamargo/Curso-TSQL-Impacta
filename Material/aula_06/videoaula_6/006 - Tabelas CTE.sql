Use SysConVendas;
WITH CTE(Ano,Mês,MaiorPedido)
AS
	(
		SELECT YEAR(DataPedido) AS Ano, Mes AS Mês, MAX(DataPedido) AS MaiorPedido
		FROM Dados GROUP BY YEAR(DataPedido),Mes
	)
SELECT * FROM CTE WHERE Ano = 2006 AND Mês = 'Abril'
UNION
SELECT * FROM CTE WHERE Ano = 2007 AND Mês = 'Junho'

Use SisDep;
WITH Reajuste
AS
(
    SELECT TOP 10 idMatricula,NomeFuncionario,Admissao,Salario
    FROM Funcionario
    ORDER BY Admissao ASC 
)
UPDATE Reajuste
SET Salario *= 1.1
OUTPUT
	deleted.NomeFuncionario,
	deleted.Salario,
	inserted.Salario
