CREATE DATABASE TESTE_PROC
GO
USE TESTE_PROC

GO

CREATE PROCEDURE PROC_A
AS BEGIN
PRINT 'PROC_A  -  ' + CAST( @@NESTLEVEL AS VARCHAR(2) );
EXEC PROC_B;
PRINT 'VOLTEI PARA PROC_A'
END

GO

CREATE PROCEDURE PROC_B
AS BEGIN
PRINT 'PROC_B  -  ' + CAST( @@NESTLEVEL AS VARCHAR(2) );
EXEC PROC_C;
PRINT 'VOLTEI PARA PROC_B'
END

GO

CREATE PROCEDURE PROC_C
AS BEGIN
PRINT 'PROC_C  -  ' + CAST( @@NESTLEVEL AS VARCHAR(2) );
END

GO

EXEC PROC_A

---------------------------------------------------------------
-- 1.
GO
USE PEDIDOS;

GO
CREATE PROCEDURE STP_TOT_VENDIDO @ANO INT
AS BEGIN
SELECT MONTH( DATA_EMISSAO ) AS MES,
       YEAR( DATA_EMISSAO ) AS ANO,
       SUM( VLR_TOTAL ) AS TOT_VENDIDO
FROM TB_PEDIDO
WHERE YEAR(DATA_EMISSAO) = @ANO
GROUP BY MONTH(DATA_EMISSAO), YEAR(DATA_EMISSAO)
ORDER BY MES
END

GO

--- Testando
EXEC STP_TOT_VENDIDO 2013
EXEC STP_TOT_VENDIDO 2014

GO

-- 2.

CREATE PROCEDURE STP_ITENS_PEDIDO @DT1 DATETIME,
                                  @DT2 DATETIME,
                                  @CLIENTE VARCHAR(40) = '%', 
                                  @VENDEDOR VARCHAR(40) = '%'
AS BEGIN
SELECT 
  I.NUM_PEDIDO, I.NUM_ITEM, I.ID_PRODUTO, I.COD_PRODUTO,
  I.QUANTIDADE, I.PR_UNITARIO, I.DESCONTO, I.DATA_ENTREGA,
  PE.DATA_EMISSAO, PR.DESCRICAO, C.NOME AS CLIENTE,
  V.NOME AS VENDEDOR
FROM TB_PEDIDO PE
  JOIN TB_CLIENTE C ON PE.CODCLI = C.CODCLI
  JOIN TB_VENDEDOR V ON PE.CODVEN = V.CODVEN
  JOIN TB_ITENSPEDIDO I ON PE.NUM_PEDIDO = I.NUM_PEDIDO
  JOIN TB_PRODUTO PR ON I.ID_PRODUTO = PR.ID_PRODUTO
WHERE PE.DATA_EMISSAO BETWEEN @DT1 AND @DT2 AND
      C.NOME LIKE @CLIENTE AND V.NOME LIKE @VENDEDOR
ORDER BY I.NUM_PEDIDO
END

GO

-- Passando todos os parâmetros
EXEC STP_ITENS_PEDIDO '2014.1.1', '2014.1.31', '%BRINDES%', 'LEIA'

--Podemos também omitir o nome do vendedor, que é o último parâmetro:

-- Omitindo o nome do vendedor
EXEC STP_ITENS_PEDIDO '2014.1.1', '2014.1.31', '%BRINDES%'


--Podemos, ainda, omitir os nomes do vendedor e do cliente:

-- Omitindo o nome do vendedor e do cliente
EXEC STP_ITENS_PEDIDO '2014.1.1', '2014.1.31'


--Se tentarmos, contudo, omitir apenas o nome do cliente, a passagem posicional não será adequada, como podemos observar a seguir
EXEC STP_ITENS_PEDIDO '2013.1.1', '2014.1.31', '%LEIA%' 
--                    @DT1,      @DT2,       @CLIENTE

  
--Os parâmetros também podem ser passados nominalmente, conforme vemos a seguir:
EXEC STP_ITENS_PEDIDO @DT1 = '2014.1.1', 
                      @DT2 = '2014.1.31',
                      @VENDEDOR = 'LEIA%'



-- 3.                      
GO

CREATE PROCEDURE STP_ULT_DATA_COMPRA @CODCLI INT
AS BEGIN
IF NOT EXISTS( SELECT * FROM TB_PEDIDO
               WHERE CODCLI = @CODCLI )
   RETURN -1;
               
