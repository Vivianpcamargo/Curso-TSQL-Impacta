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

-- Aplicar um reajuste de selários em 10% para funcioários
-- que ganham até 2 mil e ser admitido antes de 2005
-- Somente os 10 mais antigos
Use SisDep;
WITH Reajuste
AS
(
    SELECT TOP 10 Salario,Admissao,NomeFuncionario
    FROM Funcionario
	WHERE Salario <= 2000 AND YEAR(Admissao) < 2005
    ORDER BY Admissao ASC 
)
UPDATE Reajuste
SET Salario *= 1.1
OUTPUT
	deleted.NomeFuncionario,
	deleted.Salario AS [Salário Anterior],
	inserted.Salario AS [Novo Salário]
