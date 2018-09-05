use EtudiantsExchange;
with personnes as (
		select 
			FORMAT(i.CREATE_TIME,'yyyyMMdd') as DATE,
			i.ORA_ID,
			i.FK_PER_PERSONNE_MASTER,
			i.FK_PER_PERSONNE_SLAVE,


			p.PERS_ID
		from admission.EXG_ACA_PROPOSITION_MAPPING_HISTO	i
		left join DWH_PRD.dbo.DIM_PERSONNE p on p.ORA_ID = i.FK_PER_PERSONNE_MASTER
												and p.VALID = 1
		where i.REVTYPE = ('I')
)
--,PersonneRecursive as (
	select top 10
		--DATE
		ORA_ID
		,FK_PER_PERSONNE_MASTER
		,FK_PER_PERSONNE_SLAVE
		,PERS_ID
	from personnes
	where PERS_ID is NULL and ORA_ID in (

1578

	)

