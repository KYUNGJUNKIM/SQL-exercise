
-- #61
	select sp.BusinessEntityID, concat(FirstName, coalesce(' ' + MiddleName, ''), ' ', LastName) as FullName, isnull(st.name, 'No Territory') as TerritoryName, format(sp.SalesYTD,'C0') as SalesYTD
	from Sales.SalesPerson sp
	join Person.Person p on p.BusinessEntityID = sp.BusinessEntityID
	left join Sales.SalesTerritory st on st.TerritoryID = sp.TerritoryID
	order by sp.SalesYTD desc

-- #62
	-- a.
	select sp.BusinessEntityID, 
		   concat(FirstName, coalesce(' ' + MiddleName, ''), ' ', LastName) as FullName, 
		   isnull(st.name, 'No Territory') as TerritoryName, 
		   format(sp.SalesYTD,'C0') as SalesYTD,
		   rank() over(order by sp.SalesYTD desc) as Rank
	from Sales.SalesPerson sp
	join Person.Person p on p.BusinessEntityID = sp.BusinessEntityID
	left join Sales.SalesTerritory st on st.TerritoryID = sp.TerritoryID
	order by sp.SalesYTD desc

	-- b.
	select sp.BusinessEntityID, 
		   concat(FirstName, coalesce(' ' + MiddleName, ''), ' ', LastName) as FullName, 
		   isnull(st.name, 'No Territory') as TerritoryName, 
		   format(sp.SalesYTD,'C0') as SalesYTD,
		   rank() over(order by sp.SalesYTD desc) as Rank,
		   rank() over(partition by st.name order by sp.SalesYTD desc) as TerrioryRank
	from Sales.SalesPerson sp
	join Person.Person p on p.BusinessEntityID = sp.BusinessEntityID
	left join Sales.SalesTerritory st on st.TerritoryID = sp.TerritoryID
	order by st.name, sp.SalesYTD desc

	-- c.
	select sp.BusinessEntityID, 
		   concat(FirstName, coalesce(' ' + MiddleName, ''), ' ', LastName) as FullName, 
		   isnull(st.name, 'No Territory') as TerritoryName, 
		   format(sp.SalesYTD,'C0') as SalesYTD,
		   rank() over(order by sp.SalesYTD desc) as Rank,
		   format(PERCENT_RANK() over(order by sp.SalesYTD asc),'P0') as TotalPercentRank
	from Sales.SalesPerson sp
	join Person.Person p on p.BusinessEntityID = sp.BusinessEntityID
	left join Sales.SalesTerritory st on st.TerritoryID = sp.TerritoryID
	order by st.name, sp.SalesYTD desc

-- #63
	select sp.BusinessEntityID,
		   lag(sp.BusinessEntityID) over(order by sp.SalesYTD) as LagID,
		   lead(sp.BusinessEntityID) over(order by sp.SalesYTD) as LeadID,
		   concat(FirstName, coalesce(' ' + MiddleName, ''), ' ', LastName) as FullName, 
		   isnull(st.name, 'No Territory') as TerritoryName, 
		   format(sp.SalesYTD,'C0') as SalesYTD,
		   rank() over(order by sp.SalesYTD desc) as Rank,
		   format(lag(sp.SalesYTD) over(order by sp.SalesYTD), 'C0') as LagValue,
		   format(lead(sp.SalesYTD) over(order by sp.SalesYTD), 'C0') as LeadValue
	from Sales.SalesPerson sp
	join Person.Person p on p.BusinessEntityID = sp.BusinessEntityID
	left join Sales.SalesTerritory st on st.TerritoryID = sp.TerritoryID
	order by st.name, sp.SalesYTD desc

-- #64
	create view Sales.vSalesPersonSalesYTD as (
		select sp.BusinessEntityID,
		   lag(sp.BusinessEntityID) over(order by sp.SalesYTD) as LagID,
		   lead(sp.BusinessEntityID) over(order by sp.SalesYTD) as LeadID,
		   concat(FirstName, coalesce(' ' + MiddleName, ''), ' ', LastName) as FullName, 
		   isnull(st.name, 'No Territory') as TerritoryName, 
		   format(sp.SalesYTD,'C0') as SalesYTD,
		   rank() over(order by sp.SalesYTD desc) as Rank,
		   format(PERCENT_RANK() over(order by sp.SalesYTD asc),'P0') as TotalPercentRank,
		   format(lag(sp.SalesYTD) over(order by sp.SalesYTD), 'C0') as LagValue,
		   format(lead(sp.SalesYTD) over(order by sp.SalesYTD), 'C0') as LeadValue
		from Sales.SalesPerson sp
		join Person.Person p on p.BusinessEntityID = sp.BusinessEntityID
		left join Sales.SalesTerritory st on st.TerritoryID = sp.TerritoryID
		order by st.name, sp.SalesYTD desc
	)
	
	drop view Sales.vSalesPersonSalesYTD

