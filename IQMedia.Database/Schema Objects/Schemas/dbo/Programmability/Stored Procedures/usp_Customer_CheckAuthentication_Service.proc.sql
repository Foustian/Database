CREATE PROCEDURE [dbo].[usp_Customer_CheckAuthentication_Service]
(
	@Email	varchar(300),
	@Password	varchar(30)
)
AS
BEGIN
	SET NOCOUNT ON;

	
	
	Select
			COUNT(*)
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
			Customer.LoginID = @Email	AND
			Customer.CustomerPassword = @Password COLLATE SQL_Latin1_General_Cp1_CS_AS	AND
			Customer.IsActive = 1 AND
			Client.IsActive = 1 AND
			[Role].RoleName ='v4API' AND
			ClientRole.IsAccess = 1 AND
			CustomerRole.IsAccess = 1 AND
			CustomerRole.IsActive = 1 AND
			ClientRole.IsActive = 1
	

	
END