SELECT MAX(DATA_EMISSAO) AS ULT_DATA_COMPRA 
FROM TB_PEDIDO WHERE CODCLI = @CODCLI;
END 
GO
                   
-- Teste 1
DECLARE @RET INT;
EXEC @RET = STP_ULT_DATA_COMPRA 3
IF @RET < 0 PRINT 'NÃO EXISTE PEDIDO DESTE CLIENTE'
-- Teste 2
DECLARE @RET INT;
EXEC @RET = STP_ULT_DATA_COMPRA 1
IF @RET < 0 PRINT 'NÃO EXISTE PEDIDO DESTE CLIENTE'


-- 4. 
GO
CREATE PROCEDURE STP_COPIA_PRODUTO @ID_PRODUTO INT
AS BEGIN
DECLARE @ID_PRODUTO_NOVO INT;
-- Copia o registro existente para um novo registro
INSERT INTO TB_PRODUTO
( COD_PRODUTO, DESCRICAO, COD_UNIDADE, COD_TIPO, PRECO_CUSTO,
  PRECO_VENDA, QTD_ESTIMADA, QTD_REAL, QTD_MINIMA, CLAS_FISC,
  IPI, PESO_LIQ )
SELECT COD_PRODUTO, DESCRICAO, COD_UNIDADE, COD_TIPO, PRECO_CUSTO,
  PRECO_VENDA, QTD_ESTIMADA, QTD_REAL, QTD_MINIMA, CLAS_FISC,
  IPI, PESO_LIQ
FROM TB_PRODUTO
WHERE ID_PRODUTO = @ID_PRODUTO;
-- Descobre qual foi o ID_PRODUTO gerado
SET @ID_PRODUTO_NOVO = SCOPE_IDENTITY();
-- Retorna para a aplicação cliente o novo ID_PRODUTO gerado
PRINT @ID_PRODUTO_NOVO;  
END
GO
-- Testando
EXEC STP_COPIA_PRODUTO 10


------------
GO

ALTER PROCEDURE STP_COPIA_PRODUTO @ID_PRODUTO INT
AS BEGIN
DECLARE @ID_PRODUTO_NOVO INT;
-- Copia o registro existente para um novo registro
INSERT INTO TB_PRODUTO
( COD_PRODUTO, DESCRICAO, COD_UNIDADE, COD_TIPO, PRECO_CUSTO,
  PRECO_VENDA, QTD_ESTIMADA, QTD_REAL, QTD_MINIMA, CLAS_FISC,
  IPI, PESO_LIQ )
SELECT COD_PRODUTO, DESCRICAO, COD_UNIDADE, COD_TIPO, PRECO_CUSTO,
  PRECO_VENDA, QTD_ESTIMADA, QTD_REAL, QTD_MINIMA, CLAS_FISC,
  IPI, PESO_LIQ
FROM TB_PRODUTO
WHERE ID_PRODUTO = @ID_PRODUTO;
-- Descobre qual foi o ID_PRODUTO gerado
SET @ID_PRODUTO_NOVO = SCOPE_IDENTITY();
-- Retorna para a aplicação cliente o novo ID_PRODUTO gerado
SELECT @ID_PRODUTO_NOVO AS ID_PRODUTO_NOVO;  
END
GO
-- Testando
EXEC STP_COPIA_PRODUTO 10


-------------
GO

ALTER PROCEDURE STP_COPIA_PRODUTO @ID_PRODUTO INT,
                                  @ID_PRODUTO_NOVO INT OUTPUT
AS BEGIN
-- Copia o registro existente para um novo registro
INSERT INTO TB_PRODUTO
( COD_PRODUTO, DESCRICAO, COD_UNIDADE, COD_TIPO, PRECO_CUSTO,
  PRECO_VENDA, QTD_ESTIMADA, QTD_REAL, QTD_MINIMA, CLAS_FISC,
  IPI, PESO_LIQ )
SELECT COD_PRODUTO, DESCRICAO, COD_UNIDADE, COD_TIPO, PRECO_CUSTO,
  PRECO_VENDA, QTD_ESTIMADA, QTD_REAL, QTD_MINIMA, CLAS_FISC,
  IPI, PESO_LIQ
