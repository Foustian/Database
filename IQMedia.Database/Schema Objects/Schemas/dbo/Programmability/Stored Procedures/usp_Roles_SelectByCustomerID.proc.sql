-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_Roles_SelectByCustomerID]
	-- Add the parameters for the stored procedure here
	@CustomerID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select 
	Role.RoleName, 
	Customer.CustomerKey,
	Client.ClientKey,
	CustomerRole.CustomerRoleKey,
	ClientRole.ClientRoleKey,
	CustomerRole.RoleID,
	ClientRole.RoleID


 from Customer	

	Inner join Client ON Client.ClientKey = Customer.ClientID
	
	Inner join ClientRole ON ClientRole.ClientID = Client.ClientKey
	
	Inner Join CustomerRole ON Customer.CustomerKey = CustomerRole.CustomerID and CustomerRole.RoleID = ClientRole.RoleID
    
    INNER JOIN dbo.Role ON CustomerRole.RoleID = Role.RoleKey
	
	WHERE
	
	ClientRole.IsActive = 1 and ClientRole.IsAccess=1
	and CustomerRole.IsAccess = 1 and CustomerRole.IsActive = 1 and Customer.IsActive=1
	and Customer.CustomerKey=@CustomerID and Role.IsActive=1
END
