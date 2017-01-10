
CREATE PROCEDURE [dbo].[usp_ClipDownload_SelectByCustomer]
(
	@CustomerGUID		uniqueidentifier
)
AS
BEGIN
	SET NOCOUNT ON;
	
	Select
			ClipDownload.IQ_ClipDownload_Key,
			ClipDownload.ClipID,
			ClipDownload.ClipDLFormat,
			ClipDownload.ClipDLRequestDateTime,
			ClipDownload.ClipFileLocation,
			ClipDownload.ClipDownloadStatus,
			ArchiveClip.ClipTitle
	From
			ClipDownload
				inner join ArchiveClip
					on ClipDownload.ClipID=ArchiveClip.ClipID
	Where
			ClipDownload.CustomerGUID=@CustomerGUID and
			ClipDownload.IsActive=1 and
			(
				ClipDownloadStatus!=0 and
				ClipDownloadStatus!=4
			)
			


END