FROM TB_PRODUTO
WHERE ID_PRODUTO = @ID_PRODUTO;
-- Descobre qual foi o ID_PRODUTO gerado
SET @ID_PRODUTO_NOVO = SCOPE_IDENTITY();
END
GO
-- Testando
DECLARE @IDPROD INT;
EXEC STP_COPIA_PRODUTO 10, @IDPROD OUTPUT;
PRINT 'NOVO PRODUTO = ' + CAST(@IDPROD AS VARCHAR(5));


---CURSOR

--Declara as variáveis de apoio
DECLARE @COD_SUP INT, @SUPERVISOR VARCHAR(35), @QTD INT

--Declara o cursor selecionando os supervisores
DECLARE CURSOR_SUPERVISOR CURSOR FORWARD_ONLY FOR
SELECT DISTINCT COD_SUPERVISOR FROM TB_EMPREGADO WHERE COD_SUPERVISOR IS NOT NULL

-- Abre o Cursor
OPEN CURSOR_SUPERVISOR

-- Movimenta o Cursor para a 1ª linha
FETCH NEXT FROM CURSOR_SUPERVISOR INTO @COD_SUP;

-- Enquanto o cursor possuir linhas, a variável @@FETCH_STATUS estará com valor 0
WHILE @@FETCH_STATUS = 0
	BEGIN
		-- Busca o nome do Supervisor
		SELECT	@SUPERVISOR = NOME	FROM TB_EMPREGADO
      WHERE CODFUN = @COD_SUP
		-- Busca a quantidade de subordinados do supervisor
		SELECT	@QTD = COUNT(*)		FROM TB_EMPREGADO
           WHERE COD_SUPERVISOR = @COD_SUP 
           AND CODFUN <> @COD_SUP
		-- Apresenta a informação
	PRINT	@SUPERVISOR + ' - ' + CAST(@QTD AS VARCHAR(3)) + ' Subordinados'

		-- Move o cursor para a próxima linha
		FETCH NEXT FROM CURSOR_SUPERVISOR INTO @COD_SUP;
	END
--Fecha o cursor
CLOSE		CURSOR_SUPERVISOR
-- Remove da memória
DEALLOCATE	CURSOR_SUPERVISOR

----

GO

CREATE PROCEDURE STP_MALA_DIRETA
AS BEGIN
-- Declarar variável do tipo CURSOR para "percorrer" um SELECT
DECLARE CR_MALA CURSOR KEYSET 
   FOR SELECT NOME FROM TB_CLIENTE
       WHERE ESTADO = 'MG';
-- Declarar uma variável para cada campo do cursor
DECLARE @NOME VARCHAR(50);
-- Contador de colunas
DECLARE @CONT INT;
-- Acumulador de nomes. Será usada para armazenar os 3 
-- nomes que serão gerados para cada linha do texto
DECLARE @NOMES VARCHAR(150)
-- Abrir o cursor
OPEN CR_MALA;
-- Ler a primeira linha do cursor
FETCH FIRST FROM CR_MALA INTO @NOME;
-- Enquanto não chegar no final dos dados
WHILE @@FETCH_STATUS = 0
   BEGIN
   -- "Limpar" a variável @NOMES
   SET @NOMES = '';
   -- Atribuir 1 à variável @CONT
   SET @CONT = 1;
   -- Enquanto o contador for menor ou igual a 3 e
   -- não chegar no final dos dados do SELECT
   WHILE @CONT <= 3 AND @@FETCH_STATUS = 0
      BEGIN
      -- Alterar o nome lido acrescentando espaços
      -- de modo que fique com tamanho total 50
      SET @NOME = @NOME + SPACE( 50 - LEN( @NOME) ); 
      -- Concatenar o nome na variável @NOMES
      SET @NOMES = @NOMES + @NOME;
      -- Ler o próximo registro
      FETCH NEXT FROM CR_MALA INTO @NOME;
      -- Incrementar o contador de colunas
      SET @CONT = @CONT + 1;
      END
   -- Imprimir a variável @NOME na área de mensagens   
   PRINT @NOMES;
   END
-- Fechar o cursor
CLOSE CR_MALA;
-- Liberar memória do cursor
DEALLOCATE CR_MALA;
END
GO
---- Testando
EXEC STP_MALA_DIRETA


-- Cria um Datatype tabular
GO
CREATE TYPE TypeTabCargos AS TABLE
(
	CARGO			VARCHAR(40),
	SALARIO_INIC	NUMERIC(10,2)
)
GO
-- Cria uma procedure para inserir dados em TB_CARGO
CREATE PROCEDURE STP_INSERE_CARGOS( @DADOS TypeTabCargos READONLY)
AS BEGIN
INSERT INTO TB_CARGO (CARGO, SALARIO_INIC)
SELECT CARGO, SALARIO_INIC FROM @DADOS;
END 


