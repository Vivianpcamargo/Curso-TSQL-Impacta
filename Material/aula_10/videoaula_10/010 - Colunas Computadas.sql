-------------------------------------------------------------------------------------------
-- Colunas Computadas
USE SisDep;

SELECT 
	idMatricula,NomeFuncionario,Salario,Admissao,
	FLOOR(CAST((GETDATE() - Admissao) AS FLOAT) / 365.25 ) AS [Tempo de Serviço]
FROM Funcionario;

ALTER TABLE Funcionario
ADD TempoServico AS
FLOOR(CAST((GETDATE() - Admissao) AS FLOAT) / 365.25 );

SELECT 
	idMatricula,NomeFuncionario,Salario,Admissao,TempoServico
FROM Funcionario;
