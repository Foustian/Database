/*
	Created By 	: templage Generator ( An AmulTek product )
	Created On 	: 3/22/2010
	Purpose		: To select data by Primary key in RL_GUIDS
*/

CREATE PROCEDURE [dbo].[usp_RL_GUIDS_SelectByID]
(
	@RL_GUIDSKey	BIGINT
)
AS
BEGIN
	SELECT * FROM RL_GUIDS WHERE 
	RL_GUIDSKey = @RL_GUIDSKey  and  IsActive=1
END