-- Selecione todo este bloco e execute -----
DECLARE @DADOS_CARGO TypeTabCargos;
INSERT INTO @DADOS_CARGO VALUES ('TESTANDO 1', 500);
INSERT INTO @DADOS_CARGO VALUES ('TESTANDO 2', 600);
INSERT INTO @DADOS_CARGO VALUES ('TESTANDO 3', 700);
INSERT INTO @DADOS_CARGO VALUES ('TESTANDO 4', 800);
EXEC STP_INSERE_CARGOS @DADOS_CARGO;

--------------------------------------------
SELECT * FROM TB_CARGO

--Para aumentar em 20% o preço de venda de todos os produtos, você utiliza o comando:
UPDATE TB_PRODUTO SET PRECO_VENDA = PRECO_VENDA * 1.2


--Utilizando o SET NOCOUNT ON esta mensagem é descartada.
SET NOCOUNT ON
UPDATE TB_PRODUTO SET PRECO_VENDA = PRECO_VENDA * 1.2


UPDATE TB_PRODUTO SET PRECO_VENDA = PRECO_VENDA * 1.2

SELECT @@ROWCOUNT AS QTD

--Query dinâmicas

--Execução de um comando diretamente pelo comando EXEC:

EXEC('SELECT * FROM TB_PEDIDO' )

--Utilizando uma variável:
DECLARE @SQL VARCHAR(300)

SET @SQL = 'SELECT * FROM TB_PEDIDO'
EXEC( @SQL )

--Compondo um comando com variáveis:

DECLARE @SQL VARCHAR(300) , @CODCLI INT

SET @CODCLI = 5

SET @SQL = 'SELECT * FROM TB_PEDIDO WHERE CODCLI=' + CAST(@CODCLI AS VARCHAR(5)) 
EXEC( @SQL )

--- Tratamento de erros

--Adicionando uma mensagem de erro devido à quantidade nula, severidade 16 e código 50001:
EXEC SP_ADDMESSAGE 50001,16,'Proibido inserir quantidade nula.';


--Para consultar as mensagens, utilize a tabela de sistemas SYS.MESSAGES:
SELECT * FROM SYS.messages WHERE MESSAGE_id>=50001


--Incluindo uma nova mensagem:
EXEC SP_ADDMESSAGE 50002,16,'Proibido inserir quantidade nula.';

--Excluindo a mensagem:
EXEC SP_DROPMESSAGE 50002

--Neste exemplo será retornada a mensagem de código 50001 criada com o SP_ADDMESAGE:
RAISERROR (50001,-1,-1, 'Erro!!');


GO

USE PEDIDOS

GO
-- Faz o PRECO_VENDA de TB_PRODUTO ficar menor que o PRECO_CUSTO
UPDATE TB_PRODUTO SET PRECO_VENDA = PRECO_CUSTO * 0.9
WHERE ID_PRODUTO = 1

 
-- Cria CONSTRAINT que impede que o PRECO_VENDA seja menor que PRECO_CUSTO
-- a cláusula WITH NOCHECK é necessária, pois já existe uma linha violando esta CONSTRAINT
ALTER TABLE TB_PRODUTO WITH NOCHECK 
ADD CONSTRAINT CK_PRECO_VENDA CHECK(PRECO_VENDA >= PRECO_CUSTO)
GO

