--Laboratório 1
--A – Criando procedures

--1.	Crie uma procedure que retorne os clientes (código, nome, valor e número do pedido), com parâmetro ANO e ordenado pelo nome do cliente.
CREATE PROCEDURE SP_Retorna_vendas @ANO int  AS

BEGIN
	SELECT	C.CODCLI , C.NOME , P.VLR_TOTAL , P.NUM_PEDIDO
	FROM	TB_PEDIDO AS P
	JOIN	TB_CLIENTE AS C ON C.CODCLI = P.CODCLI 
	WHERE	YEAR(P.DATA_EMISSAO)= @ANO	
	ORDER BY C.NOME
END

GO

--2.	Teste a procedure criada com os seguintes anos: 2012, 2013 e 2014
EXEC SP_Retorna_vendas 2012
EXEC SP_Retorna_vendas 2013
EXEC SP_Retorna_vendas 2014

--3.	Crie uma procedure para inserir departamentos na tabela TB_DEPARTAMENTO.
GO
CREATE PROCEDURE SP_INSERE_DEPARTAMENTO  @DEPTO VARCHAR(25) AS
BEGIN
	
	INSERT INTO TB_DEPARTAMENTO VALUES (@DEPTO)

	SELECT 'REGISTRO INSERIDO COM SUCESSO' AS MSG
END
GO

--4.	Insira os departamentos Mensageria e TI

EXEC SP_INSERE_DEPARTAMENTO 'Mensageria'
EXEC SP_INSERE_DEPARTAMENTO 'TI'

--5.	Crie uma procedure para inserir tipo de produto (TB_TIPOPRODUTO).
GO
CREATE PROCEDURE SP_INSERE_TIPOPRODUTO @TIPO VARCHAR(30) AS
BEGIN
	INSERT INTO TB_TIPOPRODUTO VALUES ( @TIPO )
	
	SELECT 'OK' AS MSG
END

GO

--6.	Insira os tipos TESTE e TESTE2.
EXEC SP_INSERE_TIPOPRODUTO 'TESTE'
EXEC SP_INSERE_TIPOPRODUTO 'TESTE2'

--7.	Crie uma procedure que exclua um tipo de produto (TB_TIPOPRODUTO). Antes de excluir é necessário que seja verificado se o tipo de produto é utilizado em produtos.
--O parâmetro deve ser a descrição do Tipo e não o código.
--O retorno deve ser um OK ou NOK para tipos que são utilizados por produtos.

GO
CREATE PROCEDURE SP_EXCLUI_TIPOPRODUTO @TIPO VARCHAR(25) AS 
BEGIN 
	IF EXISTS (	SELECT * 
				FROM TB_PRODUTO AS PR
				JOIN TB_TIPOPRODUTO AS T ON T.COD_TIPO = PR.COD_TIPO 
				WHERE TIPO = @TIPO)
		BEGIN
			SELECT 'NOK' AS MSG
		END
	ELSE
		BEGIN
			DELETE FROM TB_TIPOPRODUTO WHERE TIPO=@TIPO
			SELECT 'OK' AS MSG
		END
END
GO

--8.	Exclua o tipo de Produto TESTE.
EXEC SP_EXCLUI_TIPOPRODUTO 'TESTE'


--9.	Exclua o tipo de produto REGUA.
EXEC SP_EXCLUI_TIPOPRODUTO 'REGUA'

--10.	Crie a tabela TB_Resumo, com os seguintes campos: 
--ID_Resumo  INT auto numerável chave primária
--Ano		INT
--MÊS		INT
--Valor		DECIMAL(10,2)
GO
CREATE TABLE TB_Resumo
(
ID_Resumo	INT IDENTITY PRIMARY KEY,
Ano			INT,
Mes			INT,
Valor		DECIMAL(10,2) 
)
GO

