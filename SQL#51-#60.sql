
-- #51.
	select 
	t.name as TableName,
    max(p.rows) as RowCNT,
    sum(u.total_pages * 8) as TotalAllocated_kb,
    sum(u.used_pages * 8) as Used_kb,
    (sum(u.total_pages * 8) - sum(u.used_pages * 8)) as Unused_kb
	from sys.allocation_units u
	join sys.partitions p on p.hobt_id = u.container_id
    join sys.tables t on t.object_id = p.object_id
	group by t.name

-- #52
	-- a.
	select 
	t.name as TableName,
    max(p.rows) as RowCNT,
    sum(u.total_pages * 8) as TotalAllocated_kb,
    sum(u.used_pages * 8) as Used_kb,
    (sum(u.total_pages * 8) - sum(u.used_pages * 8)) as Unused_kb,
	case
		when cast(sum(u.total_pages * 8) - sum(u.used_pages * 8) as decimal) / nullif(Sum(u.total_pages)*8,0) < 0.10 then 1
		else 0
	end as Flag
	from sys.allocation_units u
	join sys.partitions p on p.hobt_id = u.container_id
    join sys.tables t on t.object_id = p.object_id
	group by t.name

	-- b.
	create view vDatabaseAllocation as
		select 
		t.name as TableName,
		max(p.rows) as RowCNT,
		sum(u.total_pages * 8) as TotalAllocated_kb,
		sum(u.used_pages * 8) as Used_kb,
		(sum(u.total_pages * 8) - sum(u.used_pages * 8)) as Unused_kb,
		case
			when cast(sum(u.total_pages * 8) - sum(u.used_pages * 8) as decimal) / nullif(Sum(u.total_pages)*8,0) < 0.10 then 1
			else 0
		end as Flag
		from sys.allocation_units u
		join sys.partitions p on p.hobt_id = u.container_id
		join sys.tables t on t.object_id = p.object_id
		group by t.name

-- #53
	alter view vDatabaseAllocation as
	select 
	t.name as TableName,
	max(p.rows) as RowCNT,
	sum(u.total_pages * 8) as TotalAllocated_kb,
	sum(u.used_pages * 8) as Used_kb,
	(sum(u.total_pages * 8) - sum(u.used_pages * 8)) as Unused_kb,
	format((cast((sum(u.used_pages) * 8) as decimal)/1127) * 1492,'N0') as Projected_kb,
	case
		when cast(sum(u.total_pages * 8) - sum(u.used_pages * 8) as decimal) / nullif(Sum(u.total_pages)*8,0) < 0.10 then 1
		else 0
	end as Flag
	from sys.allocation_units u
	join sys.partitions p on p.hobt_id = u.container_id
	join sys.tables t on t.object_id = p.object_id
	group by t.name

	select * from vDatabaseAllocation

-- #54
	select format(sum(TotalDue) / count(distinct OrderDate), 'C0') as AvgTotalDue from Sales.SalesOrderHeader
	where format(OrderDate, 'MM') = 7 and format(OrderDate, 'dd') = 4

-- #55
	-- a.
	select year(OrderDate) as Year, format(sum(TotalDue) / count(distinct OrderDate), 'C0') as AvgTotalDue from Sales.SalesOrderHeader
	where format(OrderDate, 'MM') = 7 and format(OrderDate, 'dd') = 4
	group by year(OrderDate)

	-- b.
	select year(OrderDate) as Year, datename(weekday, Orderdate) as Weekday, format(sum(TotalDue) / count(distinct OrderDate), 'C0') as AvgTotalDue 
	from Sales.SalesOrderHeader
	where format(OrderDate, 'MM') = 7 and format(OrderDate, 'dd') = 4
	group by year(OrderDate), datename(weekday, Orderdate)

	-- c.
	select year(OrderDate) as Year, datename(weekday, Orderdate) as Weekday, format(sum(TotalDue), 'C0') as TotalDue, format(sum(TotalDue) / count(distinct OrderDate), 'C0') as AvgTotalDue 
	into #Temp1
	from Sales.SalesOrderHeader
	where format(OrderDate, 'MM') = 7 and format(OrderDate, 'dd') = 4
	group by year(OrderDate), datename(weekday, Orderdate)

	select * from #Temp1

