
CREATE PROCEDURE [dbo].[usp_v4_Client_SelectClientWithRoleByClientID]
(
	@ClientID BIGINT
)
AS
BEGIN

	SET NOCOUNT ON;

DECLARE @sql NVARCHAR(MAX)
DECLARE @list VARCHAR(MAX)
DECLARE @selectlist VARCHAR(MAX)
SELECT @list =  COALESCE(@list + ',','') +'[' +  Rolename + ']' FROM [ROLE] WHERE IsActive = 'True'
SELECT @selectlist =  COALESCE(@selectlist + ',','') +'isnull(' +  Rolename + ',0) as'''+  RoleName+ '''' FROM [ROLE] WHERE IsActive = 'True'


SET @sql = 'SELECT 
					[ClientKey],
					[ClientName], ' + @selectlist	+ ',
					[IsActive],
					Address1,
					Address2,
					Attention,
					City,
					MasterClient,
					MCID,
					NoOfUser,
					Phone,
					Zip,
					BillFrequencyID,
					BillTypeID,
					IndustryID,
					PricingCodeID,
					StateID,
					playerlogo,
					IsActivePlayerLogo,
					CDNUpload,
					TimeZone,
					IsFliq,
					AnewstipClientID,
					isnull(IQLicense, (SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND Field =''IQLicense'')) as ''IQLicense'',
					cast(isnull(TotalNoOfIQNotification,(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND Field =''TotalNoOfIQNotification'')) as int) as ''NoOfIQNotification'',
					cast(isnull(TotalNoOfIQAgent,(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND Field =''TotalNoOfIQAgent'')) as int) as ''NoOfIQAgent'',
					cast(isnull(OtherOnlineAdRate,(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND Field =''OtherOnlineAdRate'')) as decimal(18,2)) as ''OtherOnlineAdRate'',
					cast(isnull(OnlineNewsAdRate,(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND Field =''OnlineNewsAdRate'')) as decimal(18,2)) as ''OnlineNewsAdRate'',
					cast(isnull(CompeteMultiplier,(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND Field =''CompeteMultiplier'')) as decimal(18,2)) as ''CompeteMultiplier'',
					cast(isnull(URLPercentRead,(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND Field =''URLPercentRead'')) as decimal(18,2)) as ''URLPercentRead'',
					
					cast(isnull(Multiplier,(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND Field =''Multiplier'')) as decimal(18,2)) as ''Multiplier'',
					cast(isnull(CompeteAudienceMultiplier,(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND Field =''CompeteAudienceMultiplier'')) as decimal(18,2)) as ''CompeteAudienceMultiplier'',

					cast(isnull(visibleLRIndustries,(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND Field =''visibleLRIndustries'')) as varchar(max)) as ''visibleLRIndustries'',
					cast(isnull(v4MaxDiscoveryReportItems,(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND Field =''v4MaxDiscoveryReportItems'')) as int) as ''v4MaxDiscoveryReportItems'',
					cast(isnull(v4MaxDiscoveryExportItems,(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND Field =''v4MaxDiscoveryExportItems'')) as int) as ''v4MaxDiscoveryExportItems'',
					cast(isnull(v4MaxDiscoveryHistory,(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND Field =''v4MaxDiscoveryHistory'')) as int) as ''v4MaxDiscoveryHistory'',
					cast(isnull(v4MaxFeedsExportItems,(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND Field =''v4MaxFeedsExportItems'')) as int) as ''v4MaxFeedsExportItems'',
					cast(isnull(v4MaxFeedsReportItems,(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND Field =''v4MaxFeedsReportItems'')) as int) as ''v4MaxFeedsReportItems'',
					cast(isnull(v4MaxLibraryEmailReportItems,(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND Field =''v4MaxLibraryEmailReportItems'')) as int) as ''v4MaxLibraryEmailReportItems'',
					cast(isnull(v4MaxLibraryReportItems,(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND Field =''v4MaxLibraryReportItems'')) as int) as ''v4MaxLibraryReportItems'',
					cast(isnull(UseProminence,(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND FIELD =''UseProminence'')) as int) as ''UseProminence'',
					cast(isnull(UseProminenceMediaValue,(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND FIELD =''UseProminenceMediaValue'')) as int) as ''UseProminenceMediaValue'',
					cast(isnull(ForceCategorySelection,(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND FIELD =''ForceCategorySelection'')) as int) as ''ForceCategorySelection'',
					cast(isnull(MCMediaPublishedTemplateID,(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND FIELD =''MCMediaPublishedTemplateID'')) as int) as ''MCMediaPublishedTemplateID'',
					cast(isnull(MCMediaDefaultEmailTemplateID,(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND FIELD =''MCMediaDefaultEmailTemplateID'')) as int) as ''MCMediaDefaultEmailTemplateID'',
					cast(isnull(IQRawMediaExpiration,(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND FIELD =''IQRawMediaExpiration'')) as int) as ''IQRawMediaExpiration'',
					isnull(LibraryTextType,(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND FIELD =''LibraryTextType'')) as ''LibraryTextType'',
					cast(isnull(DefaultFeedsPageSize,(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND FIELD =''DefaultFeedsPageSize'')) as int) as ''DefaultFeedsPageSize'',
					cast(isnull(DefaultDiscoveryPageSize,(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND FIELD =''DefaultDiscoveryPageSize'')) as int) as ''DefaultDiscoveryPageSize'',
					cast(isnull(DefaultArchivePageSize,(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND FIELD =''DefaultArchivePageSize'')) as int) as ''DefaultArchivePageSize'',
					cast(isnull(ClipEmbedAutoPlay,(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND FIELD =''ClipEmbedAutoPlay'')) as int) as ''ClipEmbedAutoPlay'',
					cast(isnull(DefaultFeedsShowUnread,(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND FIELD =''DefaultFeedsShowUnread'')) as int) as ''DefaultFeedsShowUnread'',
					cast(isnull(UseCustomerEmailDefault,(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND FIELD =''UseCustomerEmailDefault'')) as int) as ''UseCustomerEmailDefault'',
										
					cast(isnull(TVHighThreshold,(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND Field =''TVHighThreshold'')) as decimal(18,2)) as ''TVHighThreshold'',
					cast(isnull(TVLowThreshold,(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND Field =''TVLowThreshold'')) as decimal(18,2)) as ''TVLowThreshold'',
					cast(isnull(NMHighThreshold,(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND Field =''NMHighThreshold'')) as decimal(18,2)) as ''NMHighThreshold'',
					cast(isnull(NMLowThreshold,(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND Field =''NMLowThreshold'')) as decimal(18,2)) as ''NMLowThreshold'',
					cast(isnull(SMHighThreshold,(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND Field =''SMHighThreshold'')) as decimal(18,2)) as ''SMHighThreshold'',
					cast(isnull(SMLowThreshold,(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND Field =''SMLowThreshold'')) as decimal(18,2)) as ''SMLowThreshold'',
					cast(isnull(TwitterHighThreshold,(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND Field =''TwitterHighThreshold'')) as decimal(18,2)) as ''TwitterHighThreshold'',
					cast(isnull(TwitterLowThreshold,(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND Field =''TwitterLowThreshold'')) as decimal(18,2)) as ''TwitterLowThreshold'',
					cast(isnull(PQHighThreshold,(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND Field =''PQHighThreshold'')) as decimal(18,2)) as ''PQHighThreshold'',
					cast(isnull(PQLowThreshold,(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND Field =''PQLowThreshold'')) as decimal(18,2)) as ''PQLowThreshold''
			FROM
			(
				SELECT 
					* 
				FROM
					(
						SELECT     
								Client.ClientName, 
								Client.ClientKey,
								Client.ClientGUID, 		
								Role.RoleName,
								Client.IsActive,
								Client.Address1,
								Client.Address2,
								Client.Attention,
								Client.City,
								Client.MasterClient,
								Client.MCID,
								Client.NoOfUser,
								Client.Phone,
								Client.Zip,
								Client.BillFrequencyID,
								Client.BillTypeID,
								Client.IndustryID,
								Client.PricingCodeID,
								Client.StateID,
								Client.CreatedDate,
								CAST(ClientRole.IsAccess AS INT) AS ''IsAccess'',
								Client.playerlogo,
								cast(isnull(Client.IsActivePlayerLogo,''False'') as bit) as ''IsActivePlayerLogo'',
								CDNUpload,
								TimeZone,
								IsFliq,
								AnewstipClientID
						FROM         
								 Role 
									INNER JOIN	ClientRole 
										ON dbo.Role.RoleKey = dbo.ClientRole.RoleID 
									RIGHT OUTER JOIN Client
										ON ClientRole.ClientID = Client.ClientKey
						WHERE
								ClientKey !=0 and  
								ClientKey ='+ CONVERT(VARCHAR(4),@ClientID) +'
					) as a 
					pivot
					(
						max([IsAccess])
						FOR [RoleName] IN ('	+ @list +')
					)AS B
						LEFT OUTER JOIN IQClient_CustomSettings
								ON B.ClientGUID = IQClient_CustomSettings._ClientGUID
			) as C
			pivot 
			(
				MAX(Value) FOR [Field] IN([IQLicense],[TotalNoOfIQNotification],[TotalNoOfIQAgent],[OtherOnlineAdRate],[CompeteMultiplier],[OnlineNewsAdRate],[URLPercentRead],
								[Multiplier],[CompeteAudienceMultiplier],[visibleLRIndustries],[v4MaxDiscoveryReportItems],[v4MaxDiscoveryExportItems],[v4MaxDiscoveryHistory],[v4MaxFeedsExportItems],[v4MaxFeedsReportItems],[v4MaxLibraryEmailReportItems],
								[v4MaxLibraryReportItems],[TVHighThreshold],[TVLowThreshold],[NMHighThreshold],[NMLowThreshold],
								[SMHighThreshold],[SMLowThreshold],[TwitterHighThreshold],[TwitterLowThreshold],[PQHighThreshold],[PQLowThreshold],[UseProminence],[ForceCategorySelection],
								[MCMediaPublishedTemplateID],[MCMediaDefaultEmailTemplateID],[IQRawMediaExpiration],[LibraryTextType],[DefaultFeedsPageSize],[DefaultDiscoveryPageSize],
								[DefaultArchivePageSize],[UseProminenceMediaValue],[ClipEmbedAutoPlay],[DefaultFeedsShowUnread],[UseCustomerEmailDefault])
			) as D'
	
--	PRINT @sql

	EXEC sp_executesql @sql
END

