CREATE PROCEDURE [dbo].[usp_v4_Client_SelectAllClientWithRole]
	@ClientName varchar(255),
	@PageNumner	int,
	@PageSize	int,
	@TotalResults int output	
AS
BEGIN	
	declare @sql nvarchar(max) , @CountQuery nvarchar(max)
	declare @list varchar(max)
	declare @selectlist varchar(max)
	select @list =  coalesce(@list + ',','') +'[' +  Rolename + ']' from [Role] where IsActive = 'True'

	select @selectlist =  coalesce(@selectlist + ',','') +'cast(isnull([' +  Rolename + '],0) as bit) as'''+  replace(RoleName,'''','''''') + '''' from [Role] where IsActive = 'True' order by RoleName

	DECLARE @StartRow int, @EndRow int

	SET @StartRow = (@PageNumner  * @PageSize) + 1
	SET @EndRow = (@PageNumner  * @PageSize) + @PageSize

	set @sql = '
			; With tempClient 
			AS
			(
				SELECT ROW_NUMBER() Over ( ORDER BY ClientName asc )as RowNum,*
				FROM
				(
					SELECT     
						dbo.Client.ClientName, 
						dbo.Client.ClientKey, 		
						dbo.Role.RoleName,
						Client.IsActive,
						CAST(ClientRole.IsAccess AS INT) AS ''IsAccess''
					FROM         
						dbo.Role INNER JOIN
						dbo.ClientRole ON dbo.Role.RoleKey = dbo.ClientRole.RoleID RIGHT OUTER JOIN
						dbo.Client ON dbo.ClientRole.ClientID = dbo.Client.ClientKey
		
					WHERE
						ClientKey !=0 '
						
	IF(@ClientName IS NOT NULL OR @ClientName <> '')
	BEGIN
		SET @sql = @sql + ' AND Client.ClientName like ''%'+ replace(@ClientName,'''','''''') +'%''' 	
	END
						
	SET @sql = @sql + ') as a pivot
				(
					max([IsAccess])
					FOR [RoleName] IN 
					('	+ @list +')
				)AS B
			)'

	
	SET @CountQuery = @sql + 'SELECT @TotalResults = COUNT(RowNum) FROM  tempClient'

	SET @sql = @sql + 'SELECT [ClientKey],[ClientName], ' + @selectlist	+ ',[IsActive] FROM tempClient Where RowNum >= '+ convert(varchar,@StartRow)+' AND RowNum <= '+convert(varchar,@EndRow)+''
	
	print @sql
	Exec sp_executesql @sql
	EXEC sp_executesql 
        @query = @CountQuery, 
        @params = N'@TotalResults INT OUTPUT', 
        @TotalResults = @TotalResults OUTPUT 
END