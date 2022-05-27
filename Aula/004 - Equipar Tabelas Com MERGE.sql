----------------------------------------------------------------------------------------
-- MERGE
----------------------------------------------------------------------------------------
USE RecursosAdicionais;

SELECT * FROM Base1;
SELECT * FROM Base2;


/*
	A instrução MERGE é útil quando necessitamos sincronizar bases
	Faz-se necessário definirmos quem será a base de origem (Source)
	e destino.
	Neste exemplo iremos considerar a base1 como a base de referência
	Temos os seguintes cenários:

	- Há itens na base1 não presentes na base2
	- Há itens na base1 existentes na base2, entretanto inconsistentes
	- Há itens na base2 não presentes na base1

	A instrução MERGE exige explicitamente a especificação de fim de instrução (;)
	Há restrição de uma única instrução de UPDATE - INSERT - DELETE por vez
*/
MERGE Base2 AS B2 -- Tabela Alvo
USING Base1 AS B1 -- Tabela Origem
ON B2.id = B1.id
WHEN MATCHED AND B2.Produto <> B1.Produto THEN
	UPDATE SET B2.Produto = B1.Produto

WHEN NOT MATCHED BY TARGET THEN
	INSERT (id,produto,valor)
	VALUES
	(id,produto,valor);

MERGE Base2 AS B2 -- Tabela Alvo
USING Base1 AS B1 -- Tabela Origem
ON B2.id = B1.id
WHEN MATCHED AND B2.valor <> B1.Valor THEN
	UPDATE SET B2.Valor = B1.Valor;

-- Alterar dados na base1 e base2 (modo design-edit)

-- Instrução $ACTION
BEGIN TRAN;
MERGE Base2 AS B2
USING Base1 AS B1
ON B2.id = B1.id
WHEN MATCHED AND B2.Valor <> B1.Valor THEN
	UPDATE SET B2.Valor = B1.Valor

WHEN NOT MATCHED BY TARGET THEN
	INSERT (id,produto,valor)
	VALUES
	(id,produto,valor)
WHEN NOT MATCHED BY SOURCE THEN
	DELETE
OUTPUT
	$ACTION				AS [Ação],
	Inserted.id			AS [id Inserido],
	Inserted.Produto	AS [Produto Inserido],
	Inserted.valor		AS [Valor Inserido],
	Deleted.id			AS [Id Excluído],
	Deleted.Produto		AS [Produto Excluído],
	Deleted.Valor		AS [Valor Excluído];

COMMIT;
-------------------------------------------------------------------
BEGIN TRAN;
MERGE Base1 AS B1
USING Base2 AS B2
ON B2.id = B1.id

WHEN NOT MATCHED BY TARGET THEN
	INSERT (id,produto,valor)
	VALUES
	(id,produto,valor)
WHEN NOT MATCHED BY SOURCE THEN
	DELETE
OUTPUT
	$ACTION				AS [Ação],
	Inserted.id			AS [id Inserido],
	Inserted.Produto	AS [Produto Inserido],
	Inserted.valor		AS [Valor Inserido],
	Deleted.id			AS [Id Excluído],
	Deleted.Produto		AS [Produto Excluído],
	Deleted.Valor		AS [Valor Excluído];

COMMIT;
-----------------------------------------------------------------------------------------
