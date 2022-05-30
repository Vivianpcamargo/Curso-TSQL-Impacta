/*
	Como ter consultas mais ágeis?

	> Normalização (Bancos OLTP com baixa quantidade de dados)
	> Constraint PK
	> Quantidade de Colunas
	> Evite campos binários (Salvo exceções onde há necessidade de armazenar arquivos)
	> Recomendamos FORTEMENTE o uso de Filestream/FileTable
	> Quando possível, evite tabelas temporárias (exceto se houver índice) e cursores
	> WHERE (Procure utilizá-lo em colunas estratégicas que possuam índices)
	> Evitar a todo custo: LIKE - NOT
	> Evitar Hints ao máximo
	> índices
	> Evitar consultas ad hoc (distribuídas/externas)
*/

/*

	Criando índices

	CREATE INDEX [UNIQUE] [CLUSTERED | NONCLUSTERED] INDEX <nome_do_ indice> 
	ON <nome_tabela_ou_view> ( <nome_coluna> [ASC | DESC] [,...] )

- UNIQUE: A duplicidade do campo chave do índice não será permitida se utilizarmos essa palavra;
- CLUSTERED: Indica que as linhas da tabela estarão fisicamente ordenadas pelo campo que é a chave do índice;
- NONCLUSTERED: Indica que o índice não interfere na ordenação das linhas da tabela (default);
- <nome_tabela_ou_view>: Nome da tabela ou view para a qual o índice será criado;
- <nome_coluna>: É a coluna da tabela que será a chave do índice;
- ASC: Esta palavra determina a ordenação ascendente (padrão);
- DESC: Esta palavra determina a ordenação descendente

*/

USE SysConVendas;
SELECT * FROM Dados;
EXEC sp_help Dados;
-- Visualizar índices
EXEC sp_helpindex Dados;

-- Configurar padrão de entrada de datas
SET DATEFORMAT DMY;
-- Visualizando Plano de Execução
SELECT * FROM Dados
WHERE DataPedido BETWEEN '1/1/2007' AND '30/6/2007'
ORDER BY DataPedido DESC; 

-- Criar índices
CREATE INDEX  IX_DataPedido
ON Dados(DataPedido);

CREATE INDEX IX_Vendedor
ON Dados(Vendedor);

CREATE INDEX IX_Produto
ON Dados(Produto);

CREATE INDEX IX_Cidade
ON Dados(Cidade);

-- Criando índices Compostos
CREATE UNIQUE INDEX  UQ_Registro
ON Dados(Pedido,DataPedido,Vendedor,Cidade,Produto);

-- Excluir índice
DROP INDEX DADOS.IX_Cidade;

--------------------------------------------------------------------------------------------
-- HINTS
-- Forçar o SQL utilizar pesquina no índice
SELECT * FROM Dados
WITH (INDEX = IX_Produto)
WHERE Produto = 'Camisa';

SELECT * FROM Dados
WITH (INDEX = UQ_Registro)
WHERE Vendedor = 'Gisele' AND Produto = 'Gravata';

--------------------------------------------------------------------------------------------
-- MAXDOP
-- Definir quantidade de processadores para executar a consulta
SELECT * FROM Dados
WHERE Mes = 'Junho'
ORDER BY Regiao,Cidade
OPTION(MAXDOP 2);
