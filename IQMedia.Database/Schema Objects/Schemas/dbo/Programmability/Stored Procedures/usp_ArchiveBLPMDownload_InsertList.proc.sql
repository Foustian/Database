-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_ArchiveBLPMDownload_InsertList]
	@CustomerGuid	uniqueidentifier,
	@XmlData		xml
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT OFF;

      INSERT INTO ArchiveBLPMDownload(
			CustomerGuid,
			MediaID,
			DownloadStatus,
			DownloadLocation,
			DLRequestDateTime,
			DownloadedDatetime,
			IsActive)
	SELECT
			@CustomerGuid,
			XmlTbl.d.value('@MediaID','varchar(50)') as ArticleID,
			1,
			ISNULL(IQCore_RootPath.StoragePath + ArchiveBLPM.FileLocation,''),
			getdate(),'',1
	FROM
			ArchiveBLPM
				INNER JOIN @XmlData.nodes('ArticleBLPMDownload/Media') as XmlTbl(d)
					ON ArchiveBLPM.ArchiveBLPMKey = XmlTbl.d.value('@MediaID','varchar(50)')
				INNER JOIN IQcore_RootPath
					ON ArchiveBLPM.RPID = IQcore_RootPath.ID
	WHERE 
			XmlTbl.d.value('@MediaID','varchar(50)') NOT IN
			(
				Select 
						DISTINCT MediaID
				From
						ArchiveBLPMDownload
				Where
						MediaID = XmlTbl.d.value('@MediaID','varchar(50)') AND 			
						CustomerGUID=@CustomerGuid AND						
						DownloadStatus=1 AND IsActive=1
		)
		
END