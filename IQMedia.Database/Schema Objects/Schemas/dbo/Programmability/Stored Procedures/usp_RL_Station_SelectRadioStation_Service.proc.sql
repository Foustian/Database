
CREATE PROCEDURE [usp_RL_Station_SelectRadioStation_Service]

AS
BEGIN	
	SET NOCOUNT ON;
	
	Select
			RL_STATION.dma_name,
			RL_STATION.dma_num,
			RL_STATION.RL_Station_ID			
	From
			RL_STATION
	Where
			RL_STATION.rl_station_active=1 and
			RL_STATION.rl_format='RADIO'

    
END
