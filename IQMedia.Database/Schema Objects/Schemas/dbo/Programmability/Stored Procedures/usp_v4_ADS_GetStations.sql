CREATE PROCEDURE [dbo].[usp_v4_ADS_GetStations]
AS
BEGIN
    Select 
		StationID
	From
		IQ_ADS_Station_Control with (nolock) 
	Where 
		ISActive = 1
    
END