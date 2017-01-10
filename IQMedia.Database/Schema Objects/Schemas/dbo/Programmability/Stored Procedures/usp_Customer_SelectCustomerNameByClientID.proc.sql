-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_Customer_SelectCustomerNameByClientID] 
	-- Add the parameters for the stored procedure here
	@ClientID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    SELECT
		CustomerKey,
		FirstName,
		LastName,
		--RedlassoUserName,
		--RedlassoPassword,
		CustomerGUID
	FROM
		Customer
	WHERE
		Customer.ClientID=@ClientID and IsActive=1
	Order by FirstName
END
