USE [IQMediaGroup]
GO

/****** Object:  StoredProcedure [dbo].[usp_IQAgentResult_InsertList]    Script Date: 5/2/2016 3:38:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_IQAgentResult_InsertList]                                  
(        
 @XmlData   XML        
)          
AS        
BEGIN         
 SET NOCOUNT OFF;    
 SET XACT_ABORT ON;  
   
 BEGIN TRANSACTION;        
 BEGIN TRY        
         
 DECLARE @TVResultTable TABLE (MediaID BIGINT,Title NVARCHAR(MAX),MediaType VARCHAR(2), Category VARCHAR(50), HighlightingText NVARCHAR(MAX), MediaDate DATETIME,LocalDate DATETIME, SearchRequestID BIGINT,Sentiment XML, IsActive BIT, IQMediaValue DECIMAL(18,2), Audience INT,
PositiveSentiment TINYINT,NegativeSentiment TINYINT,NumberOfHits INT,RL_Date DATE,RL_Station VARCHAR(150),IQProminence DECIMAL(18,6),IQProminenceMultiplier DECIMAL(18,6))  

 DECLARE @MediaResultTable TABLE (MediaID BIGINT,TVID BIGINT, Title120 VARCHAR(500), RL_Date DATE, SearchRequestID BIGINT, Station_Affil VARCHAR(50))  
    
 DECLARE @IQAgent_SummaryTrackingID BIGINT  
 DECLARE @TmpUpdateMediaResults TABLE(ID BIGINT, _MediaID BIGINT, _SearchRequestID BIGINT)      
 DECLARE @TmpUpdateTVResults TABLE(ID BIGINT,NoOfHits INT, HighlightingText XML)

 DECLARE @QueuedDeleteTable TABLE (ID BIGINT)
 
 -- Get IDs of items that have been queued for deletion, but not yet processed. Used to ensure correct parent/child rollup.
 INSERT INTO @QueuedDeleteTable
 SELECT Deletes.ID.value('.', 'bigint') as ID
 FROM	IQAgent_DeleteControl WITH (NOLOCK)
 CROSS	APPLY statusUpdateData.nodes('add/doc/field[@name="iqseqid"]') as Deletes(ID)
 WHERE	isDBUpdated != 'COMPLETED'
 AND	searchRequestID IS NULL 

 UPDATE 
		IQAgent_MediaResults
 SET
		HighlightingText = CONVERT(NVARCHAR(MAX),tblXml.c.query('HighlightedCCOutput')) 
 OUTPUT inserted.ID,inserted._MediaID,inserted._SearchRequestID INTO @TmpUpdateMediaResults
 FROM
		IQAgent_MediaResults 
			INNER JOIN IQAgent_TVResults
				ON IQAgent_MediaResults._MediaID = IQAgent_TVResults.ID
				AND IQAgent_MediaResults.MediaType = 'TV'
			INNER JOIN @XmlData.nodes('/IQAgentResultsList/IQAgentResult') AS tblXml(c)        
				ON IQAgent_TVResults.RL_VideoGUID = tblXml.c.value('@RL_VideoGUID','uniqueidentifier')        
				AND IQAgent_TVResults.SearchRequestID = tblXml.c.value('@SearchRequestID','bigint')
				AND IQAgent_TVResults.Number_Hits != tblXml.c.value('@Number_Hits','int')
			INNER JOIN IQAgent_SearchRequest 
				ON tblXml.c.value('@SearchRequestID','bigint') = IQAgent_SearchRequest.ID

 UPDATE 
		IQAgent_TVResults
 SET
		Number_Hits = tblXml.c.value('@Number_Hits','int'),
		CC_Highlight = tblXml.c.query('HighlightedCCOutput'),
		Communication_flag = 0,
		h_comm_flag = 0,
		w_Comm_flag = 0,
		d_Comm_flag = 0,
		i_Comm_flag = 0
OUTPUT inserted.ID,inserted.Number_Hits,inserted.CC_Highlight INTO @TmpUpdateTVResults
 FROM
        IQAgent_TVResults
			INNER JOIN @XmlData.nodes('/IQAgentResultsList/IQAgentResult') AS tblXml(c)        
				ON IQAgent_TVResults.RL_VideoGUID = tblXml.c.value('@RL_VideoGUID','uniqueidentifier')        
				AND IQAgent_TVResults.SearchRequestID = tblXml.c.value('@SearchRequestID','bigint')
				AND IQAgent_TVResults.Number_Hits != tblXml.c.value('@Number_Hits','int')
			INNER JOIN IQAgent_SearchRequest 
				ON tblXml.c.value('@SearchRequestID','bigint') = IQAgent_SearchRequest.ID
				
INSERT INTO IQAgent_MediaResults_UpdatedRecords
(
	_MediaResultID,
	NoOfHits,
	HighlightingText,
	LastModified,
	SolrStatus,
	ClientGUID
)
SELECT
	MediaResults.ID,
	TVResults.NoOfHits,
	TVResults.HighlightingText,
	SYSDATETIME(),
	0,
	IQAgent_SearchRequest.ClientGUID
FROM
	@TmpUpdateMediaResults AS MediaResults
		INNER JOIN @TmpUpdateTVResults AS TVResults
			ON MediaResults._MediaID=TVResults.ID
		INNER JOIN IQAgent_SearchRequest WITH(NOLOCK)
			ON MediaResults._SearchRequestID=IQAgent_SearchRequest.ID
         
 INSERT INTO IQAgent_TVResults        
  (        
   SearchRequestID,        
   _QueryVersion,         
   Title120 ,        
   iq_cc_key,        
   RL_VideoGUID,        
   GMTDatetime,
   Rl_Station,        
   RL_Market,        
   RL_Date,        
   RL_Time,        
   Number_Hits,        
   AM18_20,
   AM21_24,
   AM25_34,
   AM35_49,
   AM50_54,
   AM55_64,
   AM65_Plus,
   AF18_20,
   AF21_24,
   AF25_34,
   AF35_49,
   AF50_54,
   AF55_64,
   AF65_Plus,
   Nielsen_Audience,        
   IQAdShareValue,        
   Nielsen_Result,        
   Sentiment,        
   CC_Highlight,
   _IQDmaID,
   RawMediaThumbUrl, 
   IQProminence,
   IQProminenceMultiplier,
   ProgramCategory,
   v5SubMediaType
  )        
        
 OUTPUT INSERTED.ID AS MediaID,INSERTED.Title120 AS Title, 'TV' AS MediaType,'TV' AS Category,CONVERT(NVARCHAR(MAX), INSERTED.CC_Highlight  ) AS HighlightingText, CONVERT(DATETIME,INSERTED.GMTDatetime) AS MediaDate, 
 INSERTED.GMTDatetime AS LocalDate,
 INSERTED.SearchRequestID AS SearchRequestID,INSERTED.Sentiment AS Sentiment, 1 AS IsActive, INSERTED.IQAdShareValue AS IQMediaValue, 
 INSERTED.Nielsen_Audience AS Audience,NULL AS PositiveSentiment ,NULL AS NegativeSentiment,INSERTED.Number_Hits AS NumberOfHits, INSERTED.RL_Date AS RL_Date, INSERTED.Rl_Station AS Rl_Station,
 INSERTED.IQProminence AS IQProminence,INSERTED.IQProminenceMultiplier AS IQProminenceMultiplier 
 INTO @TVResultTable        
        
  SELECT         
     tblXml.c.value('@SearchRequestID','bigint') AS [SearchRequestID],        
     tblXml.c.value('@QueryVersion','int') AS [QueryVersion],        
     tblXml.c.value('@Title120','nvarchar(128)') AS [Title120],        
     tblXml.c.value('@iq_cc_key','varchar(28)') AS [iq_cc_key],        
     tblXml.c.value('@RL_VideoGUID','uniqueidentifier') AS [RL_VideoGUID],        
	 tblXml.c.value('@GMTDatetime','datetime') AS [GMTDatetime],        
     tblXml.c.value('@Rl_Station','varchar(150)') AS [Rl_Station],        
     tblXml.c.value('@Rl_Market','varchar(150)') AS [Rl_Market],        
     tblXml.c.value('@RL_Date','date') AS [RL_Date],        
     tblXml.c.value('@RL_Time','int') AS [RL_Time],        
     tblXml.c.value('@Number_Hits','int') AS [Number_Hits],     
	 tblXml.c.value('@AM18_20','int') AS [AM18_20],
		tblXml.c.value('@AM21_24','int') AS [AM21_24],
		tblXml.c.value('@AM25_34','int') AS [AM25_34],
		tblXml.c.value('@AM35_49','int') AS [AM35_49],
		tblXml.c.value('@AM50_54','int') AS [AM50_54],
		tblXml.c.value('@AM55_64','int') AS [AM55_64],
		tblXml.c.value('@AM65','int')    AS [AM65],
		tblXml.c.value('@AF18_20','int') AS [AF18_20],
		tblXml.c.value('@AF21_24','int') AS [AF21_24],
		tblXml.c.value('@AF25_34','int') AS [AF25_34],
		tblXml.c.value('@AF35_49','int') AS [AF35_49],
		tblXml.c.value('@AF50_54','int') AS [AF50_54],
		tblXml.c.value('@AF55_64','int') AS [AF55_64],
		tblXml.c.value('@AF65','int')    AS [AF65],   
     tblXml.c.value('@Nielsen_Audience','int') AS [Nielsen_Audience],        
     tblXml.c.value('@IQAdShareValue','float') AS [IQAdShareValue],        
     CASE WHEN tblXml.c.value('@Nielsen_Result','char(1)') = '' THEN NULL ELSE tblXml.c.value('@Nielsen_Result','char(1)') END AS [Nielsen_Result],
     tblXml.c.query('Sentiment') AS [Sentiment],        
     tblXml.c.query('HighlightedCCOutput') AS [CC_Highlight],
	 tblXml.c.value('@_IQDmaID','int') AS [_IQDmaID],
	 CASE WHEN tblXml.c.value('@RawMediaThumbUrl','varchar(255)') = '' THEN NULL ELSE tblXml.c.value('@RawMediaThumbUrl','varchar(255)') END AS [RawMediaThumbUrl],
	 tblXml.c.value('@IQProminence','DECIMAL(18,6)') AS [IQProminence],
	 tblXml.c.value('@IQProminenceMultiplier','DECIMAL(18,6)') AS [IQProminenceMultiplier], 
	 CASE WHEN tblXml.c.value('@ProgramCategory','varchar(13)') = '' THEN NULL ELSE tblXml.c.value('@ProgramCategory','varchar(13)') END AS [ProgramCategory],
	 'TV' 
  FROM          
    @XmlData.nodes('/IQAgentResultsList/IQAgentResult') AS tblXml(c)        
     LEFT OUTER JOIN IQAgent_TVResults WITH(NOLOCK)        
      ON IQAgent_TVResults.SearchRequestID=tblXml.c.value('@SearchRequestID','bigint') AND        
       IQAgent_TVResults.RL_VideoGUID=tblXml.c.value('@RL_VideoGUID','uniqueidentifier') AND
	   IQAgent_TVResults.IsActive = 1
	 LEFT OUTER JOIN IQAgent_SearchRequest WITH(NOLOCK) ON
		tblXml.c.value('@SearchRequestID','bigint') = IQAgent_SearchRequest.ID
  WHERE        
    IQAgent_TVResults.SearchRequestID IS NULL AND  IQAgent_SearchRequest.IsActive = 1      
        
   
 UPDATE MResult SET   
 PositiveSentiment = (SELECT tblSentiment.c.value('.', 'tinyint') FROM MResult.Sentiment.nodes('/Sentiment/PositiveSentiment') AS tblSentiment(c)) ,        
 NegativeSentiment = (SELECT tblSentiment.c.value('.', 'tinyint') FROM MResult.Sentiment.nodes('/Sentiment/NegativeSentiment') AS tblSentiment(c))  ,
 LocalDate = CASE WHEN dbo.fnIsDayLightSaving(LocalDate) = 1 THEN  DATEADD(HOUR,(SELECT gmt + dst FROM Client WHERE ClientGuid = (SELECT ClientGuid FROM IQAgent_SearchRequest WHERE ID = MResult.SearchRequestID)),LocalDate) ELSE DATEADD(HOUR,(SELECT gmt FROM Client WHERE ClientGuid = (SELECT ClientGuid FROM IQAgent_SearchRequest WHERE ID = MResult.SearchRequestID)),LocalDate) END 
FROM @TVResultTable AS MResult 

PRINT 'TV Result Table'

SELECT * FROM @TVResultTable

 DECLARE @RecordsToInsert VARCHAR(MAX)
 SET @RecordsToInsert = STUFF((SELECT ',' + CONVERT(VARCHAR,MediaID) FROM @TVResultTable FOR XML PATH('')),1,1,'')    
            
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
OUTPUT INSERTED.ID AS MediaID, INSERTED._MediaID AS TVID, NULL AS Title120, NULL AS RL_Date,INSERTED._SearchRequestID AS SearchRequestID, NULL AS Station_Affil
INTO @MediaResultTable
     
  SELECT         
   Title ,        
   MediaID,        
   MediaType ,         
   Category ,        
   HighlightingText,         
   MediaDate,         
   SearchRequestID ,     
   PositiveSentiment,        
   NegativeSentiment ,  
   IsActive, 
   IQProminence,
   IQProminenceMultiplier,
   MediaType,
   Category
  FROM         
   @TVResultTable AS TVTbl       

UPDATE @MediaResultTable
SET Title120=TVTbl.Title,
	RL_Date=TVTbl.RL_Date,
	Station_Affil=IQ_Station.Station_Affil
FROM
		@MediaResultTable AS MRTbl
			INNER JOIN @TVResultTable AS TVTbl
				ON MRTbl.TVID=TVTbl.MediaID
			INNER JOIN IQ_Station
				ON TVTbl.RL_Station=IQ_Station.IQ_Station_ID

PRINT 'Media Result Table'

SELECT * FROM @MediaResultTable
				
DECLARE @MT TABLE (MediaID BIGINT, TVID BIGINT, Title120 VARCHAR(500), LocalDate DATE, SearchRequestID BIGINT, Station_Affil VARCHAR(20))

INSERT INTO @MT
(
	TITLE120,
	LocalDate,	
	TVID,
	SearchRequestID,
	MediaID,
	Station_Affil	
)
SELECT
	 IQAgent_TVResults.Title120,
	 IQAgent_TVResults.RL_Date,	 
	 MIN(IQAgent_TVResults.ID) AS TVID,
	 IQAgent_TVResults.SearchRequestID,
	 MIN(IQAgent_MediaResults.ID) AS MID,
	 Station_Affil
	
FROM @TVResultTable AS TVTbl		
		INNER JOIN IQAgent_TVResults WITH(NOLOCK)
			ON TVTbl.SearchRequestID=IQAgent_TVResults.SearchRequestID
			AND TVTbl.RL_Date=IQAgent_TVResults.RL_Date
			AND TVTbl.Title=IQAgent_TVResults.Title120
			AND TVTbl.MediaID!=IQAgent_TVResults.ID
		INNER JOIN IQAgent_MediaResults WITH(NOLOCK)
			ON IQAgent_TVResults.ID=IQAgent_MediaResults._MediaID
			AND IQAgent_MediaResults.MediaType='TV'
			AND _ParentID IS NULL
			AND NOT EXISTS (SELECT NULL FROM @QueuedDeleteTable delTbl WHERE delTbl.ID = IQAgent_MediaResults.ID) -- Ignore items that have been queued for deletion but not yet processed
		INNER JOIN IQ_Station WITH(NOLOCK)
			ON IQAgent_TVResults.RL_Station=IQ_Station.IQ_Station_ID
WHERE 
		Station_Affil IN ('ABC','CBS','NBC','CW','FOX','ION','Univision')
	AND IQAgent_TVResults.IsActive=1
	AND IQAgent_MediaResults.IsActive=1
GROUP BY IQAgent_TVResults.SearchRequestID, IQ_Station.Station_Affil,IQAgent_TVResults.RL_Date,IQAgent_TVResults.Title120

PRINT 'MT'

SELECT * FROM @MT

/*DECLARE @MT TABLE (MediaID BIGINT, TVID BIGINT, ParentMediaID BIGINT, Title120 VARCHAR(500), LocalDate DATE, IQStation VARCHAR(150), SearchRequestID BIGINT,DMA_NUM VARCHAR(3))

INSERT INTO @MT
(
	TITLE120,
	LocalDate,
	DMA_NUM,
	TVID,
	SearchRequestID,
	MediaID	
)
SELECT
	 IQAgent_TVResults.Title120,
	 IQAgent_TVResults.RL_Date,
	 DMA_NUM, 
	 IQAgent_TVResults.ID AS TVID,
	 IQAgent_TVResults.SearchRequestID,
	 IQAgent_MediaResults.ID AS MID
	
FROM @TVResultTable as TVTbl		
		INNER JOIN IQAgent_TVResults 
			ON TVTbl.SearchRequestID=IQAgent_TVResults.SearchRequestID
			AND TVTbl.RL_Date=IQAgent_TVResults.RL_Date
			AND TVTbl.Title=IQAgent_TVResults.Title120
			AND TVTbl.MediaID!=IQAgent_TVResults.ID
		INNER JOIN IQAgent_MediaResults
			ON IQAgent_TVResults.ID=IQAgent_MediaResults._MediaID
			AND IQAgent_MediaResults.MediaType='TV'
			AND _ParentID IS NULL
		INNER JOIN IQ_Station
			ON IQAgent_TVResults.RL_Station=IQ_Station.IQ_Station_ID
WHERE 
		Station_Affil in ('ABC','CBS','NBC','CW','FOX','ION','Univision')
*/		
DECLARE @Child TABLE(MediaID BIGINT, ParentMediaID BIGINT, ParentIsRead BIT)

