/*
	Variáveis:
	
	. São endereços de memória utilizados para alocar informações temporárias
	. Podem ser criadas em procedures ou batches
	. Devem obrigatoriamente ser declaradas (DECLARE)
	. Devem obrigatoriamente ser inicializadas (SET)
	. Possuem escopo local (@nome) e global (@@nome)
	. Nomes de variáveis:
		> Não podem iniciar por numeral
		> Não podem utilizar palavras reservadas
		> Tamanho máximo de 255 caracteres
		> Restrição a caracteres especiais !@#$%&*(){}[]<>,.;:
*/ 

-- Exemplos
DECLARE @a int,@b int,@c decimal(6,2);
SET @a = 20;
SET @b = 4;
SET @c = @a / @b;
PRINT @c;

-- Falha na conversão implícita de tipos
DECLARE @a2 int,@b2 int,@c2 decimal(6,2);
SET @a2 = 20;
SET @b2 = 3;
SET @c2 = CAST(@a2 AS decimal(6,2)) / CAST(@b2 AS decimal(6,2));
PRINT @c2;

/*
	Operadores Aritiméticos
	+	Adição
	-	Subtração
	/	Divisão
	*	Multiplicação
	%	Resto da divisão

	Operadores Relacionais

	>		Maior
	<		Menor
	>=		Maior ou igual
	!<		Maior ou igual
	<=		Menor ou igual
	!>		Menor ou igual
	=		igual
	<>		Diferente
	!=		Diferente
	
	Operadores Lógicos

	ALL			Verdadeiro se todas as condições forem (V)
	AND			Verdadeiro se duas expressões forem (V)
	ANY			Verdadeiro se qualquer condição for (V)
	BETWEEN		Verdadeiro se estiver dentro do intervalo de valores
	EXISTS		Verdadeiro se existir no conjunto de valores
	IN			Verdadeiro se existir na lista de valores
	LIKE		Verdadeiro se parte da informação é encontrada
	NOT			Reverter um valor lógico (Boleano)
	OR			Verdadeiro se uma das expressões for (V)
	SOME		Verdadeiro se parte das comparações for (V)


*/

-- Controle de Fluxo

-- IF / ELSE
DECLARE @rnd1 float, @rnd2 float; 
SET @rnd1 = (SELECT RAND());
SET @rnd2 = (SELECT RAND());
select @rnd1 = RAND() 
IF @rnd1 > @rnd2
	PRINT 'O 1º Aleatório é maior'
ELSE
	PRINT 'O 2º Aleatório é maior';

-- Bloco com mais de um comando
DECLARE @rnd3 float, @rnd4 float ;
SET @rnd3 = (SELECT RAND());
SET @rnd4 = (SELECT RAND());

IF @rnd3 > @rnd4
	BEGIN
		PRINT @rnd3;
		PRINT 'O 1º Aleatório é maior';
	END
ELSE
	BEGIN
		PRINT @rnd4;
		PRINT 'O 2º Aleatório é maior';
	END

-- Aleatório entre 1 e 60
DECLARE @rnd5 int
SET @rnd5 = ((SELECT RAND() * 59) + 1);
PRINT @rnd5;
