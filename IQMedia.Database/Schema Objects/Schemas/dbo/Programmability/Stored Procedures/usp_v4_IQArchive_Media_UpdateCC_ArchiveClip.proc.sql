-- =============================================
-- Author:		<Author,,Name>
-- Create date: 24 June 2013
-- Description:	Update ClosedCaption(CC) into ArchiveCip table
-- =============================================
CREATE PROCEDURE [dbo].[usp_v4_IQArchive_Media_UpdateCC_ArchiveClip]
	--@ClientGuid			uniqueidentifier,
	@ArchiveClipKey		BIGINT,
	@CC					XML
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE ArchiveClip 
	SET
		 ClosedCaption = @CC,
		 ModifiedDate = GETDATE()
	WHERE ArchiveClipKey = @ArchiveClipKey
	--AND ClientGUID = @ClientGuid
	
	
	UPDATE IQArchive_Media
	SET		Content = CAST(@CC AS NVARCHAR(MAX))
	WHERE	_ArchiveMediaID = @ArchiveClipKey
	AND		MediaType = 'TV' 
	--AND IQArchive_Media.ClientGUID = @ClientGuid

END