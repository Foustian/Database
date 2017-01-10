CREATE PROCEDURE [dbo].[usp_V5_Group_Customer_RemoveSubCustomer]
(
	@MasterCustomerID	BIGINT,
	@SubCustomerID		BIGINT,
	@CustomerGUID		UNIQUEIDENTIFIER
)
AS
BEGIN

	SET NOCOUNT ON;

	UPDATE
			Customer
	SET
			MasterCustomerID = NULL,
			ModifiedDate = GETDATE(),
			ModifiedBy = @CustomerGUID
	WHERE
			Customer.CustomerKey = @SubCustomerID
		AND	Customer.MasterCustomerID = @MasterCustomerID

END