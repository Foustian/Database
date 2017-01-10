-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_ArchiveClip_SelectByClipID] 
	-- Add the parameters for the stored procedure here
	@ClipID uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    
    SELECT
		ArchiveClipKey,
		ClipID,
		ClipDate,
		ClipLogo,
		ClipTitle,
		FirstName,
		ClipCreationDate,
		ClosedCaption,
		[Keywords],
		[Description],
		CustomerID,
		ThumbnailImagePath,
		--ClipImageContent,
		CustomerGUID,
		CategoryGUID,
		SubCategory1GUID,
		SubCategory2GUID,
		SubCategory3GUID,
		Rating
	
	FROM
		ArchiveClip WITH (NOLOCK)
	WHERE
		ArchiveClip.ClipID=@ClipID and ArchiveClip.IsActive = 1
END
