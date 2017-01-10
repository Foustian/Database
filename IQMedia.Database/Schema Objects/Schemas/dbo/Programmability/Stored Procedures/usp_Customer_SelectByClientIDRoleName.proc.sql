
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_Customer_SelectByClientIDRoleName]
	-- Add the parameters for the stored procedure here
	@ClientID	int,
	@RoleName	varchar(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
	     CustomerKey,FirstName,LastName,CustomerPassword,Email
    FROM
        Customer
    INNER JOIN CustomerRole ON Customer.CustomerKey = CustomerRole.CustomerID
    INNER JOIN Role ON CustomerRole.RoleID = Role.RoleKey
    WHERE
		ClientID = @ClientID
	AND	Role.RoleName = @RoleName
	AND Customer.IsActive = 1
	AND Role.IsActive = 1
	AND CustomerRole.IsAccess = 1
	
	Order By Customer.CustomerKey
	
	
END


