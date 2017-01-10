CREATE PROCEDURE [dbo].[usp_isvc_IQ_Station_SelectRadioStationByStationID]
(
	@StationID		VARCHAR(MAX)
)

AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Query NVARCHAR(MAX)
	IF(@StationID IS NULL)
	BEGIN
		SELECT
				IQ_Station.IQ_Station_ID AS StationID,
				IQ_Station.gmt_adj,
				IQ_Station.dst_adj
		FROM
				IQ_Station
		WHERE
				IQ_Station.IsActive = 1
				AND IQ_Station.Format ='RADIO'
				
	END
	ELSE
	BEGIN
		SET @Query='
		Select
				IQ_Station.IQ_Station_ID as StationID,
				IQ_Station.gmt_adj,
				IQ_Station.dst_adj
		From
				IQ_Station
		Where
				IQ_Station.IQ_Station_ID in ('+@StationID+')
				AND IQ_Station.IsActive = 1
				AND IQ_Station.Format =''RADIO'''
				
		EXEC sp_ExecuteSQL @Query
				
	END
END