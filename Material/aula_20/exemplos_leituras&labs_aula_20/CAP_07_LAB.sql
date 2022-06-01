--1. Complete o código a seguir de modo a mostrar o maior dos três números sorteados: 

DECLARE @A INT, @B INT, @C INT;
DECLARE @MAIOR INT;
SET @A = 50 * RAND();
SET @B = 50 * RAND();
SET @C = 50 * RAND();
-- Aqui você colocará os IFs ---


-- SOLUÇÃO 1
IF @A > @B
   IF @A > @C
      SET @MAIOR = @A
   ELSE
      SET @MAIOR = @C
ELSE
   IF @B > @C
      SET @MAIOR = @B
   ELSE
      SET @MAIOR = @C            
-- SOLUÇÃO 2

/*IF @A > @B AND @A > @C
      SET @MAIOR = @A
ELSE
   IF @B > @C
      SET @MAIOR = @B
   ELSE
      SET @MAIOR = @C      
*/
-- SOLUÇÃO 3

/*SET @MAIOR = @A;
IF @B > @MAIOR SET @MAIOR = @B;      
IF @C > @MAIOR SET @MAIOR = @C;
*/
--------------------------------

PRINT @A;
PRINT @B;
PRINT @C;
PRINT 'MAIOR = ' + CAST(@MAIOR AS VARCHAR(2));

/*
2. Complete o código a seguir (que sorteará quatro números no intervalo de 0 a 10, 
   os quais representarão as quatro notas de um aluno) de acordo com o que o 
   comentário pede:
*/

DECLARE @N1 NUMERIC(4,2), @N2 NUMERIC(4,2), @N3 NUMERIC(4,2), @N4 NUMERIC(4,2);
DECLARE @MEDIA NUMERIC(4,2);
SET @N1 = 10*RAND();
SET @N2 = 10*RAND();
SET @N3 = 10*RAND();
SET @N4 = 10*RAND();
-- Imprimir as 4 notas
PRINT 'Nota 1: ' + CAST( @N1 AS VARCHAR(5) );
PRINT 'Nota 2: ' + CAST( @N2 AS VARCHAR(5) );
PRINT 'Nota 3: ' + CAST( @N3 AS VARCHAR(5) );
PRINT 'Nota 4: ' + CAST( @N4 AS VARCHAR(5) );
-- Calcular e imprimir a média das 4 notas
SET @MEDIA = (@N1 + @N2 + @N3 + @N4) / 4;
PRINT 'Média: ' + CAST( @MEDIA AS VARCHAR(5) );
-- Imprimir REPROVADO se média menor que 5, caso contrário APROVADO
IF @MEDIA < 5 
   PRINT 'REPROVADO'
ELSE
   PRINT 'APROVADO'   
-- Dependendo da média, imprimir uma das classificações abaixo
--             Média até 2..................PÉSSIMO
--             Acima de 2 até 4.............RUIM
--             Acima de 4 até 6.............REGULAR
--             Acima de 6 até 8.............BOM
--             Acima de 8...................ÓTIMO
IF @MEDIA <= 2 PRINT 'PÉSSIMO'
ELSE IF @MEDIA <= 4 PRINT 'RUIM'
ELSE IF @MEDIA <= 6 PRINT 'REGULAR'
ELSE IF @MEDIA <= 8 PRINT 'BOM'
ELSE PRINT 'ÓTIMO'
-------------------------------------------------------------------

-- 3. Escreva um código que gere e imprima os números pares de 0 até 100;
DECLARE @CONT INT = 0;
WHILE @CONT <= 100
   BEGIN
   PRINT @CONT;
   SET @CONT += 2
   END
PRINT 'FIM'

-- 4. Escreva um código que gere e imprima os números ímpares entre 0 e 100;
DECLARE @CONT INT = 1;
WHILE @CONT <= 100
   BEGIN
   PRINT @CONT;
   SET @CONT += 2
   END
PRINT 'FIM'

/*
5. Complete o código de modo a calcular a soma de todos os números inteiros de 0 até @N;
*/

DECLARE @N INT, @CONT INT = 1, @SOMA INT = 0;
SET @N = CAST( 20 * RAND() AS INT );
-- Complete o código -----------------------

WHILE @CONT <= @N
   BEGIN
   SET @SOMA += @CONT;
   SET @CONT += 1;
   END
--------------------------------------------
PRINT 'A SOMA DE 1 ATÉ ' + CAST(@N AS VARCHAR(2)) +
      ' É ' + CAST(@SOMA AS VARCHAR(4));
      
/*
6. Complete o código de modo a calcular o fatorial de @N. Por exemplo, o 
fatorial de 5 é 1 * 2 * 3 * 4 * 5 = 120;
*/
DECLARE @N INT, @CONT INT = 1, @FAT INT = 1;
SET @N = CAST( 10 * RAND() AS INT );
-- Complete o código -----------------------
WHILE @CONT <= @N
   BEGIN
   SET @FAT *= @CONT;
   SET @CONT += 1;
   END
--------------------------------------------
PRINT 'O FATORIAL DE ' + CAST(@N AS VARCHAR(2)) +
      ' É ' + CAST(@FAT AS VARCHAR(10));
      
/*
7. Insira os comandos de acordo com os comentários adiante, de modo que o código
   gere todos os números primos de 1 até 1000.
   
   Números primos são números inteiros divisíveis apenas por 1 e por ele próprio. 
*/

-- 1. Declarar as variáveis @N, @I (inteiras) e @SN_PRIMO do tipo CHAR(1) 
DECLARE @N INT, @I INT, @SN_PRIMO CHAR(1);
-- 2. Imprimir os números 1, 2 e 3 que já sabemos serem primos
PRINT 1;
PRINT 2;
PRINT 3;      
-- 3. Iniciar a variável @N com 4
SET @N = 4;
-- 4. Enquanto @N for menor ou igual a 1000
WHILE @N <= 1000
   BEGIN
   -- 4.1. Iniciar a variável @I com 2
   SET @I = 2;
   -- 4.2. Iniciar a variável @SN_PRIMO com 'S'
   SET @SN_PRIMO = 'S';
   -- 4.3. Enquanto @I for menor ou igual a @N / 2
   WHILE @I <= @N/2
      BEGIN
      -- 4.3.1. Se o resto da divisão de @N por @I for zero (é divisível)
      IF @N % @I = 0
         BEGIN
         -- 4.3.1.1. Colocar 'N' na variável @SN_PRIMO sinalizando assim
         -- que @N não é um número primo
         SET @SN_PRIMO = 'N';
         -- 4.3.1.2. Abandonar este Loop (4.3)
         BREAK;
         END
      -- 4.3.2. Somar 1 na variável @I   
      SET @I += 1;   
      -- Final do loop 4.3.
      END
   -- 4.4. Se @SN_PRIMO for 'S', imprimir @N porque ele é primo  
   IF @SN_PRIMO = 'S' PRINT @N;
   -- 4.5. Somar 1 na variável @N
   SET @N = @N + 1;   
   -- Final do loop (4)
   END
      
         

