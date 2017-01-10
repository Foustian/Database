CREATE PROCEDURE [dbo].[usp_v4_IQCustomer_RsetPwd_SelectByLoginID]
(
	@LoginID	VARCHAR(300)
)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT
			ID,
			_CustomerGUID,
			Token,
			DateExpired,
			IQCustomer_RsetPwd.IsActive,
			IsUsed
	FROM
			IQCustomer_RsetPwd
				INNER JOIN Customer
					ON	IQCustomer_RsetPwd._CustomerGUID = Customer.CustomerGUID
					AND	CUSTOMER.LoginID = @LoginID
	WHERE
			Customer.IsActive = 1
		AND	IQCustomer_RsetPwd.IsActive = 1
		AND	IQCustomer_RsetPwd.IsUsed = 0

END