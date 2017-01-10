-- =============================================
-- Author:		<Author,,Name>
-- Create date: 19 June 2013
-- Description:	Return no of download count by customer
-- =============================================
CREATE PROCEDURE [dbo].[usp_v4_ClipDownload_SelectDownloadLimit]
(
	@CustomerGUID	UNIQUEIDENTIFIER
)
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT	
			COUNT(IQ_ClipDownload_Key) AS DownloadCount 
	FROM 
			[dbo].[ClipDownload]
				INNER JOIN	ArchiveClip
					ON	ClipDownload.ClipID = ArchiveClip.ClipID
					AND	ClipDownload.CustomerGUID = @CustomerGUID
					AND ArchiveClip.CustomerGUID = @CustomerGUID
	WHERE	
			ClipDownloadStatus IN (1,2,3)
		AND	ArchiveClip.IsActive = 1
		AND ClipDownload.IsActive = 1
END
