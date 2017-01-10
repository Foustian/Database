
CREATE PROCEDURE [dbo].[usp_v4_Client_Insert]
	
	@ClientName			VARCHAR(50),
	@ClientKey			INT OUT,
	@ClientGUID			UNIQUEIDENTIFIER,
	@DefaultCategory	VARCHAR(500),
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
	@CustomHeader       VARCHAR(MAX),
	@PlayerLogo			VARCHAR(MAX),
	@IsActivePlayerLogo		BIT,
	@NoOfIQNotification		TINYINT,
	@NoOfIQAgnet			SMALLINT,
	@CompeteMultiplier		DECIMAL(18,2),
	@OnlineNewsAdRate		DECIMAL(18,2),
	@OtherOnlineAdRate	DECIMAL(18,2),
	@UrlPercentRead		DECIMAL(18,2),
	@ClientRoles		XML,
	@Status				BIT OUTPUT,
	@IsCDNUpload		BIT,
	@NotificationHeaderImage VARCHAR(MAX),
	@TimeZone			VARCHAR(5),
	@MultiPlier			DECIMAL(18,2),
	@CompeteAudienceMultiplier	DECIMAL(18,2),
	@visibleLRIndustries VARCHAR(MAX),
	@v4MaxDiscoveryReportItems INT,
	@v4MaxDiscoveryExportItems INT,
	@v4MaxDiscoveryHistory INT,
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
	@RootFolder VARCHAR(255),
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
	@ClipEmbedAutoPlay	BIT,
	@DefaultFeedsShowUnread BIT,
	@UseCustomerEmailDefault BIT
