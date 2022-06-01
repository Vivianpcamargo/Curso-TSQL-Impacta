/*
	Procedures: Procedimentos armazenados

	Um procedimento armazenado (Stored Procedure), é uma coleção de instruções
	que, uma vez armazenadas ou salvas, ficam dentro do servidor de forma pré-compilada.

	Vantagens

		- Modularidade: 
		
			Procedimento divido em partes facilitando manutenção de uma aplicação

		- Diminuição de I/O: 
		
			uma vez que é passado parâmetros para o servidor, chamando o procedimento armazenado,
			as operações são executadas utilizando processamento do servidor 
			e no final deste, é retornado ou não os resultados de uma transação, 
			sendo assim, não há um tráfego imenso de dados pela rede

		- Rapidez na execução: 
		
			os stored procedures, após salvos no servidor, ficam somente aguardando,
			já em uma posição da memória cache, serem chamados para executarem uma operação,
			ou seja, como estão pré-compilados, as ações também já estão pré-carregadas, 
			dependendo somente dos valores dos parâmetros.
			Após a primeira execução, elas se tornam ainda mais rápidas (CACHE)

 
		- Encapsulamento:
			
			podemos ocultar complexidades dentro de um servidor, bastante somente aos
			usuários que irão executar o procedimento conhecer seus parâmetros


		- Segurança de dados: 
		
			 podemos bloquear o código de um procedimento (criptografado) com WITH ENCRYPTION
			 e ainda criar limitações de dados aos usuários.

		- Leitura de Dados Dinâmicos

			através de parâmetros fornecidos, o resultado da busca de informações no
			banco poderá se dar de forma dinâmica

		Restrições

		Dentro de procedures não podemos:

			> Utilizar comandos:
				. CREATE PROCEDURE
				. CREATE DEFAULT
				. CREATE RULE
				. CREATE TRIGGER
				. CREATE VIEW

			> Ter mais que 32 níveis de aninhamento

*/

-- Banco SisDep
USE SisDep;

-- Procedure sem parâmetros para retorno de dados
GO
CREATE PROCEDURE spr_DadosFuncionarios
AS
	SELECT
		F.idMatricula,F.NomeFuncionario,D.NomeDepartamento,
		C.NomeCargo,F.Admissao,F.Salario
	FROM Funcionario F
		INNER JOIN Depto D		ON F.idDepartamento = D.idDepartamento
		INNER JOIN Cargo C		ON F.idCargo = C.idCargo;
GO

-- Procedure com parâmetros para retorno de dados
GO
create PROCEDURE spr_AdmissoesPorAno
@inicio int,@fim int
AS
	SELECT
		F.idMatricula,F.NomeFuncionario,D.NomeDepartamento,
		C.NomeCargo,F.Admissao,F.Salario
	FROM Funcionario F
		INNER JOIN Depto D		ON F.idDepartamento = D.idDepartamento
		INNER JOIN Cargo C		ON F.idCargo = C.idCargo
	WHERE YEAR(F.Admissao) BETWEEN @inicio AND @fim;
GO

-- Parâmetros opcionais
CREATE PROCEDURE spr_ParteDoNome
@parteNome varchar(50) = '%'
AS
	SELECT
		F.idMatricula,F.NomeFuncionario,D.NomeDepartamento,
		C.NomeCargo,F.Admissao,F.Salario
	FROM Funcionario F
		INNER JOIN Depto D		ON F.idDepartamento = D.idDepartamento
		INNER JOIN Cargo C		ON F.idCargo = C.idCargo
	WHERE F.NomeFuncionario Like @parteNome
GO

-- Executando procedures

EXECUTE spr_DadosFuncionarios;
EXEC spr_AdmissoesPorAno 2000,2005;
EXEC spr_AdmissoesPorAno 2000;
EXEC spr_ParteDoNome '%Oliveira';
EXEC spr_ParteDoNome '%Silva%';
EXEC spr_ParteDoNome;

-- Executando procedures com parâmetros explÍcitos
EXEC spr_AdmissoesPorAno  
	@inicio = 2008,
	@fim = 2008;

-- Procedures com retorno
GO
CREATE PROCEDURE spr_PesquisaMatricula
@id int
AS
	IF NOT EXISTS(SELECT * FROM Funcionario WHERE idMatricula = @id)
		RETURN -1

	SELECT
		F.idMatricula,F.NomeFuncionario,D.NomeDepartamento,
		C.NomeCargo,F.Admissao,F.Salario
	FROM Funcionario F
		INNER JOIN Depto D		ON F.idDepartamento = D.idDepartamento
		INNER JOIN Cargo C		ON F.idCargo = C.idCargo
	WHERE F.idMatricula = @id;

-- Executando
EXEC spr_PesquisaMatricula 1025;

EXEC spr_PesquisaMatricula 5000; -- Não conseguimos ver o retorno -1

-- Recuperando retorno
DECLARE @ret int;
EXEC @ret = spr_PesquisaMatricula 5000;
IF @ret < 0 PRINT 'Matrícula Inexistente';

-- Alterando procedure
GO
ALTER PROCEDURE spr_ParteDoNome
@parteNome varchar(50) = '%'
WITH ENCRYPTION
AS
	SELECT
		F.idMatricula,F.NomeFuncionario,D.NomeDepartamento,
		C.NomeCargo,F.Admissao,F.Salario
	FROM Funcionario F
		INNER JOIN Depto D		ON F.idDepartamento = D.idDepartamento
		INNER JOIN Cargo C		ON F.idCargo = C.idCargo
	WHERE F.NomeFuncionario Like @parteNome;

-- Visualizando código de uma procedure
EXEC sp_helptext spr_AdmissoesPorAno; -- Proc está criptografada

EXEC sp_helptext spr_ParteDoNome;

-- Excluir Procedure
DROP PROCEDURE spr_AdmissoesPorAno;

