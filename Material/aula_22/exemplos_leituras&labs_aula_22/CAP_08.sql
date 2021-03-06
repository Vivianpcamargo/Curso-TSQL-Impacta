--Exemplos:
-- Retorna a quantidade de caracteres do texto
SELECT LEN('CARLOS MAGNO')

-- Valor de PI
SELECT PI()

-- Raiz quadrada de 144
SELECT SQRT(144)

-- Valor Exponencial de 12
SELECT SQUARE( 12 )

-- Exemplos: 
-- Valor rand?mico entre 0 e 1
SELECT RAND()
-- Data e hora do servidor
SELECT GETDATE()
-- Gera um valor exclusivo 
SELECT NEWID()

--- C?digo de um dado caractere
SELECT ASCII( 'A' )
SELECT ASCII( 'B' )
SELECT ASCII( '0' )

--- Caractere que tem um determinado c?digo
SELECT CHAR(65)
--
DECLARE @COD INT;
SET @COD = 1;
WHILE @COD <= 255
   BEGIN
   PRINT CAST(@COD AS VARCHAR(3)) + ' - ' + CHAR(@COD);
   SET @COD = @COD + 1; 
   END

--- Posi??o de uma string dentro de outra
SELECT CHARINDEX( 'PA', 'IMPACTA' ) -- Retorna 3
SELECT CHARINDEX( 'MAGNO', 'CARLOS MAGNO' ) -- Retorna 8
SELECT CHARINDEX( 'MANO', 'CARLOS MAGNO' ) -- Retorna 0 (zero)

--- Tamanho de uma string
SELECT LEN( 'IMPACTA' ) 
SELECT LEN( 'IMPACTA TECNOLOGIA' )

--- Pegar uma parte de uma string
SELECT LEFT( 'IMPACTA TECNOLOGIA', 5 ) -- Retorna IMPAC

SELECT RIGHT( 'IMPACTA TECNOLOGIA', 5 ) -- Retorna LOGIA

-- Retornar 6 caracteres a partir da quinta (5) posi??o
SELECT SUBSTRING( 'IMPACTA TECNOLOGIA', 5, 6 ) -- Retorna CTA TE

--- Eliminar espa?os em branco ? direita
SELECT 'IMPACTA     ' + 'TECNOLOGIA'
SELECT RTRIM('IMPACTA     ') + 'TECNOLOGIA'


--- Reverso de uma string
SELECT REVERSE('IMPACTA')
SELECT REVERSE('MAGNO')
SELECT REVERSE('TECNOLOGIA')
SELECT REVERSE('COMPUTADOR')
SELECT REVERSE('REVER')
SELECT REVERSE('ANILINA')
SELECT REVERSE('MIRIM')
SELECT REVERSE('RADAR')
SELECT REVERSE('REVIVER')

--- Replicar string v?rias vezes
PRINT REPLICATE('IMPACTA ', 10)

--- Mai?sculo
PRINT UPPER('impacta  123 @@ !!')

--- Min?sculo
PRINT LOWER( 'tECnOlOGIa 123 @@ !!' )

-- Substitui??o de texto
PRINT REPLACE( 'JOS?,CARLOS,ROBERTO,FERNANDO,MARCO',',',' - ')

-- Data e hora do servidor
SELECT  GETDATE() AS Data

-- ?ltimo dia do m?s corrente
SELECT EOMONTH(GETDATE(), 0 )

-- Apresenta a data de 28/10/2014
SELECT DATEFROMPARTS(2014,10,28)

--Converte uma data em n?mero
SELECT CAST(GETDATE() AS FLOAT) AS DATA_NUMERO

--Convertendo um texto em data
SELECT CAST('2014.1.13' AS DATETIME) AS DATA

--Convertendo um n?mero em Data
SELECT CAST(42525 AS DATETIME) AS DATA

--Convertendo uma data para texto com CAST
SELECT CAST (GETDATE() AS VARCHAR(20)) 

--Utilizando o CONVERT para retornar somente a data no formato DD/MM/YYYY.
SELECT CONVERT(VARCHAR(10), GETDATE() , 103) 


--Retornando a data no formato AAAA/MM/DD.
SELECT CONVERT(VARCHAR(10), GETDATE() , 111) 

--Retornando a Hora
SELECT CONVERT(VARCHAR(10), GETDATE() , 114) 

