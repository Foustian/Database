CREATE PROCEDURE [dbo].[usp_IQClient_CustomSettings_SelectSentimentSettingsByClientGuid]
	@ClientGuid uniqueidentifier
AS
BEGIN

	;WITH TEMP_ClientSettings AS
	(
		SELECT
				ROW_NUMBER() OVER (PARTITION BY Field ORDER BY IQClient_CustomSettings._ClientGuid desc) as RowNum,
				Field,
				Value
		FROM
				IQClient_CustomSettings
		Where
				(IQClient_CustomSettings._ClientGuid=@ClientGuid OR IQClient_CustomSettings._ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))
				AND IQClient_CustomSettings.Field IN ('TVLowThreshold','TVHighThreshold','NMLowThreshold','NMHighThreshold','SMLowThreshold','SMHighThreshold','TwitterLowThreshold','TwitterHighThreshold','PQLowThreshold','PQHighThreshold')
	)


	SELECT 
			*
	FROM
			(
				SELECT 
						Field,
						Value 
				FROM 
						TEMP_ClientSettings	
				WHERE	
						RowNum =1
			) 
			as a pivot 
			(
				MAX(Value) 
				FOR Field IN([TVLowThreshold],[TVHighThreshold],[NMLowThreshold],[NMHighThreshold],[SMLowThreshold],[SMHighThreshold],[TwitterLowThreshold],[TwitterHighThreshold],[PQLowThreshold],[PQHighTreshold])	
			) b			
END