-- =============================================
-- Author:		<Author,,Name>
-- Create date: 19 June 2013
-- Description:	Select By Customer
-- =============================================
CREATE PROCEDURE [dbo].[usp_v4_ClipDownload_SelectByCustomer]
(
	@CustomerGUID	UNIQUEIDENTIFIER
)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT	
			ArchiveClip.ClipTitle,
			ClipDownload.IQ_ClipDownload_Key,
			ClipDownload.CustomerGUID,
			ClipDownload.ClipDownloadStatus,
			ClipDownload.ClipFileLocation,
			ClipDownload.ClipDLFormat,
			ClipDownload.ClipDLRequestDateTime,
			ClipDownload.ClipDownLoadedDateTime,
			ClipDownload.IsActive,
			ClipDownload.ClipID
			
	FROM	
			ClipDownload	
				INNER JOIN	ArchiveClip WITH (NOLOCK)
					ON	ClipDownload.ClipID = ArchiveClip.ClipID
					AND	ClipDownload.CustomerGUID = @CustomerGUID
				INNER JOIN	Client
					ON	ArchiveClip.ClientGUID = Client.ClientGUID
				INNER JOIN	Customer
					ON	Client.ClientKey = Customer.ClientID
					AND	Customer.CustomerGUID = @CustomerGUID
	WHERE	
			ClipDownload.ClipDownloadStatus IN (1,2,3)
		AND	ArchiveClip.IsActive = 1
		AND ClipDownload.IsActive = 1
END
