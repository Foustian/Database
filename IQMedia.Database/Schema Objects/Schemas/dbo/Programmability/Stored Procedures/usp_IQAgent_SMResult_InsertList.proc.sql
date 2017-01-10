CREATE PROCEDURE [dbo].[usp_IQAgent_SMResults_InsertList]          
        
 @XmlData XML        
          
AS        
BEGIN        
 SET NOCOUNT OFF;        
 SET XACT_ABORT ON;
        
        
 BEGIN TRY        
        
     
	DECLARE @MediaResultTable TABLE (MediaID BIGINT,Title NVARCHAR(MAX),MediaType VARCHAR(2), Category VARCHAR(50), HighlightingText NVARCHAR(MAX), MediaDate	DATETIME,LocalDate DATETIME, SearchRequestID BIGINT,Sentiment XML, IsActive BIT, IQMediaValue DECIMAL(18,2), Audience BIGINT,
PositiveSentiment INT,NegativeSentiment INT,NumberOfHits BIGINT, IQProminence DECIMAL(18,6),IQProminenceMultiplier DECIMAL(18,6),isDuplicate bit)  
    
    DECLARE @IQAgent_SummaryTrackingID BIGINT      


	DECLARE @IQAgent_SMResults TABLE(
	[SeqID] [varchar](50) NOT NULL,
	[IQAgentSearchRequestID] [bigint] NOT NULL,
	[_QueryVersion] [int] NULL,
	[link] [nvarchar](max) NOT NULL,
	[homelink] [nvarchar](255) NULL,
	[description] [nvarchar](max) NULL,
	[itemHarvestDate_DT] [datetime] NOT NULL,
	[feedClass] [varchar](50) NOT NULL,
	[Compete_Audience] [int] NULL,
	[IQAdShareValue] [float] NULL,
	[Compete_Result] [char](1) NULL,
	[CompeteURL] [nvarchar](255) NULL,
	[Sentiment] [xml] NULL,
	[Number_Hits] [int] NULL,
	[HighlightingText] [xml] NULL,
	[IQProminence] [decimal](18, 6) NULL,
	[IQProminenceMultiplier] [decimal](18, 6) NULL,
	[ArticleStats] [xml] NULL,
	[ThumbUrl] [nvarchar](max) NULL,
	[duplicateID] [varchar](50) NULL,
	[AM18_24] [int] NULL,
	[AM25_34] [int] NULL,
	[AM35_44] [int] NULL,
	[AM45_54] [int] NULL,
	[AM55_64] [int] NULL,
	[AM65_Plus] [int] NULL,
	[AF18_24] [int] NULL,
	[AF25_34] [int] NULL,
	[AF35_44] [int] NULL,
	[AF45_54] [int] NULL,
	[AF55_64] [int] NULL,
	[AF65_Plus] [int] NULL,
	[isDuplicate] [BIT] NULL)             
        
	 INSERT INTO @IQAgent_SMResults 
		  (           
		   SeqID,        
		   IQAgentSearchRequestID,        
		   _QueryVersion,         
		   link,        
		   homelink,        
		   [description] ,        
		   itemHarvestDate_DT,        
		   --feedCategories,        
		   feedClass,         
		   --feedRank,         
		   Compete_Audience,        
		   IQAdShareValue,        
		   Compete_Result,        
		   CompeteURL,         
		   Sentiment,
		   Number_Hits,
		   HighlightingText,      
		   IQProminence,
		   IQProminenceMultiplier,
		   ArticleStats,
		   ThumbUrl,
		   duplicateID,
		   AM18_24,
		   AM25_34,
		   AM35_44,
		   AM45_54,
		   AM55_64,
		   AM65_Plus,
		   AF18_24,
		   AF25_34,
		   AF35_44,
		   AF45_54,
		   AF55_64,
		   AF65_Plus,
		   isDuplicate
		  )        
      SELECT         
		 tblXml.c.value('@SeqID','varchar(50)') AS [SeqID],        
		 tblXml.c.value('@IQAgentSearchRequestID','bigint') AS [IQAgentSearchRequestID],        
		 tblXml.c.value('@QueryVersion','int') AS [QueryVersion],        
		 tblXml.c.value('@link','nvarchar(max)') AS [link],        
		 tblXml.c.value('@homelink','nvarchar(255)') AS [homelink],        
		 tblXml.c.value('@description','nvarchar(max)') AS [description],        
		 tblXml.c.value('@itemHarvestDate_DT','datetime') AS [itemHarvestDate_DT],        
		 --tblXml.c.value('@feedCategories','varchar(max)') as [feedCategories],        
		 tblXml.c.value('@feedClass','varchar(50)') AS [feedClass],        
		 --tblXml.c.value('@feedRank','int') as [feedRank],        
		 CASE WHEN tblXml.c.value('@Compete_Audience','int') = '' THEN NULL ELSE tblXml.c.value('@Compete_Audience','int') END,        
		 CASE WHEN tblXml.c.value('@IQAdShareValue','float') = '' THEN NULL ELSE tblXml.c.value('@IQAdShareValue','float') END,        
		 CASE WHEN tblXml.c.value('@Compete_Result','char(1)') = '' THEN NULL ELSE tblXml.c.value('@Compete_Result','char(1)') END,        
		 tblXml.c.value('@CompeteURL','nvarchar(255)') AS [CompeteURL],        
		 CASE WHEN CONVERT(NVARCHAR(MAX), tblXml.c.query('Sentiment')) = '' THEN NULL ELSE tblXml.c.query('Sentiment') END AS [Sentiment],
		 tblXml.c.value('@Number_Hits','int') AS [Number_Hits],
		 CASE WHEN CONVERT(NVARCHAR(MAX), tblXml.c.query('HighlightedSMOutput')) = '' THEN NULL ELSE tblXml.c.query('HighlightedSMOutput') END AS [HighlightingText],      
		 tblXml.c.value('@IQProminence','DECIMAL(18,6)') AS [IQProminence],
		 tblXml.c.value('@IQProminenceMultiplier','DECIMAL(18,6)') AS [IQProminenceMultiplier],
		 CASE WHEN CONVERT(NVARCHAR(MAX), tblXml.c.query('ArticleStatsModel')) = '' THEN NULL ELSE tblXml.c.query('ArticleStatsModel') END AS [ArticleStats],        
		 tblXml.c.value('@ThumbUrl','nvarchar(max)') AS [ThumbUrl],
		 tblXml.c.value('@duplicateID','varchar(50)') AS [duplicateID],
		 tblXml.c.value('@AM18_24','int') AS [AM18_24],
		 tblXml.c.value('@AM25_34','int') AS [AM25_34],
		 tblXml.c.value('@AM35_44','int') AS [AM35_44],
		 tblXml.c.value('@AM45_54','int') AS [AM45_54],
		 tblXml.c.value('@AM55_64','int') AS [AM55_64],
		 tblXml.c.value('@AM65','int')    AS [AM65_Plus],
		 tblXml.c.value('@AF18_24','int') AS [AF18_24],
		 tblXml.c.value('@AF25_34','int') AS [AF25_34],
		 tblXml.c.value('@AF35_44','int') AS [AF35_44],
		 tblXml.c.value('@AF45_54','int') AS [AF45_54],
		 tblXml.c.value('@AF55_64','int') AS [AF55_64],
		 tblXml.c.value('@AF65','int')    AS [AF65_Plus],
		 (SELECT DISTINCT 1 FROM IQAgent_SMResults WITH (NOLOCK) WHERE duplicateID =  tblXml.c.value('@duplicateID','varchar(50)')
                                                    AND IQAgentSearchRequestID = tblXml.c.value('@IQAgentSearchRequestID','bigint')
                                                    AND homelink = tblXml.c.value('@homelink','varchar(255)')
						    AND IsActive = 1)
	  FROM          
		@XmlData.nodes('/IQAgentSMResultsList/IQAgentSMResult') AS tblXml(c)        
	
     
			UPDATE @IQAgent_SMResults
					 SET isDuplicate = 1
				FROM @IQAgent_SMResults b 
				   JOIN ( SELECT MIN(SeqID) AS MinSeqID, duplicateID ,Homelink, IQAgentSearchRequestID 
									   FROM @IQAgent_SMResults GROUP BY duplicateID ,Homelink,IQAgentSearchRequestID
									   HAVING COUNT(1) > 1)  a
					ON  a.duplicateID = b.duplicateID
					AND b.SeqID > a.MinSeqID
					AND b.IQAgentSearchRequestID = a.IQAgentSearchRequestID
					AND b.Homelink = a.Homelink