INSERT INTO @Child
(
	MediaID,
	ParentMediaID,
	ParentIsRead
)
SELECT
	MRTbl.MediaID,
	MTbl.MediaID AS ParentMediaID,
	IQAgent_MediaResults.IsRead AS ParentIsRead
FROM
	@MediaResultTable AS MRTbl
		INNER JOIN @MT AS MTbl
			ON MRTbl.SearchRequestID=MTbl.SearchRequestID
			AND MRTbl.Station_Affil=MTbl.Station_Affil
			AND MRTbl.Title120=MTbl.Title120
			AND MRTbl.RL_Date=MTbl.LocalDate
		INNER JOIN IQAgent_MediaResults WITH (NOLOCK)
			ON IQAgent_MediaResults.ID = MTbl.MediaID
			
PRINT 'Child'

SELECT * FROM @Child
		
/*DECLARE @Child TABLE(ROWNO BIGINT, Title120 VARCHAR(500), RL_Date DATE, DMA_NUM VARCHAR(3), TVID BIGINT, SearchRequestID BIGINT, MediaID BIGINT, ParentMediaID BIGINT)

Insert into @Child
(
	Title120,
	RL_Date,
	SearchRequestID,
	TVID,
	MediaID,
	ParentMediaID
)
Select
MRTbl.Title120,
MRTbl.RL_Date,
MRTbl.SearchRequestID,
MRTbl.TVID,
MRTbl.MediaID,
MTbl.MediaID AS ParentMediaID
From
	@MediaResultTable AS MRTbl
		INNER JOIN @MT AS MTbl
			ON MRTbl.SearchRequestID=MTbl.SearchRequestID
			AND MRTbl.SearchRequestID=MTbl.SearchRequestID
			AND MRTbl.Title120=MTbl.Title120
			AND MRTbl.RL_Date=MTbl.LocalDate
*/			
UPDATE IQAgent_MediaResults
SET _ParentID=CASE WHEN ID=Child.ParentMediaID THEN NULL ELSE Child.ParentMediaID END,
	IsRead = CASE WHEN ID = Child.ParentMediaID THEN 0 ELSE Child.ParentIsRead END
