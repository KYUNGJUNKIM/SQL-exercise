-- use AdventureWorks2019;

-- #1
select type_desc, count(*) from sys.objects
group by type_desc
order by count(*) desc;

-- #2
	-- a.
	Select 
		Count(distinct s.name) as SchemaName
		,Count(distinct t.name) as TableName
		,Count(c.name) as ColumnName
	From sys.tables as t
		INNER JOIN sys.columns as c on c.object_id = t.object_id
		INNER JOIN sys.schemas as s on s.schema_id = t.schema_id
 
	Select 
		Count(Distinct table_schema) as SchemaName
		,Count(Distinct table_name) as TableName
		,Count(column_name) as ColumnName
	From information_schema.columns
	Where table_name not in(
			Select Distinct TABLE_NAME 
			From information_schema.views)

	-- b.
	Select 
		Count(distinct s.name) as SchemaName
		,Count(distinct t.name) as TableName
		,Count(c.name) as ColumnName
	From sys.tables t
		INNER JOIN sys.columns c on c.object_id = t.object_id
		INNER JOIN sys.schemas s on s.schema_id = t.schema_id
 
	Select 
		Count(Distinct table_schema) as SchemaName
		,Count(Distinct table_name) as TableName
		,Count(column_name) as ColumnName
	From information_schema.columns
	Where table_name not in(
			Select Distinct TABLE_NAME 
			From information_schema.views)

-- #3
	-- a.
	create database Edited_AdventureWorks
	use Edited_AdventureWorks

	--b. 
	Select Distinct
		T.name as TableName
		,C.name as ColumnName
		,CC.name as CheckConstraint
		,CC.definition as [Definition]
	from AdventureWorks2019.sys.check_constraints CC
		INNER JOIN AdventureWorks2019.sys.tables T 
			on T.object_id = CC.parent_object_id
		Left JOIN AdventureWorks2019.sys.columns C 
			on C.column_id = CC.parent_column_id
			and C.object_id = CC.parent_object_id
 
	--c. 
	Create Table tbl_CheckConstraint(
		TableName varchar(100)
		,ColumnName varchar(100)
		,CheckConstraint varchar(250)
		,[Definition] varchar(500)
		,ConstraintLevel varchar(100)
		)
 
	--d. 
	Insert Into tbl_CheckConstraint 
		(TableName
		 ,ColumnName
		 ,CheckConstraint
		 ,Definition)
			Select Distinct
				T.name as TableName
				,C.name as ColumnName
				,CC.name as CheckConstraint
				,CC.definition as [Definition]
			from AdventureWorks2019.sys.check_constraints CC
				INNER JOIN AdventureWorks2019.sys.tables T 
					on T.object_id = CC.parent_object_id
				Left JOIN AdventureWorks2019.sys.columns C 
					on C.column_id = CC.parent_column_id
					and C.object_id = CC.parent_object_id 
 
	--e. 
	Update tbl_CheckConstraint
	Set ConstraintLevel = 
		Case When ColumnName is null
			 Then 'TableLevel'
			 Else 'ColumnLevel'
			 End
 
-- #4
Select 
    O.name as FK_Name
    ,S1.name as SchemaName
    ,T1.name as TableName
    ,C1.name as ColumnName
    ,S2.name as ReferencedSchemaName
    ,T2.name as ReferencedTableName
    ,C2.name as ReferencedColumnName
From sys.foreign_key_columns FKC
    INNER JOIN sys.objects O ON O.object_id = FKC.constraint_object_id
    INNER JOIN sys.tables T1 ON T1.object_id = FKC.parent_object_id
    INNER JOIN sys.tables T2 ON T2.object_id = FKC.referenced_object_id
    INNER JOIN sys.columns C1 ON C1.column_id = parent_column_id 
		             AND C1.object_id = T1.object_id
    INNER JOIN sys.columns C2 ON C2.column_id = referenced_column_id 
			     AND C2.object_id = T2.object_id
    INNER JOIN sys.schemas S1 ON T1.schema_id = S1.schema_id
    INNER JOIN sys.schemas S2 ON T2.schema_id = S2.schema_id

