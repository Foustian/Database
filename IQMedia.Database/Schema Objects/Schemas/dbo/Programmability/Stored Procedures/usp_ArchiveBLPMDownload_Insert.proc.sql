-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_ArchiveBLPMDownload_Insert]
	@MediaID bigint,
	@CustomerGuid uniqueidentifier,
	@DownloadStatus tinyint,
	@DownloadLocation varchar(255)
	
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		INSERT INTO	
			ArchiveBLPMDownload 
		(
				MediaID,
				CustomerGUID,
				DownloadStatus,
				DownloadLocation,
				DLRequestDatetime,				
				IsActive
		)		
		VALUES
		(
				@MediaID,
				@CustomerGuid,
				@DownloadStatus,
				@DownloadLocation ,
				GETDATE(),
				1
		
		)
    
END