--Convertendo um texto em data
SELECT PARSE('2016.6.10'  AS datetime ) AS RESULTADO;

--Convertendo um texto em data utilizando o formato americano
SELECT PARSE('2016.6.10'  AS datetime USING 'en-US') AS RESULTADO;

--Convertendo um texto em valor num?rico. Verifique que o ponto ? o separador de decimal e o resultado estar? correto.
SELECT PARSE( '159.00'  AS DECIMAL(10,2) ) AS RESULTADO


--Por?m, se alterar de ponto para v?rgula, a convers?o ficar? incorreta.
SELECT PARSE( '159,00'  AS DECIMAL(10,2) ) AS RESULTADO

--Para resolver este problema, utilize o formato cultural para atender o texto passado.
SELECT PARSE( '159,00'  AS DECIMAL(10,2) USING 'pt-BR' ) AS RESULTADO

--No exemplo abaixo ? passado um caractere indevido, utilizando o PARSE ? apresentado um erro.
SELECT PARSE( '159,A0'  AS DECIMAL(10,2) USING 'PT-br' ) AS RESULTADO

--Utilizando o TRY_PARSE, n?o ? retornado um erro e sim NULL.
SELECT TRY_PARSE( '159,A0'  AS DECIMAL(10,2) USING 'PT-br' ) AS RESULTADO

--Utilizando CONVERT numa convers?o indevida:
SELECT CONVERT(DATETIME, '2016.06.a' , 103)

--Com o TRY_CONVERT o retorno ? NULO:
SELECT TRY_CONVERT(DATETIME, '2016.06.a' , 103) AS RESULTADO

--Exemplo 1
USE PEDIDOS
GO

SELECT NOME , TOTAL, ROW_NUMBER() OVER (ORDER BY TOTAL DESC) AS LINHA
FROM 
(SELECT  C.NOME , SUM(P.VLR_TOTAL) AS TOTAL
	FROM	TB_PEDIDO AS P
	JOIN	TB_CLIENTE AS C ON C.CODCLI = P.CODCLI
	GROUP BY C.NOME
	) AS A

--Exemplo 2
SELECT NOME , QTD_PEDIDOS, ESTADO, ROW_NUMBER() OVER (PARTITION BY ESTADO ORDER BY QTD_PEDIDOS DESC) AS LINHA

FROM 
(SELECT  C.NOME , C.ESTADO, COUNT(*) AS QTD_PEDIDOS
	FROM	TB_PEDIDO AS P
	JOIN	TB_CLIENTE AS C ON C.CODCLI = P.CODCLI
	GROUP BY C.NOME, C.ESTADO
	) AS A

--RANK
USE PEDIDOS
GO
--Exemplo 1

SELECT NOME , QTD_PEDIDOS, RANK() OVER (ORDER BY QTD_PEDIDOS DESC) AS [CLASSIFICA??O]

FROM 
(SELECT  C.NOME , COUNT(*) AS QTD_PEDIDOS
	FROM	TB_PEDIDO AS P
	JOIN	TB_CLIENTE AS C ON C.CODCLI = P.CODCLI
	GROUP BY C.NOME
	) AS A

--Exemplo 2
SELECT NOME , ESTADO,  QTD_PEDIDOS, RANK() OVER (PARTITION BY ESTADO ORDER BY QTD_PEDIDOS DESC) AS [CLASSIFICA??O]
FROM 
(SELECT  C.NOME , C.ESTADO, COUNT(*) AS QTD_PEDIDOS
	FROM	TB_PEDIDO AS P
	JOIN	TB_CLIENTE AS C ON C.CODCLI = P.CODCLI
	GROUP BY C.NOME, C.ESTADO
	) AS A
Order by Estado

-- DENSE_RANK 

USE PEDIDOS

GO
--Exemplo 1

SELECT NOME , QTD_PEDIDOS, DENSE_RANK() OVER (ORDER BY QTD_PEDIDOS DESC) AS [CLASSIFICA??O]

FROM 
(SELECT  C.NOME , COUNT(*) AS QTD_PEDIDOS
	FROM	TB_PEDIDO AS P
	JOIN	TB_CLIENTE AS C ON C.CODCLI = P.CODCLI
	GROUP BY C.NOME
	) AS A

