USE SisDep;
-- CHECK OPTION (Restrição de Entrada de Dados)
GO
CREATE VIEW vw_NovaLocalidadeSP
AS
	SELECT idLocalidade,Uf,Cidade FROM Localidade
	WHERE Uf = 'SP'
WITH CHECK OPTION;
GO 
-- Testando
-- Vai dar erro
INSERT INTO vw_NovaLocalidadeSP
(idLocalidade,Uf,Cidade)
VALUES
(12,'RJ','Parati');
--Vai Funcionar
INSERT INTO vw_NovaLocalidadeSP
(idLocalidade,Uf,Cidade)
VALUES
(12,'SP','Ribeirão Preto');
