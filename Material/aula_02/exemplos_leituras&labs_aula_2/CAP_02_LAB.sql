--LABORATÓRIO
--==============================================================================
-- Laboratório 1

-- 1. Coloque em uso o banco de dados PEDIDOS;
USE PEDIDOS
GO
-- 2. Liste todos os pedidos (TB_PEDIDO) do vendedor 'MARCELO' em janeiro de 2014;
SELECT P.*, V.NOME
FROM TB_PEDIDO P JOIN TB_VENDEDOR V ON P.CODVEN = V.CODVEN
WHERE V.NOME = 'MARCELO' AND
      P.DATA_EMISSAO BETWEEN '2014.1.1' AND '2014.1.31'
-- OU
SELECT P.*, V.NOME
FROM TB_PEDIDO P JOIN TB_VENDEDOR V ON P.CODVEN = V.CODVEN
WHERE V.NOME = 'MARCELO' AND
      YEAR(P.DATA_EMISSAO) = 2014 AND
      MONTH( P.DATA_EMISSAO ) = 1


-- 3. Liste todos os pedidos de janeiro de 2014 
--    mostrando o nome do cliente e do vendedor em cada pedido;
SELECT P.*, C.NOME AS CLIENTE, V.NOME AS VENDEDOR
FROM TB_PEDIDO P 
     JOIN TB_CLIENTE C ON P.CODCLI = C.CODCLI
     JOIN TB_VENDEDOR V ON P.CODVEN = V.CODVEN      
WHERE P.DATA_EMISSAO BETWEEN '2014.1.1' AND '2014.1.31'

/*
   4. Liste todos os itens de TB_PEDIDO de janeiro de 2014 com desconto superior a 7%. 
      Devem ser mostrados NUM_PEDIDO, DESCRICAO do produto, NOME do cliente, nome do VENDEDOR e QUANTIDADE vendida;
*/
SELECT
  I.NUM_PEDIDO, I.DESCONTO, I.QUANTIDADE, PE.DATA_EMISSAO,
  PR.DESCRICAO, C.NOME AS CLIENTE, V.NOME AS VENDEDOR
FROM TB_PEDIDO PE
  JOIN TB_CLIENTE C ON PE.CODCLI = C.CODCLI
  JOIN TB_VENDEDOR V ON PE.CODVEN = V.CODVEN
  JOIN TB_ITENSPEDIDO I ON PE.NUM_PEDIDO = I.NUM_PEDIDO
  JOIN TB_PRODUTO PR ON I.ID_PRODUTO = PR.ID_PRODUTO
WHERE PE.DATA_EMISSAO BETWEEN '2014.1.1' AND '2014.1.31' AND    
      I.DESCONTO > 7

-- 5. Calcule a quantidade de pedidos cadastrados em janeiro de 2014 
--    e o maior e o menor valor de pedido (VLR_TOTAL);
SELECT COUNT(*) AS QTD_PEDIDOS,
       MAX(VLR_TOTAL) AS MAIOR_PEDIDO,
       MIN(VLR_TOTAL) AS MENOR_PEDIDO
FROM TB_PEDIDO
WHERE DATA_EMISSAO BETWEEN '2014.1.1' AND '2014.1.31' 

/*
   6. Calcule o valor total vendido (soma de PEDIDOS.VLR_TOTAL) e o valor da comissão 
   (soma de PEDIDOS.VLR_TOTAL * VENDEDORES.PORC_COMISSAO/100) de cada vendedor em janeiro de 2014;
*/
SELECT V.CODVEN, V.NOME, 
       SUM(P.VLR_TOTAL) AS TOT_VENDIDO,
       SUM(P.VLR_TOTAL * V.PORC_COMISSAO / 100) AS COMISSAO
FROM TB_PEDIDO P
     JOIN TB_VENDEDOR V ON P.CODVEN = V.CODVEN
