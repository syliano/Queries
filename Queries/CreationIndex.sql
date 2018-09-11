use DWH_PRD;
with cte as (
select 
'Create index [IX_' + t.name +'] on ['+SCHEMA_NAME(t.schema_id)+'].['+t.name+']('+
STUFF(
		(
			SELECT 	',[' + name+']'  from sys.columns c
			where c.object_id = t.object_id
			AND	(c.name LIKE '%_ID' or c.name like '%_BK')
			for XML PATH('')
		)
	,1,1,'')+')' as cmd
FROM		sys.tables	t
where SCHEMA_NAME(t.schema_id) = 'quality'
) 
select * from cte 
where cmd is not null
