
-- #31
	-- a.
	select ea.EmailAddress from Person.Person p
	join HumanResources.Employee e on e.BusinessEntityID = p.BusinessEntityID
	join Person.EmailAddress ea on p.BusinessEntityID = ea.BusinessEntityID
	where JobTitle='Chief Executive Officer'
	
	-- b.
	update Person.EmailAddress set EmailAddress = 'Ken.Sánchez@adventure-works.com' where BusinessEntityID = 1

-- #32
	-- a.
	update Person.EmailAddress set EmailAddress = 'ken0@adventure-works.com' where BusinessEntityID = 1

	-- b.
	select @@TranCount as OpenTransactions

	-- c.
	begin TRAN

	-- d.
	update Person.EmailAddress set EmailAddress = 'Ken.Sánchez@adventure-works.com'
	from Person.EmailAddress ea
	join Person.Person p on p.BusinessEntityID = ea.BusinessEntityID
	where p.FirstName ='Ken' and p.LastName = 'Sánchez'
 
	-- e.
	rollback

	-- f.
	select * from Person.EmailAddress
	where EmailAddress = 'Ken.Sánchez@adventure-works.com'

	-- g.
	begin TRAN
	update Person.EmailAddress set EmailAddress = 'Ken.Sánchez@adventure-works.com' where BusinessEntityID = 1
	COMMIT

-- #33
    Update Person.EmailAddress
	Set EmailAddress = 'ken0@adventure-works.com'
	Where BusinessEntityID = 1
 
	Update Person.EmailAddress
	Set EmailAddress = 'ken3@adventure-works.com'
	Where BusinessEntityID = 1726

	select @@ROWCOUNT as OpenTransaction

	select * from Person.EmailAddress

	-- a.
	BEGIN TRAN
 
	Update Person.EmailAddress
	Set EmailAddress = 'Ken.Sánchez@adventure-works.com'
	Where BusinessEntityID = 1 
 
	IF @@ROWCOUNT = 1
	Commit
	Else
	Rollback

	-- b.
	Declare @RowCNT int = (
			Select Count(*)
			From Person.EmailAddress
			Where BusinessEntityID = 1)
	BEGIN TRAN
 
	Update Person.EmailAddress
	Set EmailAddress = 'Ken.Sánchez@adventure-works.com'
	--Where BusinessEntityID = 1 
 
	IF @@ROWCOUNT = @RowCNT
	Commit
	Else
	Rollback

-- #34
	-- a.
	select BusinessEntityID, RANK() over (order by HireDate) from HumanResources.Employee

	-- b.
	select e.BusinessEntityID, 
		   concat(FirstName, ' ', LastName),
		   HireDate,
		   rank() over(order by HireDate) as seniority, 
		   cast(DATEDIFF(dd, HireDate, '2014-03-03') as float) as DaysEmployeed, 
		   round(cast(DATEDIFF(dd, HireDate, '2014-03-03') as float)/12, 2) as MonthsEmployeed, 
		   round(cast(DATEDIFF(dd, HireDate, '2014-03-03') as float)/365, 2) as YearsEmployeed 
	from HumanResources.Employee e
	join Person.Person p on e.BusinessEntityID = p.BusinessEntityID

-- #35
	-- a.
	Select 
		Rank() Over (Order by Hiredate asc) as 'Seniority',
		DATEDIFF(Day,HireDate,'2014-03-03') as 'DaysEmployed',
		DATEDIFF(Month,HireDate,'2014-03-03') as 'MonthsEmployed',
		DATEDIFF(Year,HireDate,'2014-03-03') as 'YearsEmployed',
		*	
	Into #Temp2
	From HumanResources.Employee

	-- b.
	update #Temp2 set YearsEmployed = 0 where MonthsEmployed < 12 and BusinessEntityID in ('286', '288')
	select * from #Temp2 where BusinessEntityID in ('286', '288')

	-- c.
	select count(*) as CNT from #Temp2
	where MonthsEmployed >= 66

	-- d.
	select 
	case
		when MonthsEmployed < 12 then 'LessThanOneYear'
		when MonthsEmployed between 12 and 47 then 'OneOverThreeUnder'
		when MonthsEmployed between 48 and 72 then 'FourOverSixUnder'
		when MonthsEmployed > 72 then 'OverSix'
	end as Classifier,
	count(*) as CNT,
	avg(YearsEmployed) as Sort
	from #Temp2
	group by case
				when MonthsEmployed < 12 then 'LessThanOneYear'
				when MonthsEmployed between 12 and 47 then 'OneOverThreeUnder'
				when MonthsEmployed between 48 and 72 then 'FourOverSixUnder'
				when MonthsEmployed > 72 then 'OverSix'
			 end
	order by 3 desc

	-- e.
	select 
	case
		when MonthsEmployed < 12 then 'LessThanOneYear'
		when MonthsEmployed between 12 and 47 then 'OneOverThreeUnder'
		when MonthsEmployed between 48 and 72 then 'FourOverSixUnder'
		when MonthsEmployed > 72 then 'OverSix'
	end as Classifier,
	count(*) as CNT,
	avg(YearsEmployed) as Sort,
	avg(SickLeaveHours) as AVG_SickLeaveHours,
	avg(VacationHours) as AVG_VacationHours
	from #Temp2
	group by case
				when MonthsEmployed < 12 then 'LessThanOneYear'
				when MonthsEmployed between 12 and 47 then 'OneOverThreeUnder'
				when MonthsEmployed between 48 and 72 then 'FourOverSixUnder'
				when MonthsEmployed > 72 then 'OverSix'
			 end
	order by AVG_SickLeaveHours desc, AVG_VacationHours desc