-- #56
	-- a.
	select datename(weekday, Orderdate) as Weekday, count(distinct OrderDate) as Cnt, format(sum(TotalDue), 'C0') as TotalDue, format(sum(TotalDue) / count(distinct OrderDate), 'C0') as AvgTotalperWkDay 
	into #Temp2
	from Sales.SalesOrderHeader
	group by datename(weekday, Orderdate)

	select * from #Temp2

	-- b.
	select * from #Temp1 as t1
	join #Temp2 t2 on t1.Weekday = t2.Weekday

	-- c.
	select [YEAR], #Temp1.Weekday, #Temp1.TotalDue as July4TotalDue, #Temp2.AvgTotalperWkDay,
	Case 
		When substring(#Temp1.TotalDue, 2, 100) > substring(AvgTotalperWkDay, 2, 100) Then 'Higher' 
		Else 'Lower' End as Flg
	from #Temp1
	join #Temp2 on #Temp2.Weekday = #Temp1.Weekday

-- #57
	drop table If exists #Temp2

-- #58
	select b.SalesPersonID, b.FullName, b.JobTitle, b.SalesTerritory, Format(b.[2012],'C0') as [2012], Format(b.[2013],'C0') as [2013], Format(b.[2014],'C0') as [2014]
	from (
		select 
			soh.SalesPersonID,
			concat(p.FirstName, coalesce(' ' + p.MiddleName, ''),' ',p.LastName) as FullName,
			e.JobTitle,
			st.[Name] AS SalesTerritory,
			soh.SubTotal,
			year(dateadd(m, 6, soh.OrderDate)) as FiscalYear 
		from Sales.SalesPerson sp 
			join Sales.SalesOrderHeader soh on sp.BusinessEntityID = soh.SalesPersonID
			join Sales.SalesTerritory st on sp.TerritoryID = st.TerritoryID 
			join HumanResources.Employee e on soh.SalesPersonID = e.BusinessEntityID 
			join Person.Person p on p.BusinessEntityID = sp.BusinessEntityID ) a
		pivot (sum(SubTotal) for FiscalYear in ([2012], [2013], [2014])) b

-- #59
	select FullName, format([Road Bikes],'C0') as [Road Bikes], format([Mountain Bikes],'C0') as [Mountain Bikes], format([Touring Bikes],'C0') as [Touring Bikes]
	from(
		select concat(FirstName, LastName) as FullName, psc.name as ProdSubCat, LineTotal
		from Sales.SalesOrderDetail sod
		join Production.Product p on p.ProductID = sod.ProductID
		join Production.ProductSubcategory psc on psc.ProductSubcategoryID = p.ProductSubcategoryID
		join Sales.SalesOrderHeader soh on soh.SalesOrderID = sod.SalesOrderID
		join Person.Person pr on pr.BusinessEntityID = soh.SalesPersonID
		where year(OrderDate) = 2013) a
	pivot(sum(LineTotal) for ProdSubcat in ([Road Bikes], [Mountain Bikes], [Touring Bikes])) b
	Order by ([Road Bikes] + [Mountain Bikes] + [Touring Bikes]) desc

-- #60
	create table dbo.SalesPersonSurvey(
		 SurveyId INT NOT NULL IDENTITY(1, 1),
		 [Overall Experience] TINYINT NOT NULL,
		 [Will you purchase from AdventureWorks Again] TINYINT NOT NULL,
		 [Likelihood to recommend to a friend] TINYINT NOT NULL,
		 [SalesPerson I worked with was helpful] TINYINT NOT NULL,
		 [SalesPerson I worked with was Kind] TINYINT NOT NULL
		 )
 
	insert into dbo.SalesPersonSurvey 
		([Overall Experience]
		,[Will you purchase from AdventureWorks Again]
		,[Likelihood to recommend to a friend]
		,[SalesPerson I worked with was helpful]
		,[SalesPerson I worked with was Kind])
	values
		(5,4,3,3,3),(2,3,4,2,2),(1,1,4,1,1)
	,(4,5,5,5,2),(2,3,5,5,5),(3,3,5,5,5)
	,(4,3,5,5,5),(1,1,1,1,1),(4,3,5,4,5)
	,(2,3,3,3,3)
 
	select SurveyId, questions, response
	from (
		select SurveyId, [Overall Experience], [Will you purchase from AdventureWorks Again], [Likelihood to recommend to a friend], [SalesPerson I worked with was helpful], [SalesPerson I worked with was Kind] 
		from SalesPersonSurvey) a
	unpivot (response for questions in ([Overall Experience], [Will you purchase from AdventureWorks Again], [Likelihood to recommend to a friend], [SalesPerson I worked with was helpful], [SalesPerson I worked with was Kind])) b


