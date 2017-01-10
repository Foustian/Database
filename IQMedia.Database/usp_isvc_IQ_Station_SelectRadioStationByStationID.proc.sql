CREATE PROCEDURE [dbo].[usp_isvc_IQ_Station_SelectRadioStationByStationID]
	@StationID		varchar(Max)
AS
BEGIN
	SET NOCOUNT ON;

	Declare @Query nvarchar(Max)
	IF(@StationID IS NULL)
	BEGIN
		Select
				IQ_Station.IQ_Station_ID as StationID,
				IQ_Station.gmt_adj,
				IQ_Station.dst_adj
		From
				IQ_Station
		WHERE
				IQ_Station.IsActive = 1
				and IQ_Station.Format ='RADIO'
				
	END
	ELSE
	BEGIN
		set @Query='
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
				
		exec sp_ExecuteSQL @Query
				
	END
END