-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_Customer_SelectAllCustomerWithRole] 
	-- Add the parameters for the stored procedure here
	
	(
		@ClientName varchar(100)
	)
AS
BEGIN

declare @sql nvarchar(max)
declare @list varchar(max)
declare @selectlist varchar(max)
select @list =  coalesce(@list + ',','') +'[' +  Rolename + ']' from [Role] where IsActive = 'True' and RoleName != 'IframeMicrosite'
select @selectlist =  coalesce(@selectlist + ',','') +'cast(isnull(' +  Rolename + ',0) as bit) as'''+  RoleName+ '''' 
					from 
						[Role] 
					where 
						IsActive = 'True' and 
						RoleName != 'IframeMicrosite' AND
						RoleName != 'NielsenData' AND
						RoleName != 'CompeteData' AND
						RoleName != 'MicrositeDownload'

set @sql = 'SELECT [CustomerKey],
		FirstName,
		LastName,
		Email,
		ContactNo,
		CustomerPassword,
		CustomerComment,
		ClientID, ' + @selectlist	+ ',[IsActive],isnull(MultiLogin,''False'') as ''MultiLogin''
		
FROM
(
	SELECT     
		dbo.Customer.CustomerKey,
		 FirstName,
		 LastName,
		 Email,
		 ContactNo,
		 CustomerPassword,
		 CustomerComment,
		 ClientID,
		dbo.Role.RoleName,
		Customer.IsActive,
		CAST(CustomerRole.IsAccess AS INT) AS ''IsAccess'',
		MultiLogin
	FROM         
		dbo.Role INNER JOIN
        dbo.CustomerRole ON dbo.Role.RoleKey = dbo.CustomerRole.RoleID RIGHT OUTER JOIN
		dbo.Customer ON dbo.CustomerRole.CustomerID = dbo.Customer.CustomerKey Inner join
		dbo.Client on Customer.ClientID = Client.ClientKey
		
	WHERE
		CustomerKey !=0 
		and		
		Client.ClientName ='''+ @ClientName	+
		
''') as a pivot
(
max([IsAccess])
FOR [RoleName] IN 
	('	+ @list +')
)AS B'


Exec sp_executesql @sql
	
	
	
	
END

