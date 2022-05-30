-- Importando Dados de um arquivo de texto
USE DadosExternos;

BULK INSERT 
Produtos
FROM 'C:\DADOS\Produtos.txt'
WITH     
	(
		FIELDTERMINATOR =';',
		ROWTERMINATOR = '\n',
		CODEPAGE = 'ACP'
	);

SELECT * FROM Produtos;
---------------------------------------------------------------------------------------
CREATE TABLE Cursos(
	idCurso		int		primary key,
	nomeCurso	nvarchar(50),
	valorCurso	smallMoney
);

-- Utilizar BULK INSERT para inserir o arquivo C:\Dados\Cursos.txt
-- na tabela Cursos

BULK INSERT 
Cursos
FROM 'C:\DADOS\Cursos.txt'
WITH     
	(
		FIELDTERMINATOR =';',
		ROWTERMINATOR = '\n',
		CODEPAGE = 'ACP'
	);

SELECT * FROM Cursos;