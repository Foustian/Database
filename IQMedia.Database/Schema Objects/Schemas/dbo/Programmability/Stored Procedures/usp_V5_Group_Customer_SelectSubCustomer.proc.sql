CREATE PROCEDURE [dbo].[usp_V5_Group_Customer_SelectSubCustomer]
(
	@MasterCustomerID	BIGINT
)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT
			CustomerKey,
			FirstName,
			LastName,
			ClientID,
			LoginID
	FROM
			Customer
	WHERE
			Customer.MasterCustomerID = @MasterCustomerID
		AND	Customer.IsActive = 1

END