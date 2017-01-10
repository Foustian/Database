CREATE PROCEDURE [dbo].[usp_Customer_SelectNameByCustomerGUID]
(
	@CustomerGUID	varchar(Max)
)
AS
BEGIN
	SET NOCOUNT ON;
	
	declare @Query nvarchar(MAx)
	
	set @Query='
	Select
			Customer.CustomerGUID,
			Customer.FirstName
	From
			Customer
	Where
			CONVERT(varchar(40),Customer.CustomerGUID) in ('+@CustomerGUID+')'
			
	exec sp_executesql @Query

    
END
