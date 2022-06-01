/*
	Triggers - O que são?

	O termo trigger (gatilho em inglés) define uma estrutura do banco de dados que funciona,
	como o nome sugere, como uma função que é disparada mediante alguma ação.

	Tipos de Triggers

	. DDL (Definição de Dados)
	. DML (Manipulação de Dados)



*/
-- Trigger Nível Servidor
GO
CREATE TRIGGER tr_LogServer
ON ALL SERVER
FOR CREATE_DATABASE,DROP_DATABASE,ALTER_DATABASE,DDL_DATABASE_LEVEL_EVENTS
AS
	DECLARE @dados XML;
	SET @dados = EVENTDATA();
	SELECT @dados;
GO

-- Testando Trigger
CREATE DATABASE TESTE;

DROP DATABASE TESTE;

-- Visualizando triggers do servidor
SELECT * FROM SYS.server_triggers;

-- Visualizando somente os eventos de trigger no servidor
SELECT * FROM sys.server_trigger_events;

-- Visualizando triggers do banco
SELECT * FROM SYS.triggers;

-- Visualizando somente os eventos de trigger no banco
SELECT * FROM SYS.trigger_events;

-- Visualizando todos os eventos possíveis de triggers
SELECT * FROM SYS.trigger_event_types;

-- Triggers DML
CREATE TABLE Historico_AlteraSalario
(
	idMatricula			int,
	salarioAnterior		money,
	salarioNovo			money,	
	dataAlteracao		date,
	usuario				nvarchar(50)
);

GO
CREATE TRIGGER tr_HistAlteraSalario
ON Funcionario
FOR UPDATE
AS
	DECLARE @id int,@salarioAnterior money,@salarioNovo money,@dataAlt date,@user nvarchar(50)

	SELECT @id = idMatricula FROM inserted;
	SELECT @salarioAnterior = Salario FROM deleted;
	SELECT @salarioNovo = Salario FROM inserted;

	IF @salarioAnterior <> @salarioNovo
		INSERT INTO Historico_AlteraSalario
		(idMatricula,salarioAnterior,salarioNovo,dataAlteracao,usuario)
		VALUES
		(@id,@salarioAnterior,@salarioNovo,GETDATE(),SUSER_NAME());
GO

-- Testando a Triggers
BEGIN TRAN;
	UPDATE Funcionario WITH (TABLOCK)
	SET Salario += 100
	WHERE idMatricula = 1010;
COMMIT;

SELECT * FROM Historico_AlteraSalario;

SELECT * FROM Funcionario WHERE salario <= 1500

-- Alterando uma Trigger
GO
ALTER TRIGGER tr_HistAlteraSalario
ON Funcionario
WITH ENCRYPTION
FOR UPDATE
AS
	DECLARE @id int,@salarioAnterior money,@salarioNovo money,@dataAlt date,@user nvarchar(50)

	SELECT @id = idMatricula FROM inserted;
	SELECT @salarioAnterior = Salario FROM deleted;
	SELECT @salarioNovo = Salario FROM inserted;
	IF @salarioAnterior <> @salarioNovo
		INSERT INTO Historico_AlteraSalario
		(idMatricula,salarioAnterior,salarioNovo,dataAlteracao,usuario)
		VALUES
		(@id,@salarioAnterior,@salarioNovo,GETDATE(),SUSER_NAME()); 

-- Testando após alteração
EXEC sp_helptext tr_HistAlteraSalario;

-- Excluindo uma trigger
DROP TRIGGER tr_HistAlteraSalario;

-- Desabilitando uma trigger
DISABLE TRIGGER tr_HistAlteraSalario
ON Funcionario;

-- Habilitando uma trigger
ENABLE TRIGGER tr_HistAlteraSalario
ON Funcionario;
