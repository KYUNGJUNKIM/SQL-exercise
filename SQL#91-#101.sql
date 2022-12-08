
-- #91
	-- a.
	select concat(FirstName, coalesce(''+MiddleName, ' '), ' ', LastName) as FullName, BirthDate, datediff(year, BirthDate, getdate()) as Age from Person.Person p
	join HumanResources.Employee e on e.BusinessEntityID = p.BusinessEntityID

	-- b.
	select concat(FirstName, coalesce(''+MiddleName, ' '), ' ', LastName) as FullName, BirthDate, datediff(year, BirthDate, getdate()) as Age from Person.Person p
	join HumanResources.Employee e on e.BusinessEntityID = p.BusinessEntityID
	where substring(cast(BirthDate as varchar), 6, 5) = concat(month(getdate()), '-', right(concat('100', day(getdate())), 2))

	-- SOLUTION
	SELECT 
    Concat(FirstName,' ',LastName) as FullName
    ,e.BirthDate
    ,DATEDIFF(Year,e.BirthDate,GetDate()) Age
	FROM   HumanResources.Employee E
		CROSS JOIN Person.Person P
	WHERE  P.BusinessEntityID = E.BusinessEntityID
 
	--b. 
	SELECT Concat(FirstName,' ',LastName) as FullName
		,e.BirthDate     
		,DATEDIFF(Year,e.BirthDate,GetDate()) Age
	FROM   HumanResources.Employee E
		CROSS JOIN Person.Person P
	WHERE  P.BusinessEntityID = E.BusinessEntityID
		and Month(e.Birthdate) = Month(GetDate())
		and Day(e.Birthdate) = Day(GetDate())

-- #92 
	if object_id('Sales.DailyRevenue') is not null drop table Sales.DailyRevenue
 
	create table Sales.DailyRevenue(
		OrderDate Date,
		TotalDue money
		)
 
	declare @BeginDate datetime
	declare @EndDate datetime
	declare @InsertDays int
	declare @LoopEndDate datetime
	set @BeginDate = (select min(OrderDate) from Sales.SalesOrderHeader)
	set @EndDate = (select max(OrderDate) from Sales.SalesOrderHeader)
	set @InsertDays = 100
	set @LoopEndDate = @BeginDate+@InsertDays
 
	while @BeginDate < @EndDate
	begin 
		insert Into Sales.DailyRevenue
			(OrderDate,TotalDue)
			select OrderDate, sum(Totaldue) as TotalDue
			from Sales.SalesOrderHeader
			where OrderDate > = @BeginDate and OrderDate < @LoopEndDate and OrderDate <= @EndDate
			group by OrderDate
			order by 1 desc
 
		print 'Data Between ' + DateName(month, @BeginDate) + ' ' + DateName(Year, @BeginDate) 
				+ ' through ' + DateName(month, @LoopEndDate) + ' ' + DateName(Year, @LoopEndDate) 
				+ ' inserted'
 
		set @BeginDate = @LoopEndDate
		set @LoopEndDate = (@LoopEndDate + @InsertDays)	
	end

-- #93
	-- a.
	select concat(FirstName, ' ', LastName) as FullName, c.AccountNumber, PhoneNumber, OrderDate, p.Name, sum(LineTotal) as LineTotal from Sales.SalesOrderHeader soh
	join Sales.SalesOrderDetail sod on soh.SalesOrderID = sod.SalesOrderID
	join Production.Product p on p.ProductID = sod.ProductID
	join Sales.Customer c on soh.CustomerID = c.CustomerID
	join Person.Person pe on pe.BusinessEntityID = c.PersonID
	join person.PersonPhone ph on ph.BusinessEntityID = pe.BusinessEntityID
	group by concat(FirstName, ' ', LastName), c.AccountNumber, PhoneNumber, OrderDate, p.Name 

	-- b .
	create procedure CustomerPurchaseHistory
		@PhoneNumber varchar(25),
		@AccountNumber nvarchar(15)
	as 
	begin(
		select concat(FirstName, ' ', LastName) as FullName, c.AccountNumber, PhoneNumber, OrderDate, p.Name, sum(LineTotal) as LineTotal
		into StoredProcedure
		from Sales.SalesOrderHeader soh
		join Sales.SalesOrderDetail sod on soh.SalesOrderID = sod.SalesOrderID
		join Production.Product p on p.ProductID = sod.ProductID
		join Sales.Customer c on soh.CustomerID = c.CustomerID
		join Person.Person pe on pe.BusinessEntityID = c.PersonID
		join person.PersonPhone ph on ph.BusinessEntityID = pe.BusinessEntityID
		where @PhoneNumber = PhoneNumber and @AccountNumber = soh.AccountNumber
		group by concat(FirstName, ' ', LastName), c.AccountNumber, PhoneNumber, OrderDate, p.Name
		)
	end

	-- c.
	exec CustomerPurchaseHistory @PhoneNumber = '620-555-0117', @AccountNumber = '10-4020-000695'

	-- d.
	drop procedure CustomerPurchaseHistory
	