--Exemplo 2
SELECT NOME , ESTADO,  QTD_PEDIDOS, DENSE_RANK() OVER (PARTITION BY ESTADO ORDER BY QTD_PEDIDOS DESC) AS [CLASSIFICA??O]
FROM 
(SELECT  C.NOME , C.ESTADO, COUNT(*) AS QTD_PEDIDOS
	FROM	TB_PEDIDO AS P
	JOIN	TB_CLIENTE AS C ON C.CODCLI = P.CODCLI
	GROUP BY C.NOME, C.ESTADO
	) AS A
Order by Estado

--NTILE

--Exemplo 1

SELECT NOME , TOTAL, ESTADO, NTILE (10) OVER (ORDER BY TOTAL DESC) AS GRUPO
FROM 
(SELECT  C.NOME , C.ESTADO, SUM(P.VLR_TOTAL) AS TOTAL
	FROM	TB_PEDIDO AS P
	JOIN	TB_CLIENTE AS C ON C.CODCLI = P.CODCLI
	GROUP BY C.NOME, C.ESTADO
	) AS A

-- ROW_NUMBER, RANK, DENSE_RANK e NTILE

SELECT NOME , ESTADO, QTD_PEDIDOS, 
ROW_NUMBER() OVER (PARTITION BY ESTADO ORDER BY QTD_PEDIDOS DESC) AS ROW_NUMBER,
RANK()		 OVER (PARTITION BY ESTADO ORDER BY QTD_PEDIDOS DESC) AS RANK,
DENSE_RANK() OVER (PARTITION BY ESTADO ORDER BY QTD_PEDIDOS DESC) AS DENSE_RANK,
NTILE (10)	 OVER (PARTITION BY ESTADO ORDER BY QTD_PEDIDOS DESC) AS NTILE
FROM 
(SELECT  C.NOME ,C.ESTADO, COUNT(*) AS QTD_PEDIDOS
	FROM	TB_PEDIDO AS P
	JOIN	TB_CLIENTE AS C ON C.CODCLI = P.CODCLI
	GROUP BY C.NOME,C.ESTADO
	) AS A


--Fun??es definidas pelo usu?rio

--Fun??o para receber dois n?meros INT e retornar o maior dos dois:

CREATE FUNCTION FN_MAIOR( @N1 INT, @N2 INT )
  RETURNS INT
AS BEGIN
DECLARE @RET INT;
IF @N1 > @N2
   SET @RET = @N1
ELSE
   SET @RET = @N2;
RETURN (@RET)
END

GO
-- Testando
SELECT DBO.FN_MAIOR( 5,3 )
SELECT DBO.FN_MAIOR( 7,11 )

--Fun??o para receber uma data e retornar o nome do dia da semana sempre em portugu?s, independentemente das configura??es do servidor:
GO
CREATE FUNCTION FN_NOME_DIA_SEMANA( @DT DATETIME )
   RETURNS VARCHAR(15)
AS BEGIN
DECLARE @NUM_DS INT, @NOME_DS VARCHAR(15);
SET @NUM_DS = DATEPART( WEEKDAY, @DT );
/*-------------------------------------------
IF @NUM_DS = 1 SET @NOME_DS = 'DOMINGO';
IF @NUM_DS = 2 SET @NOME_DS = 'SEGUNDA-FEIRA';
IF @NUM_DS = 3 SET @NOME_DS = 'TER?A-FEIRA';
IF @NUM_DS = 4 SET @NOME_DS = 'QUARTA-FEIRA';
IF @NUM_DS = 5 SET @NOME_DS = 'QUINTA-FEIRA';
IF @NUM_DS = 6 SET @NOME_DS = 'SEXTA-FEIRA';
IF @NUM_DS = 7 SET @NOME_DS = 'S?BADO';
---------------------------------------------*/
-- OU
SET @NOME_DS = CASE @NUM_DS
                 WHEN 1 THEN 'DOMINGO'
                 WHEN 2 THEN 'SEGUNDA-FEIRA'
                 WHEN 3 THEN 'TER?A-FEIRA'
                 WHEN 4 THEN 'QUARTA-FEIRA'
                 WHEN 5 THEN 'QUINTA-FEIRA'
                 WHEN 6 THEN 'SEXTA-FEIRA'
                 WHEN 7 THEN 'S?BADO'
               END -- CASE
