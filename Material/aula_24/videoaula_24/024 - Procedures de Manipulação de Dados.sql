-- Procedure de Atualização de Dados
USE SisDep;
GO
CREATE PROCEDURE spr_ReajusteSalarial
@matricula int
AS
	UPDATE Funcionario
	SET Salario *= 1.1
	OUTPUT
		deleted.idMatricula,
		deleted.NomeFuncionario,
		deleted.Salario AS [Salário Anterior],
		inserted.Salario AS [Novo Salário]
	WHERE idMatricula = @matricula;

-- Testar Procedure
EXEC spr_ReajusteSalarial 1025;
-------------------------------------------------------------------------------
-- Tabela Localidade possui campo IDENTITY no idLocalidade
GO
CREATE PROCEDURE spr_NovaLocalidade
@cidade nvarchar(50),@uf nchar(2)
AS
	INSERT INTO Localidade
	(Cidade,Uf)
	VALUES
	(@cidade,@uf)

-------------------------------------------------------------------------------
GO
Use SysConVendas;
GO
CREATE PROCEDURE spr_ExcluirPedido
@pedido int
AS
	DELETE FROM Dados
	WHERE Pedido = @pedido

