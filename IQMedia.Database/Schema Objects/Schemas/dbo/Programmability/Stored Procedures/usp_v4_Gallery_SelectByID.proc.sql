CREATE PROCEDURE [dbo].[usp_v4_Gallery_SelectByID]
	@CustomerGUID UNIQUEIDENTIFIER,
	@ID BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ID, Name, Title, [Description], IQGallery_Master.CreatedDate, IQGallery_Master.ModifiedDate
	FROM IQGallery_Master
		INNER JOIN Customer ON IQGallery_Master.CustomerGUID = Customer.CustomerGUID
				INNER JOIN Client ON Customer.ClientID = Client.ClientKey
	WHERE IQGallery_Master.ID = @ID AND IQGallery_Master.IsActive = 1
	
	SELECT _ArchiveMediaID, Col, [Row], IQGallery_ItemType.Name, IQGallery_ItemType.Width, IQGallery_ItemType.Height, MetaData
	FROM IQGallery_Detail
		INNER JOIN IQGallery_ItemType ON IQGallery_ItemType.ID = IQGallery_Detail._TypeID
	WHERE IQGallery_Detail._ID = @ID

END