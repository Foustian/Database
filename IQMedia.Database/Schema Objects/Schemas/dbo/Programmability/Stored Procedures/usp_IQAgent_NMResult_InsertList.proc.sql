CREATE PROCEDURE [dbo].[usp_IQAgent_NMResults_InsertList]         
(        
	@XmlData XML,
	@ClientGUID UNIQUEIDENTIFIER
)
AS        
BEGIN 
        
SET NOCOUNT OFF;        
SET XACT_ABORT ON;
   
BEGIN TRY        
            
DECLARE @MediaResultTable TABLE (MediaID BIGINT,Title NVARCHAR(MAX),MediaType VARCHAR(2), Category VARCHAR(50), HighlightingText NVARCHAR(MAX), MediaDate DATETIME,LocalDate DATETIME, SearchRequestID BIGINT,Sentiment XML, IsActive BIT, IQMediaValue DECIMAL(18,2), Audience BIGINT,
PositiveSentiment INT,NegativeSentiment INT,NumberOfHits BIGINT, IQProminence DECIMAL(18,6),IQProminenceMultiplier DECIMAL(18,6), FeedClass VARCHAR(50), isDuplicate bit, v5MediaType VARCHAR(2), v5Category VARCHAR(50))

DECLARE @QueuedDeleteTable TABLE (ID BIGINT)


DECLARE @IQAgent_NMResults TABLE(
	IQAgentSearchRequestID BIGINT NOT NULL,
	_QueryVersion INT NULL,
	ArticleID VARCHAR(50) NOT NULL,
	Url NVARCHAR(max) NOT NULL,
	Publication VARCHAR(255) NULL,
	Title nVARCHAR(max) NULL,
	harvest_time DATETIME NOT NULL,
	Category VARCHAR(250) NOT NULL,
	Genre VARCHAR(250) NOT NULL,
	DMA_Name VARCHAR(255) NULL,
	Compete_Audience INT NULL,
	IQAdShareValue FLOAT NULL,
	Compete_Result CHAR(1) NULL,
	CompeteURL VARCHAR(255) NULL,
	Sentiment XML NULL,
	Number_Hits INT NULL,
	HighlightingText XML NULL,
	_IQDMAID INT NULL,
	IQLicense TINYINT  NULL,
	IQProminence DECIMAL(18, 6) NULL,
	IQProminenceMultiplier DECIMAL(18, 6) NULL,
	State VARCHAR(100) NULL,
	CountryCode VARCHAR(2) NULL,
	feedClass VARCHAR(50) NULL,
	duplicateID VARCHAR(50) NULL,
	isDuplicate bit NULL,
	AM18_24 INT NULL,
	AM25_34 INT NULL,
	AM35_44 INT NULL,
	AM45_54 INT NULL,
	AM55_64 INT NULL,
	AM65_Plus INT NULL,
	AF18_24 INT NULL,
	AF25_34 INT NULL,
	AF35_44 INT NULL,
	AF45_54 INT NULL,
	AF55_64 INT NULL,
	AF65_Plus INT NULL,
	v5SubMediaType VARCHAR(50)
       )
 -- Get IDs of items that have been queued for deletion, but not yet processed. Used to ensure correct parent/child rollup.

 INSERT INTO @QueuedDeleteTable
 SELECT Deletes.ID.value('.', 'bigint') as ID
 FROM	IQAgent_DeleteControl WITH (NOLOCK)
 CROSS	APPLY statusUpdateData.nodes('add/doc/field[@name="iqseqid"]') as Deletes(ID)
 WHERE	isDBUpdated != 'COMPLETED'
 AND	searchRequestID IS NULL   
 AND	clientGUID = @ClientGUID
    
