-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_coresvc_IQ_Ingestion_SelectParamsForOneHourDuration]
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
			StationID, 
			RPLocationIP,
			MediaFIleType
	FROM 
		IQ_Ingestion
	WHERE 
		StationID = @StationID
		And MediaDuration = 'OneHour'
		And ISActive = 1


END
