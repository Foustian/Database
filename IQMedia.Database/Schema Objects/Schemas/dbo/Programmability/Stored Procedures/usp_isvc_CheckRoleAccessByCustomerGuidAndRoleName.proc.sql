CREATE PROCEDURE [dbo].[usp_isvc_CheckRoleAccessByCustomerGuidAndRoleName]
	@CustomerGUID uniqueidentifier, 
	@RoleName varchar(50)
AS
BEGIN
	SELECT 
		CASE WHEN  ClientRole.IsAccess = 1 AND CustomerRole.IsAccess = 1 THEN CONVERT(bit,1) ELSE CONVERT(bit,1) END as RoleAccess
	FROM 
		Role INNER JOIN CustomerRole 
			on CustomerRole.RoleID = Role.RoleKey
			INNER JOIN ClientRole
			   ON ClientRole.RoleID = Role.RoleKey
			   AND 	CustomerRole.RoleID =ClientRole.RoleID 
			 inner join Customer ON 
				Customer.CustomerKey = CustomerRole.CustomerID 
			   AND ClientRole.ClientID=Customer.ClientID
	WHERE
		Customer.CustomerGUID   = @CustomerGUID   
		and RoleName =@RoleName
		AND Role.IsActive = 1 AND ClientRole.IsActive = 1 AND CustomerRole.IsActive = 1		
		
END