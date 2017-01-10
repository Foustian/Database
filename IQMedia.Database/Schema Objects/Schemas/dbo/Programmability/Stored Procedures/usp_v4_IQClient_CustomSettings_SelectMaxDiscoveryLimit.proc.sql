
CREATE PROCEDURE [dbo].[usp_v4_IQClient_CustomSettings_SelectMaxDiscoveryLimit]
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
				AND IQClient_CustomSettings.Field IN ('v4MaxDiscoveryReportItems','v4MaxDiscoveryExportItems', 'v4MaxDiscoveryHistory')
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
				FOR Field IN([v4MaxDiscoveryReportItems],[v4MaxDiscoveryExportItems],[v4MaxDiscoveryHistory])	
			) b	
END