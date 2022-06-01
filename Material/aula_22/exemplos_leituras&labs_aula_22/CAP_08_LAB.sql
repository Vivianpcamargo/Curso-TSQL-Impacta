--LABORATÓRIO
-----------------------------------------------------------------
-- Laboratório A
-- 1. Crie uma função chamada FN_MENOR que receba 2 números inteiros e 
-- retorne o MENOR deles
-----------------------------------------------------------------
GO
CREATE FUNCTION FN_MENOR( @N1 INT, @N2 INT )
  RETURNS INT
AS BEGIN
DECLARE @RET INT;
IF @N1 < @N2
   SET @RET = @N1
ELSE
   SET @RET = @N2;

RETURN (@RET)
END
-- Testando
SELECT DBO.FN_MENOR( 5,3 )
SELECT DBO.FN_MENOR( 7,11 )

GO

-- Testando
SELECT DBO.FN_MENOR( 5,3 )
SELECT DBO.FN_MENOR( 7,11 )

-----------------------------------------------------------
-- 2. Criar função FN_NOME_MES que retorne o nome do MÊS
-- MONTH( DATA ) -> retorna o número do mês
-----------------------------------------------------------
CREATE FUNCTION FN_NOME_MES ( @DT DATETIME )
   RETURNS VARCHAR(15)
AS BEGIN
RETURN CASE  MONTH( @DT )
          WHEN  1 THEN 'JANEIRO'  
          WHEN  2 THEN 'FEVEREIRO'
          WHEN  3 THEN 'MARÇO'
          WHEN  4 THEN 'ABRIL'
          WHEN  5 THEN 'MAIO'
          WHEN  6 THEN 'JUNHO'
          WHEN  7 THEN 'JULHO'
          WHEN  8 THEN 'AGOSTO'
          WHEN  9 THEN 'SETEMBRO'
          WHEN 10 THEN 'OUTUBRO'
          WHEN 11 THEN 'NOVEMBRO'
          WHEN 12 THEN 'DEZEMBRO'
       END
END

GO

-- Testando
SELECT NOME, DATA_ADMISSAO, DATENAME(MONTH,DATA_ADMISSAO),
       DBO.FN_NOME_MES(DATA_ADMISSAO)
FROM TB_EMPREGADO

---------------------------------------------------------------
--3. Criar função que retorna a ÚLTIMA data do mês
-- Dica: Como a data é um número em que cada dia corresponde a
--       1 unidade, podemos concluir que a última data de um mês
--       é igual à primeira data do mês seguinte menos 1
---------------------------------------------------------------
GO
CREATE FUNCTION FN_ULT_DATA( @DT DATETIME )
   RETURNS DATETIME
AS BEGIN
	DECLARE @MES INT, @ANO INT , @DATA DATETIME;
	SET @MES = MONTH(@DT) + 1;
	SET @ANO = YEAR(@DT);

	IF @MES > 12
	   BEGIN
		SET @MES = 1;
		SET @ANO = @ANO + 1;
	   END
	SET @DATA = DATEFROMPARTS ( @ANO, @MES, 1 )
	RETURN @DATA - 1 ;
END

GO
-- Testando
SELECT NOME, DATA_ADMISSAO, DBO.FN_ULT_DATA(DATA_ADMISSAO)
FROM TB_EMPREGADO

-- OU
SELECT NOME, DATA_ADMISSAO, EOMONTH( DATA_ADMISSAO, 1 )
FROM TB_EMPREGADO


----------------------------------------------------------
-- 4. Criar função que retorne a quantidade de
-- dias úteis existentes entre 2 datas (inclusive as 2)
-- Parâmetros:
--            @DATA_INI	DATETIME
--            @DATA_FIM DATETIME 

GO
CREATE TABLE FERIADOS
( DATA DATETIME, MOTIVO VARCHAR(40) )

GO
CREATE FUNCTION FN_DIAS_UTEIS( @DATA_INI DATETIME, @DATA_FIM DATETIME )
  RETURNS INT
AS BEGIN
DECLARE @RET INT;
DECLARE @DT DATETIME;

SET @RET = 0;
SET @DT = @DATA_INI;

WHILE @DT < @DATA_FIM
   BEGIN
   SET @DT = @DT + 1;
   IF DATEPART( WEEKDAY, @DT ) IN (1,7)  OR
      EXISTS( SELECT * FROM FERIADOS
              WHERE DATA = @DT ) CONTINUE;
   SET @RET = @RET + 1;
   END
RETURN (@RET);
END

GO

-- Testando
SELECT DBO.FN_DIAS_UTEIS('01.01.2008' , '01.01.2009')

