CREATE PROCEDURE [dbo].[usp_v4_IQClient_CustomSettings_SelectAllSettingsByClientGuid]
	@ClientGuid uniqueidentifier
AS
BEGIN

	;WITH TEMP_ClientSettings AS
	(
		SELECT
				ROW_NUMBER() OVER (PARTITION BY Field ORDER BY IQClient_CustomSettings._ClientGuid desc) as RowNum,
				Field,
				Value,
				_ClientGuid,
				CASE Field 
					WHEN 'MCMediaPublishedTemplateID' THEN (SELECT Name FROM IQ_ReportType WHERE ID = CAST(Value AS INT))
					WHEN 'MCMediaDefaultEmailTemplateID' THEN (SELECT Name FROM IQ_ReportType WHERE ID = CAST(Value AS INT))
					ELSE NULL
				END AS StringValue
		FROM
				IQClient_CustomSettings
		Where
					(IQClient_CustomSettings._ClientGuid=@ClientGuid OR IQClient_CustomSettings._ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))
					AND IQClient_CustomSettings.Field IN 
					(
						'AutoClipDuration',
						'TotalNoOfIQAgent',
						'visibleLRIndustries',
						'v4MAxDiscoveryHistory',
						'v4MaxDiscoveryReportItems',
						'v4MaxDiscoveryExportItems',
						'v4MaxFeedsExportItems',
						'v4MaxFeedsReportItems',
						'v4MaxLibraryEmailReportItems',
						'v4MaxLibraryReportItems',
						'CompeteAudienceMultiplier',
						'CompeteMultiplier',
						'Multiplier',
						'OnlineNewsAdRate',
						'OtherOnlineAdRate',
						'URLPercentRead',
						'TVLowThreshold',
						'TVHighThreshold',
						'NMLowThreshold',
						'NMHighThreshold',
						'SMLowThreshold',
						'SMHighThreshold',
						'TwitterLowThreshold',
						'TwitterHighThreshold',
						'PQLowThreshold',
						'PQHighThreshold',
						'SearchSettings',
						'IQLicense',
						'UseProminence',
						'ForceCategorySelection',
						'MCMediaPublishedTemplateID',
						'MCMediaDefaultEmailTemplateID',
						'MCMediaAvailableTemplates',
						'IQRawMediaExpiration',
						'LibraryTextType',
						'DefaultFeedsPageSize',
						'DefaultDiscoveryPageSize',
						'DefaultArchivePageSize',
						'UseProminenceMediaValue',
						'ClipEmbedAutoPlay',
						'DefaultFeedsShowUnread',
						'UseCustomerEmailDefault'
					)
	)

	SELECT 
			Field,
			Value,
			StringValue,
			Case when _ClientGuid = @ClientGuid then 0  else 1 end as IsDefault
	FROM
			
			TEMP_ClientSettings	
	WHERE	
			RowNum =1
		
END