CREATE PROCEDURE [dbo].[usp_isvc_Customer_SelectForAuthentication]
(
	@LoginID	VARCHAR(300)	
)
AS
BEGIN

	SET NOCOUNT ON;

	Select
			[Customer].[CustomerPassword],
			[Customer].[PasswordAttempts]
	From
			Customer
				Inner join  Client 
					on Client.ClientKey = Customer.ClientID
				inner join CustomerRole
					on customer.CustomerKey = CustomerRole.CustomerID
				inner join ClientRole
					on Client.ClientKey = ClientRole.ClientID
				inner join [Role]
					on CustomerRole.RoleID = [Role].RoleKey
					and ClientRole.RoleID = [Role].RoleKey
	
	Where
			Customer.LoginID = @LoginID	AND
			Customer.IsActive = 1 AND
			Client.IsActive = 1 AND
			[Role].RoleName ='v4API' AND
			ClientRole.IsAccess = 1 AND
			CustomerRole.IsAccess = 1 AND
			CustomerRole.IsActive = 1 AND
			ClientRole.IsActive = 1

END