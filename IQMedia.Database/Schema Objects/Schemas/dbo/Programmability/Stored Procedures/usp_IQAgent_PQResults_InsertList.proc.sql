CREATE PROCEDURE [dbo].[usp_IQAgent_PQResults_InsertList]             
(        
	@XmlData XML,
	@IQAgentSearchRequestID BIGINT                
)
AS        
BEGIN         
 SET NOCOUNT ON;        
 SET XACT_ABORT ON;
 
 DECLARE @StopWatch DATETIME, @SPStartTime DATETIME,@SPTrackingID UNIQUEIDENTIFIER, @TimeDiff DECIMAL(18,2),@SPName VARCHAR(100),@QueryDetail VARCHAR(500)
 
 SET @SPStartTime=GETDATE()
 SET @Stopwatch=GETDATE()
 SET @SPTrackingID = NEWID()
 SET @SPName ='usp_IQAgent_PQResults_InsertList'
        
 BEGIN TRANSACTION;        
 BEGIN TRY        
 
	IF OBJECT_ID('tempdb..#PQMediaResultTable') IS NOT NULL
	BEGIN
		DROP TABLE #PQMediaResultTable
	END
        
	CREATE TABLE #PQMediaResultTable
	(
		ProQuestID BIGINT,
		MediaID BIGINT,
		Title NVARCHAR(255),
		MediaType VARCHAR(2),
		Category VARCHAR(2),
		HighlightingText xml,
		MediaDate DATETIME,
		LocalDate DATE,
		HourDateTime DATETIME,
		DayDate DATE,
		SearchRequestID BIGINT,
		Sentiment XML,
		IsActive BIT,
		PositiveSentiment TINYINT,
		NegativeSentiment TINYINT,
		NumberOfHits INT,
		LanguageNum SMALLINT,
		QueryVersion INT,
		Publication VARCHAR(MAX),
		AvailableDate DATETIME,
		MediaCategory NVARCHAR(MAX),
		Authors XML,
		Copyright VARCHAR(250),
		ContentHTML	VARCHAR(MAX),
		IQProminence DECIMAL(18,6),
		IQProminenceMultiplier DECIMAL(18,6),
		v5SubMediaType VARCHAR(50)
	)

	DECLARE @ClientGuid UNIQUEIDENTIFIER , @gmt INT,@dst INT, @MaxSeqID DECIMAL(25,0)


	SELECT 
		@ClientGuid = Client.ClientGuid ,
		@gmt = gmt,
		@dst = dst
	FROM 
		IQAgent_SearchRequest 
			INNER JOIN Client
				ON IQAgent_SearchRequest.ClientGuid = Client.ClientGuid
	WHERE 
		IQAgent_SearchRequest.ID = @IQAgentSearchRequestID

	SET @QueryDetail ='Get ClientGuid, gmt and dst offset from client using iqagent search request'

	SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
	INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
	SET @Stopwatch = GETDATE()

	INSERT INTO #PQMediaResultTable
	(
		ProQuestID,
		Title,
		MediaType, 		
		Category,
		HighlightingText, 
		MediaDate,		
		LocalDate, 
		SearchRequestID,
		Sentiment, 
		IsActive, 		
		PositiveSentiment,
		NegativeSentiment,
		NumberOfHits,
		LanguageNum, 		
		QueryVersion,		
		Publication ,
		AvailableDate,
		MediaCategory,
		Authors,
		Copyright,
		ContentHTML,
		IQProminence,
		IQProminenceMultiplier,
		v5SubMediaType
	)       
	SELECT         
		tblXml.c.value('@ProQuestID','bigint') AS [ProQuestID],
		 tblXml.c.value('@Title','nvarchar(255)') AS [Title],       
		 'PQ',
		 'PQ',
		 CASE WHEN CONVERT(VARCHAR(MAX), tblXml.c.query('HighlightedPQOutput')) = '' THEN NULL ELSE tblXml.c.query('HighlightedPQOutput') END AS [HighlightingText],      
		 tblXml.c.value('@MediaDate','datetime2') AS [MediaDate],        
		 CONVERT(DATE,CASE WHEN dbo.fnIsDayLightSaving(tblXml.c.value('@MediaDate','datetime2')) = 1 THEN  DATEADD(HOUR,(@gmt + @dst),tblXml.c.value('@MediaDate','datetime2')) ELSE DATEADD(HOUR,@gmt,tblXml.c.value('@MediaDate','datetime2')) END) ,
		 @IQAgentSearchRequestID AS [IQAgentSearchRequestID],      
		 CASE WHEN CONVERT(VARCHAR(MAX), tblXml.c.query('Sentiment')) = '' THEN NULL ELSE tblXml.c.query('Sentiment') END AS [Sentiment],
		 1,
		 tblXml.c.query('Sentiment/PositiveSentiment').value('.','tinyint'),
		 tblXml.c.query('Sentiment/NegativeSentiment').value('.','tinyint'),
		 tblXml.c.value('@Number_Hits','int') AS [Number_Hits], 
		 tblXml.c.value('@LanguageNum','smallint') AS [LanguageNum], 
		 tblXml.c.value('@QueryVersion','int') AS [QueryVersion],             
		 tblXml.c.value('@Publication','varchar(max)') AS [Publication],        
		 tblXml.c.value('@availabledate','datetime2') AS [AvailableDate],        
		 tblXml.c.value('@MediaCategory','nvarchar(max)') AS [mediacategory],        
		 CASE WHEN CONVERT(VARCHAR(MAX), tblXml.c.query('authors')) = '' THEN NULL ELSE tblXml.c.query('authors') END AS [Authors],
		 tblXml.c.value('@copyright','varchar(250)') AS [Copyright],
		 tblXml.c.value('@contenthtml','varchar(max)') AS [ContentHTML],
		 tblXml.c.value('@IQProminence','DECIMAL(18,6)') AS [IQProminence],
	     tblXml.c.value('@IQProminenceMultiplier','DECIMAL(18,6)') AS [IQProminenceMultiplier],
		 'PQ'
	 FROM          
		@XmlData.nodes('/IQAgentPQResultsList/IQAgentPQResult') AS tblXml(c)        		  
    				
	SET @QueryDetail ='populate temp PQ table'
	SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
	INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
	SET @Stopwatch = GETDATE()
    
   
	DELETE PQtbl FROM 
		#PQMediaResultTable AS PQtbl
			INNER JOIN IQAgent_PQResults 
				ON IQAgent_PQResults.IQAgentSearchRequestID = PQtbl.SearchRequestID        
				AND IQAgent_PQResults.ProQuestID = PQtbl.ProQuestID
				AND IQAgent_PQResults.IsActive = 1
			INNER JOIN IQAgent_SearchRequest ON
				PQtbl.SearchRequestID = IQAgent_SearchRequest.ID      
	WHERE        
		IQAgent_SearchRequest.IsActive = 1    
		
		
	SET @QueryDetail ='delete records from temp PQ table , by using join of agent PQ table.'
	SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
	INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
	SET @Stopwatch = GETDATE()
		
	IF OBJECT_ID('tempdb..#TempPQMediaIDs') IS NOT NULL
		DROP TABLE #TempPQMediaIDs
		
	CREATE TABLE #TempPQMediaIDs(MediaID BIGINT,ProQuestID BIGINT ,SearchRequestID BIGINT)
		
	INSERT INTO [dbo].[IQAgent_PQResults]         
	(           
		ProQuestID,        
		IQAgentSearchRequestID,        
		_QueryVersion,         
		Publication,        
		Title,        
		availabledate,
		mediacategory,
		mediadate,
		Number_Hits,
		LanguageNum,
		Authors,
		Sentiment,
		HighlightingText,      
		CreatedDate,      
		ModifiedDate,
		Copyright,
		ContentHTML,
		IQProminence,
		IQProminenceMultiplier,
		v5SubMediaType	
	)    
	OUTPUT INSERTED.ID AS MediaID, INSERTED.ProQuestID AS ProQuestID,INSERTED.IQAgentSearchRequestID AS SearchRequestID INTO #TempPQMediaIDs    
	SELECT
		ProQuestID,
		SearchRequestID,
		QueryVersion,		
		Publication,
		Title,
		AvailableDate,
		MediaCategory,
		MediaDate,	
		NumberOfHits,
		LanguageNum, 		
		Authors,
		Sentiment, 		
		HighlightingText, 
		SYSDATETIME(),
		SYSDATETIME(),
		Copyright,
		ContentHTML,
		IQProminence,
		IQProminenceMultiplier,
		v5SubMediaType
	FROM 
		#PQMediaResultTable   
		
		
	SET @QueryDetail ='insert into IQAgent_PQResults table from temporary PQ table'
	SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
	INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
	SET @Stopwatch = GETDATE()
   
	UPDATE 
		#PQMediaResultTable
	SET	
		 MediaID = temptbl.MediaID,
		 HourDateTime=DATEADD(HOUR,DATEPART(HOUR,MediaDate),CONVERT(VARCHAR(10),MediaDate,101)),
		 DayDate=CONVERT(DATE,MediaDate)
	FROM
		#PQMediaResultTable AS PQtbl 
			INNER JOIN #TempPQMediaIDs AS temptbl
				ON PQtbl.ProQuestID = temptbl.ProQuestID
				AND PQtbl.SearchRequestID = temptbl.SearchRequestID			
				
	SET @QueryDetail ='update MediaID in temp PQ table for newly inserted records, using join of temp mediaid table'
	SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
	INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
	SET @Stopwatch = GETDATE()
 
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
		Category,
		Convert(nvarchar(max),HighlightingText),
		MediaDate,         
		SearchRequestID ,
		PositiveSentiment,  
		NegativeSentiment,  
		IsActive,
		IQProminence,
		IQProminenceMultiplier,
		'PR',
		'PQ'
	FROM        
		#PQMediaResultTable               
        
    SET @QueryDetail ='insert into iqagent media results table from temp PQ table'
	SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
	INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
	SET @Stopwatch = GETDATE()  		

