CREATE PROCEDURE [dbo].[usp_v4_Customer_SelectAllDropDown]
AS
BEGIN
	
	SELECT
		Customer.CustomerKey,
		Customer.LoginID
	FROM
		Customer 
	WHERE
		Customer.IsActive = 1 AND Customer.MasterCustomerID IS NULL
	ORDER BY LoginID

	SELECT
		RoleKey,
		RoleName,
		UIName,
		Description,
		IsEnabledInSetup,
		GroupName,
		EnabledCustomerIDs,
		HasDefaultAccess
	FROM
		[Role]
	WHERE
		[Role].IsActive = 1 AND [Role].RoleKey != 3
	ORDER BY RoleName

	SELECT
		Client.ClientKey,
		Client.ClientName,
		Client.IsFliq
	FROM
		[Client]
	WHERE
		[Client].IsActive=1 
	ORDER BY Client.ClientName
END