-- #94
	-- a.
	select * from dbo.ufnGetContactInformation(1)

	-- b.
	select f.* from Person.Person p cross apply dbo.ufnGetContactInformation(p.BusinessEntityID) f

	-- c.
	select f.* from Person.Person p cross apply dbo.ufnGetContactInformation(p.BusinessEntityID) f
	where f.PersonID in (250,315,3780,6856,2457)

	-- d.
	select * from Person.Person p outer apply dbo.ufnGetContactInformation(p.BusinessEntityID) f
	where f.BusinessEntityType is null

-- #95
	-- a.
	select p.ProductID, p.Name, OrderDate, poh.PurchaseOrderID, OrderQty, sum(LineTotal) as LineTotal from Production.Product p 
	join Purchasing.PurchaseOrderDetail pod on pod.ProductID = p.ProductID
	join Purchasing.PurchaseOrderHeader poh on poh.PurchaseOrderID = pod.PurchaseOrderID
	group by p.ProductID, p.Name, OrderDate, poh.PurchaseOrderID, OrderQty
	
	-- b.
	create function dbo.ufnSalesByVendor (@VendorID int) 
	returns table 
	as 
	 return 
	  (	select p.ProductID, p.Name, OrderDate, poh.PurchaseOrderID, sum(OrderQty) as OrderQty, sum(LineTotal) as LineTotal from Production.Product p 
		join Purchasing.PurchaseOrderDetail pod on pod.ProductID = p.ProductID
		join Purchasing.PurchaseOrderHeader poh on poh.PurchaseOrderID = pod.PurchaseOrderID
		where poh.VendorID = @VendorID
		group by p.ProductID, p.Name, OrderDate, poh.PurchaseOrderID)

	-- c.
	select * from dbo.ufnSalesByVendor(1604)

	-- d.
	select * from Purchasing.Vendor v cross apply dbo.ufnSalesByVendor(v.BusinessEntityID) f

	-- e.
	drop function dbo.ufnSalesByVendor

-- #96
	-- a.
	select count(distinct ProductID) ProductCNT
	from(
		select ProductID, count(StartDate) as ChangedCNT from Production.ProductListPriceHistory
		group by ProductID
		having count(StartDate) > 1
		) a

	-- b.
	select ProductID, count(StartDate) as ChangedCNT 
	into #Temp1 
	from Production.ProductListPriceHistory
	group by ProductID
	having count(StartDate) > 1
	
	select count(distinct ProductID) from #Temp1

	-- c.
	select count(distinct plph1.ProductID) as CNT from Production.ProductListPriceHistory plph1
	join Production.ProductListPriceHistory plph2 on plph1.ProductID = plph2.ProductID and plph1.ListPrice <> plph2.ListPrice

-- #97
	Drop Table If Exists dbo.TestTable
	
	select Person.*, NationalIDNumber, JobTitle, BirthDate, MaritalStatus, Gender, HireDate, VacationHours, SickLeaveHours
	into dbo.TestTable
	from HumanResources.Employee cross join Person.Person

	-- a.
	select * from TestTable where BusinessEntityID = 289

	-- b.
	create index idx_TestTable_BusinessEntityID on TestTable(BusinessEntityID)

	-- c.
	drop table TestTable