BEGIN TRANSACTION
	
	 INSERT INTO [dbo].[IQAgent_SMResults]        
	  (           
	   SeqID,        
	   IQAgentSearchRequestID,        
	   _QueryVersion,         
	   link,        
	   homelink,        
	   [description] ,        
	   itemHarvestDate_DT,        
	   --feedCategories,        
	   feedClass,         
	   --feedRank,         
	   Compete_Audience,        
	   IQAdShareValue,        
	   Compete_Result,        
	   CompeteURL,         
	   Sentiment,
	   Number_Hits,
	   HighlightingText,      
	   CreatedDate,      
	   ModifiedDate,
	   IQProminence,
	   IQProminenceMultiplier,
	   ArticleStats,
	   ThumbUrl,
	   duplicateID,
	   AM18_24,
	   AM25_34,
	   AM35_44,
	   AM45_54,
	   AM55_64,
	   AM65_Plus,
	   AF18_24,
	   AF25_34,
	   AF35_44,
	   AF45_54,
	   AF55_64,
	   AF65_Plus,
	   v5SubMediaType,
	   isDuplicate
	  )        
        
	  OUTPUT INSERTED.ID AS MediaID,INSERTED.[description] AS Title, 'SM' AS MediaType,INSERTED.feedClass AS Category,CONVERT(NVARCHAR(MAX), INSERTED.HighlightingText) AS HighlightingText, INSERTED.itemHarvestDate_DT AS MediaDate,
	  INSERTED.itemHarvestDate_DT AS LocalDate,
	  INSERTED.IQAgentSearchRequestID AS SearchRequestID,      
	  INSERTED.Sentiment AS Sentiment,1 AS IsActive, INSERTED.IQAdShareValue AS IQMediaValue, INSERTED.Compete_Audience AS Audience,NULL AS PositiveSentiment ,NULL AS NegativeSentiment,INSERTED.Number_Hits AS NumberOfHits, INSERTED.IQProminence AS IQProminence,INSERTED.IQProminenceMultiplier AS IQProminenceMultiplier,
          INSERTED.isDuplicate as isDuplicate INTO @MediaResultTable        
        
	  SELECT         
		 tmp.SeqID,        
		 tmp.IQAgentSearchRequestID,        
		 tmp._QueryVersion,        
		 CONVERT(VARCHAR(MAX),tmp.link),        
		 CONVERT(VARCHAR(255),tmp.homelink),        
		 tmp.[description],        
		 tmp.itemHarvestDate_DT,        
		 --tblXml.c.value('@feedCategories','varchar(max)') as [feedCategories],        
		 tmp.feedClass,        
		 --tblXml.c.value('@feedRank','int') as [feedRank],        
		 tmp.Compete_Audience,        
		 tmp.IQAdShareValue,        
		 tmp.Compete_Result,        
		 CONVERT(VARCHAR(255),tmp.CompeteURL),        
		 tmp.Sentiment,
		 tmp.Number_Hits,
		 tmp.HighlightingText,      
		 GETDATE() AS CreatedDate  ,      
		 GETDATE() AS ModifiedDate, 
		 tmp.IQProminence,
		 tmp.IQProminenceMultiplier,
		 tmp.ArticleStats,        
		 CONVERT(VARCHAR(MAX),tmp.ThumbUrl),
		 tmp.duplicateID,
		 tmp.AM18_24,
		 tmp.AM25_34,
		 tmp.AM35_44,
		 tmp.AM45_54,
		 tmp.AM55_64,
		 tmp.AM65_Plus,
		 tmp.AF18_24,
		 tmp.AF25_34,
		 tmp.AF35_44,
		 tmp.AF45_54,
		 tmp.AF55_64,
		 tmp.AF65_Plus,
		 CASE  tmp.feedClass
		 WHEN 'Blog' THEN 'Blog'
		 WHEN 'Comment' THEN 'Blog'
		 WHEN 'Forum' THEN 'Forum'   
		 WHEN 'Review' THEN 'Forum'  
		 WHEN 'FB' THEN 'FB'
		 WHEN 'IG' THEN 'IG'
		 ELSE 'SocialMedia' END,
		 CASE WHEN tmp.isDuplicate IS NULL THEN 0 ELSE tmp.isDuplicate END
	  FROM          
		@IQAgent_SMResults tmp        
		 LEFT OUTER JOIN IQAgent_SMResults sm WITH(NOLOCK)        
		  ON sm.IQAgentSearchRequestID=tmp.IQAgentSearchRequestID
		     AND sm.SeqID=tmp.SeqID
			 AND sm.IsActive = 1
		 JOIN IQAgent_SearchRequest WITH(NOLOCK)
		   ON tmp.IQAgentSearchRequestID = IQAgent_SearchRequest.ID     
	  WHERE        
		sm.IQAgentSearchRequestID IS NULL AND IQAgent_SearchRequest.IsActive = 1     
		select * from @IQAgent_SMResults
     UPDATE MResult SET   
 PositiveSentiment = (SELECT tblSentiment.c.value('.', 'tinyint') FROM MResult.Sentiment.nodes('/Sentiment/PositiveSentiment') AS tblSentiment(c)) ,        
 NegativeSentiment = (SELECT tblSentiment.c.value('.', 'tinyint') FROM MResult.Sentiment.nodes('/Sentiment/NegativeSentiment') AS tblSentiment(c)),
  Category =   CASE         
     WHEN Category='Blog' OR Category='Comment' THEN 'Blog'
     WHEN Category='Forum' OR Category='Review' THEN 'Forum'     
	 WHEN Category='FB' THEN 'FB'
	 WHEN Category='IG' THEN 'IG'
     ELSE 'SocialMedia' END     ,
	LocalDate = CASE WHEN dbo.fnIsDayLightSaving(LocalDate) = 1 THEN  DATEADD(HOUR,(SELECT gmt + dst FROM Client WHERE ClientGuid = (SELECT ClientGuid FROM IQAgent_SearchRequest WHERE ID = MResult.SearchRequestID)),LocalDate) ELSE DATEADD(HOUR,(SELECT gmt FROM Client WHERE ClientGuid = (SELECT ClientGuid FROM IQAgent_SearchRequest WHERE ID = MResult.SearchRequestID)),LocalDate) END
