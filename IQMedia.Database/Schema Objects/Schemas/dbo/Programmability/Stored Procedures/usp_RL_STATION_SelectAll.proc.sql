/*
	Created By 	: templage Generator ( An AmulTek product )
	Created On 	: 3/22/2010
	Purpose		: To Select all data from RL_STATION
*/

CREATE PROCEDURE [dbo].[usp_RL_STATION_SelectAll]
AS
BEGIN
	Select * from RL_STATION where RL_STATION.rl_station_active=1
END