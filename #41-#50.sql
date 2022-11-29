
-- #41
	select 
		soh.SalesOrderID,
		concat(cp.FirstName,' ',cp.LastName) as 'CustomerName',
		case when cp.PersonType = 'IN' then 'Inividual Customer'
		  when cp.PersonType = 'SC' then 'Store Contact'
		  else Null end as 'PersonType',
		case When CONCAT(sp.FirstName,' ',sp.LastName) = ' ' 
		  then 'No Sales Person'
		  else CONCAT(sp.FirstName,' ',sp.LastName) end  as 'SalesPerson',
		OrderDate,
		Sum(OrderQTY) as ProductQty
	from Sales.SalesOrderHeader soh
		join Sales.SalesOrderDetail sod on soh.SalesOrderID = sod.SalesOrderID
		join Sales.Customer c on c.CustomerID = soh.CustomerID
		join Person.Person cp on cp.BusinessEntityID = c.PersonID
		left join Person.Person sp on sp.BusinessEntityID = soh.SalesPersonID
	group by soh.SalesOrderID, concat(cp.FirstName,' ',cp.LastName), cp.PersonType, OrderDate, concat(sp.FirstName,' ',sp.LastName)
	order by Sum(OrderQTY) desc

-- #42
	-- a.
	select *,
	concat(CustomerName, ' ', 'is a(n)', PersonType, ' ', 'and purchased', ' ', ProductQty, ' ' , 'Product(s) from', ' ', SalesPerson, ' ', 'on', ' ', format(OrderDate, 'yyyy-MM-dd'),'.') as comment
	from (select
			soh.SalesOrderID,
			concat(cp.FirstName,' ',cp.LastName) as 'CustomerName',
			case when cp.PersonType = 'IN' then 'Inividual Customer'
			  when cp.PersonType = 'SC' then 'Store Contact'
			  else Null end as 'PersonType',
			case When CONCAT(sp.FirstName,' ',sp.LastName) = ' ' 
			  then 'No Sales Person'
			  else CONCAT(sp.FirstName,' ',sp.LastName) end  as 'SalesPerson',
			OrderDate,
			Sum(OrderQTY) as ProductQty
		from Sales.SalesOrderHeader soh
			join Sales.SalesOrderDetail sod on soh.SalesOrderID = sod.SalesOrderID
			join Sales.Customer c on c.CustomerID = soh.CustomerID
			join Person.Person cp on cp.BusinessEntityID = c.PersonID
			left join Person.Person sp on sp.BusinessEntityID = soh.SalesPersonID
		group by 
			soh.SalesOrderID, concat(cp.FirstName,' ',cp.LastName), cp.PersonType, OrderDate, concat(sp.FirstName,' ',sp.LastName)) a 
	
	-- a. solution
	with CTE AS(
	Select 
		soh.SalesOrderID
		,(CONCAT(cp.FirstName,' ',cp.LastName) 
			+ ' is a(n) ' 
			+ Case When cp.PersonType = 'IN' Then 'Inividual Customer'
				   When cp.PersonType = 'SC' Then 'Store Contact'
				   Else Null End 
			+ ' and purchased ' 
			+ Cast(Sum(OrderQTY) as varchar) 
			+ ' Product(s) from ' 
			+ Case When CONCAT(sp.FirstName,' ',sp.LastName) = ' ' 
				   Then 'No Sales Person'
				   Else CONCAT(sp.FirstName,' ',sp.LastName) End 
			+ ' on ' 
			+ Convert(varchar, OrderDate,101)) as Comment
	From Sales.SalesOrderHeader soh
		Inner Join Sales.SalesOrderDetail sod on soh.SalesOrderID = sod.SalesOrderID
		Inner Join Sales.Customer c on c.CustomerID = soh.CustomerID
		Inner Join Person.Person cp on cp.BusinessEntityID = c.PersonID
		Left Join Person.Person sp on sp.BusinessEntityID = soh.SalesPersonID
	Group by 
		soh.SalesOrderID
		,CONCAT(cp.FirstName,' ',cp.LastName)
		,cp.PersonType
		,OrderDate
		,CONCAT(sp.FirstName,' ',sp.LastName))
	select * from CTE

	-- b.
	update Sales.SalesOrderHeader set Comment = CTE.Comment from Sales.SalesOrderHeader soh
	join CTE on CTE.SalesOrderID = soh.SalesOrderID 
	
