CREATE PROCEDURE [dbo].[usp_IQAgent_TwitterResults_InsertList]
	@XmlData XML        
AS
BEGIN

SET NOCOUNT OFF;
SET XACT_ABORT ON;

        
  
 BEGIN TRY         
   BEGIN TRANSACTION;       
 DECLARE @MediaResultTable TABLE (MediaID BIGINT,Title NVARCHAR(MAX),MediaType VARCHAR(2), Category VARCHAR(50), HighlightingText NVARCHAR(MAX), MediaDate DATETIME,LocalDate DATETIME, SearchRequestID BIGINT,Sentiment XML, IsActive BIT, IQMediaValue DECIMAL(18,2), Audience BIGINT,
PositiveSentiment INT,NegativeSentiment INT,NumberOfHits BIGINT, IQProminence DECIMAL(18,6),IQProminenceMultiplier DECIMAL(18,6))  

DECLARE @IQAgent_SummaryTrackingID BIGINT                   
    
 INSERT INTO [dbo].[IQAgent_TwitterResults]         
  (           
   TweetID,        
   IQAgentSearchRequestID,        
   _QueryVersion,         
   actor_image,        
   actor_link,        
   actor_followersCount,        
   actor_friendsCount,        
   Summary,        
   tweet_posteddatetime,        
   actor_displayname,        
   actor_preferredname,        
   gnip_klout_score,        
   Sentiment,
   Number_Hits,
   HighlightingText,      
   CreatedDate ,      
   ModifiedDate, 
   IQProminence,
   IQProminenceMultiplier,
   v5SubMediaType     
  )        
          
  OUTPUT INSERTED.ID AS MediaID,NULL AS Title, 'TW' AS MediaType,'TW' AS Category, CONVERT(NVARCHAR(MAX), INSERTED.HighlightingText) AS HighlightingText, INSERTED.tweet_posteddatetime AS MediaDate,
  INSERTED.tweet_posteddatetime AS LocalDate,
  INSERTED.IQAgentSearchRequestID AS SearchRequestID,       
 
  INSERTED.Sentiment AS Sentiment,1 AS IsActive, INSERTED.gnip_klout_score AS IQMediaValue, INSERTED.actor_followersCount AS Audience,NULL AS PositiveSentiment ,NULL AS NegativeSentiment,INSERTED.Number_Hits AS NumberOfHits, INSERTED.IQProminence AS IQProminence,INSERTED.IQProminenceMultiplier AS IQProminenceMultiplier INTO @MediaResultTable        
  SELECT         
     tblXml.c.value('@TweetID','nvarchar(50)') AS [TweetID],        
     tblXml.c.value('@IQAgentSearchRequestID','bigint') AS [IQAgentSearchRequestID],        
     tblXml.c.value('@QueryVersion','int') AS [QueryVersion],        
     tblXml.c.value('@actor_image','nvarchar(max)') AS [actor_image],        
     tblXml.c.value('@actor_link','nvarchar(max)') AS [actor_link],        
     tblXml.c.value('@actor_followersCount','int') AS [actor_followersCount],        
     tblXml.c.value('@actor_friendsCount','int') AS [actor_friendsCount],        
     tblXml.c.value('@Summary','nvarchar(max)') AS [Summary],        
     tblXml.c.value('@tweet_posteddatetime','datetime') AS [tweet_posteddatetime],        
     tblXml.c.value('@actor_displayname','nvarchar(50)') AS [actor_displayname],        
     tblXml.c.value('@actor_preferredname','nvarchar(50)') AS [actor_preferredname],        
     tblXml.c.value('@gnip_klout_score','smallint') AS [gnip_klout_score],        
     CASE WHEN CONVERT(NVARCHAR(MAX), tblXml.c.query('Sentiment')) = '' THEN NULL ELSE tblXml.c.query('Sentiment') END AS [Sentiment],
     tblXml.c.value('@Number_Hits','int') AS [Number_Hits],
     tblXml.c.query('HighlightedTWOutput') AS [HighlightingText]  ,      
     GETDATE () AS CreatedDate,      
     GETDATE () AS ModifiedDate, 
     tblXml.c.value('@IQProminence','DECIMAL(18,6)') AS [IQProminence],
	 tblXml.c.value('@IQProminenceMultiplier','DECIMAL(18,6)') AS [IQProminenceMultiplier],
	 'TW'     
  FROM          
    @XmlData.nodes('/IQAgentTwitterResultsList/IQAgentTwitterResult') AS tblXml(c)        
     LEFT OUTER JOIN IQAgent_TwitterResults WITH(NOLOCK)       
      ON IQAgent_TwitterResults.IQAgentSearchRequestID=tblXml.c.value('@IQAgentSearchRequestID','bigint') AND        
       IQAgent_TwitterResults.TweetID=tblXml.c.value('@TweetID','varchar(50)') AND
	   IQAgent_TwitterResults.IsActive = 1
	 LEFT OUTER JOIN IQAgent_SearchRequest WITH(NOLOCK)
	   ON tblXml.c.value('@IQAgentSearchRequestID','bigint') = IQAgent_SearchRequest.ID
	     
  WHERE        
    IQAgent_TwitterResults.IQAgentSearchRequestID IS NULL AND IQAgent_SearchRequest.IsActive = 1        
            
            
 UPDATE MResult SET   
 PositiveSentiment = (SELECT tblSentiment.c.value('.', 'tinyint') FROM MResult.Sentiment.nodes('/Sentiment/PositiveSentiment') AS tblSentiment(c)) ,        
 NegativeSentiment = (SELECT tblSentiment.c.value('.', 'tinyint') FROM MResult.Sentiment.nodes('/Sentiment/NegativeSentiment') AS tblSentiment(c))  , 
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
    Title,        
    MediaID,        
    MediaType,         
    Category,        
    HighlightingText,         
    MediaDate,         
    SearchRequestID , 
    PositiveSentiment,  
   NegativeSentiment,    
    IsActive, 
    IQProminence,
    IQProminenceMultiplier,
	'SM',
	'TW'
   FROM        
     @MediaResultTable        
        
	COMMIT TRANSACTION;        
  END TRY      
  BEGIN CATCH        
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
				@CreatedBy='usp_IQAgent_TwitterResults_InsertList',
				@ModifiedBy='usp_IQAgent_TwitterResults_InsertList',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1       
  END CATCH        
END
GO


