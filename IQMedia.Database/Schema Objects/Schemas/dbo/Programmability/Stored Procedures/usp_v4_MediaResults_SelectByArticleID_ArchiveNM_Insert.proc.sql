CREATE PROCEDURE [dbo].[usp_v4_MediaResults_SelectByArticleID_ArchiveNM_Insert]  
 @ArticleID VARCHAR(MAX),
 @SearchRequestID bigint, 
 @MediaType VARCHAR(10),
 @CustomerGuid UNIQUEIDENTIFIER,  
 @ClientGuid UNIQUEIDENTIFIER,
 @CategoryGUID UNIQUEIDENTIFIER
 AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
 
 -- First, Read from IQAgent_NMResults or IQAgent_SMResults
 DECLARE @Content NVARCHAR(MAX)
 DECLARE @Title VARCHAR(250)
 DECLARE @Harvest_Time DATETIME
 DECLARE @ArticleUri VARCHAR(MAX) 
 DECLARE @Publication VARCHAR(MAX)
 DECLARE @CompeteUrl VARCHAR(MAX) 
 DECLARE @PositiveSentiment TINYINT
 DECLARE @NegativeSentiment TINYINT  
 DECLARE @MediaID bigint
 DECLARE @HighLightText nvarchar(max)
 DECLARE @Number_Hits tinyint
 DECLARE @SearchTerm varchar(500)
 DECLARE @IQLicense TINYINT  
 DECLARE @rpID INT  
 DECLARE @ArchiveKeyBkp BIGINT  
    
 IF @MediaType Is NOT NULL AND @MediaType = 'NM'
		BEGIN
			SELECT 
					@ArticleUri = IQAgent_NMResults.Url,
					@Harvest_Time = IQAgent_NMResults.harvest_time,
					@Title = IQAgent_NMResults.Title,
					@Content = IQAgent_MissingArticles.Content,
					@Publication = IQAgent_NMResults.Publication,
					@CompeteUrl = IQAgent_NMResults.CompeteUrl,
					@PositiveSentiment = IQAgent_MediaResults.PositiveSentiment,
					@NegativeSentiment = IQAgent_MediaResults.NegativeSentiment, 
					@HighLightText = IQAgent_MediaResults.HighlightingText,  
					@Number_Hits = IQAgent_NMResults.Number_Hits, 
					@IQLicense = IQAgent_NMResults.iqlicense, 
					@MediaID = IQAgent_MediaResults.ID
			FROM	
				IQAgent_NMResults WITH (NOLOCK)
					inner join IQAgent_MediaResults WITH (NOLOCK)
						on IQAgent_NMResults.ID = IQAgent_MediaResults._MediaID
						and IQAgent_MediaResults.MediaType = 'NM'
					left outer join IQAgent_MissingArticles  WITH (NOLOCK)
						on IQAgent_NMResults.ArticleID = IQAgent_MissingArticles.ID
						and IQAgent_MissingArticles.Category ='NM'
			WHERE	IQAgent_NMResults.ArticleID = @ArticleID 
				and IQAgent_NMResults.IQAgentSearchRequestID = @SearchRequestID

		END
	
	--IF @MediaType Is NOT NULL AND @MediaType = 'SM'
	--	BEGIN
	--		SELECT 
	--				@ArticleUri = IQAgent_SMResults.link,
	--				@Harvest_Time = IQAgent_SMResults.itemHarvestDate_DT, 
	--				@Title = IQAgent_SMResults.[description],
	--				@Content = IQAgent_MissingArticles.Content,
	--				@Publication = IQAgent_SMResults.homelink,
	--				@CompeteUrl = IQAgent_SMResults.CompeteUrl,
	--				IQAgent_SMResults.feedClass,
	--				@PositiveSentiment = IQAgent_MediaResults.PositiveSentiment,
	--				@NegativeSentiment = IQAgent_MediaResults.NegativeSentiment,
					--@HighLightText = IQAgent_MediaResults.HighlightingText,  
					--@Number_Hits = IQAgent_NMResults.Number_Hits, 
	--				@MediaID = IQAgent_MediaResults.ID
	--		FROM	
	--			IQAgent_SMResults WITH (NOLOCK)
	--				inner join IQAgent_MediaResults WITH (NOLOCK)
	--					on IQAgent_SMResults.ID = IQAgent_MediaResults._MediaID
	--					and IQAgent_MediaResults.MediaType = 'SM'
	--				left outer join IQAgent_MissingArticles  WITH (NOLOCK)
	--					on IQAgent_SMResults.SeqID = IQAgent_MissingArticles.ID
	--					and IQAgent_MissingArticles.Category != 'NM'
	--		WHERE	IQAgent_SMResults.SeqID = @ArticleID 
	--			and IQAgent_SMResults.IQAgentSearchRequestID = @SearchRequestID
	--	END 
 -- End
 -- Now, insert data in Archive* table
    
 BEGIN TRANSACTION  
 BEGIN TRY  
   
   
 DECLARE @OtherOnlineAdRate DECIMAL(18,2)  
 DECLARE @CompeteMultiplier DECIMAL(18,2)  
 DECLARE @OnlineNewsAdRate DECIMAL(18,2)  
 DECLARE @URLPercentRead DECIMAL(18,2)  
 DECLARE @CompeteAudienceMultiplier DECIMAL(18,2)  
  
 SET @OtherOnlineAdRate = 1   
 SET @CompeteMultiplier = 1   
 SET @OnlineNewsAdRate= 1   
 SET @URLPercentRead = 1  
 SET @CompeteAudienceMultiplier = 1   
     
 ;WITH TEMP_ClientSettings AS  
 (  
  SELECT  
    ROW_NUMBER() OVER (PARTITION BY Field ORDER BY IQClient_CustomSettings._ClientGuid DESC) AS RowNum,  
    Field,  
    VALUE  
  FROM  
    IQClient_CustomSettings  
  WHERE  
    (IQClient_CustomSettings._ClientGuid=@ClientGuid OR IQClient_CustomSettings._ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))  
    AND IQClient_CustomSettings.Field IN ('OtherOnlineAdRate','CompeteMultiplier','OnlineNewsAdRate','URLPercentRead','CompeteAudienceMultiplier')  
 )  
   
 SELECT   
  @OtherOnlineAdRate = [OtherOnlineAdRate],  
  @CompeteMultiplier = [CompeteMultiplier],  
  @OnlineNewsAdRate =  [OnlineNewsAdRate],  
  @URLPercentRead   = [URLPercentRead],  
  @CompeteAudienceMultiplier =  [CompeteAudienceMultiplier]  
 FROM  
  (  
    SELECT  
      
     [Field],  
     [VALUE]  
    FROM  
     TEMP_ClientSettings  
    WHERE   
     RowNum =1  
  ) AS SourceTable  
  PIVOT  
  (  
   MAX(VALUE)  
   FOR Field IN ([OtherOnlineAdRate],[CompeteMultiplier],[OnlineNewsAdRate],[URLPercentRead],[CompeteAudienceMultiplier])  
  ) AS PivotTable   
  
 DECLARE @FirstName VARCHAR(150), @LastName  VARCHAR(150)  
  
 SELECT   
  @FirstName = FirstName,    
  @LastName = LastName  
 FROM    
  Customer   
 WHERE CustomerGuid = @CustomerGuid  
  
  
 DECLARE @Compete_Audience INT, @Compete_Result VARCHAR(5) , @AdShareValue DECIMAL(18,2)  
  
 IF(@CompeteUrl = 'facebook.com' OR @CompeteUrl = 'twitter.com' OR @CompeteUrl = 'friendfeed.com')  
 BEGIN  
  SET @Compete_Audience = -1;  
  SET @AdShareValue = -1;  
  SET @Compete_Result = NULL;  
 END   
 ELSE  
 BEGIN  
  SELECT   
   @Compete_Audience = ROUND((CONVERT(DECIMAL(18,2),c_uniq_visitor) * @CompeteAudienceMultiplier)/30,0),  
   @AdShareValue =(((CONVERT(DECIMAL(18,2),c_uniq_visitor)/30)* @CompeteMultiplier * @CompeteAudienceMultiplier * (CONVERT(DECIMAL(18,2),@URLPercentRead)/100))/1000)* @OnlineNewsAdRate,  
   @Compete_Result = results  
  FROM  
    IQ_CompeteAll   
  WHERE  
    CompeteURL = @CompeteUrl  
  
  /*IF(@Compete_Audience IS NULL OR @AdShareValue IS NULL)  
  BEGIN  
   SELECT   
    @Compete_Audience = ROUND((CONVERT(DECIMAL(18,2),c_uniq_visitor) * @CompeteAudienceMultiplier)/30,0),  
    @AdShareValue =(((CONVERT(DECIMAL(18,2),c_uniq_visitor)/30) * @CompeteMultiplier * @CompeteAudienceMultiplier * (CONVERT(DECIMAL(18,2),@URLPercentRead)/100))/1000) * @OnlineNewsAdRate,  
    @Compete_Result = 'E'  
   FROM  
    IQ_Compete_Averages  
   WHERE  
    CompeteURL = @CompeteUrl  
  END*/  
 END   
    
  
   SELECT  
       @rpID=IQCore_RootPath.ID  
     FROM  
       IQCore_RootPath  
        INNER JOIN IQCore_RootPathType  
         ON IQCore_RootPath._RootPathTypeID=IQCore_RootPathType.ID  
     WHERE  
       IQCore_RootPathType.Name='NM'  
     ORDER BY  
       NEWID()  
   
     IF NOT EXISTS(SELECT ArticleID FROM IQCore_Nm WHERE ArticleID = @ArticleID)  
      BEGIN  
       INSERT INTO   
        IQCore_Nm  
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
    
    
      IF NOT EXISTS(SELECT ArticleID FROM ArchiveNM WHERE ArticleID = @ArticleID AND CustomerGuid = @CustomerGuid AND IsActive=1)  
      BEGIN  
        SELECT  
         @SearchTerm = SearchTerm.query('SearchRequest/SearchTerm').value('.','varchar(500)')    
        FROM   
          IQAgent_SearchRequest WITH(NOLOCK)   
        WHERE  
         IQAgent_SearchRequest.ID = @SearchRequestID
  
       INSERT INTO   
        ArchiveNM  
        (  
         Title,   
         Harvest_Time,          
         FirstName,  
         LastName,  
         CustomerGuid,  
         ClientGuid,  
         CategoryGuid,           
         ArticleID,  
         ArticleContent,  
         Url,  
         Publication,  
         CompeteUrl,  
         IsActive,  
         CreatedDate,  
         ModifiedDate,  
         PositiveSentiment,  
         NegativeSentiment,  
         Compete_Audience,  
         IQAdShareValue,  
         Compete_Result,  
         IQLicense,  
         Number_Hits,  
         HighlightingText,
		 v5SubMediaType  
        )  
       SELECT    
         @Title,  
         @Harvest_Time,  
         @FirstName,  
         @LastName,  
         @CustomerGuid,  
         @ClientGuid,  
         @CategoryGuid,           
         @ArticleID,  
         @Content,  
         @ArticleUri,  
         @Publication,  
         @CompeteUrl,  
         1,  
         GETDATE(),  
         GETDATE(),  
         @PositiveSentiment,  
         @NegativeSentiment,  
         @Compete_Audience,  
         @AdShareValue,  
         @Compete_Result,  
         @IQLicense,  
         @Number_Hits,  
         @HighLightText,
		 'NM'
  
       SELECT @ArchiveKeyBkp = SCOPE_IDENTITY()  
  
       DECLARE @SecondsOnDay int= 86400  
       DECLARE @2DaysTotalSeconds int= 172800  
       DECLARE @ParentID bigint  
  
       SELECT @ParentID = ID  
       FROM   
        IQArchive_Media  WITH (NOLOCK)
       WHERE  
        Title = @Title  
        and MediaType = 'NM'  
        and CategoryGuid = @CategoryGuid  
        and ClientGuid = @ClientGuid  
        and _ParentID is null  
        and IsActive = 1  
        and Cast((CAST(@Harvest_Time AS float) - (CAST(mediadate AS float))) * @SecondsOnDay as bigint) >= 0 and  Cast((CAST(@Harvest_Time AS float) - (CAST(mediadate AS float))) * @SecondsOnDay as bigint) <= @2DaysTotalSeconds  
         
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
        _ParentID,  
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
        'NM',  
        @Title,  
        'NM',  
        @HighLightText,  
        @Harvest_Time,  
        @CategoryGuid,  
        @ClientGuid,  
        @CustomerGuid,  
        1,  
        GETDATE(),  
        @PositiveSentiment,  
        @NegativeSentiment,  
        @ParentID,  
        @SearchRequestID,  
        @MediaID,  
        @SearchTerm,  
		@Content,
		'NM',
		'NM'
       )  
                
      END  
      ELSE  
       BEGIN           
         SELECT  @ArchiveKeyBkp = -1  
       END  
         
         
  --SET @ArchiveKey = @ArchiveKeyBkp    
   
  COMMIT TRANSACTION  
   
    
 END TRY  
 BEGIN CATCH  
  ROLLBACK TRANSACTION  
    
  DECLARE @IQMediaGroupExceptionKey BIGINT,  
    @ExceptionStackTrace VARCHAR(500),  
    @ExceptionMessage VARCHAR(500),  
    @CreatedBy VARCHAR(50),  
    @ModifiedBy VARCHAR(50),  
    @CreatedDate DATETIME,  
    @ModifiedDate DATETIME,  
    @IsActive BIT  
      
    
  SELECT   
    @ExceptionStackTrace=(ERROR_PROCEDURE()+'_'+CONVERT(VARCHAR(50),ERROR_LINE())),  
    @ExceptionMessage=CONVERT(VARCHAR(50),ERROR_NUMBER())+'_'+ERROR_MESSAGE(),  
    @CreatedBy='usp_v4_MediaResults_SelectByArticleID_ArchiveNM_Insert',  
    @ModifiedBy='usp_v4_MediaResults_SelectByArticleID_ArchiveNM_Insert',  
    @CreatedDate=GETDATE(),  
    @ModifiedDate=GETDATE(),  
    @IsActive=1  
      
  --SET @ArchiveKey = 0  
    
  EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT  
    
 END CATCH  
END
GO


