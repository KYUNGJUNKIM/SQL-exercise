
-- #81
	select
	case
		 when datediff(dd, OrderDate, ShipDate) <= 7 then 'Before'
		 else 'after'
	end as Shipment,
	count(*) as CNT
	from Sales.SalesOrderHeader
	group by case
				 when datediff(dd, OrderDate, ShipDate) <= 7 then 'Before'
				 else 'after'
			 end

	select datediff(dd, OrderDate, ShipDate) as Shipment, count(*) as CNT from Sales.SalesOrderHeader
	group by datediff(dd, OrderDate, ShipDate)

-- #82
	-- a.
	select * from Sales.SalesPerson sp
	left join Person.Person p on sp.BusinessEntityID = p.BusinessEntityID
	order by SalesYTD

	-- b.
	declare @TopSalesPersonID int
	set @TopSalesPersonID = (select top 1 BusinessEntityID from Sales.SalesPerson order by SalesYTD desc)

	-- c.
	declare @CurrentYear int
	set @CurrentYear = (select year(max(OrderDate)) from Sales.SalesOrderHeader)

	-- d.
	declare @TopSalesPersonID int
	set @TopSalesPersonID = (select top 1 BusinessEntityID from Sales.SalesPerson order by SalesYTD desc)

	declare @CurrentYear int
	set @CurrentYear = (select year(max(OrderDate)) from Sales.SalesOrderHeader)

	select top 10 p.ProductID, p.Name, format(sum(SubTotal), 'C0') as SubTotal, format(sum(TotalDue), 'C0') as TotalDue from Sales.SalesOrderDetail sod
	join Sales.SalesOrderHeader soh on sod.SalesOrderID = soh.SalesOrderID
	join Production.Product p on sod.ProductID = p.ProductID
	where SalesPersonID = @TopSalesPersonID and year(OrderDate) = @CurrentYear
	group by p.ProductID, p.Name
	order by sum(TotalDue) desc, sum(SubTotal) desc

-- #83
	declare @ThirdSalesPersonID int
	set @ThirdSalesPersonID = (select BusinessEntityID from(select BusinessEntityID, SalesYTD, rank() over(order by SalesYTD desc) as ranking from Sales.SalesPerson) a where ranking = 3)

	declare @CurrentYear int
	set @CurrentYear = (select year(max(OrderDate)) from Sales.SalesOrderHeader)

	select top 10 p.ProductID, p.Name, format(sum(SubTotal), 'C0') as SubTotal, format(sum(TotalDue), 'C0') as TotalDue from Sales.SalesOrderDetail sod
	join Sales.SalesOrderHeader soh on sod.SalesOrderID = soh.SalesOrderID
	join Production.Product p on sod.ProductID = p.ProductID
	where SalesPersonID = @ThirdSalesPersonID and year(OrderDate) = @CurrentYear
	group by p.ProductID, p.Name
	order by sum(TotalDue) desc, sum(SubTotal) desc

-- #84
	-- a.
	select count(distinct CardNumber) from Sales.CreditCard
		-- 19,118

	-- b.
	select p.PersonType, count(CardNumber) as CardCNT
	from Sales.CreditCard cc
    join Sales.PersonCreditCard pcc on pcc.CreditCardID = cc.CreditCardID	
    join Person.Person p on p.BusinessEntityID = pcc.BusinessEntityID
	group by p.PersonType
	
	-- c.
	select *
	from (select PersonType,
		  case
			  when ExpYear <= 2005 and ExpMonth < 9 then 'Expired'
			  else 'Active'
		  end as ExpiredFlag,
		  count(*) as CNT
		  from Sales.CreditCard cc
		  join Sales.PersonCreditCard pcc on pcc.CreditCardID = cc.CreditCardID
		  join Person.Person p on p.BusinessEntityID = pcc.BusinessEntityID
		  group by PersonType, case when ExpYear <= 2005 and ExpMonth < 9 then 'Expired' else 'Active' end) a
	pivot(sum(CNT) for ExpiredFlag in([Active], [Expired])) as pivot_result

-- #85
	select concat(FirstName, coalesce(' '+MiddleName, ''), ' ', LastName) as FullName, 
		   right(cc.CardNumber, 4) as CardNumber,
		   PersonType, 
		   isnull(s.Name, 'Retail Customer') as StoreName, 
		   cast(concat(ExpYear, right(100+ExpMonth, 2))+'01' as date) as ExpirationDate, 
		   EmailAddress, 
		   PhoneNumber
	from Sales.CreditCard cc
    join Sales.PersonCreditCard pcc on pcc.CreditCardID = cc.CreditCardID
    join Person.Person p on p.BusinessEntityID = pcc.BusinessEntityID
    left join Sales.Customer c on c.PersonID = p.BusinessEntityID
    left join Sales.Store s on s.BusinessEntityID = c.StoreID
    join Person.PersonPhone pp on pp.BusinessEntityID = p.BusinessEntityID
    join Person.EmailAddress ea on ea.BusinessEntityID = p.BusinessEntityID
	where concat(ExpYear, right(100+ExpMonth, 2)) <= '200509'