RETURN (@NOME_DS)
END
GO
-- TESTANDO
SELECT NOME, DATA_ADMISSAO, DATENAME(WEEKDAY,DATA_ADMISSAO),
       DBO.FN_NOME_DIA_SEMANA( DATA_ADMISSAO )
FROM TB_EMPREGADO
--
SELECT DBO.FN_NOME_DIA_SEMANA('2013.11.12' )

SELECT DBO.FN_NOME_DIA_SEMANA(GETDATE() )


--Fun??o para gerar um n?mero aleat?rio em um determinado intervalo. Passaremos para a fun??o o valor m?nimo e o valor m?ximo para o sorteio:

-----------------------------------------------------------------
SELECT 10 + (20-10) * RAND()
SELECT 5 + (10-5) * RAND()
SELECT 1 + (10-1) * RAND()
-- OBS.:   @MIN + (@MAX - @MIN + 1) * RAND()
-----------------------------------------------------------------
-- Vers?o 1
GO

CREATE FUNCTION FN_SORTEIO( @MIN FLOAT, @MAX FLOAT )
  RETURNS FLOAT
AS BEGIN
RETURN @MIN + (@MAX - @MIN) * RAND();
END

GO

-- Vers?o 2

CREATE VIEW VIE_RAND
AS SELECT RAND() AS NUM_RAND

GO

CREATE FUNCTION FN_SORTEIO( @MIN FLOAT, @MAX FLOAT )
  RETURNS FLOAT
AS BEGIN
DECLARE @RAND FLOAT;
SELECT @RAND = NUM_RAND FROM VIE_RAND

RETURN @MIN + (@MAX - @MIN + 1) * @RAND;
END
-- Testando
GO
SELECT DBO.FN_SORTEIO( 1,60 )

INSERT INTO TB_EMPREGADO
(NOME, COD_DEPTO, COD_CARGO, SALARIO, DATA_ADMISSAO)
VALUES ('Z? LUIZ', 1, 1, 1000, GETDATE()) 

INSERT INTO TB_EMPREGADO
(NOME, COD_DEPTO, COD_CARGO, SALARIO, DATA_ADMISSAO)
VALUES ('Z? DA SILVA', 2, 2, 2000, GETDATE()) 

SELECT * FROM TB_EMPREGADO
WHERE DATA_ADMISSAO = '2006.6.24' 

SELECT * FROM TB_EMPREGADO
WHERE DATA_ADMISSAO BETWEEN '2006.6.24' AND '2006.6.24 23:59'

GO

CREATE FUNCTION FN_SORTEIO( @MIN FLOAT, @MAX FLOAT )
  RETURNS FLOAT
AS BEGIN
RETURN @MIN + (@MAX - @MIN) * RAND();
END

GO

CREATE FUNCTION FN_TRUNCA_DATA( @DT DATETIME) RETURNS DATETIME
AS BEGIN
RETURN CAST( FLOOR( CAST(@DT AS FLOAT) ) AS DATETIME )
END
GO
-- Testando
SELECT * FROM TB_EMPREGADO
WHERE DBO.FN_TRUNCA_DATA( DATA_ADMISSAO ) = '2006.2.24'
-- OU
SELECT * FROM TB_EMPREGADO   
WHERE DBO.FN_TRUNCA_DATA( DATA_ADMISSAO ) = 
      DBO.FN_TRUNCA_DATA( GETDATE() )

GO
CREATE FUNCTION FN_PRIM_DATA( @DT DATETIME )
   RETURNS DATETIME
AS BEGIN
DECLARE @RET DATETIME;

SET @RET = DATETIMEFROMPARTS (YEAR(@DT) , MONTH(@DT) , 1,0,0,0,0);

RETURN @RET;
END
GO
-- Testando
SELECT NOME, DATA_ADMISSAO, DBO.FN_PRIM_DATA(DATA_ADMISSAO)
FROM TB_EMPREGADO

GO
CREATE FUNCTION FN_N_ESIMA_DATA_UTIL ( @DT DATETIME,
                                       @N INT )
   RETURNS DATETIME
AS BEGIN
DECLARE @I INT;
SET @I = 0;
WHILE @I < @N
   BEGIN
   SET @DT = @DT + 1;
   IF DATEPART(WEEKDAY, @DT) IN (1,7)  CONTINUE
   SET @I = @I + 1;
   END
