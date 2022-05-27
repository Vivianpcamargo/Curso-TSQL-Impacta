USE RecursosAdicionais;
SET NOCOUNT ON;
GO
CREATE TABLE CotacoesPorDataMoeda
(
    DataCotacao			date NOT NULL,
    CodMoeda			varchar(3) NOT NULL,
    ValorCotacao		numeric(18, 4) NOT NULL,
    PRIMARY KEY (DataCotacao, CodMoeda)
)
GO
 
INSERT INTO CotacoesPorDataMoeda
(DataCotacao, CodMoeda, ValorCotacao)
VALUES('2014-04-17', 'USD', 2.2357),
('2014-04-16', 'USD', 2.2418),
('2014-04-15', 'USD', 2.2385),
('2014-04-14', 'USD', 2.2147),
('2014-04-17', 'EUR', 3.0927),
('2014-04-16', 'EUR', 3.1012),
('2014-04-15', 'EUR', 3.0874),
('2014-04-14', 'EUR', 3.0616),
('2014-04-17', 'LIB', 3.7593),
('2014-04-16', 'LIB', 3.7708),
('2014-04-15', 'LIB', 3.7400),
('2014-04-14', 'LIB', 3.7048);
GO
CREATE TABLE Investidores
(
    BANCO			VARCHAR(100), 
    ANO				SMALLINT,
    INVESTIMENTOS	MONEY, 
    DESPESAS		MONEY
);
 
INSERT INTO Investidores 
VALUES
('BANCO ALVORADA S/A', 2010, 9613906084.01, 8102644.84),
('BANCO ALVORADA S/A', 2011, 174343.35, 7935411.15),
('BANCO ARBI S/A', 2010, 8202652.29, 114215.13),
('BANCO ARBI S/A', 2011, 8407843.72, 81746.25);

GO


-- Transformando Linhas Em Colunas (PIVOT)
SELECT DataCotacao,
       [USD] AS VlDolar,
       [EUR] AS VlEuro,
       [LIB] AS VlLibra
FROM
(
    SELECT DataCotacao, CodMoeda, ValorCotacao
    FROM dbo.CotacoesPorDataMoeda
) C
PIVOT
(
    AVG(ValorCotacao)
    FOR CodMoeda IN ([USD], [EUR], [LIB])
) AS P


-- Transformando Colunas Em Linhas (UNPIVOT)
SELECT [BANCO], [ANO], [TIPO], [VALOR]
FROM Investidores I
UNPIVOT (
    [VALOR] FOR [TIPO] IN ( 
        [INVESTIMENTOS], 
        [DESPESAS]
    )
) AS U
ORDER BY [BANCO], [ANO], [TIPO]


