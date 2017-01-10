CREATE PROCEDURE [dbo].[usp_v4_Gallery_SelectClipID_ByMediaID]
	@IDs VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT IQArchive_Media.ID, ArchiveClip.ClipID
	FROM IQArchive_Media
		INNER JOIN ArchiveClip ON IQArchive_Media._ArchiveMediaID = ArchiveClip.ArchiveClipKey
	WHERE IQArchive_Media.ID IN(SELECT Items FROM Split(@IDs,',')) AND IQArchive_Media.IsActive = 1

END