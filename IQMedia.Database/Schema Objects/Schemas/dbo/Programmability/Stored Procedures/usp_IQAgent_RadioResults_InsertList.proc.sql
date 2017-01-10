CREATE PROCEDURE [dbo].[usp_IQAgent_RadioResults_InsertList]             
(        
	@XmlData XML           
)
AS        
BEGIN         
 SET NOCOUNT ON;        
 SET XACT_ABORT ON;
 
 DECLARE @StopWatch DATETIME, @SPStartTime DATETIME,@SPTrackingID UNIQUEIDENTIFIER, @TimeDiff DECIMAL(18,2),@SPName VARCHAR(100),@QueryDetail VARCHAR(500)
 
 SET @SPStartTime=GETDATE()
 SET @Stopwatch=GETDATE()
 SET @SPTrackingID = NEWID()
 SET @SPName ='usp_IQAgent_RadioResults_InsertList'
        
 BEGIN TRANSACTION;        
 BEGIN TRY        
 
	IF OBJECT_ID('tempdb..#RadioMediaResultTable') IS NOT NULL
	BEGIN
		DROP TABLE #RadioMediaResultTable
	END
        
	CREATE TABLE #RadioMediaResultTable
	(
		MediaID BIGINT,
		IQAgentSearchRequestID BIGINT,
		QueryVersion INT,
		Title VARCHAR(250),
		IQ_CC_Key VARCHAR(28),
		Guid UNIQUEIDENTIFIER,
		GMTDatetime DATETIME2(7),
		LocalDatetime DATETIME2(7),
		StationID VARCHAR(150),
		Market VARCHAR(150),
		IQDMAID INT,
		Number_Hits INT,
		HighlightingText XML,
		Sentiment XML NULL,
		MediaType VARCHAR(2),
		SubMediaType VARCHAR(50)
	)

	INSERT INTO #RadioMediaResultTable
	(
		IQAgentSearchRequestID,
		QueryVersion,
		Title,
		IQ_CC_Key,
		Guid,
		GMTDatetime,
		LocalDatetime,
		StationID,
		Market,
		IQDMAID,
		Number_Hits,
		HighlightingText,
		Sentiment,
		MediaType,
		SubMediaType
	)       
	SELECT         
		tblXml.c.value('@IQAgentSearchRequestID','bigint'),
		tblXml.c.value('@QueryVersion','int'),
		tblXml.c.value('@StationID','varchar(150)') + ' (Radio)',
		tblXml.c.value('@IQ_CC_Key','varchar(28)'),
		tblXml.c.value('@Guid','uniqueidentifier'),
		tblXml.c.value('@GMTDatetime','datetime2(7)'),
		tblXml.c.value('@LocalDatetime','datetime2(7)'),
		tblXml.c.value('@StationID','varchar(150)'),
		tblXml.c.value('@Market','varchar(150)'),
		tblXml.c.value('@IQDMAID','int'),
		tblXml.c.value('@Number_Hits','int'),
		CASE WHEN CONVERT(VARCHAR(MAX), tblXml.c.query('HighlightedCCOutput')) = '' THEN NULL ELSE tblXml.c.query('HighlightedCCOutput') END,
		CASE WHEN CONVERT(NVARCHAR(MAX), tblXml.c.query('Sentiment')) = '' THEN NULL ELSE tblXml.c.query('Sentiment') END AS [Sentiment],
		tblXml.c.value('@MediaType','varchar(2)'),
		tblXml.c.value('@SubMediaType','varchar(50)')
	 FROM          
		@XmlData.nodes('/IQAgentRadioResultsList/IQAgentRadioResult') AS tblXml(c)        		  
    				
	SET @QueryDetail ='populate temp Radio table'
	SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
	INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
	SET @Stopwatch = GETDATE()
    
   
	DELETE RadioTbl FROM 
		#RadioMediaResultTable AS RadioTbl
			INNER JOIN IQAgent_RadioResults 
				ON IQAgent_RadioResults.IQAgentSearchRequestID = RadioTbl.IQAgentSearchRequestID        
				AND IQAgent_RadioResults.Guid = RadioTbl.Guid
				AND IQAgent_RadioResults.IsActive = 1
			INNER JOIN IQAgent_SearchRequest ON
				RadioTbl.IQAgentSearchRequestID = IQAgent_SearchRequest.ID      
	WHERE        
		IQAgent_SearchRequest.IsActive = 1    
		
		
	SET @QueryDetail ='delete records from temp Radio table , by using join of agent Radio table.'
	SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
	INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
	SET @Stopwatch = GETDATE()
		
	IF OBJECT_ID('tempdb..#TempRadioMediaIDs') IS NOT NULL
		DROP TABLE #TempRadioMediaIDs
		
	CREATE TABLE #TempRadioMediaIDs(MediaID BIGINT, Guid UNIQUEIDENTIFIER, SearchRequestID BIGINT)
		
	INSERT INTO [dbo].[IQAgent_RadioResults]         
	(           
		IQAgentSearchRequestID,
		_QueryVersion,
		Title,
		IQ_CC_Key,
		Guid,
		GMTDatetime,
		LocalDatetime,
		_StationID,
		Market,
		_IQDMAID,
		Number_Hits,
		HighlightingText,
		Sentiment,
		v5SubMediaType
	)    
	OUTPUT INSERTED.ID AS MediaID, INSERTED.Guid AS Guid, INSERTED.IQAgentSearchRequestID AS SearchRequestID INTO #TempRadioMediaIDs    
	SELECT
		IQAgentSearchRequestID,
		QueryVersion,
		Title,
		IQ_CC_Key,
		Guid,
		GMTDatetime,
		LocalDatetime,
		StationID,
		Market,
		IQDMAID,
		Number_Hits,
		HighlightingText,
		Sentiment,
		SubMediaType
	FROM 
		#RadioMediaResultTable   
		
		
	SET @QueryDetail ='insert into IQAgent_RadioResults table from temporary Radio table'
	SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
	INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
	SET @Stopwatch = GETDATE()
   
	UPDATE 
		#RadioMediaResultTable
	SET	
		 MediaID = temptbl.MediaID
	FROM
		#RadioMediaResultTable AS RadioTbl 
			INNER JOIN #TempRadioMediaIDs AS temptbl
				ON RadioTbl.Guid = temptbl.Guid
				AND RadioTbl.IQAgentSearchRequestID = temptbl.SearchRequestID			
				
	SET @QueryDetail ='update MediaID in temp Radio table for newly inserted records, using join of temp mediaid table'
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
		v5MediaType,
		v5Category,
		IsActive
	)
	OUTPUT inserted.ID,inserted._MediaID INTO @MediaIDs
	SELECT         
		Title,        
		MediaID,        
		MediaType,         
		SubMediaType,
		Convert(nvarchar(max),HighlightingText),
		GMTDatetime,         
		IQAgentSearchRequestID,
		Sentiment.query('/Sentiment/PositiveSentiment').value('.', 'tinyint'),
		Sentiment.query('/Sentiment/NegativeSentiment').value('.', 'tinyint'),
		MediaType,
		SubMediaType,
		1
	FROM        
		#RadioMediaResultTable               
        
    SET @QueryDetail ='insert into iqagent media results table from temp Radio table'
	SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
	INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
	SET @Stopwatch = GETDATE()  	

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
			@CreatedBy='usp_IQAgent_RadioResults_InsertList',
			@ModifiedBy='usp_IQAgent_RadioResults_InsertList',
			@CreatedDate=GETDATE(),
			@ModifiedDate=GETDATE(),
			@IsActive=1	
		
	EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT
	
	RAISERROR(@ExceptionMessage,11,1)
END CATCH   
  
	SET @QueryDetail ='0'
	SET @TimeDiff = DATEDIFF(ms, @SPStartTime, GETDATE())
	INSERT INTO IQ_SPTimeTracking([Guid],SPName,INPUT,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,'<Input><XmlData>'+ CONVERT(NVARCHAR(MAX),@XmlData) +'</XmlData></Input>',@QueryDetail,@TimeDiff)

END
