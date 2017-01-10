CREATE PROCEDURE [dbo].[usp_ArchiveBLPMDownload_SelectByCustomerGuid]
	@CustomerGuid		uniqueidentifier
AS
BEGIN
	SELECT DISTINCT
		ArchiveBLPMDownload.ID
			
	From
			ArchiveBLPMDownload			
	WHERE
		   ArchiveBLPMDownload.CustomerGuid = @CustomerGuid 
		   AND ArchiveBLPMDownload.IsActive = 1
		   AND 	ArchiveBLPMDownload.DownloadStatus != 2
END