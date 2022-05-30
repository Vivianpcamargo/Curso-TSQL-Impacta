--1. Habilite a visibilidade das opções avançadas:
EXEC sp_configure 'show advanced option', '1';
reconfigure

--2. Habilite a utilização de OPENROWSET:
exec sp_configure 'Ad Hoc Distributed Queries',1
reconfigure

--3. Acesse o Excel e crie a tabela PESSOA no SQL Server:
CREATE DATABASE TESTE
GO
USE TESTE

GO
CREATE TABLE PESSOA 
(
	COD INT, 
	NOME VARCHAR(50)
)
GO

--4. Execute o seguinte trecho:
SELECT * FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0', 
'Excel 12.0;Database=C:\DADOS\PESSOA.XLSX', 
'SELECT COD, NOME FROM [NOMES$]') 

--5. Importe os dados da planilha para a tabela PESSOA do SQL Server:
--IMPORTAR DADOS
INSERT INTO PESSOA
SELECT * FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0', 
'Excel 12.0;Database=C:\DADOS\PESSOA.XLSX', 
'SELECT COD, NOME FROM [NOMES$]') 

SELECT * FROM PESSOA

--6. Exporte dados para o Excel;
--EXPORTAR DADOS
INSERT INTO OPENROWSET('Microsoft.ACE.OLEDB.12.0', 
'Excel 12.0;Database=C:\DADOS\PESSOA.XLSX', 
'SELECT COD, NOME FROM [NOMES$]') 
SELECT * FROM PESSOA

SELECT * FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
'Excel 8.0;Database=C:\DADOS\PESSOA.XLS', 
'SELECT COD, NOME FROM [NOMES$]');
SELECT * FROM PESSOA 

--7. Acesse o Access;
SELECT *
   FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
      'C:\Dados\Pedidos.accdb';
      'admin';'',PEDIDOS)

--8. Crie uma JOIN entre a tabela do Access e a tabela do SQL Server:
SELECT P.*, C.NOME
   FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
      'C:\Dados\Pedidos.accdb';
      'admin';'',PEDIDOS) P
   JOIN PEDIDOS.DBO.TB_CLIENTE C ON P.CODCLI = C.CODCLI

--9. Importe dados do Access;

CREATE TABLE TIPOPRODUTO 
(COD_TIPO INT PRIMARY KEY, TIPO VARCHAR(30))

INSERT INTO TIPOPRODUTO
SELECT *
   FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
      'C:\Dados\Pedidos.accdb';
      'admin';'',TIPOPRODUTO) 

SELECT * FROM TIPOPRODUTO


--- Bulk insert

--1.	Criação da tabela TESTE_BULK_INSERT
CREATE TABLE TESTE_BULK_INSERT
( CODIGO			INT, 
  NOME			VARCHAR(40),
  DATA_NASCIMENTO 	DATETIME )


--2.	Execução do commando BULK INSERT

BULK INSERT TESTE_BULK_INSERT
   FROM 'C:\DADOS\BULK_INSERT.txt'
   WITH
     (
        FIELDTERMINATOR =';',
        ROWTERMINATOR = '\n',
        codepage = 'acp' 
      )

--3.	Consulta à tabela

SELECT * FROM TESTE_BULK_INSERT


---XML
USE PEDIDOS 
GO

SELECT ID_PRODUTO, COD_TIPO, DESCRICAO, PRECO_VENDA
FROM TB_PRODUTO
FOR XML RAW

SELECT ID_PRODUTO, COD_TIPO, DESCRICAO, PRECO_VENDA
FROM TB_PRODUTO
--      tag da linha  , tag principal
FOR XML RAW('Produto'), ROOT('Produtos')


UPDATE TB_PRODUTO SET DESCRICAO = 'ABRIDOR SACA & ROLHA' WHERE ID_PRODUTO = 1

SELECT ID_PRODUTO, COD_TIPO, DESCRICAO, PRECO_VENDA
FROM TB_PRODUTO
FOR XML RAW('Produto'), ROOT('Produtos'), ELEMENTS

SELECT ID_PRODUTO, COD_TIPO, DESCRICAO, PRECO_VENDA
FROM TB_PRODUTO
FOR XML RAW('Produto'), ROOT('Produtos'), ELEMENTS XSINIL