WHERE P.DATA_EMISSAO BETWEEN '2014.1.1' AND '2014.1.31'
GROUP BY V.CODVEN, V.NOME

-- 7. Liste os nomes e o total comprado pelos 10 clientes que mais compraram em janeiro de 2014; 
SELECT TOP 10 
   C.CODCLI, C.NOME, SUM(P.VLR_TOTAL) AS TOT_COMPRADO
FROM TB_PEDIDO P 
     JOIN TB_CLIENTE C ON P.CODCLI = C.CODCLI
WHERE P.DATA_EMISSAO BETWEEN '2014.1.1' AND '2014.1.31'
GROUP BY C.CODCLI, C.NOME
ORDER BY TOT_COMPRADO DESC

-- 8. Liste os nomes dos clientes que não compraram em janeiro de 2014;
SELECT * FROM TB_CLIENTE
WHERE CODCLI NOT IN
(
SELECT DISTINCT CODCLI FROM TB_PEDIDO
WHERE DATA_EMISSAO BETWEEN '2014.1.1' AND '2014.1.31'
)
ORDER BY NOME

-- 9. Reajuste os preços de venda de todos os produtos com COD_TIPO = 5 de modo que fiquem 20% acima do preço de custo;
UPDATE TB_PRODUTO SET PRECO_VENDA = PRECO_CUSTO * 1.2
WHERE COD_TIPO = 5

/*
   10. Reajuste os preços de venda de todos os produtos com descrição do tipo igual a REGUA, 
       de modo que fiquem 40% acima do preço de custo;
*/
UPDATE TB_PRODUTO SET PRECO_VENDA = PRECO_CUSTO * 1.4
FROM TB_PRODUTO P JOIN TB_TIPOPRODUTO T ON P.COD_TIPO = T.COD_TIPO
WHERE T.TIPO = 'REGUA'
-- OU
UPDATE TB_PRODUTO SET PRECO_VENDA = PRECO_CUSTO * 1.4
WHERE COD_TIPO = (SELECT COD_TIPO FROM TB_TIPOPRODUTO
                  WHERE TIPO = 'REGUA')

--==============================================================================
-- Laboratório 2
-- Parte A

-- 1. Coloque em uso o banco de dados PEDIDOS;
USE PEDIDOS

-- 2. Gere uma cópia da tabela PRODUTOS chamada PRODUTOS_COPIA;
IF OBJECT_ID('PRODUTOS_COPIA','U') IS NOT NULL
   DROP TABLE PRODUTOS_COPIA;
   
SELECT * INTO PRODUTOS_COPIA FROM TB_PRODUTO;
GO

-- 3. Exclua da tabela PRODUTOS_COPIA os produtos que sejam do tipo 'CANETA', 
--    exibindo os registros que foram excluídos (OUTPUT);
DELETE FROM PRODUTOS_COPIA
OUTPUT DELETED.*
FROM PRODUTOS_COPIA P JOIN TB_TIPOPRODUTO T ON P.COD_TIPO = T.COD_TIPO
WHERE T.TIPO = 'CANETA'

/*
   4. Aumente em 10% os preços de venda dos produtos do tipo REGUA, mostrando com OUTPUT as seguintes colunas: 
      ID_PRODUTO, DESCRICAO, PRECO_VENDA_ANTIGO e PRECO_VENDA_NOVO;
*/
UPDATE PRODUTOS_COPIA SET PRECO_VENDA = PRECO_VENDA * 1.10
OUTPUT INSERTED.ID_PRODUTO, INSERTED.DESCRICAO, 
       DELETED.PRECO_VENDA AS PRECO_VENDA_ANTIGO, 
       INSERTED.PRECO_VENDA AS PRECO_VENDA_NOVO
FROM PRODUTOS_COPIA P JOIN TB_TIPOPRODUTO T ON P.COD_TIPO = T.COD_TIPO
WHERE T.TIPO = 'REGUA'