-- #36
	-- a.
	select distinct Name from Sales.SalesTerritory

	-- b.
	select distinct st.Name as RegionName, format(Sum(TotalDue),'C0') as TotalDue
	from Sales.SalesTerritory st
	join Sales.SalesOrderHeader soh on soh.TerritoryID = st.TerritoryID
	group by st.Name

	-- c.
	select distinct st.Name as RegionName, format(Sum(TotalDue),'C0') as TotalDue, concat(FirstName, ' ', LastName) as CustomerName from Sales.SalesTerritory st
	join Sales.SalesOrderHeader soh on st.TerritoryID = soh.TerritoryID
	join Sales.Customer c on c.CustomerID = soh.CustomerID
	join Person.Person p on p.BusinessEntityID = c.PersonID
	group by st.Name, concat(FirstName, ' ',LastName)

	-- d.
	select distinct st.Name as RegionName, format(Sum(TotalDue),'C0') as TotalDue, concat(FirstName, ' ', LastName) as CustomerName, ROW_NUMBER() Over(Partition by st.Name Order by Sum(TotalDue) desc) as RowNum 
	from Sales.SalesTerritory st
	join Sales.SalesOrderHeader soh on st.TerritoryID = soh.TerritoryID
	join Sales.Customer c on c.CustomerID = soh.CustomerID
	join Person.Person p on p.BusinessEntityID = c.PersonID
	group by st.Name, concat(FirstName, ' ',LastName)

-- #37
	-- a.
	select *
	from(select distinct st.Name as RegionName, format(Sum(TotalDue),'C0') as TotalDue, concat(FirstName, ' ', LastName) as CustomerName, ROW_NUMBER() Over(partition by st.Name order by Sum(TotalDue) desc) as RowNum 
		 from Sales.SalesTerritory st
		 join Sales.SalesOrderHeader soh on st.TerritoryID = soh.TerritoryID
		 join Sales.Customer c on c.CustomerID = soh.CustomerID
		 join Person.Person p on p.BusinessEntityID = c.PersonID
		 group by st.Name, concat(FirstName, ' ',LastName)) a
	where RowNum <= 25
	
	
	-- b.
	select 
		RegionName
		,format(avg(TotalDue),'C0') as AvgTotalDue
		,avg(TotalDue) as Sort
	from(
		select
			distinct st.Name as RegionName,
			Sum(TotalDue) as TotalDue, 
			concat(FirstName, ' ', LastName) as CustomerName, 
			ROW_NUMBER() Over(partition by st.Name order by Sum(TotalDue) desc) as RowNum
		from Sales.SalesTerritory st
		join Sales.SalesOrderHeader soh on st.TerritoryID = soh.TerritoryID
		join Sales.Customer c on c.CustomerID = soh.CustomerID
		join Person.Person p on p.BusinessEntityID = c.PersonID
		group by st.Name, concat(FirstName, ' ',LastName)) a
	where RowNum <= 25
	group by RegionName

-- #38
	-- a. 
	select format(sum(Freight), 'C0') from Sales.SalesOrderHeader 

	-- b.
	select YEAR(ShipDate) as Year, format(sum(Freight), 'C0') from Sales.SalesOrderHeader
	group by YEAR(shipDate)
	order by 1

	-- c.
	select YEAR(ShipDate) as Year, format(sum(Freight), 'C0') as TotalFreihgt, format(avg(freight), 'C0') as AvgFreight from Sales.SalesOrderHeader
	group by YEAR(shipDate)
	order by 1

	-- d.
	select ShipYear, format(TotalFreight,'C0') as TotalFreight, format(AvgFreight,'C0') as AvgFreight, format(sum(TotalFreight) over(order by ShipYear), 'C0') as RunningTotal
	from(
		select 
			YEAR(ShipDate) as ShipYear
			,sum(Freight) as TotalFreight
			,avg(Freight) as AvgFreight 
		from Sales.SalesOrderHeader
		group by YEAR(ShipDate)) a

