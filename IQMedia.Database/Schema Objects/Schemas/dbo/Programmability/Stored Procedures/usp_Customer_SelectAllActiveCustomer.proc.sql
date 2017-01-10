-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_Customer_SelectAllActiveCustomer] 
	
AS
BEGIN
	
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    
    SELECT
		CustomerKey,
		--RedlassoUserName,
		--RedlassoPassword,
		--RedlassoUserGUID,
		FirstName,
		LastName,
		Email,
		CustomerComment,
		CustomerPassword,
		ContactNo,
		IsActive
	FROM
		Customer
	WHERE
		Customer.IsActive = 1
END
