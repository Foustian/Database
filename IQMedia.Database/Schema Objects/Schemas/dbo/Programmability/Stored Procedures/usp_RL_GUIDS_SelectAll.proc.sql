/*
	Created By 	: templage Generator ( An AmulTek product )
	Created On 	: 3/22/2010
	Purpose		: To Select all data from RL_GUIDS
*/

CREATE PROCEDURE [dbo].[usp_RL_GUIDS_SelectAll]
AS
BEGIN
	SELECT
			RL_GUIDSKey,
			RL_Station_ID,
			RL_Station_Date,
			RL_Station_Time,
			RL_Time_zone,
			RL_GUID,
			GMT_Date,
			GMT_Time,
			IQ_CC_Key,
			GUID_Status 
	FROM	RL_GUIDS 
	WHERE 
			IsActive=1
END