RETURN ( @DT );
END
GO
-- TESTANDO
SELECT DBO.FN_N_ESIMA_DATA_UTIL( GETDATE(), 5 )

GO
CREATE TABLE FERIADOS
( DATA DATETIME, MOTIVO VARCHAR(40) )
GO
--
INSERT INTO FERIADOS VALUES ('2014.1.25','ANIV. S?O PAULO')
INSERT INTO FERIADOS VALUES ('2014.2.21','CARNAVAL')
INSERT INTO FERIADOS VALUES ('2014.2.22','CARNAVAL')
INSERT INTO FERIADOS VALUES ('2014.2.23','CARNAVAL')
INSERT INTO FERIADOS VALUES ('2014.2.24','CARNAVAL')

INSERT INTO FERIADOS VALUES ('2014.3.2','RESSACA')

INSERT INTO FERIADOS VALUES ('2014.3.10','P?SCOA')
INSERT INTO FERIADOS VALUES ('2014.4.19','TIRADENTES')

INSERT INTO FERIADOS VALUES ('2014.5.1','TRABALHO')
INSERT INTO FERIADOS VALUES ('2014.5.2','TRABALHO PROLONGAMENTO')

INSERT INTO FERIADOS VALUES ('2014.6.11','CORPUS CHRISTI')
INSERT INTO FERIADOS VALUES ('2014.6.12','CORPUS CHRISTI PROLONGAMENTO')
INSERT INTO FERIADOS VALUES ('2014.6.13','CORPUS CHRISTI PROLONGAMENTO')

INSERT INTO FERIADOS VALUES ('2014.2.16','DIA DA RESSACA')

GO
CREATE FUNCTION FN_N_ESIMA_DATA_UTIL ( @DT DATETIME,
                                       @N INT )
   RETURNS DATETIME
AS BEGIN
DECLARE @I INT;
SET @I = 0;
WHILE @I < @N
   BEGIN
   SET @DT = @DT + 1;
   IF DATEPART(WEEKDAY, @DT) IN (1,7) OR
      EXISTS( SELECT * FROM FERIADOS
              WHERE DATA = DBO.FN_TRUNCA_DATA( @DT ) )  CONTINUE
   SET @I = @I + 1;
   END
RETURN ( @DT );
END
GO
-- Testando
SELECT DBO.FN_N_ESIMA_DATA_UTIL( GETDATE(), 5 )

-- Fun??o para calcular a diferen?a entre duas datas
SELECT DATEDIFF(DAY, '2009.1.1', '2009.1.15')

SELECT DATEDIFF(MONTH, '2008.12.20', '2009.1.15')

GO

CREATE FUNCTION FN_DIF_DATAS( @TIPO CHAR(1),
                           @DT1  DATETIME,
                           @DT2  DATETIME )
  RETURNS FLOAT
AS BEGIN
DECLARE @DIA1 INT, @MES1 INT, @ANO1 INT;
DECLARE @DIA2 INT, @MES2 INT, @ANO2 INT;
DECLARE @RET FLOAT;

SET @DIA1 = DAY(@DT1);
SET @MES1 = MONTH(@DT1);
SET @ANO1 = YEAR(@DT1);

SET @DIA2 = DAY(@DT2);
SET @MES2 = MONTH(@DT2);
SET @ANO2 = YEAR(@DT2);

IF @TIPO = 'D'
   SET @RET = CAST(@DT2 - @DT1 AS INT);
ELSE IF @TIPO = 'M'
   BEGIN
   IF @MES1 <= @MES2
      BEGIN
      SET @RET = 12 * (@ANO2 - @ANO1) + (@MES2 - @MES1)
      IF @DIA1 > @DIA2 SET @RET = @RET - 1; 
      END
   ELSE
      BEGIN
      SET @RET = 12 * (@ANO2 - (@ANO1 + 1)) + (12 - (@MES1 - @MES2));
      IF @DIA1 > @DIA2 SET @RET = @RET - 1; 
      END
   END
ELSE
   BEGIN 
   SET @RET = @ANO2 - @ANO1;
   IF @MES1 > @MES2 SET @RET = @RET - 1;
   IF @MES1 = @MES2 AND @DIA1 > @DIA2 SET @RET = @RET - 1;
   END
