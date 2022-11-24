-- #11
	-- a.
	Select 
	Count(*) as EmpCNT
	,Count(Distinct BusinessEntityID) as EmpCNT2
	,Count(Distinct NationalIDNumber) as EmpCNT3
	From HumanResources.Employee


	-- b.
	Select 
		CurrentFlag
		,Count(*) as EmpCT
	From HumanResources.Employee
	Group by CurrentFlag

	-- c.
	select distinct JobTitle, PersonType from HumanResources.Employee he
	join Person.Person p on he.BusinessEntityID = p.BusinessEntityID
	where PersonType = 'SP'

	-- d.
	select jobtitle, count(distinct p.BusinessEntityID) from Person.Person p 
	join HumanResources.Employee he on he.BusinessEntityID = p.BusinessEntityID
	where PersonType = 'SP'
	group by JobTitle
		-- 17

-- #12
	-- a.
	select JobTitle, concat(FirstName, ' ', MiddleName, ' ', LastName) as FullName from person.person p
	join HumanResources.Employee he on he.BusinessEntityID = p.BusinessEntityID
	where JobTitle = 'Chief Executive Officer'
		-- Ken Sánchez

	-- b.
	select HireDate, JobTitle from HumanResources.Employee
	where JobTitle = 'Chief Executive Officer'
		-- 2009-01-14

	-- c.
	select JobTitle, concat(FirstName, ' ', MiddleName, ' ', LastName) from person.person p
	join HumanResources.Employee he on he.BusinessEntityID = p.BusinessEntityID
	where OrganizationLevel = 1


-- #13
	-- a.
	select JobTitle, concat(FirstName, ' ', MiddleName, ' ', LastName) from person.person p
	join HumanResources.Employee he on he.BusinessEntityID = p.BusinessEntityID
	where FirstName = 'John' and LastName = 'Evans'
		-- Production Technician - WC50

	-- b.
	select d.name as departmentName from HumanResources.Employee he 
	join person.person p on he.BusinessEntityID = p.BusinessEntityID
	join HumanResources.EmployeeDepartmentHistory dh on dh.BusinessEntityID = he.BusinessEntityID 
	join HumanResources.Department d on dh.DepartmentID = d.DepartmentID
	where FirstName = 'John' and LastName = 'Evans'
		-- Production

-- #14
	-- a.
	select * from Purchasing.Vendor
	order by CreditRating desc
		-- Merit Bikes

	-- b.
	select 
	case
		when PreferredVendorStatus = 1 then 'Preferred'
		else 'Not Preferred'
	end as 'perferenece',
	count(*) as PreferenceCNT
	from Purchasing.Vendor
	group by case
				when PreferredVendorStatus = 1 then 'Preferred'
				else 'Not Preferred'
			 end
		-- 93

	-- c.
	select 
	case
		when PreferredVendorStatus = 1 then 'Preferred'
		else 'Not Preferred'
	end as 'perferenece',
	avg(cast(CreditRating as decimal)) as AVG_rating
	from Purchasing.Vendor
	where ActiveFlag = 1
	group by case
				when PreferredVendorStatus = 1 then 'Preferred'
				else 'Not Preferred'
			 end

	-- d.
	Select Count(*) as CNT From Purchasing.Vendor
	Where ActiveFlag = 1 and PreferredVendorStatus = 0
		-- 7
	
-- #15
	-- Assume Today is August 15, 2014
	-- a.
	select BusinessEntityID, birthdate, datediff(YEAR, BirthDate, '2014-08-15') as current_age from HumanResources.Employee
	order by 2
		-- 62
	
	-- b.
	select OrganizationLevel, format(Avg(cast(DATEDIFF(Year, BirthDate, '2014-08-15') as decimal)), 'N2') as Age from HumanResources.Employee
	group by OrganizationLevel
	order by 2

	-- c.
	select OrganizationLevel, CEILING(format(Avg(cast(DATEDIFF(Year, BirthDate, '2014-08-15') as decimal)), 'N2')) as Age from HumanResources.Employee
	group by OrganizationLevel
	order by 2

	-- d.
	select OrganizationLevel, FLOOR(format(Avg(cast(DATEDIFF(Year, BirthDate, '2014-08-15') as decimal)), 'N2')) as Age from HumanResources.Employee
	group by OrganizationLevel
	order by 2