AS
BEGIN
	
	SET NOCOUNT ON;
	BEGIN TRANSACTION
	BEGIN TRY
   
	EXEC usp_v4_Client_ImageCheck @PlayerLogo,@ClientKey,@Status OUTPUT

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

		IF(@Status = 0)
		BEGIN
								DECLARE @ClientCount INT
								SELECT @ClientCount = COUNT(*) FROM Client WHERE ClientName=@ClientName
								IF @ClientCount = 0 
								BEGIN 
								INSERT INTO	
										Client
											(
												ClientName,
												ClientGUID,
												CreatedDate,
												ModifiedDate,
												IsActive,
												PricingCodeID,
												BillFrequencyID,
												BillTypeID,
												IndustryID,
												StateID,
												Address1,
												Address2,
												City,
												Zip,
												Attention,
												Phone,
												MasterClient,
												MCID,
												NoOfUser,
												PlayerLogo,
												IsActivePlayerLogo,
												CDNUpload,
												TimeZone,
												dst,
												gmt,
												AuthorizedVersion,
												IsFliq
											)
										VALUES
											(
												@ClientName,
												@ClientGUID,
												SYSDATETIME(),
												SYSDATETIME(),
												@IsActive,
												@PricingCodeID,
												@BillFrequencyID,
												@BillTypeID,
												@IndustryID,
												@StateID,
												@Address1,
												@Address2,
												@City,
												@Zip,
												@Attention,
												@Phone,
												@MasterClient,
												@MCID,
												@NoOfUser,
												@PlayerLogo,					
												@IsActivePlayerLogo,
												@IsCDNUpload,
												@TimeZone,
												@dst,
												@gmt,
												4,
												@IsFliq

											)
										SELECT @ClientKey=SCOPE_IDENTITY()
										

										INSERT INTO IQReport_Folder
										(
											Name,
											_ClientGUID,
											IsActive,
											CreatedDate,
											ModifiedDate
										)
										VALUES
										(
											@RootFolder,
											@ClientGUID,
											1,
											GETDATE(),
											GETDATE()
										)

										
										IF(ISNULL(@MCID,0) = 0)
										BEGIN

											UPDATE
												Client
											SET
												MCID = @ClientKey
											WHERE 
												ClientKey = @ClientKey
											
										END	
								
										INSERT INTO CustomCategory
										(
											ClientGUID,
											CategoryName,
											CategoryDescription,
											CreatedDate,
											ModifiedDate,
											IsActive
										)
										VALUES
										(
											@ClientGUID,
											@DefaultCategory,
											@DefaultCategory,
											SYSDATETIME(),
											SYSDATETIME(),
											1
										)

										
										IF(LOWER(@CustomHeader) = LOWER(@NotificationHeaderImage))
										BEGIN
											INSERT INTO IQClient_CustomImage
											(
												_ClientGUID,Location,IsDefault,IsDefaultEmail,IsActive,ModifiedDate
											)
											VALUES
											(
												@ClientGUID,@CustomHeader,1,1,1,SYSDATETIME()
											)
										END
										ELSE
										BEGIN
											INSERT INTO IQClient_CustomImage
											(
												_ClientGUID,Location,IsDefault,IsDefaultEmail,IsActive,ModifiedDate
											)
											VALUES
											(
												@ClientGUID,@CustomHeader,1,0,1,SYSDATETIME()
											)

											INSERT INTO IQClient_CustomImage
											(
												_ClientGUID,Location,IsDefault,IsDefaultEmail,IsActive,ModifiedDate
											)
											VALUES
											(
												@ClientGUID,@NotificationHeaderImage,0,1,1,SYSDATETIME()
											)
										END
									
										IF(@IQLicense IS NOT NULL)
										BEGIN
											INSERT INTO IQClient_CustomSettings
												VALUES
												(@ClientGUID,'IQLicense',@IQLicense)
										END
									
										IF(@CompeteMultiplier IS NOT NULL)
										BEGIN
											INSERT INTO IQClient_CustomSettings
												VALUES
												(@ClientGUID,'CompeteMultiplier',@CompeteMultiplier)
										END 

										IF(@OtherOnlineAdRate IS NOT NULL)
										BEGIN
											INSERT INTO IQClient_CustomSettings
												VALUES
												(@ClientGUID,'OtherOnlineAdRate',@OtherOnlineAdRate)
										END

										IF(@OnlineNewsAdRate IS NOT NULL)
										BEGIN
											INSERT INTO IQClient_CustomSettings
												VALUES
												(@ClientGUID,'OnlineNewsAdRate',@OnlineNewsAdRate)
										END
									
										IF(@UrlPercentRead IS NOT NULL)
										BEGIN
											INSERT INTO IQClient_CustomSettings
												VALUES
												(@ClientGUID,'URLPercentRead',@UrlPercentRead)
										END
									
									
										IF(@NoOfIQNotification IS NOT NULL)
										BEGIN
											INSERT INTO IQClient_CustomSettings
											VALUES
											(@ClientGUID,'TotalNoOfIQNotification',@NoOfIQNotification)
										END


										IF(@NoOfIQAgnet IS NOT NULL)
										BEGIN
											INSERT INTO IQClient_CustomSettings
											VALUES
											(@ClientGUID,'TotalNoOfIQAgent',@NoOfIQAgnet)
										END

										IF(@MultiPlier IS NOT NULL)
										BEGIN
											INSERT INTO IQClient_CustomSettings
											VALUES
											(@ClientGUID,'Multiplier',@MultiPlier)
										END

										IF(@CompeteAudienceMultiplier IS NOT NULL)
										BEGIN
											INSERT INTO IQClient_CustomSettings
											VALUES
											(@ClientGUID,'CompeteAudienceMultiplier',@CompeteAudienceMultiplier)
										END

										IF(@visibleLRIndustries IS NOT NULL)
										BEGIN
											INSERT INTO IQClient_CustomSettings
												VALUES
												(@ClientGUID,'visibleLRIndustries',@visibleLRIndustries)
										END

										IF(@v4MaxDiscoveryReportItems IS NOT NULL)
										BEGIN
											INSERT INTO IQClient_CustomSettings
											VALUES
											(@ClientGUID,'v4MaxDiscoveryReportItems',@v4MaxDiscoveryReportItems)
										END
										
										IF(@v4MaxDiscoveryExportItems IS NOT NULL)
										BEGIN
											INSERT INTO IQClient_CustomSettings
											VALUES
											(@ClientGUID,'v4MaxDiscoveryExportItems',@v4MaxDiscoveryExportItems)
										END

										IF(@v4MaxDiscoveryHistory IS NOT NULL)
										BEGIN
											INSERT INTO IQClient_CustomSettings
											VALUES
											(@ClientGUID,'v4MaxDiscoveryHistory',@v4MaxDiscoveryHistory)
										END

										IF(@v4MaxFeedsExportItems IS NOT NULL)
										BEGIN
											INSERT INTO IQClient_CustomSettings
											VALUES
											(@ClientGUID,'v4MaxFeedsExportItems',@v4MaxFeedsExportItems)
										END									

										IF(@v4MaxFeedsReportItems IS NOT NULL)
										BEGIN
											INSERT INTO IQClient_CustomSettings
											VALUES
											(@ClientGUID,'v4MaxFeedsReportItems',@v4MaxFeedsReportItems)
										END

										IF(@v4MaxLibraryEmailReportItems IS NOT NULL)
										BEGIN
											INSERT INTO IQClient_CustomSettings
											VALUES
											(@ClientGUID,'v4MaxLibraryEmailReportItems',@v4MaxLibraryEmailReportItems)
										END

										IF(@v4MaxLibraryReportItems IS NOT NULL)
										BEGIN
											INSERT INTO IQClient_CustomSettings
											VALUES
											(@ClientGUID,'v4MaxLibraryReportItems',@v4MaxLibraryReportItems)
										END

										IF(@TVHighThreshold IS NOT NULL)
										BEGIN
											INSERT INTO IQClient_CustomSettings
											VALUES
											(@ClientGUID,'TVHighThreshold',@TVHighThreshold)
										END

										IF(@TVLowThreshold IS NOT NULL)
										BEGIN
											INSERT INTO IQClient_CustomSettings
											VALUES
											(@ClientGUID,'TVLowThreshold',@TVLowThreshold)
										END

										IF(@NMHighThreshold IS NOT NULL)
										BEGIN
											INSERT INTO IQClient_CustomSettings
											VALUES
											(@ClientGUID,'NMHighThreshold',@NMHighThreshold)
										END

										IF(@NMLowThreshold IS NOT NULL)
										BEGIN
											INSERT INTO IQClient_CustomSettings
											VALUES
											(@ClientGUID,'NMLowThreshold',@NMLowThreshold)
										END

										IF(@SMHighThreshold IS NOT NULL)
										BEGIN
											INSERT INTO IQClient_CustomSettings
											VALUES
											(@ClientGUID,'SMHighThreshold',@SMHighThreshold)
										END

										IF(@SMLowThreshold IS NOT NULL)
										BEGIN
											INSERT INTO IQClient_CustomSettings
											VALUES
											(@ClientGUID,'SMLowThreshold',@SMLowThreshold)
										END

										IF(@TwitterHighThreshold IS NOT NULL)
										BEGIN
											INSERT INTO IQClient_CustomSettings
											VALUES
											(@ClientGUID,'TwitterHighThreshold',@TwitterHighThreshold)
										END

										IF(@TwitterLowThreshold IS NOT NULL)
										BEGIN
											INSERT INTO IQClient_CustomSettings
											VALUES
											(@ClientGUID,'TwitterLowThreshold',@TwitterLowThreshold)
										END

										IF(@PQHighThreshold IS NOT NULL)
										BEGIN
											INSERT INTO IQClient_CustomSettings
											VALUES
											(@ClientGUID,'PQHighThreshold',@PQHighThreshold)
										END

										IF(@PQLowThreshold IS NOT NULL)
										BEGIN
											INSERT INTO IQClient_CustomSettings
											VALUES
											(@ClientGUID,'PQLowThreshold',@PQLowThreshold)
										END
										
										IF(@UseProminence IS NOT NULL)
										BEGIN
											INSERT INTO IQClient_CustomSettings
											VALUES
											(@ClientGUID,'UseProminence',@UseProminence)
										END
										
										IF(@ForceCategorySelection IS NOT NULL)
										BEGIN
											INSERT INTO IQClient_CustomSettings
											VALUES
											(@ClientGUID,'ForceCategorySelection',@ForceCategorySelection)
										END
										
										IF(@MCMediaPublishedTemplateID IS NOT NULL)
										BEGIN
											INSERT INTO IQClient_CustomSettings
											VALUES
											(@ClientGUID,'MCMediaPublishedTemplate',@MCMediaPublishedTemplateID)
										END
										
										IF(@MCMediaDefaultEmailTemplateID IS NOT NULL)
										BEGIN
											INSERT INTO IQClient_CustomSettings
											VALUES
											(@ClientGUID,'MCMediaDefaultEmailTemplateID',@MCMediaDefaultEmailTemplateID)
										END
										
										IF(@IQRawMediaExpiration IS NOT NULL)
										BEGIN
											INSERT INTO IQClient_CustomSettings
											VALUES
											(@ClientGUID,'IQRawMediaException',@IQRawMediaExpiration)
										END
										
										IF(@LibraryTextType IS NOT NULL)
										BEGIN
											INSERT INTO IQClient_CustomSettings
											VALUES
											(@ClientGUID,'LibraryTextType',@LibraryTextType)
										END
										
										IF(@DefaultFeedsPageSize IS NOT NULL)
										BEGIN
											INSERT INTO IQClient_CustomSettings
											VALUES
											(@ClientGUID,'DefaultFeedsPageSize',@DefaultFeedsPageSize)
										END
										
										IF(@DefaultDiscoveryPageSize IS NOT NULL)
										BEGIN
											INSERT INTO IQClient_CustomSettings
											VALUES
											(@ClientGUID,'DefaultDiscoveryPageSize',@DefaultDiscoveryPageSize)
										END
										
										IF(@DefaultArchivePageSize IS NOT NULL)
										BEGIN
											INSERT INTO IQClient_CustomSettings
											VALUES
											(@ClientGUID,'DefaultArchivePageSize',@DefaultArchivePageSize)
										END

										IF(@UseProminenceMediaValue IS NOT NULL)
										BEGIN
											INSERT INTO IQClient_CustomSettings
											VALUES
											(@ClientGUID,'UseProminenceMediaValue',@UseProminenceMediaValue)
										END

										INSERT INTO IQClient_CustomSettings
										(_ClientGuid,Field,Value)
										VALUES
										(@ClientGUID,'ClipEmbedAutoPlay',@ClipEmbedAutoPlay)

										INSERT INTO IQClient_CustomSettings
										(_ClientGuid,Field,Value)
										VALUES
										(@ClientGUID,'DefaultFeedsShowUnread',@DefaultFeedsShowUnread)

										INSERT INTO IQClient_CustomSettings
										(_ClientGuid,Field,Value)
										VALUES
										(@ClientGUID,'UseCustomerEmailDefault',@UseCustomerEmailDefault)

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
												@ClientRoles.nodes('/Roles/Role') AS tblXml(c)

											DECLARE @GoogleRoleID bigint
											SELECT @GoogleRoleID = RoleKey FROM Role WHERE RoleName = 'v4Google'

											-- If the Google role was given, create the necessary third-party data types
											IF EXISTS(SELECT NULL FROM ClientRole WHERE ClientID = @ClientKey AND RoleID = @GoogleRoleID)
											  BEGIN
												INSERT INTO IQ3rdP_DataTypes VALUES (@ClientGUID, 'GoogleSessions', 'Sessions', 1, 'Google Analytics', 'usp_v5_IQ3rdP_GoogleSummary_Select', 0, 1, 1, 'shortdash', 1,'Google Analytics', getdate(), getdate(), 1, @GoogleRoleID)
												INSERT INTO IQ3rdP_DataTypes VALUES (@ClientGUID, 'GoogleUsers', 'Users', 1, 'Google Analytics', 'usp_v5_IQ3rdP_GoogleSummary_Select', 0, 1, 1, 'shortdash', 1,'Google Analytics', getdate(), getdate(), 1, @GoogleRoleID)
											  END
										END
								
									
								END
								ELSE
									SET @ClientKey=0
		END
		ELSE	
	    BEGIN
				SET @ClientKey = 0
	    END
			
	
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
	
		ROLLBACK TRANSACTION
		
		SET @ClientKey=0
		SET @Status = -1
		DECLARE @IQMediaGroupExceptionKey BIGINT,
				@ExceptionStackTrace VARCHAR(500),
				@ExceptionMessage VARCHAR(500),
				@CreatedBy	VARCHAR(50),
				@ModifiedBy	VARCHAR(50),
				@CreatedDate	DATETIME,
				@ModifiedDate	DATETIME,
				@IsActiveSP	BIT
				
		
		SELECT 
				@ExceptionStackTrace=(ERROR_PROCEDURE()+'_'+CONVERT(VARCHAR(50),ERROR_LINE())),
				@ExceptionMessage=CONVERT(VARCHAR(50),ERROR_NUMBER())+'_'+ERROR_MESSAGE(),
				@CreatedBy='usp_v4_Client_Insert',
				@ModifiedBy='usp_v4_Client_Insert',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActiveSP=1
				
		
		EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT
	
	END CATCH
	
    
END