-------------------------------------------------------------------
-- 5. Criar uma função tabular (FN_VENDAS_POR_PRODUTO)
-- que receba as datas inicial (@DT1) e final (@DT2) de um período
-- e retorne o total vendido de cada produto neste período
------------------------------------------------------------------
/*
 	SELECT
		Pr.ID_PRODUTO, Pr.DESCRICAO, SUM( I.QUANTIDADE ) AS QTD_TOTAL,
		SUM( I.QUANTIDADE * I.PR_UNITARIO ) AS VALOR_TOTAL
	FROM ITENSPEDIDO I
		 JOIN PRODUTOS Pr ON I.ID_PRODUTO=Pr.ID_PRODUTO
		 JOIN PEDIDOS Pe ON I.NUM_PEDIDO=Pe.NUM_PEDIDO
	WHERE 
	     Pe.DATA_EMISSAO BETWEEN @DT1 AND @DT2
	GROUP BY Pr.ID_PRODUTO, Pr.DESCRICAO
*/
GO
CREATE FUNCTION FN_VENDAS_POR_PRODUTO ( @DT1 DATETIME,
                                        @DT2 DATETIME )
RETURNS TABLE
AS  
RETURN (SELECT
		Pr.ID_PRODUTO, Pr.DESCRICAO, SUM( I.QUANTIDADE ) AS QTD_TOTAL,
		SUM( I.QUANTIDADE * I.PR_UNITARIO ) AS VALOR_TOTAL
	FROM TB_ITENSPEDIDO I
		 JOIN TB_PRODUTO Pr ON I.ID_PRODUTO=Pr.ID_PRODUTO
		 JOIN TB_PEDIDO Pe ON I.NUM_PEDIDO=Pe.NUM_PEDIDO
	WHERE 
	     Pe.DATA_EMISSAO BETWEEN @DT1 AND @DT2
	GROUP BY Pr.ID_PRODUTO, Pr.DESCRICAO)
GO
-- Testando a função
SELECT * FROM FN_VENDAS_POR_PRODUTO( '2006.1.1','2006.12.31')
ORDER BY 3
--
SELECT * FROM FN_VENDAS_POR_PRODUTO( '2006.1.1','2006.12.31')
ORDER BY DESCRICAO
--
SELECT TOP 10 * 
FROM FN_VENDAS_POR_PRODUTO( '2006.1.1','2006.12.31')
ORDER BY 4 DESC

----------------------------------------------------------

--B – Funções de classificação
--1.	Faça uma consulta que apresente o nome do cliente, o número do pedido e o valor total. 
--      Além desses campos, crie uma coluna que seja numerada automaticamente.

SELECT	ROW_NUMBER() OVER(ORDER BY NUM_PEDIDO)  AS ORDER_ROW_NUMBER, 
		C.NOME , P.NUM_PEDIDO , P.VLR_TOTAL 
FROM	TB_PEDIDO AS P
JOIN	TB_CLIENTE AS C ON C.CODCLI = P.CODCLI 

--2.	Utilizando a mesma consulta, adicione uma coluna que apresente o Ranking 
--      das vendas dos clientes

SELECT	ROW_NUMBER() OVER(ORDER BY NUM_PEDIDO) AS ORDER_ROW_NUMBER, 
		RANK() OVER (ORDER BY VLR_TOTAL DESC) AS ORDER_RANK, 
		C.NOME , P.NUM_PEDIDO , P.VLR_TOTAL 
FROM	TB_PEDIDO AS P
JOIN	TB_CLIENTE AS C ON C.CODCLI = P.CODCLI 


--C – Campos calculados com função

--1.	Crie uma função que apresente o total de funcionários de um departamento.
GO
	CREATE FUNCTION FN_QTD_EMPREGADOS (@DEPTO INT ) RETURNS INT AS
	BEGIN
		DECLARE @RET INT

		SELECT @RET = COUNT(*) FROM TB_EMPREGADO 
		WHERE COD_DEPTO = @DEPTO
	
		RETURN (@RET )
	END
GO
--Teste
SELECT DBO.FN_QTD_EMPREGADOS ( 1)

--2.	Adicione uma coluna calculada na tabela TB_DEPARTAMENTO. Esta coluna deve utilizar a função criada no exercício anterior.
GO
ALTER TABLE TB_DEPARTAMENTO ADD
	QTD_FUNC AS DBO.FN_QTD_EMPREGADOS (COD_DEPTO)

GO

--3.	Realize uma consulta na tabela TB_DEPARTAMENTO que apresente os departamentos e a quantidade de funcionários.
SELECT * FROM TB_DEPARTAMENTO


