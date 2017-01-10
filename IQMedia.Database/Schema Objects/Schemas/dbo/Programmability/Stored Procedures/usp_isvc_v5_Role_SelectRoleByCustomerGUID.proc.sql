CREATE PROCEDURE [dbo].[usp_isvc_v5_Role_SelectFeedsRoleByCustomerGUID]
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
			[Role]
				INNER JOIN CustomerRole
					ON	[Role].RoleKey = CustomerRole.RoleID

				INNER JOIN	Customer					
					ON	CustomerRole.CustomerID = Customer.CustomerKey
					AND	Customer.CustomerGUID =@CustomerGuid					
	
				INNER JOIN ClientRole
					ON	Customer.ClientID = ClientRole.ClientID
					AND	ClientRole.RoleID = CustomerRole.RoleID
    
	WHERE	[Role].IsActive = 1
		AND	[Role].RoleName IN ('v4Feeds','NielsenData','CompeteData')


END