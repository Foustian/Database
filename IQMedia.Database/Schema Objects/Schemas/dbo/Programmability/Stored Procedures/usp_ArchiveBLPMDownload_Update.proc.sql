-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_ArchiveBLPMDownload_Update]
	
	@ID bigint,
	@DownloadStatus tinyint
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT OFF;

    UPDATE 
		ArchiveBLPMDownload
	
	Set
		DownloadStatus = @DownloadStatus,
		DownloadedDatetime = getdate()
	Where ID = @ID
    
    
END