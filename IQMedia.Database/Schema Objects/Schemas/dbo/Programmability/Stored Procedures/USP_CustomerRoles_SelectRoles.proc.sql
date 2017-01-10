-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[USP_CustomerRoles_SelectRoles] 
	-- Add the parameters for the stored procedure here
	@CustomerKey int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    SELECT 
		CustomerRoleKey,
		RoleName,
		IsAccess
	FROM
		CustomerRole
	INNER JOIN
		[Role]
	ON
		CustomerRole.RoleID = [Role].RoleKey
	WHERE
		CustomerRole.CustomerID = @CustomerKey
END
