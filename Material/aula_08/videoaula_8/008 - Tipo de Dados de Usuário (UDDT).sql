-- Visualizando Tipos de Dados do SQL Server
-- Tabela de Sistema
select * from systypes;
-- View de Sistema
select * from sys.types;

-- Criando Banco UDDT
create database UDDT;
go
use UDDT;

-- Criando Tipos de Dados Personalizados (UDDT)
create type NomePessoa
from varchar(50) not null;

create type ValorMonetario
from decimal(10,2) not null;

create type OpcaoSN
from char(1) not null;

create type DataRegra
from date null;

-- Visualizando somente os tipos personalizados
select * from systypes where uid = 1;

select * from sys.types where schema_id = 1;

-- Criando Regras de Validação
go
create rule r_ValorMonetario as @valor >=0;
go
create rule r_OpcaoSN as @sn in('S','N');
go
create rule r_DataRegra as @data between '2014-1-1' and getdate();
go
-- Visualizando regras criadas
select * from sysobjects where xtype = 'r';

-- Associando as regras aos tipos criados
exec sp_bindrule 'r_ValorMonetario','ValorMonetario';
exec sp_bindrule 'r_OpcaoSN','OpcaoSN';
exec sp_bindrule 'r_DataRegra','DataRegra';

-- Criando Defaults
go
create default def_SN as 'S'
go
create default def_DataRegra as getdate();
go

-- Visualizando defaults
select * from sysobjects where xtype = 'd';

-- Associando os defaults aos tipos criados
exec sp_bindefault 'def_SN','OpcaoSN';
exec sp_bindefault 'def_DataRegra','DataRegra';

-- Criando Sequencial (Identity Personalizado)
create sequence seq_Registro
	start with 1000
	increment by 10
	minvalue 10
	maxvalue 100000
	cycle -- Indica para retornar ao valor mínimo se o valor máximo for alcançado [cycle / no cycle]
	cache 10 -- Aumentar desempenho dos aplicativos que se comunicarão com o Banco; [cache (nº de valores mantidos no cache) / no cache]

-- visualizando sequências criadas
select * from sys.sequences;

-- Utilizando UDDT e sequência criada
create table TabelaUDDT
(
	id					int
	,NomeCliente		NomePessoa
	,StatusAtivo		OpcaoSN
	,cadastroCliente	DataRegra
);

-- Inserindo Dados
-- OBS: Para utilizarmos a sequência deveremos utilizar a instrução NEXT VALUE FOR
insert into TabelaUDDT
(id,NomeCliente,StatusAtivo,cadastroCliente)
values
(next value for dbo.seq_Registro,'Hélio de Almeida','S','2015-6-6');

select * from TabelaUDDT;

-- Testando Defaults
insert into TabelaUDDT
(id,NomeCliente)
values
(next value for dbo.seq_Registro,'Nícolas Fernandes');

select * from TabelaUDDT;

-- Testando Regras
-- Status
insert into TabelaUDDT
(id,NomeCliente,StatusAtivo,cadastroCliente)
values
(next value for dbo.seq_Registro,'Rosangela Raquel','X','2015-4-15');

-- Cadastro
insert into TabelaUDDT
(id,NomeCliente,StatusAtivo,cadastroCliente)
values
(next value for dbo.seq_Registro,'Rosangela Raquel','N','2013-7-5');

-- Criando Sinônimos
create synonym TabT for dbo.TabelaUDDT;

-- Visualizando Sinônimos criados
select * from sys.synonyms

-- Utilizando um Sinônimo
select * from TabT;
