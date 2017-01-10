/*
	Created By 	: templage Generator ( An AmulTek product )
	Created On 	: 3/22/2010
	Purpose		: To Select all data from RL_STATION Which is TV and IsActive = 1
*/

CREATE PROCEDURE [dbo].[usp_RL_STATION_SelectAllTVStation]
AS
BEGIN
	
	SELECT 
			RL_Stationkey ,
			RL_Station_ID,
			rl_format,
			station_call_sign,
			rl_station_active,
			time_zone,
			dma_name,
			dma_num,
			gmt_adj,
			dst_adj
	
	FROM 
			RL_STATION 
	WHERE RL_STATION.rl_format = 'TV' 
	AND RL_STATION.rl_station_active=1
END
