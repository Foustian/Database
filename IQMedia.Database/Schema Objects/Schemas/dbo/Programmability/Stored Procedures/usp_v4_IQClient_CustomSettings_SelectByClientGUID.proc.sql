CREATE PROCEDURE [dbo].[usp_v4_IQClient_CustomSettings_SelectByClientGUID]
(
	@ClientGUID		UNIQUEIDENTIFIER
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @MasterClientGUID UNIQUEIDENTIFIER
	
	SELECT	@MasterClientGUID = MasterClient.ClientGUID
	FROM	Client 
	INNER	JOIN Client MasterClient ON MasterClient.ClientKey = Client.MCID
	WHERE	Client.ClientGUID = @ClientGUID
	
	DECLARE @MaxLibraryReportItems AS INT,
			@MaxLibraryEmailReportItems AS INT,
			@v4LibraryRollup bit,
			@MCMediaPublishedTemplateID int,
			@MCMediaDefaultEmailTemplateID int,
			@LibraryTextType varchar(50),
			@DefaultArchivePageSize int,
			@DefaultFeedsPageSize int,
			@DefaultDiscoveryPageSize int,
			@UseProminence bit,
			@UseProminenceMediaValue bit,
			@ClipEmbedAutoPlay BIT,
			@IQTVCountry varchar(max),
			@IQTVRegion	varchar(max),
			@DefaultFeedsShowUnread bit,
			@UseCustomerEmailDefault bit,
			@Industries xml
	
	SELECT	@MaxLibraryReportItems = [Value] 
	FROM	IQClient_CustomSettings 
	WHERE	Field = 'v4MaxLibraryReportItems'
	AND		(_ClientGuid = @ClientGUID OR _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))
	order by _ClientGuid asc
	
	SELECT	@MaxLibraryEmailReportItems = [Value] 
	FROM	IQClient_CustomSettings 
	WHERE	Field = 'v4MaxLibraryEmailReportItems'
	AND		(_ClientGuid = @ClientGUID OR _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))
	order by _ClientGuid asc

	SELECT	@v4LibraryRollup = [Value] 
	FROM	IQClient_CustomSettings 
	WHERE	Field = 'v4LibraryRollup'
	AND		(_ClientGuid = @ClientGUID OR _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))
	order by _ClientGuid asc
	
	SELECT	@MCMediaPublishedTemplateID = [Value] 
	FROM	IQClient_CustomSettings 
	WHERE	Field = 'MCMediaPublishedTemplateID'
	AND		(_ClientGuid = @MasterClientGUID OR _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))
	order by _ClientGuid asc
	
	SELECT	@MCMediaDefaultEmailTemplateID = [Value] 
	FROM	IQClient_CustomSettings 
	WHERE	Field = 'MCMediaDefaultEmailTemplateID'
	AND		(_ClientGuid = @ClientGUID OR _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))
	order by _ClientGuid asc

	SELECT	@LibraryTextType = [Value] 
	FROM	IQClient_CustomSettings 
	WHERE	Field = 'LibraryTextType'
	AND		(_ClientGuid = @ClientGUID OR _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))
	order by _ClientGuid asc

	SELECT	@DefaultArchivePageSize = [Value] 
	FROM	IQClient_CustomSettings 
	WHERE	Field = 'DefaultArchivePageSize'
	AND		(_ClientGuid = @ClientGUID OR _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))
	order by _ClientGuid asc

	SELECT	@DefaultFeedsPageSize = [Value] 
	FROM	IQClient_CustomSettings 
	WHERE	Field = 'DefaultFeedsPageSize'
	AND		(_ClientGuid = @ClientGUID OR _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))
	order by _ClientGuid asc

	SELECT	@DefaultDiscoveryPageSize = [Value] 
	FROM	IQClient_CustomSettings 
	WHERE	Field = 'DefaultDiscoveryPageSize'
	AND		(_ClientGuid = @ClientGUID OR _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))
	order by _ClientGuid asc

	SELECT	@UseProminence = [Value] 
	FROM	IQClient_CustomSettings 
	WHERE	Field = 'UseProminence'
	AND		(_ClientGuid = @ClientGUID OR _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))
	order by _ClientGuid asc

	SELECT	@UseProminenceMediaValue = [Value] 
	FROM	IQClient_CustomSettings 
	WHERE	Field = 'UseProminenceMediaValue'
	AND		(_ClientGuid = @ClientGUID OR _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))
	order by _ClientGuid asc

	SELECT	@ClipEmbedAutoPlay = [Value] 
	FROM	IQClient_CustomSettings 
	WHERE	Field = 'ClipEmbedAutoPlay'
	AND		(_ClientGuid = @ClientGUID OR _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))
	ORDER BY _ClientGuid ASC

	SELECT	@IQTVCountry = [Value] 
	FROM	IQClient_CustomSettings 
	WHERE	Field = 'IQTVCountry'
	AND		(_ClientGuid = @ClientGUID OR _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))
	ORDER BY _ClientGuid ASC

	SELECT	@IQTVRegion = [Value] 
	FROM	IQClient_CustomSettings 
	WHERE	Field = 'IQTVRegion'
	AND		(_ClientGuid = @ClientGUID OR _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))
	ORDER BY _ClientGuid ASC

	SELECT	@DefaultFeedsShowUnread = [Value] 
	FROM	IQClient_CustomSettings 
	WHERE	Field = 'DefaultFeedsShowUnread'
	AND		(_ClientGuid = @ClientGUID OR _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))
	ORDER BY _ClientGuid ASC

	SELECT	@UseCustomerEmailDefault = [Value] 
	FROM	IQClient_CustomSettings 
	WHERE	Field = 'UseCustomerEmailDefault'
	AND		(_ClientGuid = @ClientGUID OR _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))
	ORDER BY _ClientGuid ASC

	
	

	SELECT 
			@MaxLibraryReportItems AS MaxLibraryReportItems,
			@MaxLibraryEmailReportItems AS MaxLibraryEmailReportItems,
			@v4LibraryRollup as v4LibraryRollup,
			@MCMediaPublishedTemplateID as MCMediaPublishedTemplateID,
			@MCMediaDefaultEmailTemplateID as MCMediaDefaultEmailTemplateID,
			@LibraryTextType as LibraryTextType,
			@DefaultArchivePageSize as DefaultArchivePageSize,
			@DefaultFeedsPageSize as DefaultFeedsPageSize,
			@DefaultDiscoveryPageSize as DefaultDiscoveryPageSize,
			@UseProminence as UseProminence,
			@UseProminenceMediaValue as UseProminenceMediaValue,
			@ClipEmbedAutoPlay AS ClipEmbedAutoPlay,
			@IQTVCountry as IQTVCountry,
			@IQTVRegion as IQTVRegion,
			@DefaultFeedsShowUnread as DefaultFeedsShowUnread,
			@UseCustomerEmailDefault as UseCustomerEmailDefault
			

	Select @Industries = [Value] 
	from IQClient_CustomSettings
	where Field = 'VisibleLRIndustries'
	And (_ClientGuid = @ClientGUID OR _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))
	order by _ClientGuid asc

	declare @isAllowAll varchar(50)
	set @isAllowAll = @Industries.value('(/VisibleLRIndustries/@IsAllowAll)[1]', 'varchar(50)')

	if @isAllowAll is null or @isAllowAll ='false'
	begin
	select IQ_LR_Industry.ID
	from IQ_LR_Industry 
	inner join @Industries.nodes('/VisibleLRIndustries/Industries/IQ_Industry/ID') as Industry(ID)
	on Industry.ID.value('.','int')=IQ_LR_Industry.ID

	select  IQ_LR_Brand.ID
	from IQ_LR_Brand 
	inner join @industries.nodes('/VisibleLRIndustries/Industries/IQ_Industry/ID') as Industry(ID)
	on Industry.ID.value('.','int')=_IndustryID
	order by Brand asc

	end

	 
END