-- procedure para criar uma cópia de um produto
CREATE PROCEDURE STP_COPIA_PRODUTO @ID_PRODUTO_FONTE INT
AS BEGIN
-- declara variável para o ID do novo produto gerado
DECLARE @ID_PRODUTO_NOVO INT;
BEGIN TRY
    -- se o ID_PRODUTO passado como parâmetro não existir	
    IF NOT EXISTS(SELECT * FROM TB_PRODUTO
	              WHERE ID_PRODUTO = @ID_PRODUTO_FONTE) 
       BEGIN
	   -- gera um erro, o que provoca a execução do bloco CATCH
	   THROW 60000, 'PRODUTO NÃO EXISTE',1
	   END

	-- executa INSERT de SELECT na tabela TB_PRODUTO para efetuar a cópia
	INSERT INTO TB_PRODUTO ( COD_PRODUTO, DESCRICAO, COD_UNIDADE, COD_TIPO, PRECO_CUSTO, 
	PRECO_VENDA, QTD_ESTIMADA, QTD_REAL, QTD_MINIMA, CLAS_FISC, IPI, PESO_LIQ)

	SELECT COD_PRODUTO, DESCRICAO, COD_UNIDADE, COD_TIPO, PRECO_CUSTO, PRECO_VENDA, 
	QTD_ESTIMADA, QTD_REAL, QTD_MINIMA, CLAS_FISC, IPI, PESO_LIQ
	FROM TB_PRODUTO WHERE ID_PRODUTO = @ID_PRODUTO_FONTE

	-- descobre o novo ID_PRODUTO gerado
	SET @ID_PRODUTO_NOVO = SCOPE_IDENTITY()
	-- se os dados de TB_PRODUTO estivessem contidos em mais de uma
	-- tabela, aqui viriam os outros INSERTs

	-- retorna o novo ID_PRODUTO para a aplicação que executou a procedure
	SELECT @ID_PRODUTO_NOVO AS ID_PRODUTO_NOVO, 'SUCESSO' AS MSG
END TRY
BEGIN CATCH

    -- recupera informações sobre o erro ocorrido
	-- que pode ser o erro de constraint, que já preparamos,
	-- ou pode ser o erro gerado dentro do bloco TRY
	DECLARE @ERRO VARCHAR(1000) = ERROR_MESSAGE();
	DECLARE @NUM INT = ERROR_NUMBER();
	DECLARE @STATUS INT = ERROR_STATE();
	/*
	-- mantendo o SELECT, a procedure não gera erro no
	-- aplicativo, apenas retorna uma linha com ID_PRODUTO
-- igual a -1 e a mensagem de erro
	SELECT -1 AS ID_PRODUTO_NOVO, @ERRO AS MSG;
	*/
	-- se quisermos provocar um erro no aplicativo
-- que executa a procedure, podemos usar
	-- THROW erroCodigo, erroMsg, erroStatus 
	THROW @NUM, @ERRO, @STATUS
END CATCH
END
GO

SELECT ID_PRODUTO, PRECO_VENDA, PRECO_CUSTO 
FROM TB_PRODUTO
WHERE PRECO_VENDA < PRECO_CUSTO
GO

-- Verifique que, ao executar a procedure, ocorrerá
-- um ERRO de constraint
EXEC STP_COPIA_PRODUTO 1


-- ERRO gerado no bloco TRY
EXEC STP_COPIA_PRODUTO 999

GO

CREATE PROCEDURE STP_COPIA_PEDIDO @NUM_PEDIDO_ANTIGO INT
AS BEGIN
DECLARE @NUM_PEDIDO_NOVO INT
-- Inserir em TB_PEDIDO
INSERT INTO TB_PEDIDO (CODCLI,CODVEN,DATA_EMISSAO,VLR_TOTAL,
      SITUACAO,OBSERVACOES)
SELECT CODCLI,CODVEN,DATA_EMISSAO,VLR_TOTAL,
      SITUACAO,OBSERVACOES 
FROM TB_PEDIDO WHERE NUM_PEDIDO = @NUM_PEDIDO_ANTIGO
-- Descobrir o num. pedido gerado
SET @NUM_PEDIDO_NOVO = SCOPE_IDENTITY()
-- Inserir em TB_ITENSPEDIDO
INSERT INTO TB_ITENSPEDIDO( NUM_PEDIDO,NUM_ITEM,ID_PRODUTO,
            COD_PRODUTO,CODCOR,QUANTIDADE,PR_UNITARIO,
            DATA_ENTREGA,SITUACAO,DESCONTO)
SELECT @NUM_PEDIDO_NOVO,NUM_ITEM,ID_PRODUTO,
       COD_PRODUTO,CODCOR,QUANTIDADE,PR_UNITARIO,
       DATA_ENTREGA,SITUACAO,DESCONTO
FROM TB_ITENSPEDIDO WHERE NUM_PEDIDO = @NUM_PEDIDO_ANTIGO
-- Retornar com o num. pedido gerado
SELECT @NUM_PEDIDO_NOVO AS NUM_PEDIDO_NOVO
END

GO

ALTER TABLE TB_ITENSPEDIDO WITH NOCHECK
ADD CONSTRAINT UQ_ITENSPEDIDO_QUANTIDADE
CHECK( QUANTIDADE > 0 )

