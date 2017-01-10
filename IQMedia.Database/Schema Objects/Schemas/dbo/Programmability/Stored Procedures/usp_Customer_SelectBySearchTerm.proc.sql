-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_Customer_SelectBySearchTerm] 
	-- Add the parameters for the stored procedure here
(
	--@IsActive bit,
	@prefixText varchar(100)
	
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
 --   SELECT
	--	ClientKey,
	--	ClientName,
	--	IsActive
	--FROM
	--	Client
	
	--"SELECT TOP " + count.ToString()
 --               + " CountryName FROM Countries WHERE CountryName LIKE '" + key + "%'"
	
	--Select Top(@Count) * from Client where ClientName LIKE '" + @prefixText + "%'
	--Select  * from Client where ClientName like 'te%'
	declare @query nvarchar(max)
	set @query='Select CustomerKey,Email from Customer where Email like ''' + @prefixText + '%'' and IsActive=1 ORDER BY Email'
	exec sp_executesql @query
	--if(@prefixText is null)
	--	begin 
	--		set @query='Select * from Client where ClientName ORDER BY ClientName'
	--		exec sp_executesql @query
	--	end
	--else
	--	begin
	--		set @query='Select * from Client where ClientName like ''' + @prefixText + '%'' ORDER BY ClientName'
	--		exec sp_executesql @query
	--	end
		
	
	/*	and
		ClientKey !=0 and
		(@IsActive is null or Client.IsActive=@IsActive)
	
	
	ORDER BY ClientName*/
	
END
