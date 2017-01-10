CREATE PROCEDURE [dbo].[usp_v4_IQClient_CustomImage_Select]
	@ClientGuid uniqueidentifier
AS
BEGIN

	SELECT 
			IQClient_CustomImage.ID,
			IQClient_CustomImage.[Location],
			IQClient_CustomImage.IsDefault,
			IQClient_CustomImage.IsDefaultEmail,
			IQClient_CustomImage.ModifiedDate
	FROM 
			IQClient_CustomImage
	WHERE
			_ClientGUID = @ClientGuid
			AND IsActive = 1
	ORDER BY IQClient_CustomImage.[Location]
END