GO

EXEC STP_COPIA_PEDIDO 999

--
GO

ALTER PROCEDURE STP_COPIA_PEDIDO @NUM_PEDIDO_ANTIGO INT
AS BEGIN
DECLARE @NUM_PEDIDO_NOVO INT

-- Abrir processo de transação
BEGIN TRAN

-- Inserir em TB_PEDIDO
INSERT INTO TB_PEDIDO (CODCLI,CODVEN,DATA_EMISSAO,VLR_TOTAL,
      SITUACAO,OBSERVACOES)
SELECT CODCLI,CODVEN,DATA_EMISSAO,VLR_TOTAL,
      SITUACAO,OBSERVACOES 
FROM TB_PEDIDO WHERE NUM_PEDIDO = @NUM_PEDIDO_ANTIGO
-- Verificar se houve erro
IF @@ERROR <> 0
   BEGIN
   ROLLBACK
   RETURN
   END


-- Descobrir o num. pedido gerado
SET @NUM_PEDIDO_NOVO = SCOPE_IDENTITY()
-- Inserir em TB_ITENSPEDIDO
INSERT INTO TB_ITENSPEDIDO( NUM_PEDIDO,NUM_ITEM,ID_PRODUTO,
            COD_PRODUTO,CODCOR,QUANTIDADE,PR_UNITARIO,
            DATA_ENTREGA,SITUACAO,DESCONTO)
SELECT @NUM_PEDIDO_NOVO,NUM_ITEM,ID_PRODUTO,
       COD_PRODUTO,CODCOR,QUANTIDADE,PR_UNITARIO,
       DATA_ENTREGA,SITUACAO,DESCONTO
FROM TB_ITENSPEDIDO WHERE NUM_PEDIDO = @NUM_PEDIDO_ANTIGO
-- Verificar se houve erro
IF @@ERROR <> 0
   BEGIN
   ROLLBACK
   RETURN
   END

-- Retornar com o num. pedido gerado
SELECT @NUM_PEDIDO_NOVO AS NUM_PEDIDO_NOVO
-- Finalizar transação gravando
COMMIT
END

GO

EXEC STP_COPIA_PEDIDO 999

GO

ALTER PROCEDURE STP_COPIA_PEDIDO @NUM_PEDIDO_ANTIGO INT
AS BEGIN
DECLARE @NUM_PEDIDO_NOVO INT

-- Abrir processo de transação
BEGIN TRAN
-- Abrir bloco protegido de erro
BEGIN TRY
	-- Inserir em TB_PEDIDO
	INSERT INTO TB_PEDIDO (CODCLI,CODVEN,DATA_EMISSAO,VLR_TOTAL,
		  SITUACAO,OBSERVACOES)
	SELECT CODCLI,CODVEN,DATA_EMISSAO,VLR_TOTAL,
		  SITUACAO,OBSERVACOES 
	FROM TB_PEDIDO WHERE NUM_PEDIDO = @NUM_PEDIDO_ANTIGO

	-- Descobrir o num. pedido gerado
	SET @NUM_PEDIDO_NOVO = SCOPE_IDENTITY()
	-- Inserir em TB_ITENSPEDIDO
	INSERT INTO TB_ITENSPEDIDO( NUM_PEDIDO,NUM_ITEM,ID_PRODUTO,
				COD_PRODUTO,CODCOR,QUANTIDADE,PR_UNITARIO,
				DATA_ENTREGA,SITUACAO,DESCONTO )
	SELECT @NUM_PEDIDO_NOVO,NUM_ITEM,ID_PRODUTO,
		   COD_PRODUTO,CODCOR,QUANTIDADE,PR_UNITARIO,
		   DATA_ENTREGA,SITUACAO,DESCONTO
	FROM TB_ITENSPEDIDO WHERE NUM_PEDIDO = @NUM_PEDIDO_ANTIGO

	-- Retornar com o num. pedido gerado
	SELECT @NUM_PEDIDO_NOVO AS NUM_PEDIDO_NOVO,
           'SUCESSO' AS MSG_ERRO
	-- Finalizar transação gravando
	COMMIT
END TRY
BEGIN CATCH
    ROLLBACK
    SELECT -1 AS NUM_PEDIDO_NOVO,
            ERROR_MESSAGE() AS MSG_ERRO
END CATCH
END

GO

EXEC STP_COPIA_PEDIDO 999
