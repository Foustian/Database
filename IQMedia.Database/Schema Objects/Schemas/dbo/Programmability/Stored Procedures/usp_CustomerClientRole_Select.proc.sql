-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_CustomerClientRole_Select]
	-- Add the parameters for the stored procedure here
	@CustomerKey int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @ClientID int
  
    SELECT @ClientID=ClientID FROM Customer WHERE CustomerKey = @CustomerKey
    
     SELECT 
		CustomerRole.CustomerRoleKey,
		CustomerRole.CustomerID,
		CustomerRole.RoleID AS CustomerRoleID,
		CustomerRole.IsAccess AS CustomerAccess,
		ClientRole.ClientRoleKey,
		ClientRole.RoleID AS ClientRoleID,
	    ClientRole.IsAccess AS ClientAccess,
		[Role].RoleKey,
		[Role].RoleName,
		[Role].IsActive AS RoleIsActive
		
	FROM
		CustomerRole
	INNER JOIN
		[Role]
	ON
		CustomerRole.RoleID = [Role].RoleKey
	INNER JOIN 
		ClientRole 
	ON
		ClientRole.RoleID = CustomerRole.RoleID 
	WHERE
		CustomerRole.CustomerID = @CustomerKey AND ClientRole.ClientID = @ClientID
END
