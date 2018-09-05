use EtudiantsExchange;
WITH 
personnes as 
	(
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
	),
PersonneRecursive as 
	(
		select
			DATE
			,ORA_ID
			,FK_PER_PERSONNE_MASTER
			,FK_PER_PERSONNE_SLAVE
			,PERS_ID
			,0 as rnk
		from personnes
		where PERS_ID is NULL --and ORA_ID in (1578)
	
		union all
		select 
			p.DATE
			,pr.ORA_ID
			,p.FK_PER_PERSONNE_MASTER
			,p.FK_PER_PERSONNE_SLAVE
			,p.PERS_ID
			,rnk +1
		from PersonneRecursive pr 
		inner join personnes p on pr.FK_PER_PERSONNE_MASTER=p.FK_PER_PERSONNE_SLAVE	
		where pr.ORA_ID <> p.ORA_ID
		and pr.PERS_ID is NULL
	),
PersonneRecursiveFiltre as 
	(
		select 
		ORA_ID,
		PERS_ID,
		DENSE_RANK() OVER (PARTITION by ORA_ID ORDER by rnk DESC) as filtre
		from PersonneRecursive
	)

select DISTINCT
	i.EXG_ID,
	i.ORA_ID,
	format(d.UPDATE_TIME,'yyyyMMdd') as DateFusion,
	i.FK_PER_PERSONNE_MASTER,
	COALESCE
		(
			per.PERS_ID,
			rec.PERS_ID,
			-9
		)		as	PERS_ID
from		admission.EXG_ACA_PROPOSITION_MAPPING_HISTO i
inner join	admission.EXG_ACA_PROPOSITION_MAPPING_HISTO	d	on	d.ORA_ID	=	i.ORA_ID
															and d.REVTYPE	=	'D'
left JOIN	DWH_PRD.dbo.DIM_PERSONNE					per	on	per.ORA_ID	=	i.FK_PER_PERSONNE_MASTER
															and	per.VALID	=	1
left join	PersonneRecursiveFiltre						rec	ON	rec.ORA_ID	=	i.ORA_ID
															AND	rec.filtre	=	1
where i.REVTYPE ='I' and i.ORA_ID = 1578
ORDER by 1