-- #65.
	-- a.
	select BusinessEntityID, concat(FirstName, coalesce(' '+MiddleName, ''), ' ', LastName) as FullName, count(*) as CNT
	from HumanResources.vEmployeeDepartmentHistory
	group by BusinessEntityID, concat(FirstName, coalesce(' '+MiddleName, ''), ' ', LastName)
	having count(*) > 1

	-- b.
	select * from HumanResources.vEmployeeDepartmentHistory
	where BusinessEntityID in (select BusinessEntityID
							   from HumanResources.vEmployeeDepartmentHistory
							   group by BusinessEntityID
							   having count(*) > 1)

-- #66
	select * from(
				select 
					row_number() over(partition by edh.BusinessEntityID order by RateChangeDate desc) as rownum,
					edh.BusinessEntityID,
					concat(FirstName, coalesce(' ' + MiddleName, ''), ' ', LastName) as FullName,
					Department,
					RateChangeDate,
					Rate
				from HumanResources.vEmployeeDepartmentHistory edh
				join HumanResources.EmployeePayHistory eph on edh.BusinessEntityID = eph.BusinessEntityID) a
	where rownum = 1

-- #67
	select *
	from(
		select 
			row_number() over(partition by edh.BusinessEntityID order by RateChangeDate desc) as rownum,
			edh.BusinessEntityID,
			concat(FirstName, coalesce(' ' + MiddleName, ''), ' ', LastName) as FullName,
			Department,
			RateChangeDate,
			Rate,
			format(percent_rank() over(order by Rate), 'P1') as Percentile
		from HumanResources.vEmployeeDepartmentHistory edh
		join HumanResources.EmployeePayHistory eph on edh.BusinessEntityID = eph.BusinessEntityID) a
	where rownum = 1
	order by Rate desc

-- #68
	select *
	from(
		select 
			row_number() over(partition by edh.BusinessEntityID order by RateChangeDate desc) as rownum,
			edh.BusinessEntityID,
			concat(FirstName, coalesce(' ' + MiddleName, ''), ' ', LastName) as FullName,
			Department,
			RateChangeDate,
			Rate,
			format(percent_rank() over(order by Rate), 'P1') as Percentile,
			format(percent_rank() over(partition by department order by Rate), 'P1') as DepartmentPercentile
		from HumanResources.vEmployeeDepartmentHistory edh
		join HumanResources.EmployeePayHistory eph on edh.BusinessEntityID = eph.BusinessEntityID) a
	where rownum = 1
	order by department, Rate desc

-- #69
	select *
	from(
		select 
			row_number() over(partition by edh.BusinessEntityID order by RateChangeDate desc) as rownum,
			edh.BusinessEntityID,
			concat(FirstName, coalesce(' ' + MiddleName, ''), ' ', LastName) as FullName,
			Department,
			RateChangeDate,
			Rate,
			format(percent_rank() over(order by Rate), 'P1') as Percentile,
			format(percent_rank() over(partition by Department order by Rate), 'P1') as DepartmentPercentile,
			ntile(4) over(order by Rate) as Quartile,
			ntile(4) over(partition by Department order by Rate) as DepartmentQuartile
		from HumanResources.vEmployeeDepartmentHistory edh
		join HumanResources.EmployeePayHistory eph on edh.BusinessEntityID = eph.BusinessEntityID) a
	where rownum = 1
	order by department, Rate desc

-- #70
	-- a.
	select count(distinct OrderDate) from Sales.SalesOrderHeader
		--1,124

	-- b.
	select datediff(dd, min(OrderDate), max(OrderDate))+1 from Sales.SalesOrderHeader
		--1,127

	-- c. 
	declare @FirstDate as date = (select min(orderdate) from Sales.SalesOrderHeader)
	declare @LastDate as date = (select max(orderdate) from Sales.SalesOrderHeader)
 
 
	Create Table dimDate 
		([DateKey] INT Primary Key
		,[Date] Date)
 
	while (@FirstDate<=@LastDate)
	begin
		   insert into dimDate
		select convert(char(8), @FirstDate, 112) as DateKey, @FirstDate as Date
	set @FirstDate=cast(dateadd(day, 1, @FirstDate) as date)
	end
 
	select * from dimDate d
	left join Sales.SalesOrderHeader soh on soh.OrderDate = d.Date
	Where OrderDate is null
