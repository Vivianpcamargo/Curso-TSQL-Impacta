-- Criando Funções Escalares
GO
CREATE FUNCTION fn_Maior(@n1 int,@n2 int)
RETURNS int
AS
	BEGIN
		DECLARE @ret int
		IF @n1 > @n2
			SET @ret = @n1
		ELSE
			SET @ret = @n2
	
		RETURN @ret
	END
GO
-- Utilizando nossa função
-- Ao chamar a função é obrigatório especificar OWNER (dbo)
SELECT dbo.fn_Maior(2,5);

GO
CREATE FUNCTION fn_AdicionarData2(@dt date,@op char(1),@n int)
RETURNS date
WITH ENCRYPTION
AS
	BEGIN
		DECLARE @ret date
		SET @ret = 
			CASE UPPER(@op)
				WHEN 'D'	THEN DATEADD(DAY,@n,@dt)
				WHEN 'S'	THEN DATEADD(WEEK,@n,@dt)
				WHEN 'M'	THEN DATEADD(MONTH,@n,@dt)
				WHEN 'Q'	THEN DATEADD(QUARTER,@n,@dt)
				WHEN 'A'	THEN DATEADD(YEAR,@n,@dt)
			END
		RETURN @ret
	END
GO
exec sp_helptext fn_AdicionarData2
SELECT dbo.fn_AdicionarData(GETDATE(),'d',20);
SELECT dbo.fn_AdicionarData(GETDATE(),'s',6);
SELECT dbo.fn_AdicionarData(GETDATE(),'m',3);
SELECT dbo.fn_AdicionarData(GETDATE(),'q',2);
SELECT dbo.fn_AdicionarData(GETDATE(),'a',5);

-- Visualizar o código da function (SEM OWNER)
EXEC sp_help fn_Maior;

SELECT
	T2.name,T1.text
FROM SYSCOMMENTS T1,SYSOBJECTS T2
WHERE T2.xtype = 'FN' AND T2.uid = 1 AND T1.id = T2.id


-- Funções Tabulares
-- Banco Seguro Veículo
USE SeguroVeiculo;
GO
CREATE FUNCTION fn_Apolices(@ano int)
RETURNS table
AS
RETURN
(SELECT        
Clientes.nomeSegurado, Clientes.cadastroSegurado, Seguradoras.nomeSeguradora, 
Apolices.valorApolice, Apolices.dataContratacao, Apolices.prazoMeses, Cidades.nomeCidade
FROM Apolices INNER JOIN
       Cidades ON Apolices.idCidade = Cidades.idCidade INNER JOIN
       Clientes ON Apolices.nContrato = Clientes.nContrato INNER JOIN
       Seguradoras ON Apolices.idSeguradora = Seguradoras.idSeguradora
	   WHERE YEAR(Clientes.cadastroSegurado) = @ano
);
GO

-- Testando a função
SELECT * FROM dbo.fn_Apolices(2013);

