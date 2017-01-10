

CREATE PROCEDURE [dbo].[usp_iqsvc_NIELSEN_LOCMTHLY_SelectNielSenDataByRecordFileGuid_2012_09_03]
	@RecordFileGuid uniqueidentifier,
	@IsRawMedia bit,
	@IQ_Start_Point int
AS
BEGIN
	IF @IsRawMedia=0
		BEGIN
			SELECT
				IQ_START_POINT,
				RATINGS_PT
			FROM
				NIELSEN_LOCMTHLY  
					INNER JOIN RL_GUIDS
					ON NIELSEN_LOCMTHLY.IQ_CC_KEY = RL_GUIDS.IQ_CC_Key
			WHERE
				RL_GUIDS.RL_GUID = @RecordFileGuid AND
				IQ_START_POINT = @IQ_Start_Point
		END
	ELSE
		BEGIN
			SELECT
				IQ_START_POINT,
				RATINGS_PT
			FROM
				NIELSEN_LOCMTHLY  
					INNER JOIN RL_GUIDS
					ON NIELSEN_LOCMTHLY.IQ_CC_KEY = RL_GUIDS.IQ_CC_Key
			WHERE
				RL_GUIDS.RL_GUID = @RecordFileGuid
		END
END
