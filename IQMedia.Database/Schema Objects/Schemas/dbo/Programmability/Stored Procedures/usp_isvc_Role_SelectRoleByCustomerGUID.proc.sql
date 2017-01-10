CREATE PROCEDURE [dbo].[usp_isvc_Role_SelectRoleByCustomerGUID]
(
	@CustomerGUID	UNIQUEIDENTIFIER
)
AS
BEGIN

	SET NOCOUNT ON;


	SELECT
			DISTINCT
			[Role].RoleName,
			(CASE WHEN CustomerRole.IsAccess = 1 AND ClientRole.IsAccess = 1 THEN 1 ELSE 0 END) AS HasAccess
	
	FROM 
			Customer	
				INNER JOIN CustomerRole
					ON	CustomerRole.CustomerID = Customer.CustomerKey
					AND	Customer.CustomerGUID =@CustomerGuid
	
				INNER JOIN [Role]
					ON	[Role].RoleKey = CustomerRole.RoleID
	
				INNER JOIN ClientRole
					ON	Customer.ClientID = ClientRole.ClientID
					AND	ClientRole.RoleID = CustomerRole.RoleID
    
	WHERE	[Role].IsActive = 1
		AND	[Role].RoleName IN ('v4Feeds','v4TV','v4SM','v4NM','v4TW','v4TM','v4BLPM','v4PQ','NielsenData','CompeteData')


END