/*
	Created By 	: templage Generator ( An AmulTek product )
	Created On 	: 3/22/2010
	Purpose		: To Update data in RL_GUIDS
*/

CREATE PROCEDURE USP_RL_GUIDS_Update
(
	@RL_GUIDSKey	BIGINT,
	@RL_Station_ID	VARCHAR(50),
	@RL_Station_Date	DATE,
	@RL_Station_Time	INT,
	@RL_Time_zone	VARCHAR(150),
	@RL_GUID	VARCHAR(150),
	@GMT_Date	DATE,
	@GMT_Time	INT,
	@IQ_CC_Key	VARCHAR(150),
	@GUID_Status	BIT,
	@CreatedBy	VARCHAR(50),
	@ModifiedBy	VARCHAR(50),
	@CreatedDate	DATETIME,
	@ModifiedDate	DATETIME,
	@IsActive	BIT
)
AS
BEGIN
	UPDATE RL_GUIDS SET
	RL_Station_ID = @RL_Station_ID,
 	RL_Station_Date = @RL_Station_Date,
 	RL_Station_Time = @RL_Station_Time,
 	RL_Time_zone = @RL_Time_zone,
 	RL_GUID = @RL_GUID,
 	GMT_Date = @GMT_Date,
 	GMT_Time = @GMT_Time,
 	IQ_CC_Key = @IQ_CC_Key,
 	GUID_Status = @GUID_Status,
 	CreatedBy = @CreatedBy,
 	ModifiedBy = @ModifiedBy,
 	CreatedDate = @CreatedDate,
 	ModifiedDate = @ModifiedDate,
 	IsActive = @IsActive
	WHERE
	RL_GUIDSKey = @RL_GUIDSKey
END