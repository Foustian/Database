CREATE PROCEDURE [dbo].[usp_v4_ArchiveClip_SelectClipTitleByClipID]
(
	@ClipID		UNIQUEIDENTIFIER
)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT
			ClipTitle
	FROM
			ArchiveClip WITH(NOLOCK)
	WHERE
			ClipID = @ClipID
		AND IsActive = 1

END