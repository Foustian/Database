CREATE PROCEDURE [dbo].[usp_v4_Gallery_SelectByCustomerGUID]
	@CustomerGUID UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ID, Name, [Description], IQGallery_Master.CreatedDate
	FROM IQGallery_Master
		INNER JOIN Customer ON IQGallery_Master.CustomerGUID = Customer.CustomerGUID
		INNER JOIN Client ON Customer.ClientID = Client.ClientKey
	WHERE IQGallery_Master.CustomerGUID = @CustomerGUID AND IQGallery_Master.IsActive = 1

END