RETURN @RET; 
END
GO
-- TESTANDO
SELECT DBO.FN_DIF_DATAS('D', '2009.1.1', '2009.1.15')

SELECT DBO.FN_DIF_DATAS('M', '2008.1.2', '2009.2.15')
SELECT DBO.FN_DIF_DATAS('M', '2008.1.20', '2009.2.15')

SELECT DBO.FN_DIF_DATAS('M', '2008.8.2', '2009.2.15')
SELECT DBO.FN_DIF_DATAS('M', '2007.8.2', '2009.2.15')
SELECT DBO.FN_DIF_DATAS('M', '2007.8.20', '2009.2.15')

SELECT DBO.FN_DIF_DATAS('A', '2008.8.2', '2009.2.15')
SELECT DBO.FN_DIF_DATAS('A', '2006.8.2', '2009.10.15')
SELECT DBO.FN_DIF_DATAS('A', '2006.10.2', '2009.10.15')
SELECT DBO.FN_DIF_DATAS('A', '2006.11.2', '2009.10.15')
SELECT DBO.FN_DIF_DATAS('A', '2006.10.20', '2009.10.20')

GO
CREATE FUNCTION FN_PRIM_NOME( @S VARCHAR(200) )
   RETURNS VARCHAR(200)
AS BEGIN
DECLARE @RET VARCHAR(200);
DECLARE @CONT INT;
SET @S = LTRIM( @S );
SET @RET = '';
SET @CONT = 1;
WHILE @CONT <= LEN(@S)
   BEGIN
   IF SUBSTRING(@S, @CONT, 1) = ' ' BREAK;
   SET @RET = @RET + SUBSTRING(@S, @CONT, 1);
   SET @CONT = @CONT + 1;
   END
RETURN @RET;
END
GO
-- TESTANDO
SELECT DBO.FN_PRIM_NOME( 'CARLOS  MAGNO' )
SELECT DBO.FN_PRIM_NOME( '  CARLOS  MAGNO' )

GO
CREATE FUNCTION FN_PROPER( @S VARCHAR(200) )
   RETURNS VARCHAR(200)
AS BEGIN
DECLARE @RET VARCHAR(200);
DECLARE @CONT INT;
SET @RET = UPPER(LEFT(@S,1));
SET @CONT = 2;
WHILE @CONT <= LEN(@S)
   BEGIN
   IF SUBSTRING(@S, @CONT - 1, 1) = ' '
      SET @RET = @RET + UPPER( SUBSTRING(@S, @CONT, 1) )
   ELSE
      SET @RET = @RET + LOWER( SUBSTRING(@S, @CONT, 1) )

   SET @CONT = @CONT + 1
   END
RETURN @RET;
END
GO
-- Testando
SELECT NOME, DBO.FN_PROPER( NOME ) FROM TB_EMPREGADO

SELECT * FROM TB_EMPREGADO WHERE NOME LIKE '%JOSE%'
SELECT * FROM TB_EMPREGADO WHERE NOME LIKE '%JOS?%'

GO

CREATE FUNCTION FN_TIRA_ACENTO( @S VARCHAR(200) )
  RETURNS VARCHAR( 200 )
AS BEGIN
DECLARE @I INT, @RET VARCHAR(200), @C CHAR(1);
SET @I = 1;
SET @RET = '';
-- Enquanto @I for menor que o tamanho de @S
WHILE @I <= LEN(@S)
   BEGIN
   SET @C = SUBSTRING( @S, @I, 1 );
   SET @RET = @RET + 
              CASE 
                WHEN ASCII(@C) IN (ASCII('?'), ASCII('?'), ASCII('?'), 
                     ASCII('?')) THEN 'A'
                WHEN ASCII(@C) IN (ASCII('?'), ASCII('?'), ASCII('?'), 
                     ASCII('?')) THEN 'a'
                WHEN ASCII(@C) IN (ASCII('?'),ASCII('?')) THEN 'E'
                WHEN ASCII(@C) IN (ASCII('?'),ASCII('?')) THEN 'e'
                WHEN ASCII(@C) IN (ASCII('?')) THEN 'I'
                WHEN ASCII(@C) IN (ASCII('?')) THEN 'i'
                WHEN ASCII(@C) IN (ASCII('?'),ASCII('?'),ASCII('?')) 
                                               THEN 'O'
                WHEN ASCII(@C) IN (ASCII('?'),ASCII('?'),ASCII('?')) 
                                               THEN 'o'
                WHEN ASCII(@C) IN (ASCII('?'),ASCII('?')) THEN 'U'
                WHEN ASCII(@C) IN (ASCII('?'),ASCII('?')) THEN 'u'
                WHEN ASCII(@C) = ASCII('?') THEN 'C'
                WHEN ASCII(@C) = ASCII('?') THEN 'c'
                ELSE @C
              END -- CASE   
    SET @I = @I + 1
    END  