-- #16
	-- a.
	select count(distinct ProductID) from Production.Product
	where FinishedGoodsFlag = 1
		-- 295

	-- b.
	select count(distinct ProductID) as ProductCNT from Production.Product
	where FinishedGoodsFlag = 1 and SellEndDate is null
		-- 197

	-- c.
	select MakeFlag, count(distinct ProductID) from Production.Product
	where FinishedGoodsFlag = 1 and SellEndDate is null
	group by MakeFlag
		-- in house: 61, purchased: 136


-- #17
	-- a.
	select concat('$', Format(cast(sum(LineTotal) as decimal), 'N2')) from Production.Product p
	join Sales.SalesOrderDetail s on p.ProductID = s.ProductID

	Select Format(Sum(linetotal),'C0') as LineTotal From Sales.SalesOrderDetail

	-- b.
	select 
	case
		when MakeFlag =  1 then 'Manufactured'
		else 'Purchased'
	end as MakeFlag
	, concat('$', Format(cast(sum(LineTotal) as decimal), 'N2')) from Production.Product p
	join Sales.SalesOrderDetail s on p.ProductID = s.ProductID
	group by case
				when MakeFlag =  1 then 'Manufactured'
				else 'Purchased'
			 end
		-- manufactured: $106,175,056.00, purchased: $3,671,325.00
 
	-- c.
	select 
	case
		when MakeFlag =  1 then 'Manufactured'
		else 'Purchased'
	end as MakeFlag,
	concat('$', Format(cast(sum(LineTotal) as decimal), 'N2')) as LineTotal,
	Format(Count(Distinct SalesOrderID),'N0') as SalesOrderIDCNT
	from Production.Product p
	join Sales.SalesOrderDetail s on p.ProductID = s.ProductID
	group by case
				when MakeFlag =  1 then 'Manufactured'
				else 'Purchased'
			 end 



	-- d.
	Select 
	Case 
		When p.MakeFlag = 1 Then 'Manufactured'
		Else 'Purchased' 
	End as MakeFlag,
	Format(Sum(linetotal),'C0') as LineTotal,
	Format(Count(Distinct SalesOrderID),'N0') as SalesOrderID_CNT,
	Format(Sum(linetotal)/Count(Distinct s.SalesOrderID),'C0') as AvgLineTotal
	From Sales.SalesOrderDetail s
	join Production.Product p on p.ProductID = s.ProductID
	Group by Case 
				When p.MakeFlag = 1 Then 'Manufactured'
				Else 'Purchased' 
			 End

-- #18.
	-- a.
	select t.name as TableName ,c.name as ColumnName ,ep.value as Definitions
	from sys.extended_properties ep
	join sys.tables t on t.object_id = ep.major_id
	join sys.columns c on c.object_id = ep.major_id	and c.column_id = ep.minor_id
	where class = 1 and t.name in ('TransactionHistory') and c.name = 'TransactionType'

	-- b.
	select * from Production.TransactionHistory
	union
	select * from Production.TransactionHistoryArchive

	-- c.
	select cast(MIN(TransactionDate) as Date) as FirstDate,
		   cast(MAX(TransactionDate) as date) as LastDate
	from(
	select * from Production.TransactionHistoryArchive
	union
	select * from Production.TransactionHistory) as a
		-- First: 2011-04-16, Last: 2014-08-03
	
	-- d.
	select TransactionType,
		   cast(min(a.TransactionDate) as date) as FirstDate,
		   cast(max(a.TransactionDate) as date) as LastDate
	from (
	select * from Production.TransactionHistoryArchive
	union
	select * from Production.TransactionHistory) as a
	group by TransactionType
		-- W	2011-06-03	2014-06-02
		-- S	2011-05-31	2014-06-30
		-- P	2011-04-16	2014-08-03

-- #19
	select
	cast(min(OrderDate) as date) as FirstDate,
	cast(max(OrderDate) as date) as LastDate 
	from Sales.SalesOrderHeader
		-- 2011-05-31, 2014-06-30

-- #20
	-- a.
	select 
	Status,
	cast(min(OrderDate) as date) as FirstDate, 
	cast(max(OrderDate) as date) as LastDate from Purchasing.PurchaseOrderHeader
	Group by Status

	-- b.
	select 
	convert(date,min(DueDate)) as FirstDate,
	convert(date,max(DueDate)) as LastDate,
	convert(date,min(StartDate)) as FirstStartDate, 
	convert(date,max(StartDate)) as LastStartDate, 
	convert(date,min(EndDate)) as FirstEndDate,
	convert(date,max(EndDate)) as LastEndDate from Production.WorkOrder