-- #5
	--a.
	Create Database Edited_AdventureWorks
	use Edited_AdventureWorks
 
	--b. 
	Select 
		O.name as FK_Name
		,S1.name as SchemaName
		,T1.name as TableName
		,C1.name as ColumnName
		,S2.name as ReferencedSchemaName
		,T2.name as ReferencedTableName
		,C2.name as ReferencedColumnName
	Into Edited_AdventureWorks.dbo.Table_Relationships
	From sys.foreign_key_columns FKC
			INNER JOIN sys.objects O ON O.object_id = FKC.constraint_object_id
			INNER JOIN sys.tables T1 ON T1.object_id = FKC.parent_object_id
			INNER JOIN sys.tables T2 ON T2.object_id = FKC.referenced_object_id
			INNER JOIN sys.columns C1 ON C1.column_id = parent_column_id 
					AND C1.object_id = T1.object_id
			INNER JOIN sys.columns C2 ON C2.column_id = referenced_column_id 
					AND C2.object_id = T2.object_id
			INNER JOIN sys.schemas S1 ON T1.schema_id = S1.schema_id
			INNER JOIN sys.schemas S2 ON T2.schema_id = S2.schema_id

	--c. 
		Select 
			FK_NAME
			,Count(*) as CNT
		From Edited_AdventureWorks.dbo.Table_Relationships
		Group by FK_NAME
		Order by 2 desc
 
	--d. 
		Select 
			Count(Distinct FK_Name)
		From Edited_AdventureWorks.dbo.Table_Relationships
		Where ColumnName = 'BusinessEntityID' or 
			  ReferencedColumnName = 'BusinessEntityID'
 
		Select 
			*
		From Edited_AdventureWorks.dbo.Table_Relationships
		Where ColumnName = 'BusinessEntityID' or 
			  ReferencedColumnName = 'BusinessEntityID'

-- #6
Select 
	s.name as SchemaName
	,t.name as TableName
	,c.name as ColumnName
	,dc.name as DefaultConstraint
	,dc.definition as DefaultDefinition
From sys.default_constraints dc
	Inner Join sys.tables t on t.object_id = dc.parent_object_id
	Inner Join sys.schemas s on s.schema_id = dc.schema_id
	Inner Join sys.columns c on c.column_id = dc.parent_column_id
			        and c.object_id = dc.parent_object_id


-- #7
	-- a.
	Select 
		t.name as TableName
		,c.name as ColumnName
	From sys.tables t
		Inner Join sys.columns c on t.object_id = c.object_id
	Where c.name like '%rate%'

	-- b.
	Select 
	t.name as TableName
	,c.name as ColumnName
	From sys.tables t
		Inner Join sys.columns c on t.object_id = c.object_id
	Where t.name like '%History%'

-- #8
	-- a.
	Select Data_Type, Count(*) as cnt_of_dt
	From Information_Schema.Columns
	Group by Data_Type
	Order by 2 desc

	--b.
	Select 
	Case When Character_Maximum_Length is not null then 'Character'
		 When Numeric_Precision is not null then 'Numeric'
		 When Datetime_Precision is not null then 'Date'
		 Else null
		 End as 'DataTypeGroup'
	,Count(*) as CNT
	From Information_Schema.Columns
	Group by 
		Case When Character_Maximum_Length is not null then 'Character'
			 When Numeric_Precision is not null then 'Numeric'
			 When Datetime_Precision is not null then 'Date'
			 Else null
			 End
	Order by count(*) desc

	--c.
	Select * from Information_Schema.Columns
	Where Character_Maximum_Length is null
		and Numeric_Precision is null
		and Datetime_Precision is null

-- #9
Select VIEW_NAME,
count(distinct TABLE_NAME) as cnt_table
from Information_Schema.View_Column_Usage
group by VIEW_NAME

-- #10
	-- a.
	Select 
	t.name as TableName
	,c.name as ColumnName
	,ep.value as 'Definition'
	From sys.extended_properties ep
	Inner Join sys.tables t on t.object_id = ep.major_id
	Inner join sys.columns c on c.object_id = ep.major_id and c.column_id = ep.minor_id
	Where class = 1

	-- b.
	select 
	t.name as TableName,
	c.name as ColumnName,
	ep.value as Definition
	from sys.extended_properties ep
	join sys.tables t on t.object_id = ep.major_id
	join sys.columns c on c.object_id = ep.major_id and c.column_id = ep.minor_id
	where class = 1 and t.name = 'Person'