/*11.	Crie uma procedure que carregue as informações da tabela de pedidos. Utilize os parâmetros @ANO INT para filtrar as informações.

- Não insira valores duplicados;
- Exclua os registros do ano antes de realizar a carga;
- Utilize Transações;
- Faça o tratamento de erros com o TRY CATCH;
- Retorne a quantidade de registros carregados;
- Caso ocorra erro, retorne a mensagem.
*/

GO

CREATE PROCEDURE SP_CARREGA_TB_RESUMO @ANO INT   AS
BEGIN
	BEGIN TRAN
	BEGIN TRY
		
		--Apaga registros do Ano e mês
		DELETE FROM TB_Resumo 
		WHERE ANO =@ANO 

		INSERT INTO TB_Resumo 
		SELECT YEAR(DATA_EMISSAO), MONTH(DATA_EMISSAO), SUM(VLR_TOTAL)
		FROM TB_PEDIDO
		WHERE YEAR(DATA_EMISSAO) = @ANO 
		GROUP BY YEAR(DATA_EMISSAO), MONTH(DATA_EMISSAO)
		
		SELECT CAST(@@ROWCOUNT  AS VARCHAR(10)) AS MSG

		COMMIT

	END TRY
	BEGIN CATCH
		ROLLBACK
		SELECT ERROR_MESSAGE() AS MSG
	END CATCH
END
GO
--
--12.	Faça o teste carregando os seguintes anos: 2012, 2013 e 2014.

EXEC SP_CARREGA_TB_RESUMO 2012
EXEC SP_CARREGA_TB_RESUMO 2013
EXEC SP_CARREGA_TB_RESUMO 2014


--13.	Faça a consulta na tabela TB_RESUMO e verifique se as informações estão corretas.
SELECT * FROM TB_RESUMO


--LABORATÓRIO 2
-------------------------------------------------------------
-- 
/*
Laboratório A. Criar uma stored procedure que crie um campo novo em todas as tabelas do banco de dados.

Sabendo que
     SELECT ID, NAME FROM SYSOBJECTS WHERE XTYPE = 'U': Lista os nomes de todas as
           tabelas do banco de dados.
     EXEC( @COMANDO ): Executa uma instrução SQL contida em uma variável. 
     
Crie uma stored procedure que receba como parâmetro uma variável 
@CAMPO VARCHAR(200) que conterá o nome do campo e @TIPO VARCHAR(200),
o tipo e outras características de uma campo,

por exemplo: @CAMPO -> 'COD_USUARIO' 
             @TIPO  -> 'INT NOT NULL DEFAULT 0'

*/

-- Resposta:
-- 1. Criar procedure
USE PEDIDOS

CREATE PROCEDURE STP_CRIA_CAMPO @CAMPO VARCHAR(200), @TIPO VARCHAR(200)
AS BEGIN
-- 2. Declarar variável @COMANDO VARCHAR(200), @TABELA VARCHAR(200) e
--    @ID INT.
DECLARE @COMANDO VARCHAR(200), @TABELA VARCHAR(200),
        @ID INT;
-- 3. Declarar cursor para SELECT ID, NAME FROM SYSOBJECTS WHERE XTYPE = 'U'
DECLARE CR_TABELAS CURSOR KEYSET
   FOR SELECT ID, NAME FROM SYSOBJECTS WHERE XTYPE = 'U'
-- 4. Abrir o cursor
OPEN CR_TABELAS;
-- 5. Ler a primeira linha do cursor 
FETCH FIRST FROM CR_TABELAS INTO @ID, @TABELA;
-- 6. Enquanto não chegar no final dos dados
WHILE @@FETCH_STATUS = 0
   BEGIN
   -- a. Armazenar na variável comando a instrução 
   --           'ALTER TABLE ' + @TABELA + ' ADD ' + @CAMPO + ' ' + @TIPO;
   SET @COMANDO = 'ALTER TABLE ' + @TABELA + ' ADD ' + @CAMPO + ' ' + @TIPO;
   -- b. Executar o comando contido na variável @COMANDO
   EXEC(@COMANDO);   
   -- c. Imprimir na área de mensagens o comando que foi executado
   PRINT @COMANDO

   -- d. Ler a próxima linha da tabela
   FETCH NEXT FROM CR_TABELAS INTO @ID, @TABELA;
   -- e. Finaliza o loop
   END -- WHILE
