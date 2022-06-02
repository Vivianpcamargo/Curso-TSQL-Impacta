Use SisDep;

SELECT DISTINCT 
	F.NomeFuncionario,CA.[Mais Novo],CA.[Mais Velho]
FROM Funcionario AS F INNER JOIN Dependente AS D
ON F.idMatricula = D.idMatricula

CROSS APPLY
(
	SELECT MAX(NascimentoDependente)AS [Mais Novo], MIN(NascimentoDependente)AS [Mais Velho]
	FROM Dependente AS D
	WHERE D.idMatricula = F.idMatricula
)AS CA;


SELECT DISTINCT
	D.NomeDepartamento,CA.[Primeira Contratação],ca.[Última Contratação]
FROM Funcionario AS F INNER JOIN Depto AS D
ON F.idDepartamento = D.idDepartamento
AND D.NomeDepartamento IN('Administrativo','Financeiro','RH','TI')

CROSS APPLY
(
	SELECT 
		MAX(admissao) [Última Contratação],
		MIN(admissao) AS [Primeira Contratação]
	FROM Funcionario AS F
	WHERE F.idDepartamento = D.idDepartamento
	AND YEAR(F.Admissao) BETWEEN 2000 AND 2005
) AS CA;