/*
   5. Utilizando o comando MERGE, faça com que a tabela PRODUTOS_COPIA volte a ser idêntica à tabela PRODUTOS, ou seja, 
      o que foi deletado de PRODUTOS_COPIA deve ser reinserido, e os produtos que tiveram seus preços alterados devem ser alterados novamente para que voltem a ter o preço anterior. 
      O MERGE deve possuir uma cláusula OUTPUT que mostre as seguintes colunas: ação executada pelo MERGE (DELETE, INSERT, UPDATE), ID_PRODUTO, PRECO_VENDA_ANTIGO, PRECO_VENDA_NOVO;
*/
SET IDENTITY_INSERT PRODUTOS_COPIA ON;

MERGE PRODUTOS_COPIA PC
USING TB_PRODUTO P
ON PC.ID_PRODUTO = P.ID_PRODUTO
WHEN MATCHED AND PC.PRECO_VENDA <> P.PRECO_VENDA THEN
     UPDATE SET PC.PRECO_VENDA = P.PRECO_VENDA
WHEN NOT MATCHED THEN
     INSERT (ID_PRODUTO,COD_PRODUTO,DESCRICAO,COD_UNIDADE,
             COD_TIPO,PRECO_CUSTO,PRECO_VENDA,QTD_ESTIMADA,
             QTD_REAL,QTD_MINIMA,CLAS_FISC,IPI,PESO_LIQ)
     VALUES (ID_PRODUTO,COD_PRODUTO,DESCRICAO,COD_UNIDADE,
             COD_TIPO,PRECO_CUSTO,PRECO_VENDA,QTD_ESTIMADA,
             QTD_REAL,QTD_MINIMA,CLAS_FISC,IPI,PESO_LIQ)        
OUTPUT $ACTION, INSERTED.ID_PRODUTO, 
                DELETED.PRECO_VENDA AS PRECO_VENDA_ANTIGO,
                INSERTED.PRECO_VENDA AS PRECO_VENDA_NOVO;

SET IDENTITY_INSERT PRODUTOS_COPIA OFF;

-- Laboratório 2
-- Parte B
--1
USE PEDIDOS
GO

--2
SELECT ESTADO, VLR_TOTAL, MONTH(DATA_EMISSAO) AS MES
      FROM	TB_PEDIDO
	  JOIN	TB_CLIENTE  ON TB_CLIENTE.CODCLI = TB_PEDIDO.CODCLI 
      WHERE YEAR(DATA_EMISSAO) = 2006

--3
SELECT ESTADO, [1] AS MES1, [2] AS MES2, [3] AS MES3, [4] AS MES4, [5] AS MES5, 
               [6] AS MES6, [7] AS MES7, [8] AS MES8, [9] AS MES9, [10] AS MES10,
               [11] AS MES11, [12] AS MES12
FROM (SELECT ESTADO, VLR_TOTAL, MONTH(DATA_EMISSAO) AS MES
      FROM	TB_PEDIDO 
	  JOIN	TB_CLIENTE  ON TB_CLIENTE.CODCLI = TB_PEDIDO.CODCLI 
      WHERE YEAR(DATA_EMISSAO) = 2006) P
   PIVOT( SUM(VLR_TOTAL) FOR MES IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])) AS PVT
ORDER BY 1     

--4
SELECT ESTADO, CIDADE,	[1] AS MES1, [2] AS MES2, [3] AS MES3, [4] AS MES4, [5] AS MES5, 
				        [6] AS MES6, [7] AS MES7, [8] AS MES8, [9] AS MES9, [10] AS MES10,
						[11] AS MES11, [12] AS MES12
FROM (SELECT ESTADO, CIDADE, VLR_TOTAL, MONTH(DATA_EMISSAO) AS MES
      FROM	TB_PEDIDO
	  JOIN	TB_CLIENTE  ON TB_CLIENTE.CODCLI = TB_PEDIDO.CODCLI 
      WHERE YEAR(DATA_EMISSAO) = 2006
	  ) P
   PIVOT( SUM(VLR_TOTAL) FOR MES IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])) AS PVT