FROM
	IQAgent_MediaResults
		INNER JOIN @Child AS Child
			ON IQAgent_MediaResults.ID=Child.MediaID

		

  /* UPDATE
			IQAgent_MediaResults
   SET
			_ParentID = (SELECT CASE WHEN tmpParent.ID = IQAgent_MediaResults.ID THEN NULL ELSE  tmpParent.ID END FROM 
						(
							SELECT 
								TOP 1 IQAgent_MediaResults.ID
							FROM 
								IQAgent_MediaResults
									INNER JOIN IQAgent_TVResults 
										ON IQAgent_TVResults.ID = IQAgent_MediaResults._MediaID
										AND IQAgent_MediaResults.MediaType ='TV'
										AND IQAgent_MediaResults.IsActive = 1
										AND IQAgent_TVResults.IsActive = 1
									INNER JOIN IQAgent_SearchRequest
										ON IQAgent_MediaResults._SearchRequestID = IQAgent_SearchRequest.ID
										AND IQAgent_TVResults.SearchRequestID = IQAgent_SearchRequest.ID
										AND IQAgent_SearchRequest.IsActive = 1 
									INNER JOIN IQ_Station 
										ON IQAgent_TVResults.Rl_Station = IQ_Station.IQ_Station_ID
							WHERE
								Title120 =mtbl.Title
								AND RL_Date = mtbl.RL_Date
								AND _ParentID IS NULL
							ORDER BY IQ_Station.Dma_Num,IQAgent_MediaResults.ID asc
						) As tmpParent)
	FROM
		IQAgent_MediaResults
			INNER JOIN @TVResultTable as mtbl
				ON 	mtbl.MediaID = IQAgent_MediaResults._MediaID 
				AND mtbl.MediaType = IQAgent_MediaResults.MediaType
			INNER JOIN IQ_Station 
				ON mtbl.Rl_Station = IQ_Station.IQ_Station_ID
			AND (UPPER(IQ_Station.Station_Affil) = 'ABC' OR UPPER(IQ_Station.Station_Affil) = 'CBS' OR UPPER(IQ_Station.Station_Affil) = 'NBC' OR UPPER(IQ_Station.Station_Affil) = 'CW' OR UPPER(IQ_Station.Station_Affil) = 'FOX' OR UPPER(IQ_Station.Station_Affil) = 'UNIVISION'OR UPPER(IQ_Station.Station_Affil) = 'ION')
    */
    /*
   INSERT INTO IQAgent_SummaryTracking
		(
			Operation,
			OperationTable,
			RecordsBeforeUpdation,
			SP,
			Detail
		)
		VALUES
		(
			'INSERT TV',
			'IQAgent_HourSummary',
			(SELECT SUM(NoOfDocs) FROM IQAgent_HourSummary WHERE MediaType ='TV'),
			'usp_IQAgentResult_InsertList',
			@RecordsToInsert
		)

		SET @IQAgent_SummaryTrackingID = SCOPE_IDENTITY();       
       */ 



 /*  July 2015  Note: Updating Day and Hour Summary tables are thru a dirty table process 

  --IQ Hours Report Update      
 UPDATE IQHRS   
 SET IQHRS.NoOfDocs = (IQHRS.NoOfDocs + IQHRSTmp.Number_Docs ) ,    
  Audience = (IQHRS.Audience + IQHRSTmp.Audience),      
  IQMediaValue = (IQHRS.IQMediaValue + IQHRSTmp.IQMediaValue) ,   
  IQHRS.PositiveSentiment = (ISNULL(IQHRS.PositiveSentiment,0) + IQHRSTmp.PositiveSentiment) ,   
  IQHRS.NegativeSentiment = (ISNULL(IQHRS.NegativeSentiment,0) + IQHRSTmp.NegativeSentiment) ,
  IQHRS.NoOfHits = (IQHRS.NoOfHits + Number_Of_Hits)
 FROM IQAgent_HourSummary AS IQHRS      
 INNER JOIN (      
  SELECT             
     IQSearch.ClientGUID AS ClientGUID,      
     DATEADD (HOUR,DATEPART(HOUR,MResult.MediaDate), CONVERT (VARCHAR(10),MResult.MediaDate,101) ) AS GMT_DateTime,      
     MResult.MediaType AS MediaType,  
	 MResult.SearchRequestID,    
     COUNT(*) AS Number_Docs,      
     SUM(ISNULL(MResult.NumberOfHits,0)) AS Number_Of_Hits,      
     SUM(ISNULL(MResult.Audience,0))  AS Audience,      
     SUM(ISNULL(MResult.IQMediaValue,0))  AS IQMediaValue,  
     SUM (ISNULL(MResult.PositiveSentiment,0)) AS PositiveSentiment,         
     SUM (ISNULL(MResult.NegativeSentiment ,0)) AS NegativeSentiment ,
     MResult.category AS SubMediaType              
  FROM @TVResultTable AS MResult      
  INNER JOIN IQAgent_SearchRequest AS IQSearch WITH(NOLOCK) ON IQSearch.ID = MResult.SearchRequestID      
  GROUP BY      
  DATEADD (HOUR,DATEPART(HOUR,MResult.MediaDate), CONVERT(VARCHAR(10),MResult.MediaDate,101)) ,IQSearch.ClientGUID,MResult.SearchRequestID,MResult.MediaType,MResult.category) 
  AS IQHRSTmp ON IQHRS.ClientGuid = IQHRSTmp.ClientGUID 
  AND IQHRS.MediaType = IQHRSTmp.MediaType 
  AND IQHRS.HourDateTime = IQHRSTmp.GMT_DateTime      
  AND IQHRS.SubMediaType = IQHRSTmp.SubMediaType
  AND IQHRS._SearchRequestID = IQHRSTmp.SearchRequestID
         
          
 --IQ Hours Report Insert      
   INSERT INTO IQAgent_HourSummary      
   (      
   ClientGuid,      
   HourDateTime,      
   MediaType,      
   NoOfDocs,      
   NoOfHits,      
   Audience,      
   IQMediaValue,  
   PositiveSentiment,  
   NegativeSentiment,
   SubMediaType ,
   _SearchRequestID 
   )      
         
 SELECT             
  IQSearch.ClientGUID AS ClientGUID,      
  DATEADD (HOUR,DATEPART(HOUR,MResult.MediaDate), CONVERT (VARCHAR(10),MResult.MediaDate,101) ) AS HourDateTime,      
  MResult.MediaType AS MediaType,      
  COUNT(*) AS NoOfDocs,      
  SUM(ISNULL(MResult.NumberOfHits,0)) AS NoOfHits,      
  SUM(ISNULL(MResult.Audience,0))  AS Audience,      
  SUM(ISNULL(MResult.IQMediaValue,0))  AS IQMediaValue    ,  
  SUM(ISNULL(MResult.PositiveSentiment,0)) AS PositiveSentiment,         
  SUM(ISNULL(MResult.NegativeSentiment ,0)) AS NegativeSentiment,
  MResult.category AS SubMediaType  ,
  MResult.SearchRequestID     
 FROM @TVResultTable AS MResult 
 INNER JOIN IQAgent_SearchRequest AS IQSearch WITH(NOLOCK) ON IQSearch.ID = MResult.SearchRequestID      
 LEFT JOIN IQAgent_HourSummary AS IQHRS WITH(NOLOCK) ON IQHRS.ClientGuid = IQSearch.ClientGUID 
 AND IQHRS.MediaType = MResult.MediaType 
 AND IQHRS.HourDateTime =  DATEADD (HOUR,DATEPART(HOUR,MediaDate), CONVERT (VARCHAR(10),MediaDate,101) ) 
 AND IQHRS.SubMediaType = MResult.category
 AND IQHRS._SearchRequestID = MResult.SearchRequestID
 WHERE IQHRS.ID IS NULL      
 GROUP BY      
 DATEADD (HOUR,DATEPART(HOUR,MResult.MediaDate), CONVERT (VARCHAR(10),MResult.MediaDate,101) ),IQSearch.ClientGUID, MResult.SearchRequestID, MResult.MediaType,MResult.category
       
       /*
		UPDATE 
				IQAgent_SummaryTracking
		SET
				RecordsAfterUpdation = (SELECT SUM(NoOfDocs) FROM IQAgent_HourSummary WHERE MediaType ='TV')
		WHERE
				ID = @IQAgent_SummaryTrackingID
			
		
		INSERT INTO IQAgent_SummaryTracking
		(
			Operation,
			OperationTable,
			RecordsBeforeUpdation,
			SP,
			Detail
		)
		VALUES
		(
			'INSERT TV',
			'IQAgent_DaySummary',
			(SELECT SUM(NoOfDocs) FROM IQAgent_DaySummary WHERE MediaType ='TV'),
			'usp_IQAgentResult_InsertList',
			@RecordsToInsert
		)

		SET @IQAgent_SummaryTrackingID = SCOPE_IDENTITY();     
		*/
		--IQ Day Report Update      
		UPDATE IQDay   
 SET IQDay.NoOfDocs = (IQDay.NoOfDocs + IQDayTmp.Number_Docs ) ,    
  IQDay.Audience = (IQDay.Audience + IQDayTmp.Audience),      
  IQDay.IQMediaValue = (IQDay.IQMediaValue + IQDayTmp.IQMediaValue),  
  IQDay.PositiveSentiment = (ISNULL(IQDay.PositiveSentiment,0) + IQDayTmp.PositiveSentiment) ,   
  IQDay.NegativeSentiment = (ISNULL(IQDay.NegativeSentiment,0) + IQDayTmp.NegativeSentiment) ,
  IQDay.NoOfHits = (IQDay.NoOfHits + Number_Of_Hits)
    
 FROM IQAgent_DaySummary AS IQDay      
 INNER JOIN (      
  SELECT             
     IQSearch.ClientGUID AS ClientGUID,      
     CONVERT (DATE,MResult.MediaDate)  AS GMT_DateTime,      
     MResult.MediaType AS MediaType,      
	 MResult.SearchRequestID,
     COUNT(*) AS Number_Docs,      
     SUM(ISNULL(MResult.NumberOfHits,0)) AS Number_Of_Hits,      
     SUM(ISNULL(MResult.Audience,0))  AS Audience,      
     SUM(ISNULL(MResult.IQMediaValue,0))  AS IQMediaValue,  
     SUM (ISNULL(MResult.PositiveSentiment,0)) AS PositiveSentiment,         
     SUM (ISNULL(MResult.NegativeSentiment,0)) AS NegativeSentiment ,                  
     MResult.category AS SubMediaType  
  FROM @TVResultTable AS MResult      
  INNER JOIN IQAgent_SearchRequest AS IQSearch WITH(NOLOCK) ON IQSearch.ID = MResult.SearchRequestID      
  GROUP BY      
  CONVERT (DATE,MResult.MediaDate),IQSearch.ClientGUID, MResult.SearchRequestID, MResult.MediaType, MResult.category
 ) AS IQDayTmp ON IQDay.ClientGuid = IQDayTmp.ClientGUID 
 AND IQDay.MediaType = IQDayTmp.MediaType 
 AND IQDay.DayDate = IQDayTmp.GMT_DateTime      
 AND IQDay.SubMediaType = IQDayTmp.SubMediaType   
 AND IQDay._SearchRequestID = IQDayTmp.SearchRequestID    
        
		--IQ Day Report Insert      
		INSERT INTO IQAgent_DaySummary    
   (      
    ClientGuid,      
    DayDate,      
    MediaType,      
    NoOfDocs,      
    NoOfHits,      
    Audience,      
    IQMediaValue,  
    PositiveSentiment,  
    NegativeSentiment,
	NoOfDocsLD,      
    NoOfHitsLD,      
    AudienceLD,      
    IQMediaValueLD,  
    PositiveSentimentLD,  
    NegativeSentimentLD,
    SubMediaType,
	_SearchRequestID        
   )      
          
 SELECT             
  IQSearch.ClientGUID AS ClientGUID,      
  CONVERT (DATE,MResult.MediaDate) AS DayDate,      
  MResult.MediaType AS MediaType,      
  COUNT(*) AS NoOfDocs,      
  SUM(ISNULL(MResult.NumberOfHits,0)) AS NoOfHits,      
  SUM(ISNULL(MResult.Audience,0))  AS Audience,      
  SUM(ISNULL(MResult.IQMediaValue,0))  AS IQMediaValue,  
  SUM (ISNULL(MResult.PositiveSentiment,0)) AS PositiveSentiment,         
  SUM (ISNULL(MResult.NegativeSentiment,0)) AS NegativeSentiment,
  0,
  0,
  0,
  0,
  0,
  0,
   MResult.category AS SubMediaType      ,
   MResult.SearchRequestID        
 FROM @TVResultTable AS MResult      
 INNER JOIN IQAgent_SearchRequest AS IQSearch WITH(NOLOCK) ON IQSearch.ID = MResult.SearchRequestID      
 LEFT JOIN IQAgent_DaySummary AS IQDay WITH(NOLOCK) ON  IQDay.ClientGuid = IQSearch.ClientGUID 
	 AND IQDay.MediaType = MResult.MediaType 
	 AND IQDay.DayDate =  CONVERT (DATE,MResult.MediaDate)      
	 AND IQDay.SubMediaType = MResult.category
	 AND IQDay._SearchRequestID = MResult.SearchRequestID    
 WHERE IQDay.ID IS NULL      
 GROUP BY     
 CONVERT (DATE,MResult.MediaDate),      
 IQSearch.ClientGUID, MResult.SearchRequestID ,MResult.MediaType,MResult.category
       
       /*
		UPDATE 
				IQAgent_SummaryTracking
		SET
				RecordsAfterUpdation = (SELECT SUM(NoOfDocs) FROM IQAgent_DaySummary WHERE MediaType ='TV')
		WHERE
				ID = @IQAgent_SummaryTrackingID

		INSERT INTO IQAgent_SummaryTracking
		(
			Operation,
			OperationTable,
			RecordsBeforeUpdation,
			SP,
			Detail
		)
		VALUES
		(
			'INSERT TV LD',
			'IQAgent_DaySummary',
			(SELECT SUM(NoOfDocsLD) FROM IQAgent_DaySummary WHERE MediaType ='TV'),
			'usp_IQAgentResult_InsertList',
			@RecordsToInsert
		)

		SET @IQAgent_SummaryTrackingID = SCOPE_IDENTITY();     
		*/
		
		--IQ Day Report Update      
		UPDATE IQDay   
		 SET IQDay.NoOfDocsLD = (IQDay.NoOfDocsLD + IQDayTmp.Number_Docs ) ,    
		  IQDay.AudienceLD = (IQDay.AudienceLD + IQDayTmp.Audience),      
		  IQDay.IQMediaValueLD = (IQDay.IQMediaValueLD + IQDayTmp.IQMediaValue),  
		  IQDay.PositiveSentimentLD = (ISNULL(IQDay.PositiveSentimentLD,0) + IQDayTmp.PositiveSentiment) ,   
		  IQDay.NegativeSentimentLD = (ISNULL(IQDay.NegativeSentimentLD,0) + IQDayTmp.NegativeSentiment) ,
		  IQDay.NoOfHitsLD = (IQDay.NoOfHitsLD + Number_Of_Hits)
    
		 FROM IQAgent_DaySummary AS IQDay      
		 INNER JOIN (      
		  SELECT             
			 IQSearch.ClientGUID AS ClientGUID,      
			 CONVERT (DATE,MResult.LocalDate)  AS Local_DateTime,      
			 MResult.MediaType AS MediaType,      
			 MResult.SearchRequestID,
			 COUNT(*) AS Number_Docs,      
			 SUM(ISNULL(MResult.NumberOfHits,0)) AS Number_Of_Hits,      
			 SUM(ISNULL(MResult.Audience,0))  AS Audience,      
			 SUM(ISNULL(MResult.IQMediaValue,0))  AS IQMediaValue,  
			 SUM (ISNULL(MResult.PositiveSentiment,0)) AS PositiveSentiment,         
			 SUM (ISNULL(MResult.NegativeSentiment,0)) AS NegativeSentiment ,                  
			 MResult.category AS SubMediaType  
		  FROM @TVResultTable AS MResult      
		  INNER JOIN IQAgent_SearchRequest AS IQSearch WITH(NOLOCK) ON IQSearch.ID = MResult.SearchRequestID      
		  GROUP BY      
		  CONVERT (DATE,MResult.LocalDate),IQSearch.ClientGUID, MResult.SearchRequestID, MResult.MediaType, MResult.category
		 ) AS IQDayTmp ON IQDay.ClientGuid = IQDayTmp.ClientGUID 
		 AND IQDay.MediaType = IQDayTmp.MediaType 
		 AND IQDay.DayDate = IQDayTmp.Local_DateTime      
		 AND IQDay.SubMediaType = IQDayTmp.SubMediaType   
		 AND IQDay._SearchRequestID = IQDayTmp.SearchRequestID    
        
		--IQ Day Report Insert      
		INSERT INTO IQAgent_DaySummary    
		   (      
			ClientGuid,      
			DayDate,      
			MediaType,      
			NoOfDocsLD,      
			NoOfHitsLD,      
			AudienceLD,      
			IQMediaValueLD,  
			PositiveSentimentLD,  
			NegativeSentimentLD,
			NoOfDocs,      
			NoOfHits,      
			Audience,      
			IQMediaValue,  
			PositiveSentiment,  
			NegativeSentiment,
			SubMediaType,
			_SearchRequestID        
		   )      
          
		 SELECT             
		  IQSearch.ClientGUID AS ClientGUID,      
		  CONVERT (DATE,MResult.LocalDate) AS DayDate,      
		  MResult.MediaType AS MediaType,      
		  COUNT(*) AS NoOfDocs,      
		  SUM(ISNULL(MResult.NumberOfHits,0)) AS NoOfHits,      
		  SUM(ISNULL(MResult.Audience,0))  AS Audience,      
		  SUM(ISNULL(MResult.IQMediaValue,0))  AS IQMediaValue,  
		  SUM (ISNULL(MResult.PositiveSentiment,0)) AS PositiveSentiment,         
		  SUM (ISNULL(MResult.NegativeSentiment,0)) AS NegativeSentiment,
		  0,
		  0,
		  0,
		  0,
		  0,
		  0,
		   MResult.category AS SubMediaType      ,
		   MResult.SearchRequestID        
		 FROM @TVResultTable AS MResult      
		 INNER JOIN IQAgent_SearchRequest AS IQSearch WITH(NOLOCK) ON IQSearch.ID = MResult.SearchRequestID      
		 LEFT JOIN IQAgent_DaySummary AS IQDay WITH(NOLOCK) ON  IQDay.ClientGuid = IQSearch.ClientGUID 
			 AND IQDay.MediaType = MResult.MediaType 
			 AND IQDay.DayDate =  CONVERT (DATE,MResult.LocalDate)      
			 AND IQDay.SubMediaType = MResult.category
			 AND IQDay._SearchRequestID = MResult.SearchRequestID    
		 WHERE IQDay.ID IS NULL      
		 GROUP BY     
		 CONVERT (DATE,MResult.LocalDate),      
		 IQSearch.ClientGUID, MResult.SearchRequestID ,MResult.MediaType,MResult.category
       
       /*
		UPDATE 
				IQAgent_SummaryTracking
		SET
				RecordsAfterUpdation = (SELECT SUM(NoOfDocsLD) FROM IQAgent_DaySummary WHERE MediaType ='TV')
		WHERE
				ID = @IQAgent_SummaryTrackingID
		*/
     
	-- End of Day and Hour Summary tables updates */
  COMMIT TRANSACTION;        
 END TRY        
 BEGIN CATCH          
  ROLLBACK TRANSACTION;       
 END CATCH        
END

