CREATE PROCEDURE [dbo].[usp_IQAgent_Station_SelectFiveMinute]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT [StationID]	FROM [IQMediaGroup].[dbo].[IQ_Ingestion]
	WHERE MediaDuration = 'FiveMin' AND ISActive = 1
END