CREATE PROCEDURE [dbo].[usp_v4_Customer_SelectCustomerWithRoleByCustomerID]
(
	@CustomerID bigint
)
AS
BEGIN
	declare @sql nvarchar(max)
declare @list varchar(max)
declare @selectlist varchar(max)
select @list =  coalesce(@list + ',','') +'[' +  Rolename + ']' from [Role] where IsActive = 'True'
select @selectlist =  coalesce(@selectlist + ',','') +'cast(isnull(' +  Rolename + ',0) as bit) as'''+  RoleName+ '''' from [Role] where IsActive = 'True'


set @sql = 'Select [CustomerKey],
		FirstName,
		LastName,
		Email,
		MasterCustomerID,
		LoginID,
		ContactNo,
		CustomerComment,
		ClientID, ' + @selectlist	+ ',[IsActive],isnull(MultiLogin,''False'') as ''MultiLogin'',CreatedDate,
		DefaultPage,
		IsFliqCustomer,
		AnewstipUserID
		
FROM
(
	SELECT     
		dbo.Customer.CustomerKey,
		 FirstName,
		 LastName,
		 Email,
		 ContactNo,		 
		 CustomerComment,
		 MasterCustomerID,
		 LoginID,
		 ClientID,
		 Customer.CreatedDate,
		 dbo.Role.RoleName,
		Customer.IsActive,
		CAST(CustomerRole.IsAccess AS INT) AS ''IsAccess'',
		DefaultPage,
		MultiLogin,
		CASE WHEN EXISTS(SELECT 1 FROM fliq_Customer Where _CustomerID = '''+ CONVERT(varchar(10),@CustomerID) + ''' AND IsActive = 1) THEN 1 ELSE 0 END as IsFliqCustomer,
		AnewstipUserID
	FROM         
		dbo.Role INNER JOIN
        dbo.CustomerRole ON dbo.Role.RoleKey = dbo.CustomerRole.RoleID RIGHT OUTER JOIN
		dbo.Customer ON dbo.CustomerRole.CustomerID = dbo.Customer.CustomerKey Inner join
		dbo.Client on Customer.ClientID = Client.ClientKey
		
	WHERE
		CustomerKey !=0 
		and		
		Customer.CustomerKey ='''+ CONVERT(varchar(10),@CustomerID)	+
		
''') as a pivot
(
max([IsAccess])
FOR [RoleName] IN 
	('	+ @list +')
)AS B'

print @sql
Exec sp_executesql @sql
END
