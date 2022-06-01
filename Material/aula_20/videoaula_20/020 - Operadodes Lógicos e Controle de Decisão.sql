-- Operadores Lógicos OR AND
DECLARE @uf char(2),@valorPedido smallmoney,@imposto smallmoney;
SET @uf = 'PR';
SET @valorPedido = 1000;
IF @uf = 'SP' OR @uf = 'RJ'
	BEGIN
		SET @imposto = @valorPedido * 0.1;
		PRINT 'Imposto Retido (10%): ' + FORMAT(@imposto,'c','pt-br')
	END
ELSE
	BEGIN
		SET @imposto = @valorPedido * 0.18;
		PRINT 'Imposto Retido (18%): ' + FORMAT(@imposto,'c','pt-br')
	END
---------------------------------------------------------------------------------
DECLARE @salario smallmoney,@reajuste smallmoney,@tempoServico tinyint;
SET @salario = 1500;
SET @tempoServico = 4;
IF @salario <= 2000 AND @tempoServico >= 3
	BEGIN
		SET @reajuste = @salario * 1.1;
		PRINT 'Reajuste de 10% - Novo Salário: ' + FORMAT(@reajuste,'C','pt-br');
	END
ELSE
	BEGIN
		SET @reajuste = @salario * 1.05;
		PRINT 'Reajuste de 5% - Novo Salário: ' + FORMAT(@reajuste,'C','pt-br');
	END










