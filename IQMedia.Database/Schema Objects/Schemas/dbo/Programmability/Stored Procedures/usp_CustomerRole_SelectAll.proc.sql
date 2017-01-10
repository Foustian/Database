-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_CustomerRole_SelectAll]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    SELECT
		CustomerRole.CustomerRoleKey,
		CustomerRole.CustomerID,
		CustomerRole.RoleID,
		CustomerRole.IsAccess,
		Customer.FirstName,
		Customer.LastName,
		[Role].RoleName,
		Client.ClientName,
		Client.ClientKey
	FROM
		CustomerRole
	INNER JOIN
		Customer
	ON
		Customer.CustomerKey = CustomerRole.CustomerID
	
	INNER JOIN
		Client
	ON 
		Client.ClientKey = Customer.ClientID	
			
	
	INNER JOIN
		[Role]
	ON
		Role.RoleKey = CustomerRole.RoleID
	
END