-- 7. Fechar o cursor   
CLOSE CR_TABELAS;
-- 8. Desalocar o cursor da memória
DEALLOCATE CR_TABELAS;
END
-- Testar
EXEC STP_CRIA_CAMPO 'DATA_ALTERACAO', 
                    'DATETIME NOT NULL DEFAULT GETDATE()'

EXEC STP_CRIA_CAMPO 'COD_USR_ALTEROU',
                    'INT NOT NULL DEFAULT 0'
------------------------------------------------------------------
-- Laboratório B.
--     Alterando a procedure anterior para testar se o campo já existe na tabela e imprimindo-o, 
--     caso ele exista.
/*     Obs: Para testar se a tabela produtos tem um campo chamado 
            PRECO_VENDA, podemos fazer:
            
            SELECT ID FROM SYSOBJECTS WHERE NAME = 'PRODUTOS'
            
            o ID da tabela PRODUTOS é: 357576312
            
            SELECT * FROM SYSCOLUMNS 
            WHERE NAME = 'PRECO_VENDA' AND ID = 357576312

            Adaptando para a procedure, podemos fazer:

            IF EXISTS(SELECT * FROM SYSCOLUMNS 
               WHERE NAME = @CAMPO AND ID = @ID)
*/ 

-- Resposta:

USE PEDIDOS

ALTER PROCEDURE STP_CRIA_CAMPO @CAMPO VARCHAR(200), @TIPO VARCHAR(200)
AS BEGIN
-- 1. Declarar variável @COMANDO VARCHAR(200), @TABELA VARCHAR(200) e
--    @ID INT.
DECLARE @COMANDO VARCHAR(200), @TABELA VARCHAR(200),
        @ID INT;
-- 2. Declarar cursor para SELECT ID, NAME FROM SYSOBJECTS WHERE XTYPE = 'U'
DECLARE CR_TABELAS CURSOR KEYSET
   FOR SELECT ID, NAME FROM SYSOBJECTS WHERE XTYPE = 'U'
-- 3. Abrir o cursor
OPEN CR_TABELAS;
-- 4. Ler a primeira linha do cursor 
FETCH FIRST FROM CR_TABELAS INTO @ID, @TABELA;
-- 5. Enquanto não chegar no final dos dados
WHILE @@FETCH_STATUS = 0
   BEGIN
    IF EXISTS(SELECT * FROM SYSCOLUMNS 
               WHERE NAME = @CAMPO AND ID = @ID)
       PRINT @CAMPO + ' JÁ EXISTE EM ' + @TABELA;
   ELSE
	   BEGIN
	   -- 5.1. Armazenar na variável comando a instrução 
	   --           'ALTER TABLE ' + @TABELA + ' ADD ' + @CAMPO + ' ' + @TIPO;
	   SET @COMANDO = 'ALTER TABLE ' + @TABELA + ' ADD ' + @CAMPO + ' ' + @TIPO;
	   -- 5.2. Executar o comando contido na variável @COMANDO
	   EXEC(@COMANDO);   
	   -- 5.3. Imprimir na área de mensagens o comando que foi executado
	   PRINT @COMANDO
	   END -- Fim do bloco ELSE do IF
   -- 5.4. Ler a próxima linha da tabela
   FETCH NEXT FROM CR_TABELAS INTO @ID, @TABELA;
   -- Fim do loop
   END -- WHILE
-- 6. Fechar o cursor   
CLOSE CR_TABELAS;
-- 7. Desalocar o cursor da memória
DEALLOCATE CR_TABELAS;
END