DECLARE @ClientIQLicense TABLE(IQLicense VARCHAR(50))
    
    IF EXISTS(SELECT VALUE FROM IQClient_CustomSettings WHERE IQClient_CustomSettings._ClientGuid = @ClientGuid AND Field ='IQLicense') 
		BEGIN
			INSERT INTO @ClientIQLicense
			SELECT 
				SplitTbl.Items
			FROM 
				IQClient_CustomSettings CROSS APPLY Split(IQClient_CustomSettings.Value,',') AS SplitTbl
			WHERE					
				IQClient_CustomSettings._ClientGuid = @ClientGuid
				AND Field ='IQLicense' 
		END
	ELSE
		BEGIN
			INSERT INTO @ClientIQLicense
			SELECT 
			SplitTbl.Items
			FROM 
				IQClient_CustomSettings CROSS APPLY Split(IQClient_CustomSettings.Value,',') AS SplitTbl
			WHERE					
				IQClient_CustomSettings._ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER)
				AND Field ='IQLicense' 
		END
    
DECLARE @StopWatch DATETIME,@SPStartTime DATETIME,@SPTrackingID UNIQUEIDENTIFIER, @TimeDiff DECIMAL(18,2),@SPName VARCHAR(100),@QueryDetail VARCHAR(500)
SET @SPStartTime=GETDATE()
SET @Stopwatch=GETDATE()
SET @SPTrackingID = NEWID()
SET @SPName ='usp_IQAgent_NMResults_InsertList'

 INSERT INTO @IQAgent_NMResults    
		  (           
		   ArticleID,        
		   IQAgentSearchRequestID,        
		   _QueryVersion,         
		   Url,
		   Publication,
		   Title,
		   harvest_time,
		   Category,
		   Genre,
		   DMA_Name,
		   Compete_Audience,
		   IQAdShareValue,
		   Compete_Result,
		   CompeteURL,         
		   Sentiment,
		   Number_Hits,
		   HighlightingText,      
		   _IQDmaID,
		   IQLicense,
		   IQProminence,
		   IQProminenceMultiplier,
		   State,
		   CountryCode,
		   FeedClass,
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
             
		  SELECT         
			 tblXml.c.value('@ArticleID','varchar(50)') AS [ArticleID],        
			 tblXml.c.value('@IQAgentSearchRequestID','bigint') AS [IQAgentSearchRequestID],        
			 tblXml.c.value('@QueryVersion','int') AS [QueryVersion],        
			 tblXml.c.value('@Url','nvarchar(max)') AS [Url],        
			 tblXml.c.value('@Publication','varchar(255)') AS [Publication],        
			 tblXml.c.value('@Title','nvarchar(max)') AS [Title],        
			 tblXml.c.value('@harvest_time','datetime') AS [harvest_time],        
			 tblXml.c.value('@Category','varchar(250)') AS [Category],        
			 tblXml.c.value('@Genre','varchar(250)') AS [Genre],        
			 tblXml.c.value('@DMA_Name','varchar(250)') AS [DMA_Name],        
			 CASE WHEN tblXml.c.value('@Compete_Audience','int') = '' THEN NULL ELSE tblXml.c.value('@Compete_Audience','int') END,        
			 CASE WHEN tblXml.c.value('@IQAdShareValue','float') = '' THEN NULL ELSE tblXml.c.value('@IQAdShareValue','float') END,        
			 CASE WHEN tblXml.c.value('@Compete_Result','char(1)') = '' THEN NULL ELSE tblXml.c.value('@Compete_Result','char(1)') END,        
			 tblXml.c.value('@CompeteURL','varchar(255)') AS [CompeteURL],        
			 CASE WHEN CONVERT(NVARCHAR(MAX), tblXml.c.query('Sentiment')) = '' THEN NULL ELSE tblXml.c.query('Sentiment') END AS [Sentiment],
			 tblXml.c.value('@Number_Hits','int') AS [Number_Hits],
			 CASE WHEN CONVERT(NVARCHAR(MAX), tblXml.c.query('HighlightedNewsOutput')) = '' THEN NULL ELSE tblXml.c.query('HighlightedNewsOutput') END AS [HighlightingText]  ,    
			 tblXml.c.value('@_IQDmaID','int') AS [_IQDmaID],
			 tblXml.c.value('@IQLicense','tinyint') AS [IQLicense],
			 tblXml.c.value('@IQProminence','DECIMAL(18,6)') AS [IQProminence],
			 tblXml.c.value('@IQProminenceMultiplier','DECIMAL(18,6)') AS [IQProminenceMultiplier],
			 CASE WHEN tblXml.c.value('@State','varchar(100)') = '' THEN NULL ELSE tblXml.c.value('@State','varchar(100)') END,  
			 CASE WHEN tblXml.c.value('@CountryCode','varchar(2)') = '' THEN NULL ELSE tblXml.c.value('@CountryCode','varchar(2)') END,
			 tblXml.c.value('@FeedClass','varchar(50)'),
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
			 CASE tblXml.c.value('@FeedClass', 'varchar(50)') WHEN 'Print' THEN 'LN' ELSE 'NM' END,
			  (SELECT DISTINCT 1 FROM IQAgent_NMResults WITH (NOLOCK) WHERE duplicateID = tblXml.c.value('@duplicateID','varchar(50)')
                                                    AND IQAgentSearchRequestID = tblXml.c.value('@IQAgentSearchRequestID','bigint')
                                                    AND Publication = tblXml.c.value('@Publication','varchar(255)')
													AND v5SubMediaType = CASE tblXml.c.value('@FeedClass', 'varchar(50)') WHEN 'Print' THEN 'LN' ELSE 'NM' END
					            AND IsActive = 1)
		  FROM          
			@XmlData.nodes('/IQAgentNMResultsList/IQAgentNMResult') AS tblXml(c)
				JOIN @ClientIQLicense AS templicense
				ON templicense.IQLicense = tblXml.c.value('@IQLicense','varchar(50)')
   		
		 
		 UPDATE @IQAgent_NMResults
					 SET isDuplicate = 1
				FROM @IQAgent_NMResults b 
				   JOIN ( SELECT MIN(ArticleID) AS MinArticleID, duplicateID ,Publication, IQAgentSearchRequestID, v5SubMediaType
									   FROM @IQAgent_NMResults GROUP BY duplicateID ,Publication,IQAgentSearchRequestID, v5SubMediaType
									   HAVING COUNT(1) > 1)  a
					ON  a.duplicateID = b.duplicateID
					AND b.ArticleID > a.MinArticleID
					AND b.IQAgentSearchRequestID = a.IQAgentSearchRequestID
					AND b.Publication = a.Publication
					AND b.v5SubMediaType = a.v5SubMediaType

  SET @QueryDetail ='insert into @IQAgent_NMResults table'
  SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
  INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
  SET @Stopwatch = GETDATE()  

BEGIN TRANSACTION;

 INSERT INTO [dbo].[IQAgent_NMResults]         
		  (           
		   ArticleID,        
		   IQAgentSearchRequestID,        
		   _QueryVersion,         
		   Url,
		   Publication,
		   Title,
		   harvest_time,
		   Category,
		   Genre,
		   DMA_Name,
		   Compete_Audience,
		   IQAdShareValue,
		   Compete_Result,
		   CompeteURL,         
		   Sentiment,
		   Number_Hits,
		   HighlightingText,      
		   _IQDmaID,
		   IQLicense,
		   IQProminence,
		   IQProminenceMultiplier,
		   "State",
		   CountryCode,
		   FeedClass,
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
        
		  OUTPUT INSERTED.ID AS MediaID,INSERTED.Title AS Title, 'NM' AS MediaType,'NM' AS Category,CONVERT(NVARCHAR(MAX), INSERTED.HighlightingText )AS HighlightingText, 
		  INSERTED.harvest_time AS MediaDate,
		  INSERTED.harvest_time AS LocalDate,
		  INSERTED.IQAgentSearchRequestID AS SearchRequestID,      
		  INSERTED.Sentiment AS Sentiment, 1 AS IsActive,INSERTED.IQAdShareValue AS IQMediaValue, INSERTED.Compete_Audience AS Audience, NULL AS PositiveSentiment ,
		  NULL AS	NegativeSentiment,INSERTED.Number_Hits AS NumberOfHits, 
		  INSERTED.IQProminence AS IQProminence,INSERTED.IQProminenceMultiplier AS IQProminenceMultiplier, INSERTED.FeedClass AS FeedClass, 
		  INSERTED.isDuplicate as isDuplicate, CASE INSERTED.feedClass WHEN 'Print' THEN 'PR' ELSE 'NM' END AS v5MediaType, CASE INSERTED.feedClass WHEN 'Print' THEN 'LN' ELSE 'NM' END AS v5Category
		  INTO @MediaResultTable
        
		  SELECT         
			 tmp.ArticleID,        
			 tmp.IQAgentSearchRequestID,        
			 tmp._QueryVersion,        
			 tmp.Url,        
			 tmp.Publication,        
			 tmp.Title,        
			 tmp.harvest_time,        
			 tmp.Category,        
			 tmp.Genre,        
			 tmp.DMA_Name,        
			 tmp.Compete_Audience,
			 tmp.IQAdShareValue,        
			 tmp.Compete_Result,        
			 tmp.CompeteURL,        
			 tmp.Sentiment,
			 tmp.Number_Hits,
			 tmp.HighlightingText  ,    
			 tmp._IQDmaID,
			 tmp.IQLicense,
			 tmp.IQProminence,
			 tmp.IQProminenceMultiplier,
			 tmp."State",  
			 tmp.CountryCode,
			 tmp.FeedClass,
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
			 CASE WHEN tmp.FeedClass = 'Print' THEN 'LN' ELSE 'NM' END,
			 CASE WHEN tmp.isDuplicate IS NULL THEN 0 ELSE tmp.isDuplicate END
		  FROM          
			@IQAgent_NMResults tmp
				LEFT OUTER JOIN IQAgent_NMResults nm WITH (NOLOCK)
						ON nm.IQAgentSearchRequestID = tmp.IQAgentSearchRequestID      
						AND nm.ArticleID = tmp.ArticleID
						AND nm.IsActive = 1
				 JOIN IQAgent_SearchRequest WITH (NOLOCK) ON
						tmp.IQAgentSearchRequestID    = IQAgent_SearchRequest.ID  
						AND IQAgent_SearchRequest.IsActive = 1
			 WHERE nm.IQAgentSearchRequestID IS NULL

  UPDATE MResult SET   
 PositiveSentiment = (SELECT tblSentiment.c.value('.', 'tinyint') FROM MResult.Sentiment.nodes('/Sentiment/PositiveSentiment') AS tblSentiment(c)) ,        
 NegativeSentiment = (SELECT tblSentiment.c.value('.', 'tinyint') FROM MResult.Sentiment.nodes('/Sentiment/NegativeSentiment') AS tblSentiment(c))  ,
 LocalDate = CASE WHEN dbo.fnIsDayLightSaving(LocalDate) = 1 THEN  DATEADD(HOUR,(SELECT gmt + dst FROM Client WHERE ClientGuid = (SELECT ClientGuid FROM IQAgent_SearchRequest WHERE ID = MResult.SearchRequestID)),LocalDate) ELSE DATEADD(HOUR,(SELECT gmt FROM Client WHERE ClientGuid = (SELECT ClientGuid FROM IQAgent_SearchRequest WHERE ID = MResult.SearchRequestID)),LocalDate) END 
FROM @MediaResultTable AS MResult      
    
  SET @QueryDetail ='update MResult for Positive/Negative Sentiment and Local date'
  SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
  INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
  SET @Stopwatch = GETDATE()        
     
 DECLARE @RecordsToInsert VARCHAR(MAX)
 SET @RecordsToInsert = STUFF((SELECT ',' + CONVERT(VARCHAR,MediaID) FROM @MediaResultTable FOR XML PATH('')),1,1,'')
 
   DECLARE @MediaIDs TABLE(ID BIGINT,MediaID BIGINT)
    
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
   OUTPUT inserted.ID,inserted._MediaID INTO @MediaIDs
   SELECT         
    Title ,        
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
	v5MediaType,
	v5Category
   FROM        
     @MediaResultTable        
      
    SET @QueryDetail ='insert into iqagent media results table from temp media result table'
	SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
	INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
	SET @Stopwatch = GETDATE()    
        
	DECLARE @SecondsOnDay INT= 86400
	DECLARE @2DaysTotalSeconds INT= 172800

	CREATE TABLE #ParentTbl
	(
		ID	BIGINT,
		_MediaID	BIGINT,
		Title	NVARCHAR(MAX),
		MediaDate	DATETIME,
		_SearchRequestID	BIGINT,
		v5Category VARCHAR(50)	
	)
	
	DECLARE @MinMediaDate DATETIME2, @MaxMediaDate DATETIME2,@MinSearchRequestID BIGINT
	
	SELECT
		@MinMediaDate=MIN(MediaDate),
		@MinSearchRequestID=MIN(SearchRequestID),
		@MaxMediaDate=MAX(MediaDate)
	FROM
		@MediaResultTable 
		
	SET @MinMediaDate= DATEADD(ms,-172800000,@MinMediaDate)
		
	INSERT INTO #ParentTbl
	(
		ID,
		_MediaID,
		Title,
		MediaDate,
		_SearchRequestID,
		v5Category
	)
	SELECT
		ID,
		_MediaID,
		Title,
		MediaDate,
		@MinSearchRequestID,
		v5Category
	FROM
		IQAgent_MediaResults WITH (NOLOCK)
	WHERE
			_SearchRequestID=@MinSearchRequestID
		AND MediaDate >= @MinMediaDate AND MediaDate <= @MaxMediaDate
		AND IsActive=1
		AND _ParentID IS NULL
		AND NOT EXISTS (SELECT NULL FROM @QueuedDeleteTable delTbl WHERE delTbl.ID = IQAgent_MediaResults.ID) -- Ignore items that have been queued for deletion but not yet processed
   
	DECLARE @MediaGroupTable TABLE (MediaID BIGINT, Title VARCHAR(MAX), MediaDate DATETIME, SearchRequestID BIGINT,_ParentRecordID BIGINT,GroupRank INT, v5Category VARCHAR(50))  
	
	INSERT INTO @MediaGroupTable
	(
		MediaID,
		Title,
		MediaDate,
		SEarchRequestID,
		_ParentRecordID,
		v5Category
	)
	SELECT
		mIDs.ID,
		mTBL.Title,
		m2.MEdiaDate,
		mTBL.SearchRequestID,
		m2.id,
		mTBl.v5Category
	FROM
		@MediaResultTable AS mTBL
			INNER JOIN @MediaIDs AS mIDs 
				ON mTBL.MediaID  = mIDs.MediaID
		INNER JOIN
			#ParentTbl m2 WITH(NOLOCK)
				ON mTBL.title=  m2.title
				AND mTBL.SearchRequestID = m2._searchrequestid
		AND ((CAST(mTBL.mediadate AS FLOAT) - (CAST(m2.mediadate AS FLOAT))) * @SecondsOnDay) >= 0 AND  ((CAST(mTBL.mediadate AS FLOAT) - (CAST(m2.mediadate AS FLOAT))) * @SecondsOnDay) <= @2DaysTotalSeconds
		AND mIDs.ID != m2.ID
		AND m2.v5Category = mTBL.v5Category
		

	ORDER BY m2.mediadate,m2.id
	
	SET @QueryDetail ='populate @MediaGroupTable from temp media result table and media result table to find parent / child relations'
	SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
	INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
	SET @Stopwatch = GETDATE()  

	DECLARE @RankID INT,@LastDate DATETIME

	SET @RankID  =1

	UPDATE 
			@MediaGroupTable
	SET
			@RankID  = CASE WHEN ((CAST(MediaDate AS FLOAT) - (CAST(@LastDate AS FLOAT))) * @SecondsOnDay) > @2DaysTotalSeconds THEN @RankID + 1  ELSE @RankID END,
			@LastDate = CASE WHEN ((CAST(MediaDate AS FLOAT) - (CAST(@LastDate AS FLOAT))) * @SecondsOnDay) > @2DaysTotalSeconds  OR @LastDate IS NULL THEN MediaDate ELSE @LastDate END,
			GroupRank = @RankID

	SET @QueryDetail ='update @MediaGroupTable table for group rank'
	SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
	INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
	SET @Stopwatch = GETDATE()  	

	DECLARE @MT TABLE (MediaID BIGINT, Title VARCHAR(500), SearchRequestID BIGINT, GroupRank INT)

	INSERT INTO @MT
	(
		Title,
		SearchRequestID,
		MediaID,	
		GroupRank
	)
	SELECT 
		Title,
		SearchRequestID,
		MID,
		GroupRank
	FROM
		(
			SELECT DISTINCT
				ROW_NUMBER() OVER (PARTITION BY mtbl.SearchRequestID, mtbl.Title,mtbl.GroupRank,mtbl.v5Category ORDER BY mediadate ASC,_ParentRecordID ASC) AS RowNumner,
				mtbl.Title,
				mtbl.SearchRequestID,
				_ParentRecordID AS MID,
				mtbl.GroupRank
			FROM   
				@MediaGroupTable mtbl 
		) AS A
	WHERE RowNumner = 1

	SET @QueryDetail ='populate @MT from @MediaGroupTable table for all parent records'
	SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
	INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
	SET @Stopwatch = GETDATE()  	

	DECLARE @Child TABLE(MediaID BIGINT, ParentMediaID BIGINT, ParentIsRead BIT)

	INSERT INTO @Child
	(
		MediaID,
		ParentMediaID,
		ParentIsRead
	)
	SELECT
		DISTINCT 
			MRTbl.MediaID,
			MTbl.MediaID AS ParentMediaID,
			IQAgent_MediaResults.IsRead AS ParentIsRead
	FROM
			@MediaGroupTable AS MRTbl
				INNER JOIN @MT AS MTbl
				 ON MRTbl._ParentRecordID = MTbl.MediaID
				 AND MRTbl.MediaID != MTbl.MediaID
				 AND MRTbl.GroupRank = MTbl.GroupRank
				INNER JOIN IQAgent_MediaResults WITH (NOLOCK)
				 ON IQAgent_MediaResults.ID = MTbl.MediaID

	SET @QueryDetail ='populate @Child using join of @MediaGroupTable and @MT table for parent / child mappings'
	SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
	INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
	SET @Stopwatch = GETDATE()

	UPDATE IQAgent_MediaResults WITH (ROWLOCK)
		SET _ParentID=CASE WHEN ID=Child.ParentMediaID THEN NULL ELSE Child.ParentMediaID END,
			IsRead = CASE WHEN ID = Child.ParentMediaID THEN 0 ELSE Child.ParentIsRead END
	FROM
		IQAgent_MediaResults
			INNER JOIN @Child AS Child
				ON IQAgent_MediaResults.ID=Child.MediaID

   SET @QueryDetail ='update IQAgent_MediaResults table for parent id using join of @Child table'
	SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
	INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
	SET @Stopwatch = GETDATE()  

         
   COMMIT TRANSACTION;        

       -- To Mark the duplicate Article as an Inactive Media rightaway

	UPDATE IQAgent_MediaResults WITH (ROWLOCK)
 		SET IsActive = 0
		FROM IQAgent_MediaResults mr
		JOIN @MediaResultTable tmp ON mr._MediaID = tmp.MediaID 
  		AND mr.v5Category = tmp.v5Category
  		AND tmp.isDuplicate = 1

   RETURN 0
END TRY        
BEGIN CATCH        
        
   IF @@TRANCOUNT    > 0
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
				@CreatedBy='usp_IQAgent_NMResults_InsertList',
				@ModifiedBy='usp_IQAgent_NMResults_InsertList',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
				
		
		EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT
  END CATCH      
  
  SET @QueryDetail ='0'
	  SET @TimeDiff = DATEDIFF(ms, @SPStartTime, GETDATE())
	  INSERT INTO IQ_SPTimeTracking([Guid],SPName,INPUT,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,'<Input><XmlData>'+ CONVERT(NVARCHAR(MAX),@XmlData) +'</XmlData></Input>',@QueryDetail,@TimeDiff)
    RETURN -1
END


