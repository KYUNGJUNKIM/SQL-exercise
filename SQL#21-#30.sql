
-- #21
	-- a.
	select cr.Name as 'Country',sp.Name as 'State' from Person.StateProvince sp
	join Person.CountryRegion cr on cr.CountryRegionCode = sp.CountryRegionCode

	-- b.
	select cr.Name as 'Country',sp.Name as 'State', TaxRate from Person.StateProvince sp
	join Person.CountryRegion cr on cr.CountryRegionCode = sp.CountryRegionCode
	left join Sales.SalesTaxRate st on sp.StateProvinceID = st.StateProvinceID

	-- c.
	select * from Sales.SalesTaxRate
	where StateProvinceID in (select sp.StateProvinceID
							 from Person.StateProvince sp
							 join Person.CountryRegion cr on sp.CountryRegionCode = cr.CountryRegionCode
							 left join Sales.SalesTaxRate tr on sp.StateProvinceID = tr.StateProvinceID 
							 group by sp.StateProvinceID
							 having count(*) > 1)

	-- d.
	select cr.Name as 'Country',sp.Name as 'State', TaxRate from Person.StateProvince sp
	join Person.CountryRegion cr on cr.CountryRegionCode = sp.CountryRegionCode
	left join Sales.SalesTaxRate st on sp.StateProvinceID = st.SalesTaxRateID
	order by TaxRate desc
		-- United States

-- #22
	-- a.
	select count(*) as CNT_IN from Person.Person
	where PersonType = 'IN'
		-- 18484

	-- b.
	select cr.Name, count(p.BusinessEntityID) as CNT from Person.Person p
	join Person.BusinessEntityAddress bea on bea.BusinessEntityID = p.BusinessEntityID
	join Person.Address a on a.AddressID = bea.AddressID
	join Person.StateProvince sp on sp.StateProvinceID = a.StateProvinceID
	join Person.CountryRegion cr on cr.CountryRegionCode = sp.CountryRegionCode
	where p.PersonType = 'IN'
	group by cr.Name
	order by 2 desc

	-- c.
	select 
	cr.Name, 
	count(distinct p.BusinessEntityID) as CNT, 
	format(cast(count(distinct p.BusinessEntityID) as float)/(select count(BusinessEntityID) from Person.Person where PersonType = 'IN'), 'P') as PCT 
	from Person.Person p
	join Person.BusinessEntityAddress bea on bea.BusinessEntityID = p.BusinessEntityID
	join Person.Address a on a.AddressID = bea.AddressID
	join Person.StateProvince sp on sp.StateProvinceID = a.StateProvinceID
	join Person.CountryRegion cr on cr.CountryRegionCode = sp.CountryRegionCode
	where p.PersonType = 'IN'
	group by cr.Name
	order by 2 desc

-- #23

	Declare @TotalRetailCustomers
	float = (select count(distinct BusinessEntityID) from Person.Person where PersonType='IN')

	select 
	cr.Name as Country
	,Format(count(Distinct p.BusinessEntityID),'N0') as CNT
	,Format(Cast(count(Distinct p.BusinessEntityID) as float)/@TotalRetailCustomers,'P') as PCT
 
	from Person.Person p
		Inner Join Person.BusinessEntityAddress bea on bea.BusinessEntityID = p.BusinessEntityID
		Inner Join Person.Address a on a.AddressID = bea.AddressID
		Inner Join Person.StateProvince sp on sp.StateProvinceID = a.StateProvinceID
		Inner Join Person.CountryRegion cr on cr.CountryRegionCode = sp.CountryRegionCode
	Where PersonType = 'IN'
	Group by cr.Name
	Order by 2 desc

-- #24
	-- a, c.
	select SubTotal, TaxAmt, Freight, (taxAmt + Freight) as variance, (subtotal + TaxAmt + Freight) as totaldue2, TotalDue from Sales.SalesOrderHeader
	where SalesOrderID='69411'

	-- b, d.
	select UnitPrice, UnitPriceDiscount, OrderQty, (UnitPrice-UnitPriceDiscount)*OrderQty as except_for_disc, LineTotal from Sales.SalesOrderDetail
	where SalesOrderID = '69411'

-- #25

	select Name, ListPrice, StandardCost,(ListPrice - StandardCost) as ProductMargins
	From Production.Product
	Order by 4 desc

-- #26
	-- a.
	select * from Production.Product
	where name like '%Mountain-100%'

	-- b.
	select so.StartDate, so.EndDate, so.Type, so.Category, DiscountPct, count(distinct p.Name) as CNT from Sales.SpecialOfferProduct sop
	join Sales.SpecialOffer so on sop.SpecialOfferID = so.SpecialOfferID
	join Production.Product p on sop.ProductID = p.ProductID
	where p.name like '%Mountain-100%'
	group by so.StartDate, so.EndDate, so.Type, so.Category, DiscountPct

	-- c.
	select SellStartDate, SellEndDate, DiscontinuedDate from Production.Product
	where ProductModelID = '19'

	-- d.
	select Min(OrderDate) as FirstDate, Max(OrderDate) as MostRecentDate from Sales.SalesOrderHeader soh
	join Sales.SalesOrderDetail sod on sod.SalesOrderID = soh.SalesOrderID
	join Production.Product p on p.ProductID = sod.ProductID	
	where ProductModelID = '19'

-- #27
	select pp.name, sum(Quantity) as inventory from Production.Product pp
	join Production.ProductInventory ppi on ppi.ProductID = pp.ProductID
	where ProductModelID = '19'
	group by pp.name

--#28
	-- a.
	select distinct name from Sales.SalesReason	

	-- b.
	select ssr.SalesReasonID, sr.name, count(*) as CNT from Sales.SalesOrderHeaderSalesReason ssr
	join Sales.SalesReason sr on sr.SalesReasonID = ssr.SalesReasonID
	group by ssr.SalesReasonID, sr.name

	-- c.
	select ssr.SalesReasonID, sr.name, count(*) as CNT from Sales.SalesOrderHeaderSalesReason ssr
	join Sales.SalesReason sr on sr.SalesReasonID = ssr.SalesReasonID
	group by ssr.SalesReasonID, sr.name
	order by 3 desc


-- #29

	with CTE as(
		select soh.SalesOrderID, count(hsr.SalesOrderID) as CNT from Sales.SalesOrderHeader soh
		  left join Sales.SalesOrderHeaderSalesReason hsr on hsr.SalesOrderID = soh.SalesOrderID
		group by soh.SalesOrderID)
 
	select CNT, count(CNT) from CTE
	group by CNT
	order by 2 desc

-- #30

	select * from Production.ProductReview
	where ReviewerName in (select concat(FirstName, ' ', LastName) from Person.Person)
		-- John Smith, Laura Norman
 

 



