-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_ArchiveBLPMDownload_Select] 
	@CustomerGuid uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    
    Select
		ArchiveBLPMDownload.*,ArchiveBLPM.Headline
	FROM
		ArchiveBLPMDownload
		INNER JOIN ArchiveBLPM
		ON ArchiveBLPMDownload.MediaID = ArchiveBLPM.ArchiveBLPMKey
	
	Where
		ArchiveBLPMDownload.DownloadStatus < 2
	AND
		ArchiveBLPMDownload.IsActive = 1 
	And
		ArchiveBLPMDownload.CustomerGuid = @CustomerGuid
		
    
END