-- o nome da coluna dá nome ao elemento de cada campo
SELECT Empregado.CODFUN AS Codigo, Empregado.NOME, Empregado.DATA_ADMISSAO, Empregado.SALARIO
-- o apelido da tabela dá nome à tag de linha      
FROM TB_EMPREGADO Empregado 
FOR XML AUTO, ROOT('Empregados'), ELEMENTS XSINIL

SELECT Empregado.CODFUN, Empregado.NOME, Empregado.DATA_ADMISSAO, Empregado.SALARIO, Dependente.CODDEP, Dependente.NOME, Dependente.DATA_NASCIMENTO
FROM TB_EMPREGADO Empregado JOIN TB_DEPENDENTE Dependente ON Empregado.CODFUN = Dependente.CODFUN
FOR XML AUTO, ROOT('Empregados'), ELEMENTS XSINIL


SELECT 
  Cliente.CODCLI AS IdCliente, Cliente.NOME AS Cliente, 
  Pedidos.NUM_PEDIDO AS IdPedido, Pedidos.VLR_TOTAL AS VlrPedido, 
  Pedidos.DATA_EMISSAO AS Emissao
FROM TB_CLIENTE Cliente JOIN TB_PEDIDO Pedidos ON Cliente.CODCLI = Pedidos.CODCLI
WHERE Pedidos.DATA_EMISSAO BETWEEN '2014.1.1' AND '2014.1.31'  
FOR XML AUTO, ROOT('Clientes')


SELECT 
  Cliente.CODCLI AS IdCliente, Cliente.NOME AS Cliente, 
  Pedidos.NUM_PEDIDO AS IdPedido,
  Pedidos.VLR_TOTAL AS VlrPedido, Pedidos.DATA_EMISSAO AS Emissao
FROM TB_CLIENTE Cliente JOIN TB_PEDIDO Pedidos ON Cliente.CODCLI = Pedidos.CODCLI
WHERE Pedidos.DATA_EMISSAO BETWEEN '2014.1.1' AND '2014.1.31'  
FOR XML AUTO, ROOT('Clientes'), ELEMENTS


SELECT   
  Cliente.CODCLI AS IdCliente, Cliente.NOME AS Cliente, 
  Pedidos.NUM_PEDIDO AS IdPedido,
  Pedidos.VLR_TOTAL AS VlrPedido, Pedidos.DATA_EMISSAO AS Emissao,
  Itens.NUM_ITEM AS IdItem, Itens.ID_PRODUTO AS IdProduto,
  Itens.QUANTIDADE AS Quantidade, Itens.PR_UNITARIO AS PrUnitario
FROM TB_CLIENTE Cliente 
JOIN TB_PEDIDO Pedidos ON Cliente.CODCLI = Pedidos.CODCLI
JOIN TB_ITENSPEDIDO Itens ON Pedidos.NUM_PEDIDO = Itens.NUM_PEDIDO
WHERE Pedidos.DATA_EMISSAO BETWEEN '2014.1.1' AND '2014.1.31'  
-- Importante para ter um resultado correto
ORDER BY Cliente.NOME, Pedidos.NUM_PEDIDO 
FOR XML AUTO, ROOT('Clientes')


SELECT 1 AS Tag, NULL AS Parent, 
--     conteúdo        tag      id  atributo -->> <Empregado Codigo="1">
       CODFUN         [Empregado!1!Codigo],
--     dentro da tag Empregado criar elemento "Nome"
       NOME AS [Empregado!1!Funcionario!ELEMENT],
--     dentro da tag Empregado criar elemento "Salario"
       SALARIO [Empregado!1!Renda!ELEMENT],
--     dentro da tag Empregado criar elemento "DataAdm"       
       DATA_ADMISSAO [Empregado!1!DataAdm!ELEMENT]
FROM TB_EMPREGADO
ORDER BY CODFUN
FOR XML EXPLICIT, ROOT('Empregados')


SELECT 1 AS Tag, NULL AS Parent, 
--     conteúdo        tag      id  elemento
--	<Codigo>1</Codigo>					
       CODFUN         [Empregado!1!Codigo!ELEMENT],
--     dentro da tag Empregado criar elemento "Nome"
       NOME AS [Empregado!1!Funcionario!ELEMENT],
--     dentro da tag Empregado criar elemento "Salario"
       SALARIO [Empregado!1!Renda!ELEMENT],
