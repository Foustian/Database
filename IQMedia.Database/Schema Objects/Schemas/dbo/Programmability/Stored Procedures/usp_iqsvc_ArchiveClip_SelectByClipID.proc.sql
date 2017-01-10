-- =============================================
-- Create date: 16/2/2012
-- Description:	Get ArchiveClip By ClipID
-- =============================================
CREATE PROCEDURE [dbo].[usp_iqsvc_ArchiveClip_SelectByClipID] 	
	@ClipID uniqueidentifier
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT
			ArchiveClip.ClipTitle,			
			--ArchiveClip.ClipImageContent,
			ArchiveClip.ThumbnailImagePath,
			ArchiveClip.ArchiveClipKey
	FROM
			ArchiveClip
	WHERE
			ArchiveClip.ClipID=@ClipID AND IsActive=1
			
END