FROM @MediaResultTable AS MResult     
            
DECLARE @RecordsToInsert VARCHAR(MAX)
 SET @RecordsToInsert = STUFF((SELECT ',' + CONVERT(VARCHAR,MediaID) FROM @MediaResultTable FOR XML PATH('')),1,1,'')   

   INSERT INTO IQAgent_MediaResults        
   (        
    Title,        
    _MediaID,        
    MediaType,  -- Once media type reorganization is done, MediaType and Category should be removed
    Category,        
    HighlightingText,        
    MediaDate,        
    _SearchRequestID,  
    PositiveSentiment,        
    NegativeSentiment,        
    IsActive, 
    IQProminence,
    IQProminenceMultiplier,
	v5MediaType,
	v5Category
   )        
   SELECT         
    CONVERT(VARCHAR(512),Title ),        
    MediaID,        
    MediaType ,         
    Category ,        
    HighlightingText,         
    MediaDate,         
    SearchRequestID ,  
    PositiveSentiment,  
   NegativeSentiment,  
    IsActive, 
    IQProminence,
    IQProminenceMultiplier,
	CASE Category WHEN 'Blog' THEN 'BL' WHEN 'Forum' THEN 'FO' ELSE 'SM' END,
	Category    
   FROM         
    @MediaResultTable        
          
  COMMIT TRANSACTION;        

	-- To Mark the duplicate Article as an Inactive Media rightaway

	UPDATE IQAgent_MediaResults
 		SET IsActive = 0
		FROM IQAgent_MediaResults mr
		JOIN @MediaResultTable tmp ON mr._MediaID = tmp.MediaID 
  		AND mr.MediaType='SM' 
  		AND tmp.isDuplicate = 1
  END TRY        
  BEGIN CATCH       

   IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;        

   DECLARE @IQMediaGroupExceptionKey BIGINT,
				@ExceptionStackTrace VARCHAR(500),
				@ExceptionMessage VARCHAR(500),
				@CreatedBy	VARCHAR(50),
				@ModifiedBy	VARCHAR(50),
				@CreatedDate	DATETIME,
				@ModifiedDate	DATETIME,
				@IsActive	BIT
				
		
		SELECT 
				@ExceptionStackTrace=(ERROR_PROCEDURE()+'_'+CONVERT(VARCHAR(50),ERROR_LINE())),
				@ExceptionMessage=CONVERT(VARCHAR(50),ERROR_NUMBER())+'_'+ERROR_MESSAGE(),
				@CreatedBy='usp_IQAgent_SMResults_InsertList',
				@ModifiedBy='usp_IQAgent_SMResults_InsertList',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
				
		
		-- exec usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@ModifiedBy,@CreatedDate,@ModifiedDate,@IsActive,@IQMediaGroupExceptionKey output
		EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT
  END CATCH     
END



GO


