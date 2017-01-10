CREATE PROCEDURE [dbo].[usp_v4_Client_Update]
(
	@ClientName VARCHAR(50),
	@ClientKey BIGINT, --Output,
	@Active BIT,
	@PricingCodeID		BIGINT,
	@BillFrequencyID	BIGINT,
	@BillTypeID         BIGINT,
	@IndustryID			BIGINT,
	@StateID			BIGINT,
	@Address1			VARCHAR(MAX),
	@Address2			VARCHAR(MAX),
	@City				VARCHAR(50),
	@Zip				VARCHAR(5),
	@Attention			VARCHAR(50),
	@Phone				VARCHAR(15),
	@MasterClient		VARCHAR(50),
	@MCID				BIGINT,
	@NoOfUser			INT,
	@ModifiedDate		DATETIME,
	@PlayerLogo			VARCHAR(MAX),
	@IsActivePlayerLogo		BIT,
	@NoOfIQNotification		TINYINT,
	@NoOfIQAgnet			SMALLINT,
	@CompeteMultiplier		DECIMAL(18,2),
	@OnlineNewsAdRate		DECIMAL(18,2),
	@OtherOnlineAdRate		DECIMAL(18,2),
	@UrlPercentRead		DECIMAL(18,2),
	@ClientRoles		XML,
	@NotificationStatus		INT OUT,
	@IQAgentStatus			INT OUT,
	@Status				BIT OUT,
	@IsCDNUpload		BIT,
	@TimeZone			VARCHAR(5),
	@MultiPlier			DECIMAL(18,2),
	@CompeteAudienceMultiplier	DECIMAL(18,2),
	@visibleLRIndustries VARCHAR(MAX),
	@v4MaxDiscoveryHistory INT,
	@v4MaxDiscoveryReportItems INT,
	@v4MaxDiscoveryExportItems INT,
	@v4MaxFeedsExportItems INT,
	@v4MaxFeedsReportItems INT,
	@v4MaxLibraryEmailReportItems INT,
	@v4MaxLibraryReportItems INT,
	@TVHighThreshold DECIMAL(18,2),
	@TVLowThreshold DECIMAL(18,2),
	@NMHighThreshold DECIMAL(18,2),
	@NMLowThreshold DECIMAL(18,2),
	@SMHighThreshold DECIMAL(18,2),
	@SMLowThreshold DECIMAL(18,2),
	@TwitterHighThreshold DECIMAL(18,2),
	@TwitterLowThreshold DECIMAL(18,2),
	@PQHighThreshold DECIMAL(18,2),
	@PQLowThreshold DECIMAL(18,2),
	@IsActive BIT,
	@IsFliq BIT,
	@UseProminence BIT,
	@ForceCategorySelection BIT,
	@MCMediaPublishedTemplateID INT,
	@MCMediaDefaultEmailTemplateID INT,
	@IQRawMediaExpiration INT,
	@LibraryTextType VARCHAR(50),
	@DefaultFeedsPageSize INT,
	@DefaultDiscoveryPageSize INT,
	@DefaultArchivePageSize INT,
	@IQLicense VARCHAR(MAX),
	@UseProminenceMediaValue BIT,
	@IsClientExist BIT OUT,
	@ClipEmbedAutoPlay BIT,
	@DefaultFeedsShowUnread BIT,
	@UseCustomerEmailDefault BIT
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
     
   EXEC usp_v4_Client_ImageCheck @PlayerLogo,@ClientKey,@Status OUTPUT
   SET @NotificationStatus = 0;
   SET @IQAgentStatus = 0;
   SET @IsClientExist = 0;
   IF(@Status = 0)
   BEGIN
		DECLARE @ClientCount INT
		SELECT @ClientCount = COUNT(*) FROM Client WHERE ClientName=@ClientName AND ClientKey<>@ClientKey
		IF @ClientCount = 0 
		BEGIN 
			PRINT @ClientKey
						
			DECLARE @ClientGUID UNIQUEIDENTIFIER
			DECLARE @TotalNotificationCount TINYINT
			DECLARE @TotalIQAgentCount TINYINT
							
			SELECT @ClientGUID =  ClientGUID FROM Client WHERE ClientKey = @ClientKey
						
			SELECT @TotalNotificationCount = 
				MAX(TotalCount)
				FROM
					(
							SELECT COUNT(*) AS 'TotalCount'
							FROM
								IQNotificationSettings
								--Inner JOIN IQAgent_SearchRequest
								--ON IQNotificationSettings.SearchRequestID = IQAgent_SearchRequest.ID
											
								WHERE IQNotificationSettings.IsActive = 1 --AND IQAgent_SearchRequest.IsActive = 1
								AND IQNotificationSettings.ClientGUID = @ClientGUID
								--Group By SearchRequestID
					)a

			 SELECT @TotalIQAgentCount = COUNT(*) FROM IQAgent_SearchRequest WHERE IQAgent_SearchRequest.ClientGUID = @ClientGUID AND IQAgent_SearchRequest.IsActive = 1;
		
		
			IF(ISNULL(@TotalNotificationCount,0) > @NoOfIQNotification)
			BEGIN
				SET @NotificationStatus = -2
			END					    
			ELSE IF (ISNULL(@TotalIQAgentCount,0) > @NoOfIQAgnet)
			BEGIN
				SET @IQAgentStatus = -2;
			END
			ELSE
			BEGIN

				DECLARE @dst DECIMAL(18,2)
				DECLARE @gmt DECIMAL(18,2)
	  
				  SET @dst = 1
				  IF(@TimeZone = 'CST')
				  BEGIN
					SET @gmt = -6.0
				  END
				  ELSE IF(@TimeZone = 'EST')
				  BEGIN
					SET @gmt = -5.0
				  END
				  ELSE IF(@TimeZone = 'MST')
				  BEGIN
					SET @gmt = -7.0
				  END
				  ELSE IF(@TimeZone = 'PST')
				  BEGIN
					SET @gmt = -8.0
				  END


				UPDATE Client 
				SET
					ClientName=@ClientName,
					--IsActive=@Active,
					PricingCodeID=@PricingCodeID,		
					BillFrequencyID=@BillFrequencyID,	
					BillTypeID=@BillTypeID,
					IndustryID=@IndustryID,			
					StateID=@StateID,			
					Address1=@Address1,			
					Address2=@Address2,			
					City=@City,				
					Zip=@Zip,				
					Attention=@Attention,			
					Phone=@Phone,		
					MasterClient=@MasterClient,		
					MCID = CASE WHEN ISNULL(@MCID,0) = 0 THEN @ClientKey ELSE @MCID END,
					NoOfUser=@NoOfUser,	
					ModifiedDate = @ModifiedDate,
					PlayerLogo = CASE WHEN ISNULL(@PlayerLogo,'') = '' THEN PlayerLogo ELSE @PlayerLogo END,
					IsActivePlayerLogo = @IsActivePlayerLogo,
					CDNUpload = @IsCDNUpload,
					TimeZone = @TimeZone,
					gmt = @gmt,
					dst = @dst,
					IsActive = @IsActive,
					IsFliq = @IsFliq
				WHERE
									
					ClientKey=@ClientKey	

				IF(@IsFliq = 0 OR @IsActive = 0)
				BEGIN
					UPDATE
							fliQ_Customer 
					SET
							IsActive = 0
					WHERE
							ClientID = @ClientKey
							AND IsActive  = 1
				END
				
				IF(@IQLicense IS NOT NULL)
				BEGIN
					IF(EXISTS(SELECT VALUE FROM IQClient_CustomSettings WHERE _ClientGUID = @ClientGUID AND Field = 'IQLicense' ))
						BEGIN
							UPDATE  IQClient_CustomSettings
							SET VALUE = @IQLicense
							WHERE _ClientGuid = @ClientGUID AND Field = 'IQLicense'
						END
					ELSE
						BEGIN
							INSERT INTO IQClient_CustomSettings
								VALUES
								(@ClientGUID, 'IQLicense', @IQLicense)
						END		
				END

				IF(@CompeteMultiplier IS NOT NULL)
				BEGIN
					IF(EXISTS(SELECT VALUE FROM IQClient_CustomSettings WHERE _ClientGUID = @ClientGUID AND Field = 'CompeteMultiplier' ))
						BEGIN
							UPDATE  IQClient_CustomSettings
							SET VALUE = @CompeteMultiplier
							WHERE _ClientGuid = @ClientGUID AND Field = 'CompeteMultiplier'
						END
					ELSE
						BEGIN
							INSERT INTO IQClient_CustomSettings
								VALUES
								(@ClientGUID,'CompeteMultiplier',@CompeteMultiplier)
						END		
				END

				IF(@OtherOnlineAdRate IS NOT NULL)
				BEGIN
					IF(EXISTS(SELECT VALUE FROM IQClient_CustomSettings WHERE _ClientGUID = @ClientGUID AND Field = 'OtherOnlineAdRate' ))
						BEGIN
							UPDATE  IQClient_CustomSettings
							SET VALUE = @OtherOnlineAdRate
							WHERE _ClientGuid = @ClientGUID AND Field = 'OtherOnlineAdRate'
						END
					ELSE
						BEGIN
							INSERT INTO IQClient_CustomSettings
								VALUES
								(@ClientGUID,'OtherOnlineAdRate',@OtherOnlineAdRate)
						END		
				END

				IF(@OnlineNewsAdRate IS NOT NULL)
				BEGIN
					IF(EXISTS(SELECT VALUE FROM IQClient_CustomSettings WHERE _ClientGUID = @ClientGUID AND Field = 'OnlineNewsAdRate' ))
						BEGIN
							UPDATE  IQClient_CustomSettings
							SET VALUE = @OnlineNewsAdRate
							WHERE _ClientGuid = @ClientGUID AND Field = 'OnlineNewsAdRate'
						END
					ELSE
						BEGIN
							INSERT INTO IQClient_CustomSettings
								VALUES
								(@ClientGUID,'OnlineNewsAdRate',@OnlineNewsAdRate)
						END		
				END
				
				IF(@UrlPercentRead IS NOT NULL)
				BEGIN
					IF(EXISTS(SELECT VALUE FROM IQClient_CustomSettings WHERE _ClientGUID = @ClientGUID AND Field = 'URLPercentRead' ))
						BEGIN
							UPDATE  IQClient_CustomSettings
							SET VALUE = @UrlPercentRead
							WHERE _ClientGuid = @ClientGUID AND Field = 'URLPercentRead'
						END
					ELSE
						BEGIN
							INSERT INTO IQClient_CustomSettings
								VALUES
								(@ClientGUID,'URLPercentRead',@UrlPercentRead)
						END		
				END
				

				IF(@NoOfIQAgnet IS NOT NULL)
				BEGIN
					IF(EXISTS(SELECT VALUE FROM IQClient_CustomSettings WHERE _ClientGuid = @ClientGUID AND Field ='TotalNoOfIQAgent'))
					BEGIN
						UPDATE IQClient_CustomSettings
						SET VALUE = @NoOfIQAgnet
						WHERE _ClientGuid = @ClientGUID AND Field = 'TotalNoOfIQAgent'
					END
					ELSE
					BEGIN
						INSERT INTO IQClient_CustomSettings(_ClientGuid,Field,VALUE) VALUES(@ClientGUID,'TotalNoOfIQAgent',@NoOfIQAgnet);
					END
				END

				IF(@NoOfIQNotification IS NOT NULL)
				BEGIN
					IF(EXISTS(SELECT VALUE FROM IQClient_CustomSettings WHERE _ClientGUID = @ClientGUID AND Field = 'TotalNoOfIQNotification' ))
						BEGIN
							UPDATE  IQClient_CustomSettings
							SET VALUE = @NoOfIQNotification
							WHERE _ClientGuid = @ClientGUID AND Field = 'TotalNoOfIQNotification'
						END
					ELSE
						BEGIN
							INSERT INTO IQClient_CustomSettings
								VALUES
								(@ClientGUID,'TotalNoOfIQNotification',@NoOfIQNotification)
						END
					END		
				END

				IF(@MultiPlier IS NOT NULL)
				BEGIN
					IF(EXISTS(SELECT VALUE FROM IQClient_CustomSettings WHERE _ClientGUID = @ClientGUID AND Field = 'Multiplier' ))
						BEGIN
							UPDATE  IQClient_CustomSettings
							SET VALUE = @MultiPlier
							WHERE _ClientGuid = @ClientGUID AND Field = 'Multiplier'
						END
					ELSE
						BEGIN
							INSERT INTO IQClient_CustomSettings
								VALUES
								(@ClientGUID,'Multiplier',@MultiPlier)
						END	
				END

				IF(@CompeteAudienceMultiplier IS NOT NULL)
				BEGIN
					IF(EXISTS(SELECT VALUE FROM IQClient_CustomSettings WHERE _ClientGUID = @ClientGUID AND Field = 'CompeteAudienceMultiplier' ))
						BEGIN
							UPDATE  IQClient_CustomSettings
							SET VALUE = @CompeteAudienceMultiplier
							WHERE _ClientGuid = @ClientGUID AND Field = 'CompeteAudienceMultiplier'
						END
					ELSE
						BEGIN
							INSERT INTO IQClient_CustomSettings
							VALUES
							(@ClientGUID,'CompeteAudienceMultiplier',@CompeteAudienceMultiplier)
						END
					END

			IF(@visibleLRIndustries IS NOT NULL)
				BEGIN
					IF(EXISTS(SELECT VALUE FROM IQClient_CustomSettings WHERE _ClientGUID = @ClientGUID AND Field = 'visibleLRIndustries' ))
						BEGIN
							UPDATE  IQClient_CustomSettings
							SET VALUE = @visibleLRIndustries
							WHERE _ClientGuid = @ClientGUID AND Field = 'visibleLRIndustries'
						END
					ELSE
						BEGIN
							INSERT INTO IQClient_CustomSettings
							VALUES
							(@ClientGUID,'visibleLRIndustries',@visibleLRIndustries)
						END
				END

				IF(@v4MaxDiscoveryReportItems IS NOT NULL)
				BEGIN
					IF(EXISTS(SELECT VALUE FROM IQClient_CustomSettings WHERE _ClientGUID = @ClientGUID AND Field = 'v4MaxDiscoveryReportItems' ))
						BEGIN
							UPDATE  IQClient_CustomSettings
							SET VALUE = @v4MaxDiscoveryReportItems
							WHERE _ClientGuid = @ClientGUID AND Field = 'v4MaxDiscoveryReportItems'
						END
					ELSE
						BEGIN
							INSERT INTO IQClient_CustomSettings
							VALUES
							(@ClientGUID,'v4MaxDiscoveryReportItems',@v4MaxDiscoveryReportItems)
						END
				END

				IF(@v4MaxDiscoveryHistory IS NOT NULL)
				BEGIN
					IF(EXISTS(SELECT VALUE FROM IQClient_CustomSettings WHERE _ClientGUID = @ClientGUID AND Field = 'v4MaxDiscoveryHistory' ))
						BEGIN
							UPDATE  IQClient_CustomSettings
							SET VALUE = @v4MaxDiscoveryHistory
							WHERE _ClientGuid = @ClientGUID AND Field = 'v4MaxDiscoveryHistory'
						END
					ELSE
						BEGIN
							INSERT INTO IQClient_CustomSettings
							VALUES
							(@ClientGUID,'v4MaxDiscoveryHistory',@v4MaxDiscoveryHistory)
						END
				END
				
				IF(@v4MaxDiscoveryExportItems IS NOT NULL)
				BEGIN
					IF(EXISTS(SELECT VALUE FROM IQClient_CustomSettings WHERE _ClientGUID = @ClientGUID AND Field = 'v4MaxDiscoveryExportItems' ))
						BEGIN
							UPDATE  IQClient_CustomSettings
							SET VALUE = @v4MaxDiscoveryExportItems
							WHERE _ClientGuid = @ClientGUID AND Field = 'v4MaxDiscoveryExportItems'
						END
					ELSE
						BEGIN
							INSERT INTO IQClient_CustomSettings
							VALUES
							(@ClientGUID,'v4MaxDiscoveryExportItems',@v4MaxDiscoveryExportItems)
						END
				END

				IF(@v4MaxFeedsExportItems IS NOT NULL)
				BEGIN
					IF(EXISTS(SELECT VALUE FROM IQClient_CustomSettings WHERE _ClientGUID = @ClientGUID AND Field = 'v4MaxFeedsExportItems' ))
						BEGIN
							UPDATE  IQClient_CustomSettings
							SET VALUE = @v4MaxFeedsExportItems
							WHERE _ClientGuid = @ClientGUID AND Field = 'v4MaxFeedsExportItems'
						END
					ELSE
						BEGIN
							INSERT INTO IQClient_CustomSettings
							VALUES
							(@ClientGUID,'v4MaxFeedsExportItems',@v4MaxFeedsExportItems)
						END
				END

				IF(@v4MaxFeedsReportItems IS NOT NULL)
				BEGIN
					IF(EXISTS(SELECT VALUE FROM IQClient_CustomSettings WHERE _ClientGUID = @ClientGUID AND Field = 'v4MaxFeedsReportItems' ))
						BEGIN
							UPDATE  IQClient_CustomSettings
							SET VALUE = @v4MaxFeedsReportItems
							WHERE _ClientGuid = @ClientGUID AND Field = 'v4MaxFeedsReportItems'
						END
					ELSE
						BEGIN
							INSERT INTO IQClient_CustomSettings
							VALUES
							(@ClientGUID,'v4MaxFeedsReportItems',@v4MaxFeedsReportItems)
						END
				END

				IF(@v4MaxLibraryEmailReportItems IS NOT NULL)
				BEGIN
					IF(EXISTS(SELECT VALUE FROM IQClient_CustomSettings WHERE _ClientGUID = @ClientGUID AND Field = 'v4MaxLibraryEmailReportItems' ))
						BEGIN
							UPDATE  IQClient_CustomSettings
							SET VALUE = @v4MaxLibraryEmailReportItems
							WHERE _ClientGuid = @ClientGUID AND Field = 'v4MaxLibraryEmailReportItems'
						END
					ELSE
						BEGIN
							INSERT INTO IQClient_CustomSettings
							VALUES
							(@ClientGUID,'v4MaxLibraryEmailReportItems',@v4MaxLibraryEmailReportItems)
						END
				END

				IF(@v4MaxLibraryReportItems IS NOT NULL)
				BEGIN
					IF(EXISTS(SELECT VALUE FROM IQClient_CustomSettings WHERE _ClientGUID = @ClientGUID AND Field = 'v4MaxLibraryReportItems' ))
						BEGIN
							UPDATE  IQClient_CustomSettings
							SET VALUE = @v4MaxLibraryReportItems
							WHERE _ClientGuid = @ClientGUID AND Field = 'v4MaxLibraryReportItems'
						END
					ELSE
						BEGIN
							INSERT INTO IQClient_CustomSettings
							VALUES
							(@ClientGUID,'v4MaxLibraryReportItems',@v4MaxLibraryReportItems)
						END
				END

				IF(@TVHighThreshold IS NOT NULL)
				BEGIN
					IF(EXISTS(SELECT VALUE FROM IQClient_CustomSettings WHERE _ClientGUID = @ClientGUID AND Field = 'TVHighThreshold' ))
						BEGIN
							UPDATE  IQClient_CustomSettings
							SET VALUE = @TVHighThreshold
							WHERE _ClientGuid = @ClientGUID AND Field = 'TVHighThreshold'
						END
					ELSE
						BEGIN
							INSERT INTO IQClient_CustomSettings
							VALUES
							(@ClientGUID,'TVHighThreshold',@TVHighThreshold)
						END
				END

				IF(@TVLowThreshold IS NOT NULL)
				BEGIN
					IF(EXISTS(SELECT VALUE FROM IQClient_CustomSettings WHERE _ClientGUID = @ClientGUID AND Field = 'TVLowThreshold' ))
						BEGIN
							UPDATE  IQClient_CustomSettings
							SET VALUE = @TVLowThreshold
							WHERE _ClientGuid = @ClientGUID AND Field = 'TVLowThreshold'
						END
					ELSE
						BEGIN
							INSERT INTO IQClient_CustomSettings
							VALUES
							(@ClientGUID,'TVLowThreshold',@TVLowThreshold)
						END
				END

				IF(@NMHighThreshold IS NOT NULL)
				BEGIN
					IF(EXISTS(SELECT VALUE FROM IQClient_CustomSettings WHERE _ClientGUID = @ClientGUID AND Field = 'NMHighThreshold' ))
						BEGIN
							UPDATE  IQClient_CustomSettings
							SET VALUE = @NMHighThreshold
							WHERE _ClientGuid = @ClientGUID AND Field = 'NMHighThreshold'
						END
					ELSE
						BEGIN
							INSERT INTO IQClient_CustomSettings
							VALUES
							(@ClientGUID,'NMHighThreshold',@NMHighThreshold)
						END
				END

				IF(@NMLowThreshold IS NOT NULL)
				BEGIN
					IF(EXISTS(SELECT VALUE FROM IQClient_CustomSettings WHERE _ClientGUID = @ClientGUID AND Field = 'NMLowThreshold' ))
						BEGIN
							UPDATE  IQClient_CustomSettings
							SET VALUE = @NMLowThreshold
							WHERE _ClientGuid = @ClientGUID AND Field = 'NMLowThreshold'
						END
					ELSE
						BEGIN
							INSERT INTO IQClient_CustomSettings
							VALUES
							(@ClientGUID,'NMLowThreshold',@NMLowThreshold)
						END
				END

				IF(@SMHighThreshold IS NOT NULL)
				BEGIN
					IF(EXISTS(SELECT VALUE FROM IQClient_CustomSettings WHERE _ClientGUID = @ClientGUID AND Field = 'SMHighThreshold' ))
						BEGIN
							UPDATE  IQClient_CustomSettings
							SET VALUE = @SMHighThreshold
							WHERE _ClientGuid = @ClientGUID AND Field = 'SMHighThreshold'
						END
					ELSE
						BEGIN
							INSERT INTO IQClient_CustomSettings
							VALUES
							(@ClientGUID,'SMHighThreshold',@SMHighThreshold)
						END

				END

				IF(@SMLowThreshold IS NOT NULL)
				BEGIN
					IF(EXISTS(SELECT VALUE FROM IQClient_CustomSettings WHERE _ClientGUID = @ClientGUID AND Field = 'SMLowThreshold' ))
						BEGIN
							UPDATE  IQClient_CustomSettings
							SET VALUE = @SMLowThreshold
							WHERE _ClientGuid = @ClientGUID AND Field = 'SMLowThreshold'
						END
					ELSE
						BEGIN
							INSERT INTO IQClient_CustomSettings
							VALUES
							(@ClientGUID,'SMLowThreshold',@SMLowThreshold)
						END
				END

				IF(@TwitterHighThreshold IS NOT NULL)
				BEGIN
					IF(EXISTS(SELECT VALUE FROM IQClient_CustomSettings WHERE _ClientGUID = @ClientGUID AND Field = 'TwitterHighThreshold' ))
						BEGIN
							UPDATE  IQClient_CustomSettings
							SET VALUE = @TwitterHighThreshold
							WHERE _ClientGuid = @ClientGUID AND Field = 'TwitterHighThreshold'
						END
					ELSE
						BEGIN
							INSERT INTO IQClient_CustomSettings
							VALUES
							(@ClientGUID,'TwitterHighThreshold',@TwitterHighThreshold)
						END

				END

				IF(@TwitterLowThreshold IS NOT NULL)
				BEGIN
					IF(EXISTS(SELECT VALUE FROM IQClient_CustomSettings WHERE _ClientGUID = @ClientGUID AND Field = 'TwitterLowThreshold' ))
						BEGIN
							UPDATE  IQClient_CustomSettings
							SET VALUE = @TwitterLowThreshold
							WHERE _ClientGuid = @ClientGUID AND Field = 'TwitterLowThreshold'
						END
					ELSE
						BEGIN
							INSERT INTO IQClient_CustomSettings
							VALUES
							(@ClientGUID,'TwitterLowThreshold',@TwitterLowThreshold)
						END
				END

				IF(@PQHighThreshold IS NOT NULL)
				BEGIN
					IF(EXISTS(SELECT VALUE FROM IQClient_CustomSettings WHERE _ClientGUID = @ClientGUID AND Field = 'PQHighThreshold' ))
						BEGIN
							UPDATE  IQClient_CustomSettings
							SET VALUE = @PQHighThreshold
							WHERE _ClientGuid = @ClientGUID AND Field = 'PQHighThreshold'
						END
					ELSE
						BEGIN
							INSERT INTO IQClient_CustomSettings
							VALUES
							(@ClientGUID,'PQHighThreshold',@PQHighThreshold)
						END

				END

				IF(@PQLowThreshold IS NOT NULL)
				BEGIN
					IF(EXISTS(SELECT VALUE FROM IQClient_CustomSettings WHERE _ClientGUID = @ClientGUID AND Field = 'PQLowThreshold' ))
						BEGIN
							UPDATE  IQClient_CustomSettings
							SET VALUE = @PQLowThreshold
							WHERE _ClientGuid = @ClientGUID AND Field = 'PQLowThreshold'
						END
					ELSE
						BEGIN
							INSERT INTO IQClient_CustomSettings
							VALUES
							(@ClientGUID,'PQLowThreshold',@PQLowThreshold)
						END
				END
										
				IF(@UseProminence IS NOT NULL)
				BEGIN
					IF(EXISTS(SELECT VALUE FROM IQClient_CustomSettings WHERE _ClientGUID = @ClientGUID AND Field = 'UseProminence' ))
						BEGIN
							UPDATE  IQClient_CustomSettings
							SET VALUE = @UseProminence
							WHERE _ClientGuid = @ClientGUID AND Field = 'UseProminence'
						END
					ELSE
						BEGIN
							INSERT INTO IQClient_CustomSettings
							VALUES
							(@ClientGUID,'UseProminence',@UseProminence)
						END
				END
										
				IF(@ForceCategorySelection IS NOT NULL)
				BEGIN
					IF(EXISTS(SELECT VALUE FROM IQClient_CustomSettings WHERE _ClientGUID = @ClientGUID AND Field = 'ForceCategorySelection' ))
						BEGIN
							UPDATE  IQClient_CustomSettings
							SET VALUE = @ForceCategorySelection
							WHERE _ClientGuid = @ClientGUID AND Field = 'ForceCategorySelection'
						END
					ELSE
						BEGIN
							INSERT INTO IQClient_CustomSettings
							VALUES
							(@ClientGUID,'ForceCategorySelection',@ForceCategorySelection)
						END
				END

				IF(@MCMediaPublishedTemplateID IS NOT NULL)
				  BEGIN
					IF(EXISTS(SELECT VALUE FROM IQClient_CustomSettings WHERE _ClientGuid = @ClientGUID AND Field = 'MCMediaPublishedTemplateID'))
					  BEGIN
						UPDATE IQClient_CustomSettings
						SET VALUE = @MCMediaPublishedTemplateID
						WHERE _ClientGuid = @ClientGUID AND Field = 'MCMediaPublishedTemplateID'
					  END
					ELSE
					  BEGIN
						INSERT INTO IQClient_CustomSettings
						VALUES
						(@ClientGUID, 'MCMediaPublishedTemplateID', @MCMediaPublishedTemplateID)
					  END

					-- Update the client's published report to the new report type
					UPDATE IQ_Report 
					SET _ReportTypeID = @MCMediaPublishedTemplateID
					WHERE ClientGuid = @ClientGUID 
						AND EXISTS (SELECT NULL 
									FROM IQ_ReportType 
									WHERE MasterReportType = 'MCMediaTemplate'
										AND IQ_ReportType.ID = IQ_Report._ReportTypeID)
				  END

				IF(@MCMediaDefaultEmailTemplateID IS NOT NULL)
				  BEGIN
					IF(EXISTS(SELECT VALUE FROM IQClient_CustomSettings WHERE _ClientGuid = @ClientGUID AND Field = 'MCMediaDefaultEmailTemplateID'))
					  BEGIN
						UPDATE IQClient_CustomSettings
						SET VALUE = @MCMediaDefaultEmailTemplateID
						WHERE _ClientGuid = @ClientGUID AND Field = 'MCMediaDefaultEmailTemplateID'
					  END
					ELSE
					  BEGIN
						INSERT INTO IQClient_CustomSettings
						VALUES
						(@ClientGUID, 'MCMediaDefaultEmailTemplateID', @MCMediaDefaultEmailTemplateID)
					  END
				  END

				IF(@IQRawMediaExpiration IS NOT NULL)
				  BEGIN
					IF(EXISTS(SELECT VALUE FROM IQClient_CustomSettings WHERE _ClientGuid = @ClientGUID AND Field = 'IQRawMediaExpiration'))
					  BEGIN
						UPDATE IQClient_CustomSettings
						SET VALUE = @IQRawMediaExpiration
						WHERE _ClientGuid = @ClientGUID AND Field = 'IQRawMediaExpiration'
					  END
					ELSE
					  BEGIN
						INSERT INTO IQClient_CustomSettings
						VALUES
						(@ClientGUID, 'IQRawMediaExpiration', @IQRawMediaExpiration)
					  END
				  END
										
				IF(@LibraryTextType IS NOT NULL)
				BEGIN
					IF(EXISTS(SELECT VALUE FROM IQClient_CustomSettings WHERE _ClientGUID = @ClientGUID AND Field = 'LibraryTextType' ))
						BEGIN
							UPDATE  IQClient_CustomSettings
							SET VALUE = @LibraryTextType
							WHERE _ClientGuid = @ClientGUID AND Field = 'LibraryTextType'
						END
					ELSE
						BEGIN
							INSERT INTO IQClient_CustomSettings
							VALUES
							(@ClientGUID,'LibraryTextType',@LibraryTextType)
						END
				END
										
				IF(@DefaultFeedsPageSize IS NOT NULL)
				BEGIN
					IF(EXISTS(SELECT VALUE FROM IQClient_CustomSettings WHERE _ClientGUID = @ClientGUID AND Field = 'DefaultFeedsPageSize' ))
						BEGIN
							UPDATE  IQClient_CustomSettings
							SET VALUE = @DefaultFeedsPageSize
							WHERE _ClientGuid = @ClientGUID AND Field = 'DefaultFeedsPageSize'
						END
					ELSE
						BEGIN
							INSERT INTO IQClient_CustomSettings
							VALUES
							(@ClientGUID,'DefaultFeedsPageSize',@DefaultFeedsPageSize)
						END
				END
										
				IF(@DefaultDiscoveryPageSize IS NOT NULL)
				BEGIN
					IF(EXISTS(SELECT VALUE FROM IQClient_CustomSettings WHERE _ClientGUID = @ClientGUID AND Field = 'DefaultDiscoveryPageSize' ))
						BEGIN
							UPDATE  IQClient_CustomSettings
							SET VALUE = @DefaultDiscoveryPageSize
							WHERE _ClientGuid = @ClientGUID AND Field = 'DefaultDiscoveryPageSize'
						END
					ELSE
						BEGIN
							INSERT INTO IQClient_CustomSettings
							VALUES
							(@ClientGUID,'DefaultDiscoveryPageSize',@DefaultDiscoveryPageSize)
						END
				END
										
				IF(@DefaultArchivePageSize IS NOT NULL)
				BEGIN
					IF(EXISTS(SELECT VALUE FROM IQClient_CustomSettings WHERE _ClientGUID = @ClientGUID AND Field = 'DefaultArchivePageSize' ))
						BEGIN
							UPDATE  IQClient_CustomSettings
							SET VALUE = @DefaultArchivePageSize
							WHERE _ClientGuid = @ClientGUID AND Field = 'DefaultArchivePageSize'
						END
					ELSE
						BEGIN
							INSERT INTO IQClient_CustomSettings
							VALUES
							(@ClientGUID,'DefaultArchivePageSize',@DefaultArchivePageSize)
						END
				END

				IF(@UseProminenceMediaValue IS NOT NULL)
				BEGIN
					IF(EXISTS(SELECT VALUE FROM IQClient_CustomSettings WHERE _ClientGUID = @ClientGUID AND Field = 'UseProminenceMediaValue' ))
						BEGIN
							UPDATE  IQClient_CustomSettings
							SET VALUE = @UseProminenceMediaValue
							WHERE _ClientGuid = @ClientGUID AND Field = 'UseProminenceMediaValue'
						END
					ELSE
						BEGIN
							INSERT INTO IQClient_CustomSettings
							VALUES
							(@ClientGUID,'UseProminenceMediaValue',@UseProminenceMediaValue)
						END
				END

				IF(EXISTS(SELECT VALUE FROM IQClient_CustomSettings WHERE _ClientGuid = @ClientGUID AND Field = 'ClipEmbedAutoPlay'))
					BEGIN
						UPDATE IQClient_CustomSettings
						SET VALUE = @ClipEmbedAutoPlay
						WHERE _ClientGuid = @ClientGUID AND Field = 'ClipEmbedAutoPlay'
					END
				ELSE
					BEGIN
						INSERT INTO IQClient_CustomSettings
						(_ClientGuid, Field, Value)
						VALUES
						(@ClientGUID, 'ClipEmbedAutoPlay', @ClipEmbedAutoPlay)
					END

				IF(@DefaultFeedsShowUnread IS NOT NULL)
				BEGIN
					IF(EXISTS(SELECT VALUE FROM IQClient_CustomSettings WHERE _ClientGUID = @ClientGUID AND Field = 'DefaultFeedsShowUnread' ))
						BEGIN
							UPDATE  IQClient_CustomSettings
							SET VALUE = @DefaultFeedsShowUnread
							WHERE _ClientGuid = @ClientGUID AND Field = 'DefaultFeedsShowUnread'
						END
					ELSE
						BEGIN
							INSERT INTO IQClient_CustomSettings
							VALUES
							(@ClientGUID,'DefaultFeedsShowUnread',@DefaultFeedsShowUnread)
						END
				END

				IF(@UseCustomerEmailDefault IS NOT NULL)
				BEGIN
					IF(EXISTS(SELECT VALUE FROM IQClient_CustomSettings WHERE _ClientGUID = @ClientGUID AND Field = 'UseCustomerEmailDefault' ))
						BEGIN
							UPDATE  IQClient_CustomSettings
							SET VALUE = @UseCustomerEmailDefault
							WHERE _ClientGuid = @ClientGUID AND Field = 'UseCustomerEmailDefault'
						END
					ELSE
						BEGIN
							INSERT INTO IQClient_CustomSettings
							VALUES
							(@ClientGUID,'UseCustomerEmailDefault',@UseCustomerEmailDefault)
						END
				END

				IF(@ClientRoles IS NOT NULL)
				BEGIN
					INSERT INTO	
						ClientRole
						(
							ClientID,
							RoleID,
							IsAccess,
							CreatedBy,
							ModifiedBy,
							CreatedDate,
							ModifiedDate
						)
					SELECT 
							@ClientKey,
							tblXml.c.value('.','bigint'),
							1,
							'System',
							'System',
							SYSDATETIME(),
							SYSDATETIME()
					FROM
						@ClientRoles.nodes('/Roles/Role') AS tblXml(c) LEFT OUTER JOIN  
							ClientRole
							ON tblXml.c.value('.','bigint')  = ClientRole.RoleID 
							AND ClientRole.ClientID = @ClientKey
					WHERE
						ClientRole.RoleID IS NULL

					UPDATE
						ClientRole
					SET
						IsAccess = 1 ,
						ModifiedDate = @ModifiedDate
					FROM
						@ClientRoles.nodes('/Roles/Role') AS tblXml(c) INNER JOIN  
							ClientRole
							ON tblXml.c.value('.','bigint')  = ClientRole.RoleID 
							AND ClientRole.ClientID = @ClientKey

					UPDATE
						ClientRole
					SET
						IsAccess = 0 ,
						ModifiedDate = @ModifiedDate
					FROM
						@ClientRoles.nodes('/Roles/Role') AS tblXml(c) RIGHT OUTER JOIN  
							ClientRole
							ON tblXml.c.value('.','bigint')  = ClientRole.RoleID 
			
					WHERE 
						tblXml.c.value('.','bigint') IS NULL
						AND ClientRole.ClientID = @ClientKey
						AND ClientRole.RoleID != 3

					DECLARE @GoogleRoleID bigint
					SELECT @GoogleRoleID = RoleKey FROM Role WHERE RoleName = 'v4Google'
					
					-- If the Google role was given, create the necessary third-party data types. If it was removed, delete the data types.
					IF EXISTS(SELECT NULL FROM ClientRole WHERE ClientID = @ClientKey AND RoleID = @GoogleRoleID AND IsAccess = 1)
					  BEGIN
						DECLARE @NewAxisID INT, @NewGroupID INT
						
						SELECT	@NewAxisID = ISNULL(MAX(YAxisID), 0) + 1,
								@NewGroupID = ISNULL(MAX(GroupID), 0) + 1
						FROM	IQ3rdP_DataTypes
						WHERE	_ClientGuid = @ClientGUID

						IF NOT EXISTS(SELECT NULL FROM IQ3rdP_DataTypes WHERE _ClientGuid = @ClientGUID AND DataType = 'GoogleSessions')
						  BEGIN
							INSERT INTO IQ3rdP_DataTypes VALUES (@ClientGUID, 'GoogleSessions', 'Sessions', @NewAxisID, 'Google Analytics', 'usp_v5_IQ3rdP_GoogleSummary_Select', 0, 1, 1, 'shortdash', @NewGroupID,'Google Analytics', getdate(), getdate(), 1, @GoogleRoleID)
						  END

						IF NOT EXISTS(SELECT NULL FROM IQ3rdP_DataTypes WHERE _ClientGuid = @ClientGUID AND DataType = 'GoogleUsers')
						  BEGIN
							INSERT INTO IQ3rdP_DataTypes VALUES (@ClientGUID, 'GoogleUsers', 'Users', @NewAxisID, 'Google Analytics', 'usp_v5_IQ3rdP_GoogleSummary_Select', 0, 1, 1, 'shortdash', @NewGroupID,'Google Analytics', getdate(), getdate(), 1, @GoogleRoleID)
						  END
					  END
					ELSE
					  BEGIN
						DELETE FROM IQ3rdP_CustomerDataTypes
						WHERE EXISTS (SELECT NULL 
									  FROM Customer
									  WHERE ClientID = @ClientKey
											AND CustomerGUID = _CustomerGuid)
						AND EXISTS (SELECT NULL
									FROM IQ3rdP_DataTypes
									WHERE ID = _DataTypeID
									AND DataType IN ('GoogleSessions','GoogleUsers'))

						DELETE FROM IQ3rdP_DataTypes WHERE _ClientGuid = @ClientGUID AND DataType IN ('GoogleSessions','GoogleUsers')
					  END
				END
							
			END
			ELSE
			BEGIN
				SET @ClientKey=0
				SET @IsClientExist = 1
			END
   END
   ELSE	
   BEGIN
		SET @ClientKey = 0
   END
END