RETURN (@RET);
END
GO
-- TESTANDO
SELECT NOME FROM TB_EMPREGADO
WHERE DBO.FN_TIRA_ACENTO( NOME ) LIKE '%JOSE%'

SELECT NOME FROM TB_EMPREGADO
WHERE DBO.FN_TIRA_ACENTO( NOME ) LIKE '%JOAO%'

GO
CREATE FUNCTION FN_MAIOR_PEDIDO( @DT1 DATETIME,
                                 @DT2 DATETIME )
RETURNS TABLE
AS
RETURN ( SELECT MONTH( DATA_EMISSAO ) AS MES, 
                YEAR( DATA_EMISSAO ) AS ANO, 
                MAX( VLR_TOTAL ) AS MAIOR_VALOR
                FROM TB_PEDIDO
                WHERE DATA_EMISSAO BETWEEN @DT1 AND @DT2
                GROUP BY MONTH( DATA_EMISSAO ), 
                         YEAR( DATA_EMISSAO ) )
GO
-- Testando
SELECT * FROM DBO.FN_MAIOR_PEDIDO( '2014.1.1','2014.12.31')
ORDER BY ANO, MES

GO

CREATE FUNCTION FN_TOT_DEPTOS()
   RETURNS @TotDeptos TABLE ( COD_DEPTO INT, 
                              NOME VARCHAR(40),          
                              TIPO CHAR(1),
                              VALOR NUMERIC(12,2) )
AS BEGIN
DECLARE @I INT; -- Contador
DECLARE @TOT INT; -- Total de departamentos existentes
SELECT @TOT = MAX(COD_DEPTO) FROM TB_DEPARTAMENTO
SET @I = 1;
WHILE @I <= @TOT
   BEGIN
   -- Se existir o departamento de c?digo = @I...
   IF EXISTS( SELECT * FROM TB_DEPARTAMENTO
              WHERE COD_DEPTO = @I )
      BEGIN
      -- Inserir na tabela de retorno os funcion?rios do
      -- departamento c?digo @I
      INSERT INTO @TotDeptos
      SELECT COD_DEPTO, NOME, 'D', SALARIO 
      FROM TB_EMPREGADO WHERE COD_DEPTO = @I;
      -- Inserir na tabela de retorno uma linha contendo
      -- o total de sal?rios do departamento @I
      -- Coloque no campo NOME a mensagem 'TOTAL' e no
      -- campo TIPO a letra 'T'. 
      -- O campo VALOR vai armazenar o total de sal?rios
      INSERT INTO @TotDeptos
      SELECT COD_DEPTO, 'TOTAL DO DEPTO.:', 'T',
             SUM( SALARIO ) 
      FROM TB_EMPREGADO WHERE COD_DEPTO = @I
      GROUP BY COD_DEPTO;      
      END -- IF EXISTS
   SET @I = @I + 1;
   END -- WHILE
RETURN
END -- FUNCTION

GO
--
SELECT * FROM FN_TOT_DEPTOS()


GO
CREATE FUNCTION FN_CALCULA_VALOR_TOTAL (@PEDIDO INT) RETURNS NUMERIC(10,2)  AS
BEGIN

RETURN ( SELECT SUM(PR_UNITARIO * QUANTIDADE * (1-DESCONTO/100)) 
		 FROM TB_ITENSPEDIDO
		 WHERE NUM_PEDIDO =@PEDIDO)

END

GO

ALTER TABLE TB_PEDIDO 
ADD VALOR_CALC AS DBO.FN_CALCULA_VALOR_TOTAL(NUM_PEDIDO)

SELECT NUM_PEDIDO, VLR_TOTAL, VALOR_CALC FROM TB_PEDIDO


