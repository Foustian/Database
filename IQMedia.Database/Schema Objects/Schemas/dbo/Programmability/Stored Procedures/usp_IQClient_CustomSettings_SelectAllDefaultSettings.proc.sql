CREATE PROCEDURE [dbo].[usp_IQClient_CustomSettings_SelectAllDefaultSettings]
AS
BEGIN
	
	declare @sql nvarchar(max)
	declare @list varchar(500)
	declare @selectlist varchar(max)
	select @list =  coalesce(@list + ',','') +'[' +  Field + ']' from IQClient_CustomSettings GROUP BY Field
	select @selectlist =  coalesce(@selectlist + ',','') +'isnull(' +  Field + ',0) as'''+  Field+ '''' from IQClient_CustomSettings GROUP BY Field

	set @sql = 'SELECT 
					
						' + @selectlist	+ '
				FROM
				(	
					SELECT     
						Field,
						Value
					FROM         
						IQClient_CustomSettings
					WHERE
						_ClientGuid = CAST(CAST(0 AS BINARY) as UNIQUEIDENTIFIER)
				) as a 
					
				pivot
				(
					max([Value])
					FOR [Field] IN ('	+ @list +')
				)AS B '
	
	print @sql

	exec sp_executesql @sql
	 
END