use [CommonExport];

with 
PersonneEmploye as
	(
		select 
			ETU_ORA_ID,ETU_AVS,p.PERS_ID
		from DWH_PRD.dbo.DIM_ETUDIANT		et
		inner join DWH_PRD.dbo.DIM_PERSONNE	p	on p.ETU_ID		=	et.ETU_ID
												and p.VALID		=	1
		where ETU_AVS is not NULL
		UNION
		select 
			EMP_ORA_ID,EMP_NUMERO_AVS,p.PERS_ID
		from DWH_PRD.dbo.DIM_EMPLOYE		ep
		inner join DWH_PRD.dbo.DIM_PERSONNE	p	on	p.EMP_ID	=	ep.EMP_ID
												and p.VALID		=	1
		where EMP_NUMERO_AVS is not NULL
	),
Result as (
SELECT
	convert(int, s.ORA_ID)							as COMEXP_PER_PERSONNE_AVS_BK,
	format(ACTION_DATE,'yyyyMMdd')					as JOUR_ID,
	FORMAT(convert(BIGINT,AVS),'### #### #### ##')	as AVS,
	COALESCE( pe.PERS_ID,-9)						as PERS_ID,
	DENSE_RANK() OVER (PARTITION by s.ORA_ID ORDER BY s.ACTION_DATE DESC) as One
from personne.COMEXP_PER_PERSONNE_AVS	s
left join PersonneEmploye				pe	on pe.ETU_AVS	=	AVS COLLATE French_CI_AS

GROUP by 
	 s.ORA_ID,
	ACTION_DATE,
	AVS,
	COALESCE( pe.PERS_ID,-9) 
)
select 
	convert(int,COMEXP_PER_PERSONNE_AVS_BK) as COMEXP_PER_PERSONNE_AVS_BK
	,convert(int,JOUR_ID) as JOUR_ID
	,AVS
	,PERS_ID
 from Result r
 where one = 1

 and COMEXP_PER_PERSONNE_AVS_BK in(8930,25)

