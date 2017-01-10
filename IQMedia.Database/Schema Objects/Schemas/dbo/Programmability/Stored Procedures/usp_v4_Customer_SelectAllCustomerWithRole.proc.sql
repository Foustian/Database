CREATE PROCEDURE [dbo].[usp_v4_Customer_SelectAllCustomerWithRole]
	(
		@ClientName varchar(100),
		@CustomerName	varchar(500),
		@PageNumner	int,
		@PageSize	int,
		@TotalResults int output
	)
AS
BEGIN
	

	DECLARE @StartRow int, @EndRow int

	SET @StartRow = (@PageNumner  * @PageSize) + 1
	SET @EndRow = (@PageNumner  * @PageSize) + @PageSize

	declare @sql nvarchar(max), @CountQuery nvarchar(max)
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


set @sql = ';WITH tempCustomer
AS
(

	SELECT
		ROW_NUMBER() OVER (ORDER BY FirstName Asc) as RowNum,*
	FROM
		(
			SELECT     
				dbo.Customer.CustomerKey,
				 FirstName,
				 LastName,
				 Email,
				 LoginID,
				 ContactNo,				 
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
				CustomerKey !=0 '
	if(ISNULL(@ClientName,'') != '')			
	BEGIN			
		set @sql = @sql + ' and		
				Client.ClientName ='''+ REPLACE(@ClientName,'''','''''')	+ ''''
	END

	if(ISNULL(@CustomerName,'') != '')			
	BEGIN			
		set @sql = @sql + ' and		
				(
					Customer.FirstName + '' '' +  Customer.LastName like  ''%'+ REPLACE(@CustomerName,'''','''''')	+ '%'' 
					OR Customer.Email like  ''%'+ REPLACE(@CustomerName,'''','''''')	+ '%'' 
					OR Customer.LoginID like  ''%'+ REPLACE(@CustomerName,'''','''''')	+ '%'' 
				)'
	END
		
		set @sql = @sql + ') as a pivot
		(
		max([IsAccess])
		FOR [RoleName] IN 
			('	+ @list +')
		)AS B
		
	)'

	SET @CountQuery = @sql + 'SELECT @TotalResults = COUNT(RowNum) FROM  tempCustomer'
	
	SET @sql = @sql + 'SELECT [CustomerKey],
		FirstName,
		LastName,
		Email,
		LoginID,
		ContactNo,		
		CustomerComment,
		ClientID, ' + @selectlist	+ ',[IsActive],isnull(MultiLogin,''False'') as ''MultiLogin'' 
		
	FROM 
		tempCustomer 
	Where 
		RowNum >= '+ convert(varchar,@StartRow)+' AND RowNum <= '+convert(varchar,@EndRow)+''

	Exec sp_executesql @sql
	EXEC sp_executesql 
        @query = @CountQuery, 
        @params = N'@TotalResults INT OUTPUT', 
        @TotalResults = @TotalResults OUTPUT
	
END

