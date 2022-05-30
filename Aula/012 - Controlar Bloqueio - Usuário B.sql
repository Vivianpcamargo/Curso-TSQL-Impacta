-- Usuário B
USE SISDEP;
-- Usuário B tenta ler dados da tabela funcionário
SELECT * FROM Funcionario;
-- Forçar a ler dados com atualizações não confirmadas
SELECT * FROM Funcionario WITH(NOLOCK);
-- Isto causa leitura suja (Dirty Read)
-- Ler somente dados que não estão participando da transação (Leitura segura)
SELECT * FROM Funcionario WITH(READPAST);
-- Isto causa uma leitura de dados segura
-- Ira até a janela usuário A e aplicar um Rollback

-- Configurando TimeOut
DBCC USEROPTIONS;
SET LOCK_TIMEOUT 5000;

-- Usuário B tenta ler dados da tabela funcionário
-- Retorno de erro após 5 segundos
SELECT * FROM Funcionario;

-- Confirmar Transação TR03 em usuário A

-- Alterando o nível de isolamento
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- Vá até usuário A e execute transação TR03


-- Usuário B tenta ler dados
SELECT * FROM Funcionario;

-- Retornar para o nível de isolamento read committed
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- Usuário B tenta ler dados novamente
SELECT * FROM Funcionario;

-- Confirmar transação TR03 em usuário A

-- Usuário B inicia nova transação
BEGIN TRAN TR04
	UPDATE Projeto WITH (ROWLOCK)
	SET [DataTermino] = GETDATE()
	WHERE idProjeto = 2

SELECT * FROM projeto

-- Na Janela Usuário A visualizar
-- Bloqueios por transação

-- Visualizando transações ativas nesta seção
SELECT @@TRANCOUNT;