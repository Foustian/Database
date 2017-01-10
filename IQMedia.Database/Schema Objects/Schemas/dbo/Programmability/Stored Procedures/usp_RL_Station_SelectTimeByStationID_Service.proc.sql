
CREATE PROCEDURE [dbo].[usp_RL_Station_SelectTimeByStationID_Service]
(
	@StationID		varchar(Max)
)

AS
BEGIN
	SET NOCOUNT ON;

	Declare @Query nvarchar(Max)
	
	set @Query='
	Select
			RL_STATION.RL_Station_ID,
			RL_STATION.gmt_adj,
			RL_STATION.dst_adj
	From
			RL_STATION
	Where
			RL_STATION.RL_Station_ID in ('+@StationID+')'
			
	exec sp_ExecuteSQL @Query
    
END