--     dentro da tag Empregado criar elemento "DataAdm"       
       DATA_ADMISSAO [Empregado!1!DataAdm!ELEMENT]
FROM TB_EMPREGADO
ORDER BY CODFUN
FOR XML EXPLICIT, ROOT('Empregados')

SELECT 1 AS Tag, NULL AS Parent, 
--     atributo ficará oculto
       CODFUN         [Empregado!1!Codigo!HIDE], 
--     dentro da tag Empregado criar tag "Nome"
       NOME AS [Empregado!1!Funcionario!ELEMENT],
--     dentro da tag Empregado criar tag "Salario"
       SALARIO [Empregado!1!Renda!ELEMENT],
--     dentro da tag Empregado criar tag "DataAdm"       
       DATA_ADMISSAO [Empregado!1!DataAdm!ELEMENT]
FROM TB_EMPREGADO 
ORDER BY CODFUN
FOR XML EXPLICIT, ROOT('Empregados')



SELECT 1 AS TAG, NULL AS PARENT,
   -- gera a tag principal no primeiro nível
   '' [Empregados!1],
   -- define o restante da estrutura do XML
    NULL AS [Empregado!2!CODFUN],
    NULL AS [Empregado!2!Nome!ELEMENT],
    NULL [Empregado!2!Salario!ELEMENT],
    NULL [Empregado!2!DataAdm!ELEMENT]
UNION ALL   
-- fornece os dados definidos na estrutura anterior
-- Tag de nível 2, o parent desta Tag é a Tag do nível anterior 
SELECT 2 AS Tag, 1 AS Parent, NULL,
       CODFUN,
       NOME,
       SALARIO,
       DATA_ADMISSAO
FROM TB_EMPREGADO
FOR XML EXPLICIT , ROOT('Empregados')


SELECT 1 AS TAG, NULL AS PARENT,
   -- gera a tag principal no primeiro nível
   '' [Empregados!1],
   -- define o restante da estrutura
    NULL AS [Empregado!2!CODFUN],
    NULL AS [Empregado!2!Nome!ELEMENT],
    NULL [Empregado!2!Salario!ELEMENT],
    NULL [Empregado!2!DataAdm!ELEMENT],
    -- subnível vinculado a cada empregado
    NULL [Dependente!3!CodFun!HIDE],
    NULL [Dependente!3!CodDep],
    NULL [Dependente!3!Nome!ELEMENT],
    NULL [Dependente!3!DataNasc!ELEMENT]
UNION ALL   
-- fornece os dados definidos na estrutura anterior
-- Tag de nível 2, o parent desta Tag é a Tag do nível anterior (1)
SELECT 2 AS Tag, 1 AS Parent, NULL,
       CODFUN,
       NOME,
       SALARIO,
       DATA_ADMISSAO, NULL, NULL, NULL, NULL       
FROM TB_EMPREGADO
UNION ALL
-- Tag de nível 3, o parent desta Tag é a Tag do nível anterior (2)
SELECT 3 AS Tag, 2 AS Parent, NULL,        
       E.CODFUN,
       E.NOME,
       E.SALARIO,
       E.DATA_ADMISSAO,
       D.CODFUN, D.CODDEP, D.NOME, D.DATA_NASCIMENTO
FROM TB_EMPREGADO E 
JOIN TB_DEPENDENTE D ON E.CODFUN = D.CODFUN
ORDER BY [Empregado!2!CODFUN],[Dependente!3!CodFun!HIDE]
FOR XML EXPLICIT;

GO

CREATE FUNCTION FN_XML_CHAR( @S VARCHAR(1000) )
  RETURNS VARCHAR(1000)
