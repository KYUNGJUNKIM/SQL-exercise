
-- #71
	-- a.
	select p.BusinessEntityID, concat(FirstName, ' ', LastName) as FullName, substring(EmailAddress, 0, charindex('@', EmailAddress)) as username from Person.EmailAddress ea
	join Person.Person p on ea.BusinessEntityID = p.BusinessEntityID
	order by p.BusinessEntityID

	-- b.
	select *
	from (select p.BusinessEntityID as BusinessEntityID, concat(FirstName, ' ', LastName) as FullName, substring(EmailAddress, 0, charindex('@', EmailAddress)) as username from Person.EmailAddress ea
		  join Person.Person p on ea.BusinessEntityID = p.BusinessEntityID) a
	group by BusinessEntityID, FullName, username
	having count(distinct username) > 1

	-- c.
	select 
	p.BusinessEntityID, 
	concat(FirstName, ' ', LastName) as FullName, 
	substring(EmailAddress, 0, charindex('@', EmailAddress)) as UserName,
	concat(left(FirstName, 2), '.', left(LastName, 2), '.', left(newid(), 5)) as TempPassword
	from Person.EmailAddress ea
	join Person.Person p on ea.BusinessEntityID = p.BusinessEntityID
	order by p.BusinessEntityID

-- #72
	-- a.
	select p.BusinessEntityID, concat(FirstName, ' ', LastName) as FullName, substring(EmailAddress, 0, charindex('@', EmailAddress)) as username 
	into Person.Username
	from Person.EmailAddress ea
	join Person.Person p on ea.BusinessEntityID = p.BusinessEntityID
	order by 1 

	-- b.
	select username, len(username) as CharLength from Person.Username

	-- c.
	select username,
	case
		when len(username) = 2 then concat(username, '123')
		when len(username) = 3 then concat(username, '12')
		when len(username) = 4 then concat(username, '1')
		else username
	end as NewUserName
	from Person.Username

	update Person.Username set Username = case when len(username) = 2 then concat(username, '123')
											   when len(username) = 3 then concat(username, '12')
											   when len(username) = 4 then concat(username, '1')
		  									   else Username 
										  end 
 
	select * From Person.Username

	-- d.
	truncate table Person.Username

	-- e.
	drop table Person.Username

-- #73
	select FirstName, LastName, JobTitle, cr.Name as country, sp.Name as state, a.City, PostalCode, a.AddressLine1, a.AddressLine2 from Person.Person p
	join Person.BusinessEntityAddress bea on bea.BusinessEntityID = p.BusinessEntityID
	join Person.Address a on bea.AddressID = a.AddressID
	join Person.StateProvince sp on sp.StateProvinceID = a.StateProvinceID
	join Person.CountryRegion cr on cr.CountryRegionCode = sp.CountryRegionCode
	join HumanResources.Employee e on e.BusinessEntityID = p.BusinessEntityID
	order by p.BusinessEntityID

-- #74
	select name, WeightUnitMeasureCode, Weight,
	case
		when WeightUnitMeasureCode = 'LB' then weight*453.592
		else weight
	end as AdjustedWeight
	from Production.Product
	order by 4 desc

-- #75
	-- a.
	if OBJECT_ID('tempdb..#Temp1') is not Null
	drop table #Temp1

	select pp.Name, SafetyStockLevel, ReorderPoint, sum(ppi.Quantity) as Quantity,
	case
		when SafetyStockLevel > sum(ppi.Quantity) then 1
		else 0
	end SafetyStockFlag,
	case
		when ReorderPoint > sum(ppi.Quantity) then 1
		else 0 
	end ReorderFlag
	into #Temp1
	from Production.Product pp
	join Production.ProductInventory ppi on pp.ProductID = ppi.ProductID
	group by pp.Name, SafetyStockLevel, ReorderPoint

	select * from #Temp1

	-- b.
	select count(ProductID) as CNT from Production.Product
		--504

	-- c.
	select count(distinct ProductID) as DistinctCNT from Production.ProductInventory
		--432

	-- d.
	select ProductID, Name from Production.Product
	where ProductID not in (select ProductID from Production.ProductInventory)

	-- e.
	select count(*) as BelowStock from #Temp1
	where SafetyStockFlag = 1
		--69

	-- f.
	select count(*) as ReorderPoint from #Temp1
	where ReorderFlag = 1
		--7