ORDER BY 1     

-- Laboratório 2
-- Parte C
--1
USE PEDIDOS
GO

--2
WITH CTE( MES, ANO, MAIOR_PEDIDO )
AS
(
-- Membro âncora
SELECT MONTH( DATA_EMISSAO ) AS MES,
       YEAR( DATA_EMISSAO ) AS ANO,
       MAX( VLR_TOTAL ) AS MAIOR_PEDIDO
FROM TB_PEDIDO
WHERE YEAR(DATA_EMISSAO) = 2006
GROUP BY MONTH(DATA_EMISSAO), YEAR(DATA_EMISSAO)	
)

-- Utilização da CTE fazendo JOIN com a tabela PEDIDOS
SELECT CTE.MES, CTE.ANO, CTE.MAIOR_PEDIDO, P.NUM_PEDIDO , C.NOME
FROM CTE JOIN TB_PEDIDO P ON CTE.MES = MONTH(P.DATA_EMISSAO) AND
                           CTE.ANO = YEAR(P.DATA_EMISSAO) AND
                           CTE.MAIOR_PEDIDO = P.VLR_TOTAL
JOIN	TB_CLIENTE C		ON C.CODCLI = P.CODCLI


--D – Utilizando APPLY
--1. Coloque em uso o banco de dados PEDIDOS;
USE PEDIDOS

/*2. Realize uma consulta que apresente as informações abaixo:

- Código, nome, número do pedido, valor total e estado do cliente;

- Quantos pedidos os cliente realizou;

- A soma do valor total dos pedidos do cliente;

- A quantidade dos pedidos do estado do cliente;

- A soma do valor total dos pedidos do estado do cliente;

- O maior e menor valor dos pedidos do estado do cliente;

- A data da última compra do pedido do estado do cliente,

- Percentual da compra sobre o total do mês:
(VLR_Total / Total do mês *100);

- Quantidade de dias entre data de emissão com a última compra;

Os registros devem ser apenas de Janeiro de 2014;

Ordenar pelo nome do cliente e número de pedido.*/


SELECT	C.CODCLI, C.NOME, P.NUM_PEDIDO, C.ESTADO,P.DATA_EMISSAO,P.VLR_TOTAL,
		(	SELECT COUNT(*) 
			FROM TB_PEDIDO AS PE 
			JOIN TB_CLIENTE AS CL ON PE.CODCLI = CL.CODCLI 
			WHERE CL.ESTADO = C.ESTADO AND
			YEAR(PE.DATA_EMISSAO) =2014 ) AS QTD_ESTADO,
		CR.QTD_PED, CR.TOTAL, CR.MAIOR_VALOR , CR.MENOR_VALOR , CR.DT_ULT_PEDIDO ,
		P.VLR_TOTAL/CR.TOTAL *100 AS Perc_Pedido,
		FLOOR(CAST(CR.DT_ULT_PEDIDO - P.DATA_EMISSAO  AS FLOAT)) AS QTD_DIAS
FROM TB_CLIENTE AS C
JOIN TB_PEDIDO AS P ON P.CODCLI = C.CODCLI 
CROSS APPLY
 ( SELECT	COUNT(*) AS QTD_PED, 
			SUM(VLR_TOTAL) AS TOTAL,
			MAX(VLR_TOTAL) AS MAIOR_VALOR,
			MIN(VLR_TOTAL) AS MENOR_VALOR,
			MAX(DATA_EMISSAO) AS DT_ULT_PEDIDO 
 FROM TB_PEDIDO  AS PC
 WHERE C.CODCLI = PC.CODCLI AND YEAR(PC.DATA_EMISSAO) = 2014 )AS CR
WHERE  YEAR(P.DATA_EMISSAO) = 2014
ORDER BY C.NOME
