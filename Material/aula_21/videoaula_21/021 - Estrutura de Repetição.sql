-- Repetição (WHILE)
DECLARE @cont1 int = 1
WHILE @cont1 <= 100
	BEGIN
		PRINT 'Valor do contador: ' + CAST(@cont1 AS varchar)
		SET @cont1 += 1
	END

-- Encadeando Loops
DECLARE @t int = 1,@n int;
WHILE @t <= 10
	BEGIN
		PRINT 'Tabuada do ' + CAST(@t AS VARCHAR(2));
		PRINT '';
		SET @n = 1;
		WHILE @n <= 10
			BEGIN
				PRINT	CAST(@t AS VARCHAR(2)) + ' X ' +
						CAST(@n AS VARCHAR(2)) + ' = ' +
						CAST(@t * @n AS VARCHAR(3));
				SET @n += 1;
			END
		SET @t += 1;
		SET @n = 1;
	END

-- CONTINUE
DECLARE @dezena int, @cont int = 1;
IF OBJECT_ID('MegaSena') IS NOT NULL DROP TABLE MegaSena;   

CREATE TABLE MegaSena(dezena int);   

WHILE @cont <= 6   
	BEGIN   
		SET @dezena = 1 + 60 * RAND();   
		
		IF EXISTS(SELECT * FROM MegaSena WHERE dezena = @dezena)
			CONTINUE;
			
		INSERT INTO MegaSena VALUES (@dezena);  
		SET @cont += 1;   
	END 

SELECT * FROM MegaSena ORDER BY 1;