AS BEGIN  
DECLARE @CONT INT = 1;
DECLARE @RET VARCHAR(1000) = '';
DECLARE @C CHAR(1);
WHILE @CONT <= LEN(@S)
   BEGIN
   SET @C = SUBSTRING(@S,@CONT,1);
   SET @RET += CASE
					WHEN @C = '<' THEN '&lt;'
					WHEN @C = '>' THEN '&gt;'
					WHEN @C = '&' THEN '&amp;'
					WHEN @C = '"' THEN '&quot;'
					WHEN @C = '''' THEN '&#39;'
                    ELSE @C
	           END  
   SET @CONT += 1;	            
   END 
RETURN @RET;   
END
GO


SELECT 
 CAST('<Codigo>'+CAST(C.CODCLI AS VARCHAR(5))+'</Codigo>' AS XML) AS "node()",
 CAST('<Nome>'+DBO.FN_XML_CHAR( C.NOME ) + '</Nome>' AS XML) AS "node()"
FROM TB_CLIENTE C
FOR XML PATH('Cliente'), ROOT('Clientes')


SELECT 
   CAST('<Codigo>'+CAST(C.CODCLI AS VARCHAR(5))+'</Codigo>' AS XML) AS "node()",
   CAST('<Nome>'+DBO.FN_XML_CHAR( C.NOME ) + '</Nome>' AS XML) AS "node()",
      (	SELECT 
	   NUM_PEDIDO AS "@IdPedido", VLR_TOTAL AS "@VlrTotal", 
          DATA_EMISSAO AS "@DataEmissao"
	FROM TB_PEDIDO
	   WHERE CODCLI = C.CODCLI AND 
                DATA_EMISSAO BETWEEN '2007.1.1' AND '2007.1.31'
       ORDER BY NUM_PEDIDO
	FOR XML PATH('Pedidos'), TYPE)
FROM TB_CLIENTE C
ORDER BY C.NOME
FOR XML PATH('Cliente'), ROOT('Clientes')


SELECT 
   CAST('<Codigo>'+ CAST(C.CODCLI AS VARCHAR(5))+'</Codigo>' AS XML) AS "node()",
   CAST('<Nome>'+DBO.FN_XML_CHAR( C.NOME ) + '</Nome>' AS XML) AS "node()",
      (	SELECT 
	   CAST('<NumPedido>' +CAST( NUM_PEDIDO AS VARCHAR (5)) + 
                                             '</NumPedido>' AS  XML) AS "node()", 
	   CAST('<VlrTotal>' + CAST( VLR_TOTAL AS VARCHAR (15)) + 
                                              '</VlrTotal>' AS XML) AS "node()", 
	   CAST('<DataEmissao>' + CONVERT(VARCHAR(10),DATA_EMISSAO, 112) + 
                                              '</DataEmissao>' AS XML) AS "node()"
	FROM TB_PEDIDO
	WHERE CODCLI = C.CODCLI AND DATA_EMISSAO BETWEEN '2007.1.1' AND '2007.1.31'
	ORDER BY NUM_PEDIDO
	FOR XML PATH('Pedido'), TYPE)
FROM TB_CLIENTE C
ORDER BY C.NOME
FOR XML PATH('Cliente'), ROOT('Clientes')


-- Declarando uma variável XML 
DECLARE @XML XML

-- Carrega as informações da consulta para a variável XML, utilizando o FOR XML:
SET @XML = 
	(
	SELECT	CODFUN, NOME, DATA_ADMISSAO 
	FROM TB_EMPREGADO AS EMPREGADO
	FOR XML AUTO, ELEMENTS
    )

SELECT @XML.query('EMPREGADO')
SELECT @XML.query('EMPREGADO/NOME')
SELECT @XML.query('EMPREGADO[1]/NOME')
SELECT @XML.query('EMPREGADO[10]/NOME')
SELECT @XML.query('EMPREGADO[NOME=''MARCELO SOARES'']')
SELECT @XML.query('EMPREGADO[NOME=''MARCELO SOARES'']/DATA_ADMISSAO')

---

DECLARE @XML XML
SET @XML = 
	(SELECT	CODFUN, NOME, DATA_ADMISSAO FROM TB_EMPREGADO AS EMPREGADO
	FOR XML AUTO, ELEMENTS )
	
SELECT @XML.value('(EMPREGADO/NOME)[1]', 'varchar(100)')
SELECT @XML.value('(EMPREGADO/CODFUN)[15]', 'INT')


DECLARE @XML XML
SET @XML = 
	(SELECT	CODFUN, NOME, DATA_ADMISSAO FROM TB_EMPREGADO AS EMPREGADO
	FOR XML AUTO, ELEMENTS )
	
SELECT @XML.exist('EMPREGADO/CODFUN' )
SELECT @XML.exist('(EMPREGADO/CODFUN)[35]' )
SELECT @XML.exist('(EMPREGADO/CODFUN)[3500]' )

SELECT	CASE  @XML.exist('(EMPREGADO/CODFUN)[3500]' )
		WHEN 0 THEN 'Não EXISTE'
		WHEN 1 THEN 'EXISTE' END 


DECLARE @XML XML
SET @XML = 
	(SELECT	CODFUN, NOME, DATA_ADMISSAO 
FROM TB_EMPREGADO AS EMPREGADO 	FOR XML AUTO, ELEMENTS )
	
SELECT	C.query('.') as Nome
FROM	@xml.nodes('EMPREGADO/NOME') AS X(C)

--Habilitar opções avançadas
sp_configure 'show advanced option',1
go
reconfigure
go

--Habilitar a execução da procedure XP_CMDSHELL
sp_configure 'xp_cmdshell',1
go 
reconfigure



DECLARE @CMD VARCHAR(4000)

SET @CMD = 
'BCP "SELECT * FROM PEDIDOS.DBO.TB_TIPOPRODUTO AS TIPO FOR XML AUTO, ROOT(''RESULTADO''), ELEMENTS " ' + 
' QUERYOUT "C:\DADOS\ARQUIVOXML.XML" -SINSTRUTOR -t -w -t -T'

EXEC MASTER..XP_CMDSHELL  @CMD


CREATE TABLE TB_TIPO_XML
(
COD_TIPO	INT,
TIPO		VARCHAR(30) 
)
GO

INSERT INTO TB_TIPO_XML
SELECT 
X.TIPO.query('COD_TIPO').value('.', 'INT'),
X.TIPO.query('TIPO').value('.', 'VARCHAR(30)')
FROM
( 	
    SELECT CAST(X AS XML)
    FROM OPENROWSET(
        BULK 'C:\DADOS\ARQUIVOXML.XML',
        SINGLE_BLOB) AS T(X)
) AS T(X)
CROSS APPLY X.nodes('RESULTADO/TIPO') AS X(TIPO);


SELECT * FROM TB_TIPO_XML

--JSON
SELECT ID_PRODUTO, COD_TIPO, DESCRICAO, PRECO_VENDA
FROM TB_PRODUTO
FOR JSON AUTO;


SELECT Empregado.CODFUN AS Codigo, Empregado.NOME, Empregado.DATA_ADMISSAO, Empregado.SALARIO
FROM TB_EMPREGADO Empregado 
FOR JSON AUTO, ROOT('Empregados');


SELECT   
  Cliente.CODCLI AS IdCliente, Cliente.NOME AS Cliente, 
  Pedidos.NUM_PEDIDO AS IdPedido,
  Pedidos.VLR_TOTAL AS VlrPedido, Pedidos.DATA_EMISSAO AS Emissao,
  Itens.NUM_ITEM AS IdItem, Itens.ID_PRODUTO AS IdProduto,
  Itens.QUANTIDADE AS Quantidade, Itens.PR_UNITARIO AS PrUnitario
FROM TB_CLIENTE Cliente 
JOIN TB_PEDIDO Pedidos ON Cliente.CODCLI = Pedidos.CODCLI
JOIN TB_ITENSPEDIDO Itens ON Pedidos.NUM_PEDIDO = Itens.NUM_PEDIDO
WHERE Pedidos.DATA_EMISSAO BETWEEN '2014.1.1' AND '2014.1.31'  
-- Importante para ter um resultado correto
ORDER BY Cliente.NOME, Pedidos.NUM_PEDIDO 
FOR JSON AUTO, ROOT('Clientes')

SELECT 
  Cliente.CODCLI AS IdCliente, Cliente.NOME AS Cliente, 
  Pedidos.NUM_PEDIDO AS IdPedido,
  Pedidos.VLR_TOTAL AS VlrPedido, Pedidos.DATA_EMISSAO AS Emissao
FROM TB_CLIENTE Cliente JOIN TB_PEDIDO Pedidos ON Cliente.CODCLI = Pedidos.CODCLI
WHERE Pedidos.DATA_EMISSAO BETWEEN '2014.1.1' AND '2014.1.31'  
FOR JSON PATH, ROOT('Clientes')



SELECT * FROM OPENJSON('["São Paulo", "Rio de Janeiro", "Minas Gerais", "Paraná", "Santa Catarina"]')

DECLARE @json NVARCHAR(4000)

SET @json = N'{
"CODCLI": 1,
"NOME": "IMPACTA Treinamento"}'

SELECT * FROM OPENJSON(@json) AS CLIENTE;

DECLARE @json NVARCHAR(4000)

SET @json = N'{
"CODCLI": 1,
"NOME": "IMPACTA Treinamento"}'

SELECT [KEY], Value FROM OPENJSON(@json) AS CLIENTE;


DECLARE @json NVARCHAR(4000)

SET @json = N'{
"CODCLI": 1,
"NOME": "IMPACTA Treinamento"}'

SELECT [KEY], Value FROM OPENJSON(@json) AS CLIENTE
WHERE [KEY]='NOME'


DECLARE @json NVARCHAR(4000)

SET @json = N'{
"CODCLI": 1,
"NOME": "IMPACTA Treinamento"}'

-- Campo Nome
SELECT  JSON_VALUE(@json, '$.NOME') AS NOME

-- Campo CODCLI
SELECT  JSON_VALUE(@json, '$.CODCLI')


DECLARE @json NVARCHAR(4000)

SET @json = N'
{"CLIENTES":[
{"CODCLI":1,"NOME":"IMPACTA Treinamento"},
{"CODCLI":2,"NOME":"FACULDADE IMPACTA"} 
]}'

SELECT  JSON_VALUE(@json, '$.CLIENTES[0].NOME') AS NOME

SELECT  JSON_VALUE(@json, '$.CLIENTES[1].NOME') AS NOME



DECLARE @json NVARCHAR(4000)

SET @json = N'{
"CODCLI": 1,
"NOME": "IMPACTA Treinamento",
"FONE":["(11)3342-1234","(11)3342-1235"]}'

SELECT  JSON_VALUE(@json, '$.FONE[1]') AS FONE



DECLARE @json NVARCHAR(4000)

SET @json = N'{
"CODCLI": 1,
"NOME": "IMPACTA Treinamento",
"FONE":["(11)3342-1234", "(11)3342-1235"]}'

SELECT  JSON_QUERY(@json, '$.FONE') AS FONE


DECLARE @json NVARCHAR(4000)

SET @json = N'{"CLIENTES":[
{"CODCLI":1,"NOME":"IMPACTA Treinamento"},
{"CODCLI":2,"NOME":"FACULDADE IMPACTA"} 
]}'
SELECT  JSON_QUERY(@json, '$')  a


DECLARE @json NVARCHAR(4000)

SET @json = N'{"CLIENTES":[
{"CODCLI":1,"NOME":"IMPACTA Treinamento"},
{"CODCLI":2,"NOME":"FACULDADE IMPACTA"} 
]}'
SELECT	CASE ISJSON(@json)
		WHEN 1 THEN 'Variável JSON válida' 
		ELSE 'Variável JSON inválida'
		END as Validacao



DECLARE @json NVARCHAR(4000)

SET @json = N'{"CLIENTES"[
{"CODCLI":1,"NOME":"IMPACTA Treinamento"},
{"CODCLI":2,"NOME":"FACULDADE IMPACTA"} 
]}'
SELECT	CASE ISJSON(@json)
		WHEN 1 THEN 'Variável JSON válida' 
		ELSE 'Variável JSON inválida'
		END as Validacao


DECLARE @CMD VARCHAR(4000)

SET @CMD = 
'BCP "SELECT * FROM PEDIDOS.DBO.TB_TIPOPRODUTO AS TIPO FOR JSON AUTO" ' + 
' QUERYOUT "C:\DADOS\ARQUIVOJSON.XML" -SINSTRUTOR -t -w -t -T'

EXEC MASTER..XP_CMDSHELL  @CMD

CREATE TABLE TB_TIPO_JSON
(
COD_TIPO	INT,
TIPO		VARCHAR(30) 
)
GO


SELECT RESULTADO.*
FROM OPENROWSET (BULK 'C:\DADOS\ARQUIVOJSON.JSON', SINGLE_NCLOB) as j
CROSS APPLY OPENJSON(BulkColumn)
WITH( COD_TIPO INT, TIPO nvarchar(30)) AS RESULTADO


INSERT INTO TB_TIPO_JSON 
SELECT RESULTADO.*
FROM OPENROWSET (BULK 'C:\DADOS\ARQUIVOJSON.JSON', SINGLE_NCLOB) as j
CROSS APPLY OPENJSON(BulkColumn)
WITH( COD_TIPO INT, TIPO nvarchar(30)) AS RESULTADO


SELECT * FROM TB_TIPO_JSON