DECLARE @tsql nvarchar(max);
WITH
ListTableToDisplay as 
	(
		select 
		t.name as TableToDisplay
		FROM sys.tables	t
		where SCHEMA_NAME(schema_id) = 'quality'
		and t.name LIKE 'Fait%_%'	
	),
ListColumnToDisplay as 
	(
		select DISTINCT
			c.name as ColumnToDisplay,
			TableToDisplay,
			t.name as  Typ,
			DENSE_RANK() over	(PARTITION by TableToDisplay ORDER by c.name) as OrderBy
		from sys.columns c
		inner join sys.types t on t.user_type_id = c.user_type_id
		full join ListTableToDisplay on 1 = 1
		where 
		object_id in 
		(
			select 
			object_id
			FROM sys.tables
			where SCHEMA_NAME(schema_id) = 'quality'
			and name LIKE 'Faits_%'
		)
		and c.name not LIKE '%_BK'
		and c.name Not in ('UPDATE_BY','UPDATE_TIME','CREATE_TIME','CREATE_BY')
	),
ListTableColumn as 
	(
		select 
		t.name as TableName,
		c.name as ColumnName
		FROM sys.tables	t
		INNER join sys.columns c on c.object_id = t.object_id
		where SCHEMA_NAME(schema_id) = 'quality'
		and t.name LIKE 'Fait%_%'
	)
select @tsql=
	STUFF(
	(
	select 
		char(10)+
		N'Union all'+ char(10)+
		'Select ' +
					STUFF
					(
						(select 
							case d.Typ
								when 'int' then 		','+COALESCE( ColumnName,'-9') +' as '+COALESCE(o.ColumnName,d.ColumnToDisplay)
								when 'nvarchar' then 	','+COALESCE( ColumnName,'''N/A''') +' as '+COALESCE(o.ColumnName,d.ColumnToDisplay)
							end
	
						FROM		ListColumnToDisplay d
						LEFT JOIN	ListTableColumn		o	on	o.TableName		=	d.TableToDisplay
															AND	o.ColumnName	=	d.ColumnToDisplay
						where d.TableToDisplay = t.TableToDisplay
						order by d.OrderBy
						for XML PATH(''))
						,1,1,''
					) +' from quality.' + t.TableToDisplay 
			
	from ListTableToDisplay t
	for XML PATH(''))
	,1,10,'')

	print 'Create or alter view quality.FAIT_ALL as '
	print @tsql
