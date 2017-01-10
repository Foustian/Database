-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_Customer_SelectAll]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
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
		ContactNo,
		CustomerPassword,
		CustomerComment,
		ClientID,
		ClientName,
		Customer.IsActive 
	FROM
		Customer
    INNER JOIN
		Client 
	ON
		Client.ClientKey = Customer.ClientID  WHERE Client.IsActive=1 
		
	ORDER BY FirstName
	
END