-- #86
	select d.Name, s.Name, left(StartTime, 5) as StartTime, left(EndTime, 5) as EndTime from HumanResources.Department d
	cross join HumanResources.Shift s
	where concat(ShiftID, DepartmentID) in (select concat(ShiftID, DepartmentID) from HumanResources.EmployeeDepartmentHistory)

-- #87
	select p.ProductID, p.Name, count(*) as ChangedCNT from Production.ProductListPriceHistory plph
	right join Production.Product p on p.ProductID = plph.ProductID
	group by p.ProductID, p.Name
	order by count(*) desc

	select ProductID, Name, Count(RowNum) as PriceChanges		
	from(select row_number() OVER (Partition by p.ProductID Order by ph.StartDate) as RowNum, p.Name, p.ProductID from Production.Product p
		 left join Production.ProductListPriceHistory ph on p.ProductID = ph.ProductID) a
	Group by ProductID, Name
	Order by 3 desc

-- #88
	select SalesOrderNumber, concat(FirstName, ' ', LastName) as FullName, AddressLine1, AddressLine2, TotalDue from Sales.SalesOrderHeader soh
	join Sales.Customer c on soh.CustomerID = c.CustomerID
	join Person.Person p on p.BusinessEntityID = c.PersonID
	join Purchasing.ShipMethod sm on sm.ShipMethodID = soh.ShipMethodID
    join Person.BusinessEntityAddress bea on bea.BusinessEntityID = p.BusinessEntityID
    join Person.Address a on a.AddressID = bea.AddressID
    join Person.StateProvince sp on sp.StateProvinceID = a.StateProvinceID
	where Shipdate between '2014-03-01' and '2014-04-30' and sm.Name = 'XRQ - TRUCK GROUND' and City = 'Beverly Hills' and sp.Name = 'California'
	order by 5 desc
	
-- #89
	-- a.
	select p.Name as ProductName, isnull(FileName, 'No File on Record') as FileName, Status, Revision, concat(FirstName,' ',LastName) as EmployeeName, JobTitle
	into #Temp1 
	from Production.Product p
    left join Production.ProductDocument pd on pd.ProductID = p.ProductID
    left join Production.Document d on d.DocumentNode = pd.DocumentNode
    left join HumanResources.Employee e on e.BusinessEntityID = d.Owner
    left join Person.Person pr on pr.BusinessEntityID = e.BusinessEntityID

	select * from #Temp1

	-- b.
	select count(ProductName) as FileNameCNT from #Temp1
	where FileName <> 'No File on Record'

	-- c.
	select ProductName from #Temp1
	Where FileName <> 'No File on Record'
	group by ProductName
	having count(*) > 1

	-- d.
	select EmployeeName, avg(cast(Revision as decimal(8, 2))) as AvgRevision from #Temp1
	where FileName <> 'No File on Record'
	group by EmployeeName

-- #90
	select *, [Day]+isnull([Evening], 0)+isnull([Night], 0) as EmpTotalCnt
	from(
		select isnull(GroupName, 'Grand Total') as GroupName, s.Name as ShiftName, count(*) as CNT from HumanResources.EmployeeDepartmentHistory edh
		join HumanResources.Shift s on edh.ShiftID = s.ShiftID
		join HumanResources.Department d on edh.DepartmentID = d.DepartmentID
		where EndDate is null
		group by rollup(GroupName), s.Name) a
	pivot(sum(CNT) for ShiftName in ([Day], [Evening], [Night])) as pivot_result
	order by 2 asc

	-- SOLUTION --
	select isnull(GroupName,'Grand Total') as Department_GroupName, 
	count(Case When s.Name = 'Day' Then e.BusinessEntityID else null End) as Day_EmpCNT,
    count(Case When s.Name = 'Evening' Then e.BusinessEntityID else null End) as Evening_EmpCNT,
    count(Case When s.Name = 'Night' Then e.BusinessEntityID else null End) as Night_EmpCNT,
    count(e.BusinessEntityID) as Total_EmpCNT
	from HumanResources.Employee e
    Inner Join HumanResources.EmployeeDepartmentHistory edh on edh.BusinessEntityID = e.BusinessEntityID
    Inner Join HumanResources.Shift s on s.ShiftID = edh.ShiftID
    Inner Join HumanResources.Department d on d.DepartmentID = edh.DepartmentID
	where enddate is null
	group by Rollup(GroupName)