/*  July 2015  Note: Updating Day and Hour Summary tables are thru a dirty table process 
		
	--IQ Hours Report Update      
	UPDATE 
		IQHRS   
	SET 
		IQHRS.NoOfDocs = (IQHRS.NoOfDocs + IQHRSTmp.Number_Docs ) ,      
		IQHRS.PositiveSentiment = (ISNULL(IQHRS.PositiveSentiment,0) + IQHRSTmp.PositiveSentiment) ,   
		IQHRS.NegativeSentiment = (ISNULL(IQHRS.NegativeSentiment,0) + IQHRSTmp.NegativeSentiment) ,
		IQHRS.NoOfHits = (IQHRS.NoOfHits+Number_Of_Hits)     
	FROM 
		IQAgent_HourSummary AS IQHRS      
			INNER JOIN 
			(      
				SELECT             
					@ClientGUID AS ClientGUID,      
					HourDateTime AS GMT_DateTime,      
					MResult.MediaType AS MediaType,      
					MResult.SearchRequestID,
					COUNT(*) AS Number_Docs,      
					SUM(ISNULL(MResult.NumberOfHits,0)) AS Number_Of_Hits,     
					SUM (ISNULL(MResult.PositiveSentiment,0)) AS PositiveSentiment,         
					SUM (ISNULL(MResult.NegativeSentiment ,0)) AS NegativeSentiment ,
					MResult.category AS SubMediaType              
				FROM 
					#PQMediaResultTable AS MResult        
				GROUP BY      
					HourDateTime,MResult.SearchRequestID,MResult.MediaType,MResult.category
			) AS IQHRSTmp
				 ON IQHRS.ClientGuid = IQHRSTmp.ClientGUID 
				AND IQHRS.MediaType = IQHRSTmp.MediaType 
				AND IQHRS.HourDateTime = IQHRSTmp.GMT_DateTime      
				AND IQHRS.SubMediaType = IQHRSTmp.SubMediaType
				AND IQHRS._SearchRequestID = IQHRSTmp.SearchRequestID
         
         
	 SET @QueryDetail ='update hour summary table to update no of docs and other counts for newly inserted record'
	 SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
	 INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
	 SET @Stopwatch = GETDATE()  	
          
	--IQ Hours Report Insert      
	INSERT INTO IQAgent_HourSummary      
	(      
		ClientGuid,      
		HourDateTime,      
		MediaType,      
		NoOfDocs,      
		NoOfHits,         
		PositiveSentiment,  
		NegativeSentiment,
		SubMediaType ,
		_SearchRequestID,
		Audience,
		IQMediaValue
	)      
	     
	SELECT             
		@ClientGUID AS ClientGUID,      
		MResult.HourDateTime,      
		MResult.MediaType AS MediaType,      
		COUNT(*) AS NoOfDocs,      
		SUM(ISNULL(MResult.NumberOfHits,0)) AS NoOfHits,  
		SUM(ISNULL(MResult.PositiveSentiment,0)) AS PositiveSentiment,         
		SUM(ISNULL(MResult.NegativeSentiment ,0)) AS NegativeSentiment,
		MResult.category AS SubMediaType,
		MResult.SearchRequestID,
		0,
		0
	FROM 
		#PQMediaResultTable AS MResult  
			LEFT OUTER JOIN IQAgent_HourSummary AS IQHRS WITH(NOLOCK) 
				ON IQHRS.ClientGuid = @ClientGUID 
				AND IQHRS.MediaType = MResult.MediaType 
				AND IQHRS.HourDateTime =  MResult.HourDateTime 
				AND IQHRS.SubMediaType = MResult.category
				AND IQHRS._SearchRequestID = MResult.SearchRequestID
	WHERE 
		IQHRS.ID IS NULL  
	GROUP BY      
		MResult.HourDateTime,MResult.SearchRequestID, MResult.MediaType,MResult.category
       
	SET @QueryDetail ='insert in hour summary table for day dates which not already exist'
	SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
	INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
	SET @Stopwatch = GETDATE() 
    
	--IQ Day Report Update      
	UPDATE 
		IQDay   
	SET 
		IQDay.NoOfDocs = (IQDay.NoOfDocs + IQDayTmp.Number_Docs ) ,      
		IQDay.PositiveSentiment = (ISNULL(IQDay.PositiveSentiment,0) + IQDayTmp.PositiveSentiment) ,   
		IQDay.NegativeSentiment = (ISNULL(IQDay.NegativeSentiment,0) + IQDayTmp.NegativeSentiment) ,         
		IQDay.NoOfHits =  IQDay.NoOfHits + Number_Of_Hits
	FROM 
		IQAgent_DaySummary AS IQDay      
			INNER JOIN 
			(      
				SELECT             
					@ClientGUID AS ClientGUID,      
					DayDate  AS GMT_DateTime,      
					MResult.MediaType AS MediaType,   
					MResult.SearchRequestID,   
					COUNT(*) AS Number_Docs,      
					SUM(ISNULL(MResult.NumberOfHits,0)) AS Number_Of_Hits,     
					SUM (ISNULL(MResult.PositiveSentiment,0)) AS PositiveSentiment,         
					SUM (ISNULL(MResult.NegativeSentiment,0)) AS NegativeSentiment ,                  
					MResult.category AS SubMediaType  
				FROM 
					#PQMediaResultTable AS MResult      
				GROUP BY      
					DayDate,MResult.SearchRequestID ,MResult.MediaType, MResult.category
			) AS IQDayTmp 
				ON IQDay.ClientGuid = IQDayTmp.ClientGUID 
				AND IQDay.MediaType = IQDayTmp.MediaType 
				AND IQDay.DayDate = IQDayTmp.GMT_DateTime      
				AND IQDay.SubMediaType = IQDayTmp.SubMediaType       
				AND IQDay._SearchRequestID = IQDayTmp.SearchRequestID
 
	SET @QueryDetail ='update day summary table to update no of docs and other counts for newly inserted record'
	SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
	INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
	SET @Stopwatch = GETDATE()  	
        
	--IQ Day Report Insert      
	INSERT INTO IQAgent_DaySummary    
	(      
		ClientGuid,      
		DayDate,      
		MediaType,      
		NoOfDocs,      
		NoOfHits,          
		PositiveSentiment,  
		NegativeSentiment,
		NoOfDocsLD,      
		NoOfHitsLD,          
		PositiveSentimentLD,  
		NegativeSentimentLD,
		SubMediaType ,
		_SearchRequestID,
		Audience,
		IQMediaValue
	)      	  
	SELECT             
		@ClientGUID AS ClientGUID,      
		MResult.DayDate,      
		MResult.MediaType,      
		COUNT(*) AS NoOfDocs,      
		SUM(ISNULL(MResult.NumberOfHits,0)) AS NoOfHits,  
		SUM (ISNULL(MResult.PositiveSentiment,0)) AS PositiveSentiment,         
		SUM (ISNULL(MResult.NegativeSentiment,0)) AS NegativeSentiment,
		0,
		0,
		0,  
		0,
		MResult.category AS SubMediaType,
		MResult.SearchRequestID,
		0,
		0
	FROM 
		#PQMediaResultTable AS MResult       
			LEFT OUTER JOIN IQAgent_DaySummary AS IQDay WITH(NOLOCK) 
				ON  IQDay.ClientGuid = @ClientGUID
				AND IQDay.MediaType = MResult.MediaType 
				AND IQDay.DayDate =  MResult.DayDate
				AND IQDay.SubMediaType = MResult.category
				AND IQDay._SearchRequestID = MResult.SearchRequestID
	WHERE 
		IQDay.ID IS NULL      
	GROUP BY     
		MResult.DayDate,MResult.SearchRequestID,MResult.MediaType,MResult.category
            
			
	SET @QueryDetail ='insert in day summary table for day dates which not already exist'
	SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
	INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
	SET @Stopwatch = GETDATE() 
    
	--IQ Day Report Update      
	UPDATE 
		IQDay   
	SET 
		IQDay.NoOfDocsLD = (ISNULL(IQDay.NoOfDocsLD,0) + IQDayTmp.Number_Docs ) ,      
		IQDay.PositiveSentimentLD = (ISNULL(IQDay.PositiveSentimentLD,0) + IQDayTmp.PositiveSentiment) ,   
		IQDay.NegativeSentimentLD = (ISNULL(IQDay.NegativeSentimentLD,0) + IQDayTmp.NegativeSentiment) ,         
		IQDay.NoOfHitsLD =  ISNULL(IQDay.NoOfHitsLD,0) + Number_Of_Hits
	FROM 
		IQAgent_DaySummary AS IQDay      
			INNER JOIN 
			(      
				SELECT             
					@ClientGUID AS ClientGUID,      
					MResult.LocalDate  AS Local_DateTime,      
					MResult.MediaType AS MediaType,   
					MResult.SearchRequestID,   
					COUNT(*) AS Number_Docs,      
					SUM(ISNULL(MResult.NumberOfHits,0)) AS Number_Of_Hits,     
					SUM (ISNULL(MResult.PositiveSentiment,0)) AS PositiveSentiment,         
					SUM (ISNULL(MResult.NegativeSentiment,0)) AS NegativeSentiment ,                  
					MResult.category AS SubMediaType  
				FROM 
					#PQMediaResultTable AS MResult        
				GROUP BY      
					MResult.LocalDate,MResult.SearchRequestID ,MResult.MediaType, MResult.category
			) AS IQDayTmp 
				ON IQDay.ClientGuid = IQDayTmp.ClientGUID 
				AND IQDay.MediaType = IQDayTmp.MediaType 
				AND IQDay.DayDate = IQDayTmp.Local_DateTime      
				AND IQDay.SubMediaType = IQDayTmp.SubMediaType       
				AND IQDay._SearchRequestID = IQDayTmp.SearchRequestID
 
	SET @QueryDetail ='update day summary table to update no of docs on local date and other counts for newly inserted record'
	SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
	INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
	SET @Stopwatch = GETDATE()  
        
	--IQ Day Report Insert      
	INSERT INTO IQAgent_DaySummary    
	(      
		ClientGuid,      
		DayDate,      
		MediaType,      
		NoOfDocs,
		NoOfHits,          
		PositiveSentiment,  
		NegativeSentiment,
		NoOfDocsLD,      
		NoOfHitsLD,      
		PositiveSentimentLD,  
		NegativeSentimentLD,
		SubMediaType ,
		_SearchRequestID,
		Audience,
		IQMediaValue        
	)      
	SELECT             
		@ClientGUID AS ClientGUID,      
		MResult.LocalDate AS DayDate,      
		MResult.MediaType AS MediaType,     
		0,
		0,
		0,
		0, 
		COUNT(*) AS NoOfDocs,      
		SUM(ISNULL(MResult.NumberOfHits,0)) AS NoOfHits,  
		SUM (ISNULL(MResult.PositiveSentiment,0)) AS PositiveSentiment,         
		SUM (ISNULL(MResult.NegativeSentiment,0)) AS NegativeSentiment,
		MResult.category AS SubMediaType,
		MResult.SearchRequestID,
		0,
		0
	FROM 
		#PQMediaResultTable AS MResult       
			LEFT OUTER JOIN IQAgent_DaySummary AS IQDay WITH(NOLOCK) 
				ON  IQDay.ClientGuid = @ClientGUID 
				AND IQDay.MediaType = MResult.MediaType 
				AND IQDay.DayDate =  MResult.LocalDate
				AND IQDay.SubMediaType = MResult.category
				AND IQDay._SearchRequestID = MResult.SearchRequestID
	WHERE 
		IQDay.ID IS NULL      
	GROUP BY     
		MResult.LocalDate,MResult.SearchRequestID,MResult.MediaType,MResult.category
            
			
	SET @QueryDetail ='insert in day summary table for local day dates which not already exist'
	SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
	INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
	SET @Stopwatch = GETDATE() 
 
 -- End of Day and Hour Summary tables updates */        
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
			@ExceptionMessage=CONVERT(VARCHAR(500),ERROR_NUMBER())+'_'+ERROR_MESSAGE(),
			@CreatedBy='usp_IQAgent_PQResults_InsertList',
			@ModifiedBy='usp_IQAgent_PQResults_InsertList',
			@CreatedDate=GETDATE(),
			@ModifiedDate=GETDATE(),
			@IsActive=1	
		
	EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT
	
	RAISERROR(@ExceptionMessage,11,1)
END CATCH   
  
	SET @QueryDetail ='0'
	SET @TimeDiff = DATEDIFF(ms, @SPStartTime, GETDATE())
	INSERT INTO IQ_SPTimeTracking([Guid],SPName,INPUT,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,'<Input><XmlData>'+ CONVERT(NVARCHAR(MAX),@XmlData) +'</XmlData><IQAgentSearchRequestID>'+ CONVERT(NVARCHAR(MAX),@IQAgentSearchRequestID) +'</IQAgentSearchRequestID></Input>',@QueryDetail,@TimeDiff)

END