-- #43
	-- a.
	select count(*) from Sales.SalesPerson
	where SalesQuota < SalesYTD

	-- b.
	select count(*) as CntQualified from Sales.SalesPerson
	where SalesYTD > (select avg(SalesYTD) from Sales.SalesPerson)

-- #46
	-- a.
	select CreditRating, count(*) as CNT from Purchasing.Vendor
	group by CreditRating

	-- b.
	select 
	case 
		when CreditRating = 1 then 'Superior'
		when CreditRating = 2 then 'Excellent'
		when CreditRating = 3 then 'Above Average'
		when CreditRating = 4 then 'Average'
		when CreditRating = 5 then 'Below Average'
	end as CreditRating,
	count(*) as CNT
	from Purchasing.Vendor
	group by case 
				when CreditRating = 1 then 'Superior'
				when CreditRating = 2 then 'Excellent'
				when CreditRating = 3 then 'Above Average'
				when CreditRating = 4 then 'Average'
				when CreditRating = 5 then 'Below Average'
			 end

	-- c.
	select CHOOSE(CreditRating, 'Superior', 'Exellent', 'Above Average', 'Average', 'Below Average') as CreditRating, count(*) as CNT 
	from Purchasing.Vendor
	group by CHOOSE(CreditRating, 'Superior', 'Exellent', 'Above Average', 'Average', 'Below Average') 

	-- d.
	select 
	case
	 when PreferredVendorStatus = 0 then 'Not Preferred'
	 when PreferredVendorStatus = 1 then 'Preferred'
	end as PreferredStatus,
	count(*) as CNT
	from Purchasing.Vendor
	group by case
			 when PreferredVendorStatus = 0 then 'Not Preferred'
			 when PreferredVendorStatus = 1 then 'Preferred'
			 end

	-- e.
	select choose(PreferredVendorStatus, 'Not Preferred', 'Preferred') as VendorStatus, count(name) as CNT
	from Purchasing.Vendor
	group by PreferredVendorStatus

-- #47
	-- a.
	select 
	case
		when CreditRating = 1 then 'Approved'
		else 'Not Approved'
	end as CreditRating, 
	count(*) as CNT
	from Purchasing.Vendor
	group by case
				when CreditRating = 1 then 'Approved'
				else 'Not Approved'
	 		 end

	-- b.
	select choose(CreditRating, 'Approved', 'Not Approved', 'Not Approved', 'Not Approved', 'Not Approved') as CreditRating, count(*) as CNT from Purchasing.Vendor
	group by choose(CreditRating, 'Approved', 'Not Approved', 'Not Approved', 'Not Approved', 'Not Approved') 

	-- c.
	select IIF(CreditRating = 1, 'Approved', 'Not Approved') as CreditRating, Count(name) as CNT from Purchasing.Vendor
	group by IIF(CreditRating = 1, 'Approved', 'Not Approved')
	
-- #48
	-- a.
	alter table Purchasing.Vendor add CreditRatingDesc Varchar(100) 

	-- b.
	update Purchasing.Vendor set CreditRatingDesc = a.CreditRating
	from Purchasing.Vendor v
	join (select BusinessEntityID, Choose(CreditRating,'Superior','Excellent','Above Average','Average','Below Average') as CreditRating
		  from Purchasing.Vendor) a 
	on v.BusinessEntityID = a.BusinessEntityID

	-- c.
	alter table Purchasing.Vendor drop column CreditRatingDesc

-- #49
	-- a.
	select DATA_TYPE from INFORMATION_SCHEMA.COLUMNS
	where TABLE_SCHEMA = 'Purchasing' and TABLE_NAME = 'vendor' and COLUMN_NAME = 'Name'

	-- b.
	select DOMAIN_SCHEMA, DOMAIN_NAME from INFORMATION_SCHEMA.COLUMNS
	where TABLE_NAME = 'Vendor' and COLUMN_NAME = 'Name'

	-- c.
	select DOMAIN_SCHEMA, DOMAIN_NAME, count(*) as CNT from INFORMATION_SCHEMA.COLUMNS
	where TABLE_NAME = 'Vendor' and COLUMN_NAME = 'Name'
	group by DOMAIN_SCHEMA, DOMAIN_NAME

-- #50
	-- a.
	select * from INFORMATION_SCHEMA.COLUMNS
	where COLUMN_NAME='Status'

	-- b.
	create type [Status] from tinyint Not NUll

	-- c.
	alter table Purchasing.PurchaseOrderHeader alter column [Status] status

	-- d.
	Drop Type Status

	-- e.
	alter table Purchasing.PurchaseOrderHeader alter column [Status] tinyint NOT NULL


