-- 1. Colocar em uso o banco de dados PEDIDOS
-- Resp.:
USE PEDIDOS

-- 2. Criar VIEW (VIE_TOT_VENDIDO) para mostrar o total vendido (soma de TB_PEDIDO.VLR_TOTAL)
-- em cada mês do ano. Deve mostrar o mês, o ano e o total vendido
-- Resp.:
GO
CREATE VIEW VIE_TOT_VENDIDO AS
SELECT MONTH( DATA_EMISSAO ) AS MES,
       YEAR( DATA_EMISSAO ) AS ANO,
       SUM( VLR_TOTAL ) AS TOT_VENDIDO
FROM TB_PEDIDO
GROUP BY MONTH(DATA_EMISSAO), YEAR(DATA_EMISSAO)
GO
-- 3. Faça uma consulta  VIE_TOTAL_VENDIDO no ano de 2014. Deve ordenar os dados por mês
-- Resp.:
SELECT * FROM VIE_TOT_VENDIDO
WHERE ANO = 2014
ORDER BY MES


-- 4. Criar VIEW (VIE_MAIOR_PEDIDO) para mostrar valor do maior pedido (MAX de TB_PEDIDO.VLR_TOTAL)
-- vendido em cada mês do ano. Deve mostrar o mês, o ano e o maior pedido
GO
CREATE VIEW VIE_MAIOR_PEDIDO AS
SELECT MONTH( DATA_EMISSAO ) AS MES,
       YEAR( DATA_EMISSAO ) AS ANO,
       MAX( VLR_TOTAL ) AS MAIOR_PEDIDO
FROM TB_PEDIDO
WHERE YEAR(DATA_EMISSAO) = 2014
GROUP BY MONTH(DATA_EMISSAO), YEAR(DATA_EMISSAO)
GO
-- 5. Faça uma consulta  VIE_MAIOR_PEDIDO no ano de 2014. Deve ordenar os dados por mês
-- Resp.:
SELECT * FROM VIE_MAIOR_PEDIDO 
WHERE ANO = 2014
ORDER BY 1

-- 6. Faça um JOIN, utilizando VIE_MAIOR_PEDIDO e PEDIDOS que mostre também o número
-- do pedido (TB_PEDIDO.NUM_PEDIDO) de maior valor em cada mês. Deve filtrar o ano
-- de 2014 e ordernar por mês.
-- Resp.:
SELECT V.MES, V.ANO, V.MAIOR_PEDIDO, P.NUM_PEDIDO
FROM VIE_MAIOR_PEDIDO V 
     JOIN TB_PEDIDO P ON V.MES = MONTH(P.DATA_EMISSAO) AND
                       V.ANO = YEAR(P.DATA_EMISSAO) AND
                       V.MAIOR_PEDIDO = P.VLR_TOTAL
WHERE V.ANO = 2014                       
ORDER BY MES

-- 7. Idem ao anterior, desta vez mostrando também o nome do cliente que comprou esse pedido
SELECT V.MES, V.ANO, V.MAIOR_PEDIDO, P.NUM_PEDIDO, C.NOME AS CLIENTE
FROM VIE_MAIOR_PEDIDO V 
     JOIN TB_PEDIDO P ON V.MES = MONTH(P.DATA_EMISSAO) AND
                       V.ANO = YEAR(P.DATA_EMISSAO) AND
                       V.MAIOR_PEDIDO = P.VLR_TOTAL
     JOIN TB_CLIENTE C ON P.CODCLI = C.CODCLI
WHERE V.ANO = 2014                            
ORDER BY MES

-- 8. Criar uma VIEW (VIE_ITENS_PEDIDO) que mostre todos os campos da tabela TB_ITENSPEDIDO, mais
-- DATA_EMISSAO do pedido, DESCRIÇÃO do produto, NOME do cliente que comprou e NOME do 
-- vendedor que vendeu  
GO
CREATE VIEW VIE_ITENSPEDIDO AS
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
GO 
-- 9. Execute VIE_ITENS_PEDIDO filtrando apenas pedidos de Jan/2014
-- Resp.:
SELECT * FROM VIE_ITENSPEDIDO
WHERE YEAR(DATA_EMISSAO) = 2014 


/*10. Crie a tabela tb_CLIENTE_VIEW com os campos:
	- ID		Inteiro auto numerável e PRIMARY KEY
	- Nome	Alfanumérico de 50
	- Estado	Alfanumérico de 2
*/
GO
CREATE TABLE tb_CLIENTE_VIEW
(
ID		INT	IDENTITY PRIMARY KEY,
NOME	VARCHAR(50),
ESTADO	CHAR(2)
)
GO

--11. Crie uma view de nome vW_Clientes_VIEW para consulta e atualização da tabela tb_CLIENTE_VIEW. 
CREATE VIEW vW_Clientes_VIEW AS
SELECT * FROM tb_CLIENTE_VIEW
GO

--12. Faça a inserção de 2 registros através da view vW_Clientes_VIEW.
INSERT INTO vW_Clientes_VIEW VALUES
('Antonio da Silva', 'SP') ,
('Margarida Antunes', 'RJ')

--13. Realize a consulta através da view vW_Clientes_VIEW.
select * from vW_Clientes_VIEW
