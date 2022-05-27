-- Banco Sisdep
use SisDep;
-- Função IIF-CHOOSE
select
	NomeFuncionario
	,Admissao
	,Salario
	,IIF(salario <= 2000,'Reajuste','') As [An�lise Salarial]
from funcionario;

begin tran;
	update funcionario
	set salario *= IIF(salario <= 2000,1.1,1.05)
	output
		deleted.NomeFuncionario
		,deleted.Salario	as [Sal�rio Anterior]
		,inserted.Salario	as [Novo Salario]
		,inserted.Salario / deleted.Salario	as [�ndice]
commit;

SELECT
	idMatricula,NomeFuncionario,Admissao,
	CHOOSE(DATEPART(WEEKDAY,Admissao),'Dom','Seg','Ter','Qua','Qui','Sex','Sab') As [Dia Semana]
FROM Funcionario;

SELECT 
	CHOOSE(idDepartamento,'RH','OUTROS')
FROM Funcionario
SELECT 
	Cidade,
	CHOOSE(idLocalidade,'Matriz','Filial')
FROM Localidade

-- LAG-LEAD
select
	idMatricula
	,NomeFuncionario
	,Admissao
	,Salario
	,LAG(Admissao,1,0)	Over(Order By idMatricula)	As [Admiss�o Anterior]
	,LEAD(Admissao,1,0)	Over(Order by idMatricula)	As [Admiss�o Posterior],
	DATEDIFF(DAY,Admissao,LAG(Admissao,1,0)	Over(Order By idMatricula))
from Funcionario;

select
	idMatricula
	,NomeFuncionario
	,Admissao
	,Salario
	,LAG(Admissao,1,0)	Over(Order By idMatricula)	As [Admiss�o Anterior]
	,LEAD(Admissao,1,0)	Over(Order by idMatricula)	As [Admiss�o Posterior],
	DATEDIFF(DAY,Admissao,LAG(Admissao,1,0)	Over(Order By idMatricula))
from Funcionario;

-- FETCH-OFFSET
-- 20 primeiras linhas
select * from Funcionario
order by idMatricula
offset 0 rows fetch next 20 rows only;
-- 10 linhas a partir da 30º
select * from Funcionario
order by idMatricula
offset 30 rows fetch next 10 rows only;

select * from Funcionario
order by NewId()
offset 30 rows fetch next 10 rows only;

