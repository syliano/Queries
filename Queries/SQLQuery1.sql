
USE DWH_PRD;

select 
*
from [quality].[FAITS_FUSIONS_ETUDIANTS]
--where UPDATE_TIME <> CREATE_TIME
where EXG_ACA_PROPOSITION_MAPPING_HISTO_BK= 1578