-- #98
	-- a.
	select * from Sales.SalesOrderDetail
	drop Index AK_SalesOrderDetail_rowguid on Sales.SalesOrderDetail

	-- b.
	drop Index IX_SalesOrderDetail_ProductID on Sales.SalesOrderDetail
	
	--c.
	alter table Sales.SalesOrderDetail drop constraint PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID 

	--d.
	create unique nonclustered Index AK_SalesOrderDetail_rowguid on Sales.SalesOrderDetail(rowguid)

	--e.
	create nonclustered Index IX_SalesOrderDetail_ProductID on Sales.SalesOrderDetail(ProductID)

	--f.
	alter table Sales.SalesOrderDetail add constraint PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID Primary Key clustered (SalesOrderID, SalesOrderDetailID)

-- #99
	-- a.
	select o.name as TriggerName, s.name as SchemaName, t.name as TableName, te.type_desc as TriggerType
	from sys.objects o
    join sys.trigger_events te on o.object_id = te.object_id
	join sys.schemas s on s.schema_id = o.schema_id
    join sys.tables t on o.parent_object_id = t.object_id

	-- b.
	delete from HumanResources.Employee where BusinessEntityID = 18

	-- c.
	delete from HumanResources.EmployeeDepartmentHistory where BusinessEntityID = 18

	-- d.
	insert into HumanResources.EmployeeDepartmentHistory(
		BusinessEntityID,
        DepartmentID,
        ShiftID,
        StartDate,
        EndDate,
        ModifiedDate)
    values
		('18','4','1','2011-02-07',NULL,'2011-02-06 00:00:00.000')

	--e. 
	create trigger HumanResources.dEmployeeDepartmentHistory on HumanResources.EmployeeDepartmentHistory
	for delete 
	as
	begin
	  print 'You Cannot Delete Employee From EmployeeDepartmentHistory'
	  rollback transaction
	end
 
	--f. 
	delete from HumanResources.EmployeeDepartmentHistory where BusinessEntityID = '18'
 
	--g. 
	drop trigger HumanResources.dEmployeeDepartmentHistory

-- #100
	-- a.
	select o.name as TriggerName, s.name as SchemaName, t.name as TableName, te.type_desc as TriggerType
	from sys.objects o
    join sys.trigger_events te on o.object_id = te.object_id
	join sys.schemas s on s.schema_id = o.schema_id
    join sys.tables t on o.parent_object_id = t.object_id
		--iWorkOrder
	
	-- b.
		--Inserting Values into Production.TransactionHistory

	-- c.
	insert into Production.WorkOrder(
        ProductID,OrderQty,ScrappedQty,
        StartDate,EndDate,DueDate,
        ScrapReasonID,ModifiedDate)
	values
        (680, 1, 0, '2014-06-03', '2014-06-13', '2014-06-14', Null, '2014-06-15')

	-- d.
	select * from Production.TransactionHistory order by 1 desc

	-- e.
	select * from Production.WorkOrder where StartDate = '2014-06-03 00:00:00.000'
	delete from Production.WorkOrder where StartDate = '2014-06-03 00:00:00.000'
 
	select * from Production.TransactionHistory	where Convert(char(8), TransactionDate, 112) = Convert(char(8), GETDATE(), 112)
	delete from Production.TransactionHistory where Convert(char(8), TransactionDate, 112) = Convert(char(8), GETDATE(), 112)

-- #101
	-- a.
	select * from HumanResources.Employee where CurrentFlag = '0'

	-- b.
	alter table HumanResources.Employee add DepartureDate Date

	-- c.
	create trigger HumanResources.uEmployee on HumanResources.Employee 
	after update as
    begin
		set nocount on
		update HumanResources.Employee
		set DepartureDate = GetDate()
		from HumanResources.Employee
		join inserted on inserted.BusinessEntityID = Employee.BusinessEntityID and inserted.CurrentFlag = '0'
 
		update HumanResources.Employee
		set DepartureDate = Null
		from HumanResources.Employee
		join inserted on inserted.BusinessEntityID = Employee.BusinessEntityID and inserted.CurrentFlag = '1'			
	End

	select * from HumanResources.Employee

	-- d.
	update HumanResources.Employee set CurrentFlag = 0 where BusinessEntityID = 2

	-- e.
	drop trigger if exists HumanResources.uEmployee

	-- f.
	update HumanResources.Employee set CurrentFlag = 1 where BusinessEntityID = 2

	-- g.
	drop trigger HumanResources.uEmployee

	-- h.
	alter table HumanResources.Employee drop column DepartureDate 