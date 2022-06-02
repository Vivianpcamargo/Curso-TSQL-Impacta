-- Funções para campos do tipo IDENTITY
-- Banco RecursosAdicionais
USE RecursosAdicionais;
-- Inserindo Dados
INSERT INTO Instrutores
(nomeInstrutor)
VALUES
('Hélio'),('Agnaldo'),('Magno'),('Luciana');

SELECT * FROM Instrutores;

-- Excluir o Instrutor id 3
DELETE FROM Instrutores WHERE id = 20;

-- Reutilizando o id 20
-- Ativando o modo Insert em colunas identity
SET IDENTITY_INSERT Instrutores ON;
INSERT INTO Instrutores
(id,nomeInstrutor)
VALUES
(20,'Márcio');

SELECT * FROM Instrutores;

-- Desativando o modo Insert em colunas identity
SET IDENTITY_INSERT Instrutores OFF;

-- Listar a coluna identity de uma tabela e seus valores
SELECT IDENTITYCOL FROM Instrutores;

-- Retornando o valor inicial
SELECT IDENT_SEED('Instrutores');
-- Retornando o valor de incremento
SELECT IDENT_INCR('Instrutores');

-- Retornando o último identity gerado no escopo da conexão de qualquer tabela
SELECT @@IDENTITY;

-- Retornando o último identity gerado no escopo da conexão de qualquer tabela
-- que tenha sido gerado através de uma procedure ou trigger
-- (Visto mais adiante no treinamento)
SELECT SCOPE_IDENTITY();

-- Retorna o valor original mais atual de uma coluna identity de uma tabela
SELECT IDENT_CURRENT('Instrutores');

DELETE FROM Instrutores;
truncate table instrutores;

INSERT INTO Instrutores
(nomeInstrutor)
Values('Raimundo Nonato');

SELECT * FROM Instrutores;

-- Zerar o contador do Identity
DBCC CHECKIDENT('Instrutores', RESEED,5);

INSERT INTO Instrutores
(nomeInstrutor)
Values('Raimundo Nonato');

SELECT * FROM Instrutores;