-- #76
	-- a.
	select * from Sales.vPersonDemographics
    where BusinessEntityID = '20392'

	select * from Person.Person
    where BusinessEntityID = '20392'

	select * 
	into Dup_PersonDemographics
	from Sales.vPersonDemographics
	where DateFirstPurchase is not null

	-- b.
	alter table Dup_PersonDemographics add FullName varchar(255), Age Int

	-- c.
	update Dup_PersonDemographics set FullName = concat(FirstName, ' ', LastName) 
	from Person.Person p
	join Dup_PersonDemographics pd on p.BusinessEntityID = pd.BusinessEntityID
	
	-- d.
	update Dup_PersonDemographics set Age = datediff(year, BirthDate, '2014-08-15')

	select * from Dup_PersonDemographics

-- #77
	-- a.
	select distinct MaritalStatus from Dup_PersonDemographics

	-- b.
	alter table Dup_PersonDemographics alter column MaritalStatus Varchar(255)
	update Dup_PersonDemographics set MaritalStatus = case when MaritalStatus = 'S' then 'Single'
														   when MaritalStatus = 'M' then 'Married' 
														   else MaritalStatus end

	-- c.
	alter table Dup_PersonDemographics alter column Gender Varchar(255)
	update Dup_PersonDemographics set Gender = case when Gender = 'F' then 'Female'
													when Gender = 'M' then 'Male' 
													else MaritalStatus end

-- #78
	-- a.
	select YearlyIncome, avg(Age) as AverageAge from Dup_PersonDemographics
	group by YearlyIncome
	order by YearlyIncome

	-- b.
	select YearlyIncome, Education, MaritalStatus, avg(TotalPurchaseYTD) as AvgPurchaseYTD from Dup_PersonDemographics
	group by YearlyIncome, Education, MaritalStatus
	order by avg(TotalPurchaseYTD) desc

	-- c.
	drop table Dup_PersonDemographics

-- #79
	-- a.
	select sr.ScrapReasonID, sr.Name, sum(ScrappedQty) as ScrappedQty from Production.WorkOrder wo
	join Production.ScrapReason sr on wo.ScrapReasonID = sr.ScrapReasonID
	group by sr.ScrapReasonID, sr.Name
	order by sum(ScrappedQty) desc

	-- b.
	select wo.ProductID, p.Name, sum(ScrappedQty) as ScrappedQty from Production.WorkOrder wo
	join Production.ScrapReason sr on wo.ScrapReasonID = sr.ScrapReasonID
	join Production.Product p on wo.ProductID = p.ProductID
	group by wo.ProductID, p.Name
	order by sum(ScrappedQty) desc

	-- c.
	select p.Name, sum(ScrappedQty) as ScrappedQty from Production.WorkOrder wo
	join Production.ScrapReason sr on wo.ScrapReasonID = sr.ScrapReasonID
	join Production.Product p on wo.ProductID = p.ProductID
	group by rollup(p.Name)

-- #80
	select 
    case when PersonType = 'IN' then 'Individual Customer'
         when PersonType = 'EM' then 'Employee'
		 when PersonType = 'SP' then 'Sales Person'
		 when PersonType = 'SC' then 'Store Contact'
		 when PersonType = 'VC' then 'Vendor Contact'
		 when PersonType = 'GC' then 'General Contact'
		 else null 
	end as PersonType,
	Format(Count(*),'N0') as SPCNT
	from Person.Person P
    left join HumanResources.Employee E on P.BusinessEntityID = E.BusinessEntityID
    left Join Sales.Customer C on C.PersonID = P.BusinessEntityID
	group by PersonType