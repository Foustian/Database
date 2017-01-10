-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_coresvc_IQ_Ingestion_SelectParamsForFiveMinDuration]
	@StationID varchar(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT 
			LogFolder, 
			LogLevel, 
			InputFolder, 
			MediaStagingFolder,
			StagingRootPathID,
			StationID, 
			RPLocationIP,
			DuplicateFolder,
			ProcessedFolder,
			MP4Boxlocation,
			MP4Boxtempdir
	FROM 
		IQ_Ingestion
	WHERE 
		StationID = @StationID
		And MediaDuration = 'FiveMin'
		And ISActive = 1


END