-- #39
	-- a.
	select ShipYear, 
		   CompletedMonths,
		   format(TotalFreight,'C0') as TotalFreight, 
		   format(AvgFreight,'C0') as AvgFreight, 
		   format(sum(TotalFreight) over(order by ShipYear), 'C0') as RunningTotal
	from(
		select 
			YEAR(ShipDate) as ShipYear
			,sum(Freight) as TotalFreight
			,avg(Freight) as AvgFreight
			,count(distinct month(ShipDate)) as CompletedMonths
		from Sales.SalesOrderHeader
		group by YEAR(ShipDate)) a

	-- b.
	select ShipYear, 
		   CompletedMonths,
		   format(TotalFreight,'C0') as TotalFreight, 
		   format(AvgFreight,'C0') as AvgFreight, 
		   format(sum(TotalFreight) over(order by ShipYear), 'C0') as RunningTotal,
		   format(TotalFreight/CompletedMonths,'C0') as AvgFreightperMonth
	from(
		select 
			YEAR(ShipDate) as ShipYear
			,sum(Freight) as TotalFreight
			,avg(Freight) as AvgFreight
			,count(distinct month(ShipDate)) as CompletedMonths
		from Sales.SalesOrderHeader
		group by YEAR(ShipDate)) a

-- #40
	-- a.
	select ShipYear, 
		CompletedMonths,
		Months,
		format(TotalFreight,'C0') as TotalFreight, 
		format(AvgFreight,'C0') as AvgFreight, 
		format(sum(TotalFreight) over(order by ShipYear, CompletedMonths), 'C0') as RunningTotal
	from(
		select 
			YEAR(ShipDate) as ShipYear
			,sum(Freight) as TotalFreight
			,avg(Freight) as AvgFreight
			,month(ShipDate) as CompletedMonths
			,format(shipDate, 'MMMM') as Months
		from Sales.SalesOrderHeader
		group by YEAR(ShipDate), month(ShipDate), format(ShipDate, 'MMMM')) a

	-- b.
	select ShipYear, 
		CompletedMonths,
		Months,
		format(TotalFreight,'C0') as TotalFreight, 
		format(AvgFreight,'C0') as AvgFreight, 
		format(sum(TotalFreight) over(order by ShipYear, CompletedMonths), 'C0') as RunningTotal
	from(
		select 
			YEAR(ShipDate) as ShipYear
			,sum(Freight) as TotalFreight
			,avg(Freight) as AvgFreight
			,month(ShipDate) as CompletedMonths
			,format(shipDate, 'MMMM') as Months
		from Sales.SalesOrderHeader
		group by YEAR(ShipDate), month(ShipDate), format(ShipDate, 'MMMM')) a

	-- c.
	select ShipYear, 
		CompletedMonths,
		Months,
		format(TotalFreight,'C0') as TotalFreight, 
		format(AvgFreight,'C0') as AvgFreight, 
		format(sum(TotalFreight) over(order by ShipYear, CompletedMonths), 'C0') as RunningTotal,
		format(sum(AvgFreight) over(order by ShipYear, CompletedMonths), 'C0') as RunningAvgTotal
	from(
		select 
			YEAR(ShipDate) as ShipYear
			,sum(Freight) as TotalFreight
			,avg(Freight) as AvgFreight
			,month(ShipDate) as CompletedMonths
			,format(shipDate, 'MMMM') as Months
		from Sales.SalesOrderHeader
		group by YEAR(ShipDate), month(ShipDate), format(ShipDate, 'MMMM')) a

	-- d.
	select * 
    ,format(Sum(TotalFreight) over (order by ShipYear,ShipMonth),'C0') as RunningTotal
    ,format(Sum(TotalFreight) over (partition by ShipYear order by ShipYear, ShipMonth),'C0') as YTDRunningTotal
	from(
		select 
			YEAR(ShipDate) as ShipYear
			,sum(Freight) as TotalFreight
			,avg(Freight) as AvgFreight
			,month(ShipDate) as ShipMonth
			,format(shipDate, 'MMMM') as Monthname
		from Sales.SalesOrderHeader
		group by YEAR(ShipDate), month(ShipDate), format(ShipDate, 'MMMM')) a




