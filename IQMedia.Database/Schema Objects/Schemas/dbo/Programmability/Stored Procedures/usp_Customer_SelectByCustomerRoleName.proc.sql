
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_Customer_SelectByCustomerRoleName]
	-- Add the parameters for the stored procedure here
	@CustomerID	int,
	@RoleName	varchar(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
	     RoleID
    FROM
        CustomerRole
    
    INNER JOIN Role ON CustomerRole.RoleID = Role.RoleKey
    WHERE
		CustomerID = @CustomerID
	AND	Role.RoleName = @RoleName 
	And Role.IsActive=1 and CustomerRole.IsAccess=1
	
END


