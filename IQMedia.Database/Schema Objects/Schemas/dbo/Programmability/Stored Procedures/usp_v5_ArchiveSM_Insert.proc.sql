-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_v5_ArchiveSM_Insert]
	@ArticleID varchar(max),
	@ArticleUri varchar(max),
	@Harvest_Time Datetime,
	@Title varchar(250),		
	@CustomerGuid uniqueidentifier,
	@ClientGuid uniqueidentifier,
	@CategoryGuid uniqueidentifier,	
	@Content nvarchar(MAX),
	@HomeLink varchar(max),
	@CompeteURL varchar(max),
	@PositiveSentiment tinyint,
	@NegativeSentiment tinyint,
	@MediaID bigint,
	@HighLightText nvarchar(max),
	@SearchTerm varchar(500),
	@Number_Hits tinyint,
	@ThumbUrl varchar(max),
	@ArticleStats xml,
	@Keywords varchar(2048),
	@Description varchar(2048),
	@ProminenceMultiplier decimal(18,2),
	@MediaType varchar(2),
	@SubMediaType varchar(50),
	@ArchiveKey			bigint output
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	declare @rpID int
	Declare @ArchiveKeyBkp bigint
	
	BEGIN TRANSACTION
	BEGIN TRY
	
	
	DECLARE @OtherOnlineAdRate decimal(18,2)
	DECLARE @CompeteMultiplier decimal(18,2)
	DECLARE @OnlineNewsAdRate decimal(18,2)
	DECLARE @URLPercentRead decimal(18,2)
	DECLARE @CompeteAudienceMultiplier decimal(18,2)
	DECLARE @UseAudience bit
	DECLARE @UseMediaValue bit

	SET @OtherOnlineAdRate = 1 
	SET @CompeteMultiplier = 1 
	SET @OnlineNewsAdRate= 1 
	Set @URLPercentRead = 1
	SET @CompeteAudienceMultiplier = 1 

	SELECT @UseAudience = UseAudience,
		   @UseMediaValue = UseMediaValue	
	FROM IQ_MediaTypes
	WHERE SubMediaType = @SubMediaType
			
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
				AND IQClient_CustomSettings.Field IN ('OtherOnlineAdRate','CompeteMultiplier','OnlineNewsAdRate','URLPercentRead','CompeteAudienceMultiplier')
	)
 
	SELECT 
		@OtherOnlineAdRate = [OtherOnlineAdRate],
		@CompeteMultiplier = [CompeteMultiplier],
		@OnlineNewsAdRate	=		[OnlineNewsAdRate],
		@URLPercentRead		 =	[URLPercentRead],
		@CompeteAudienceMultiplier =  [CompeteAudienceMultiplier] 
	FROM
		(
		  SELECT
				
					[Field],
					[Value]
		  FROM
					TEMP_ClientSettings
		  WHERE	
					RowNum =1
		) AS SourceTable
		PIVOT
		(
			Max(Value)
			FOR Field IN ([OtherOnlineAdRate],[CompeteMultiplier],[OnlineNewsAdRate],[URLPercentRead],[CompeteAudienceMultiplier])
		) AS PivotTable	
		

	DECLARE @FirstName varchar(150), @LastName  varchar(150)

	SELECT 
		@FirstName = FirstName,  
		@LastName = LastName
	FROM  
		Customer 
	Where CustomerGuid = @CustomerGuid


	DECLARE @Compete_Audience int, @Compete_Result varchar(5) , @AdShareValue decimal(18,2)

	IF(@CompeteUrl = 'facebook.com' OR @CompeteUrl = 'twitter.com' OR @CompeteUrl = 'friendfeed.com')
	BEGIN
		SET @Compete_Audience = -1;
		SET @AdShareValue = -1;
		SET @Compete_Result = NULL;
	END 
	ELSE
	BEGIN
		SELECT 
			@Compete_Audience = CASE WHEN @UseAudience = 0 THEN -1 ELSE round((convert(decimal(18,2),c_uniq_visitor) * @CompeteAudienceMultiplier)/30,0) END,
			@AdShareValue = CASE WHEN @UseMediaValue = 0 THEN -1 ELSE ((((convert(decimal(18,2),c_uniq_visitor)/30)* @CompeteMultiplier * @CompeteAudienceMultiplier * (convert(decimal(18,2),@URLPercentRead)/100))/1000)* @OtherOnlineAdRate) * @ProminenceMultiplier END,
			@Compete_Result = CASE WHEN @UseAudience = 0 AND @UseMediaValue = 0 THEN NULL ELSE results END
		FROM
				IQ_CompeteAll 
		WHERE
				CompeteURL = @CompeteUrl
	END 

								Select 
										@rpID=IQCore_RootPath.ID
									From
											IQCore_RootPath
											inner join IQCore_RootPathType
											on IQCore_RootPath._RootPathTypeID=IQCore_RootPathType.ID
									Where
											IQCore_RootPathType.Name='SM'
									Order by
											NEWID()
								
									IF NOT EXISTS(SELECT ArticleID FROM IQCore_SM Where ArticleID = @ArticleID)
									BEGIN
									
										INSERT INTO 
											IQCore_SM
											(
												ArticleID,
												Url,
												harvest_time,
												[Status],
												_RootPathID
											)
										VALUES
											(
												@ArticleID,
												@ArticleUri,
												@Harvest_Time,
												'QUEUED',
												@rpID
											)	
									END
									
									IF NOT EXISTS(SELECT ArticleID FROM ArchiveSM Where ArticleID = @ArticleID and CustomerGuid = @CustomerGuid AND IsActive=1)
									BEGIN

										DECLARE @SearchRequestID bigint

										IF(@MediaID IS NOT NULL)
											SELECT
												@SearchRequestID = IQAgent_MediaResults._SearchRequestID,
												@SearchTerm = SearchTerm.query('SearchRequest/SearchTerm').value('.','varchar(500)'),
												@HighLightText = convert(nvarchar(max), IQAgent_SMResults.HighlightingText),
												@Number_Hits = IQAgent_SMResults.Number_Hits
											FROM	
												IQAgent_MediaResults WITH(NOLOCK)
													Inner join IQAgent_SearchRequest  WITH(NOLOCK)
														ON IQAgent_MediaResults._SearchRequestID =IQAgent_SearchRequest .ID
													inner join IQAgent_SMResults WITH(NOLOCK)
														on IQAgent_MediaResults.v5Category = @SubMediaType
														and IQAgent_MediaResults._MediaID = IQAgent_SMResults.ID
											WHERE
												IQAgent_MediaResults.ID = @MediaID
										ELSE
										BEGIN
											SET @SearchRequestID = -1
										END
							
										INSERT INTO 
											ArchiveSM
											(
												Title,
												harvest_time,
												FirstName,
												LastName,
												CompeteURL,
												homeLink,
												CustomerGuid,
												ClientGuid,
												CategoryGuid,												
												ArticleID,
												ArticleContent,
												Url,												
												IsActive,
												CreatedDate,
												ModifiedDate,
												PositiveSentiment,
												NegativeSentiment,
												Compete_Audience,
												IQAdShareValue,
												Compete_Result,
												Number_Hits,
												HighlightingText,
												ThumbUrl,
												ArticleStats,
												Keywords,
												Description,
												v5SubMediaType
											)
										SELECT  
												@Title,	
												@Harvest_Time,										
												Customer.FirstName,
												Customer.LastName,
												@CompeteURL,
												@HomeLink,												
												@CustomerGuid,
												@ClientGuid,
												@CategoryGuid,												
												@ArticleID,
												@Content,
												@ArticleUri,												
												1,
												GETDATE(),
												GETDATE(),
												@PositiveSentiment,
												@NegativeSentiment,
												@Compete_Audience,
												@AdShareValue,
												@Compete_Result,
												@Number_Hits,
												@HighLightText,
												@ThumbUrl,
												@ArticleStats,
												@Keywords,
												@Description,
												@SubMediaType
									
										FROM  Customer Where CustomerGuid = @CustomerGuid
										SELECT @ArchiveKeyBkp = SCOPE_IDENTITY()
										
										INSERT INTO IQArchive_Media
										(
											_ArchiveMediaID,
											MediaType,
											Title,
											SubMediaType,
											HighlightingText,
											MediaDate,
											CategoryGUID,
											ClientGUID,
											CustomerGUID,
											IsActive,
											CreatedDate,
											PositiveSentiment,
											NegativeSentiment,
											_SearchRequestID,
											_MediaID,
											SearchTerm,
											Content,
											v5MediaType,
											v5SubMediaType
										)
										VALUES
										(
											@ArchiveKeyBkp,
											'SM',
											@Title,
											@SubMediaType,
											@HighLightText,
											@Harvest_Time,
											@CategoryGuid,
											@ClientGuid,
											@CustomerGuid,
											1,
											GETDATE(),
											@PositiveSentiment,
											@NegativeSentiment,
											@SearchRequestID,
											@MediaID,
											@SearchTerm,
											@Content,
											@MediaType,
											@SubMediaType
										)
										
										--COMMIT TRANSACTION
									END
									ELSE
										BEGIN
											--ROLLBACK TRANSACTION
											SELECT  @ArchiveKeyBkp = -1
										END
							
							
		Set @ArchiveKey = @ArchiveKeyBkp		
		COMMIT TRANSACTION
		
	
		
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		
		DECLARE @IQMediaGroupExceptionKey bigint,
				@ExceptionStackTrace varchar(500),
				@ExceptionMessage varchar(500),
				@CreatedBy	varchar(50),
				@ModifiedBy	varchar(50),
				@CreatedDate	datetime,
				@ModifiedDate	datetime,
				@IsActive	bit
				
		
		SELECT 
				@ExceptionStackTrace=(ERROR_PROCEDURE()+'_'+CONVERT(varchar(50),ERROR_LINE())),
				@ExceptionMessage=convert(varchar(50),ERROR_NUMBER())+'_'+ERROR_MESSAGE(),
				@CreatedBy='usp_v5_ArchiveSM_Insert',
				@ModifiedBy='usp_v5_ArchiveSM_Insert',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
				
		SET @ArchiveKey = 0
		
		EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey output
		
	END CATCH
END
