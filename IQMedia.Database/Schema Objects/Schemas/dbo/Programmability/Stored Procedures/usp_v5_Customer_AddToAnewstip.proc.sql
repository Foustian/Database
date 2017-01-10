CREATE PROCEDURE [dbo].[usp_v5_Customer_AddToAnewstip]
	@CustomerKey BIGINT,
	@AnewstipUserID VARCHAR(300)
AS
BEGIN
	UPDATE IQMediaGroup.dbo.Customer
	SET AnewstipUserID = @AnewstipUserID
	WHERE CustomerKey = @CustomerKey
END
