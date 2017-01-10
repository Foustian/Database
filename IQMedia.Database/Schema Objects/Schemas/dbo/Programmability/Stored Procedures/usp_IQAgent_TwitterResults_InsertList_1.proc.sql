CREATE PROCEDURE [dbo].[usp_IQAgent_TwitterResults_InsertList]
	@XmlData xml        
AS
BEGIN
	
 DECLARE @StopWatch datetime, @SPStartTime datetime,@SPTrackingID uniqueidentifier, @TimeDiff decimal(18,2),@SPName varchar(100),@QueryDetail varchar(500)
 
 Set @SPStartTime=GetDate()
 Set @Stopwatch=GetDate()
 SET @SPTrackingID = NEWID()
 SET @SPName ='usp_IQAgent_TwitterResults_InsertList'     

 BEGIN TRANSACTION;        
  
 BEGIN TRY         
         
 DECLARE @MediaResultTable TABLE (MediaID BIGINT,Title NVARCHAR(Max),MediaType VARCHAR(2), Category VARCHAR(50), HighlightingText NVARCHAR(MAX), MediaDate DATETIME,LocalDate DATETIME, SearchRequestID BIGINT,Sentiment xml, IsActive BIT, IQMediaValue decimal(18,2), Audience int,
PositiveSentiment tinyint,NegativeSentiment tinyint,NumberOfHits int)  

--DECLARE @IQAgent_SummaryTrackingID bigint                   
    
 INSERT into [dbo].[IQAgent_TwitterResults]         
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
   ModifiedDate      
  )        
          
  OUTPUT INSERTED.ID as MediaID,NULL as Title, 'TW' as MediaType,'TW' as Category, convert(nvarchar(max), INSERTED.HighlightingText) as HighlightingText, INSERTED.tweet_posteddatetime as MediaDate,
  INSERTED.tweet_posteddatetime as LocalDate,
  INSERTED.IQAgentSearchRequestID as SearchRequestID,       
 
  INSERTED.Sentiment as Sentiment,1 as IsActive, INSERTED.gnip_klout_score as IQMediaValue, INSERTED.actor_followersCount as Audience,null as PositiveSentiment ,null as NegativeSentiment,INSERTED.Number_Hits as NumberOfHits INTO @MediaResultTable        
  SELECT         
     tblXml.c.value('@TweetID','varchar(50)') as [TweetID],        
     tblXml.c.value('@IQAgentSearchRequestID','bigint') as [IQAgentSearchRequestID],        
     tblXml.c.value('@QueryVersion','int') as [QueryVersion],        
     tblXml.c.value('@actor_image','varchar(max)') as [actor_image],        
     tblXml.c.value('@actor_link','varchar(max)') as [actor_link],        
     tblXml.c.value('@actor_followersCount','int') as [actor_followersCount],        
     tblXml.c.value('@actor_friendsCount','int') as [actor_friendsCount],        
     tblXml.c.value('@Summary','nvarchar(max)') as [Summary],        
     tblXml.c.value('@tweet_posteddatetime','datetime') as [tweet_posteddatetime],        
     tblXml.c.value('@actor_displayname','varchar(50)') as [actor_displayname],        
     tblXml.c.value('@actor_preferredname','varchar(50)') as [actor_preferredname],        
     tblXml.c.value('@gnip_klout_score','smallint') as [gnip_klout_score],        
     case when convert(varchar(max), tblXml.c.query('Sentiment')) = '' THEN NULL ELSE tblXml.c.query('Sentiment') END as [Sentiment],
     tblXml.c.value('@Number_Hits','int') as [Number_Hits],
     tblXml.c.query('HighlightedTWOutput') as [HighlightingText]  ,      
     getdate () as CreatedDate,      
      getdate () as ModifiedDate      
  FROM          
    @XmlData.nodes('/IQAgentTwitterResultsList/IQAgentTwitterResult') as tblXml(c)        
     left outer join IQAgent_TwitterResults with(nolock)       
      on IQAgent_TwitterResults.IQAgentSearchRequestID=tblXml.c.value('@IQAgentSearchRequestID','bigint') and        
       IQAgent_TwitterResults.TweetID=tblXml.c.value('@TweetID','varchar(50)')    
	 left outer join IQAgent_SearchRequest with(nolock)
	   on tblXml.c.value('@IQAgentSearchRequestID','bigint') = IQAgent_SearchRequest.ID
	     
  WHERE        
    IQAgent_TwitterResults.IQAgentSearchRequestID is null and IQAgent_SearchRequest.IsActive = 1        
            
        
  SET @QueryDetail ='insert into [IQAgent_TwitterResults] table using left join of xml agent tw table'
     SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
     INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
     SET @Stopwatch = GetDate()		
		    
 update MResult set   
 PositiveSentiment = (select tblSentiment.c.value('.', 'tinyint') from MResult.Sentiment.nodes('/Sentiment/PositiveSentiment') as tblSentiment(c)) ,        
 NegativeSentiment = (select tblSentiment.c.value('.', 'tinyint') from MResult.Sentiment.nodes('/Sentiment/NegativeSentiment') as tblSentiment(c))  , 
 LocalDate = CASE WHEN dbo.fnIsDayLightSaving(LocalDate) = 1 THEN  DATEADD(HOUR,(SELECT gmt + dst From Client where ClientGuid = (SELECt ClientGuid FROM IQAgent_SearchRequest Where ID = MResult.SearchRequestID)),LocalDate) ELSE DATEADD(HOUR,(SELECT gmt From Client where ClientGuid = (SELECt ClientGuid FROM IQAgent_SearchRequest Where ID = MResult.SearchRequestID)),LocalDate) END
from @MediaResultTable as MResult    

	 SET @QueryDetail ='update temporary sm table for local date and sentiments and category'
     SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
     INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
     SET @Stopwatch = GetDate()		 
       
	 DECLARE @RecordsToInsert varchar(max)
 SET @RecordsToInsert = STUFF((select ',' + CONVERT(VARCHAR,MediaID) from @MediaResultTable for xml path('')),1,1,'')     
	        
   INSERT into IQAgent_MediaResults        
   (        
    Title,        
    _MediaID,        
    MediaType,        
    Category,        
    HighlightingText,        
    MediaDate,        
    _SearchRequestID,
    PositiveSentiment,        
    NegativeSentiment,        
    IsActive        
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
    IsActive         
   FROM        
     @MediaResultTable        
        
		SET @QueryDetail ='insert into iqagent media results table from temp sm table'
		SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
		INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
		SET @Stopwatch = GetDate()    

 Update IQHRS   
 SET IQHRS.NoOfDocs = (IQHRS.NoOfDocs + IQHRSTmp.Number_Docs ) ,    
  Audience = (IQHRS.Audience + IQHRSTmp.Audience),      
  IQMediaValue = (IQHRS.IQMediaValue + IQHRSTmp.IQMediaValue) ,   
  IQHRS.PositiveSentiment = (isnull(IQHRS.PositiveSentiment,0) + IQHRSTmp.PositiveSentiment) ,   
  IQHRS.NegativeSentiment = (isnull(IQHRS.NegativeSentiment,0) + IQHRSTmp.NegativeSentiment) ,
  IQHRS.NoOfHits=(IQHRS.NoOfHits+ Number_Of_Hits)     
 FROM IQAgent_HourSummary as IQHRS      
 INNER JOIN (      
  SELECT             
     IQSearch.ClientGUID as ClientGUID,      
     DateAdd (hour,DATEPART(hour,MResult.MediaDate), convert (varchar(10),MResult.MediaDate,101) ) as GMT_DateTime,      
     MResult.MediaType as MediaType,      
	 MResult.SearchRequestID,
     COUNT(*) AS Number_Docs,      
     Sum(isnull(MResult.NumberOfHits,0)) as Number_Of_Hits,
     Sum(isnull(MResult.Audience,0))  as Audience,      
     Sum(isnull(MResult.IQMediaValue,0))  as IQMediaValue,  
     sum (isnull(MResult.PositiveSentiment,0)) as PositiveSentiment,         
     sum (isnull(MResult.NegativeSentiment ,0)) as NegativeSentiment ,
     MResult.category as SubMediaType              
  FROM @MediaResultTable as MResult      
  INNER JOIN IQAgent_SearchRequest As IQSearch with(nolock) on IQSearch.ID = MResult.SearchRequestID      
  GROUP BY      
  DateAdd (hour,DATEPART(hour,MResult.MediaDate), convert(varchar(10),MResult.MediaDate,101)),IQSearch.ClientGUID,MResult.SearchRequestID,MResult.MediaType,MResult.category) 
  as IQHRSTmp on IQHRS.ClientGuid = IQHRSTmp.ClientGUID 
  and IQHRS.MediaType = IQHRSTmp.MediaType 
  and IQHRS.HourDateTime = IQHRSTmp.GMT_DateTime      
  and IQHRS.SubMediaType = IQHRSTmp.SubMediaType
  and IQHRS._SearchRequestID = IQHRSTmp.SearchRequestID
         
      SET @QueryDetail ='update hour summary table to update no of docs and other counts for newly inserted record'
		 SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
		 INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
		 SET @Stopwatch = GetDate()  
	      
 --IQ Hours Report Insert      
   Insert Into IQAgent_HourSummary      
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
  IQSearch.ClientGUID as ClientGUID,      
  DateAdd (hour,DATEPART(hour,MResult.MediaDate), convert (varchar(10),MResult.MediaDate,101) ) as HourDateTime,      
  MResult.MediaType as MediaType,      
  COUNT(*) AS NoOfDocs,      
  Sum(isnull(MResult.NumberOfHits,0))  as NoOfHits,
  Sum(isnull(MResult.Audience,0))  as Audience,      
  Sum(isnull(MResult.IQMediaValue,0))  as IQMediaValue    ,  
  sum(isnull(MResult.PositiveSentiment,0)) as PositiveSentiment,         
  sum(isnull(MResult.NegativeSentiment ,0)) as NegativeSentiment,
  MResult.category as SubMediaType ,
  MResult.SearchRequestID    
 FROM @MediaResultTable as MResult 
 INNER JOIN IQAgent_SearchRequest As IQSearch with(nolock) on IQSearch.ID = MResult.SearchRequestID      
 LEFT Join IQAgent_HourSummary AS IQHRS with(nolock) on IQHRS.ClientGuid = IQSearch.ClientGUID 
 and IQHRS.MediaType = MResult.MediaType 
 and IQHRS.HourDateTime =  DateAdd (hour,DATEPART(hour,MediaDate), convert (varchar(10),MediaDate,101) ) 
 and IQHRS.SubMediaType = MResult.category
 and IQHRS._SearchRequestID = MResult.SearchRequestID
 where IQHRS.ID is null      
 GROUP BY      
 DateAdd (hour,DATEPART(hour,MResult.MediaDate), convert (varchar(10),MResult.MediaDate,101) ) ,IQSearch.ClientGUID, MResult.SearchRequestID, MResult.MediaType,MResult.category
       
	   SET @QueryDetail ='insert in hour summary table for day dates which not already exist'
	  SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
	  INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
	  SET @Stopwatch = GetDate()

		--IQ Day Report Update      
		Update IQDay   
 SET IQDay.NoOfDocs = (IQDay.NoOfDocs + IQDayTmp.Number_Docs ) ,    
  IQDay.Audience = (IQDay.Audience + IQDayTmp.Audience),      
  IQDay.IQMediaValue = (IQDay.IQMediaValue + IQDayTmp.IQMediaValue),  
  IQDay.PositiveSentiment = (isnull(IQDay.PositiveSentiment,0) + IQDayTmp.PositiveSentiment) ,   
  IQDay.NegativeSentiment = (isnull(IQDay.NegativeSentiment,0) + IQDayTmp.NegativeSentiment) ,        
  IQDay.NoOfHits=(IQDay.NoOfHits+Number_Of_Hits)  
 FROM IQAgent_DaySummary as IQDay      
 INNER JOIN (      
  SELECT             
     IQSearch.ClientGUID as ClientGUID,      
     convert (date,MResult.MediaDate)  as GMT_DateTime,      
     MResult.MediaType as MediaType,      
	 MResult.SearchRequestID,
     COUNT(*) AS Number_Docs,      
     Sum(isnull(MResult.NumberOfHits,0))  as Number_Of_Hits,
     Sum(isnull(MResult.Audience,0))  as Audience,      
     Sum(isnull(MResult.IQMediaValue,0))  as IQMediaValue,  
     sum (isnull(MResult.PositiveSentiment,0)) as PositiveSentiment,         
     sum (isnull(MResult.NegativeSentiment,0)) as NegativeSentiment ,                  
     MResult.category as SubMediaType  
  FROM @MediaResultTable as MResult      
  INNER JOIN IQAgent_SearchRequest As IQSearch with(nolock) on IQSearch.ID = MResult.SearchRequestID      
  GROUP BY      
  convert (date,MResult.MediaDate),IQSearch.ClientGUID,MResult.MediaType,MResult.SearchRequestID, MResult.category 
 ) as IQDayTmp on IQDay.ClientGuid = IQDayTmp.ClientGUID 
 and IQDay.MediaType = IQDayTmp.MediaType 
 and IQDay.DayDate = IQDayTmp.GMT_DateTime      
 and IQDay.SubMediaType = IQDayTmp.SubMediaType       
 and IQDay._SearchRequestID = IQDayTmp.SearchRequestID
        
		 SET @QueryDetail ='update day summary table to update no of docs and other counts for newly inserted record'
		 SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
		 INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
		 SET @Stopwatch = GetDate()  

		--IQ Day Report Insert      
		Insert Into IQAgent_DaySummary    
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
    SubMediaType     ,
	_SearchRequestID    
   )      
          
 SELECT             
  IQSearch.ClientGUID as ClientGUID,      
  convert (date,MResult.MediaDate) as DayDate,      
  MResult.MediaType as MediaType,      
  COUNT(*) AS NoOfDocs,      
  Sum(isnull(MResult.NumberOfHits,0))  as NoOfHits,
  Sum(isnull(MResult.Audience,0))  as Audience,      
  Sum(isnull(MResult.IQMediaValue,0))  as IQMediaValue,  
  sum (isnull(MResult.PositiveSentiment,0)) as PositiveSentiment,         
  sum (isnull(MResult.NegativeSentiment,0)) as NegativeSentiment,
  0,
  0,
  0,
  0,
  0,
  0,
   MResult.category as SubMediaType ,
   MResult.SearchRequestID           
 FROM @MediaResultTable as MResult      
 INNER JOIN IQAgent_SearchRequest As IQSearch with(nolock) on IQSearch.ID = MResult.SearchRequestID      
 LEFT Join IQAgent_DaySummary AS IQDay with(nolock) on  IQDay.ClientGuid = IQSearch.ClientGUID 
	 and IQDay.MediaType = MResult.MediaType 
	 and IQDay.DayDate =  convert (date,MResult.MediaDate)      
	 and IQDay.SubMediaType = MResult.category
	 and IQDay._SearchRequestID = MResult.SearchRequestID
 where IQDay.ID is null      
 GROUP BY     
 convert (date,MResult.MediaDate),IQSearch.ClientGUID, MResult.SearchRequestID ,MResult.MediaType,MResult.category
        
		 SET @QueryDetail ='insert in day summary table for day dates which not already exist'
	  SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
	  INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
	  SET @Stopwatch = GetDate() 

		--IQ Day Report Update      
		Update IQDay   
 SET IQDay.NoOfDocsLD = (IQDay.NoOfDocsLD + IQDayTmp.Number_Docs ) ,    
  IQDay.AudienceLD = (IQDay.AudienceLD + IQDayTmp.Audience),      
  IQDay.IQMediaValueLD = (IQDay.IQMediaValueLD + IQDayTmp.IQMediaValue),  
  IQDay.PositiveSentimentLD = (isnull(IQDay.PositiveSentimentLD,0) + IQDayTmp.PositiveSentiment) ,   
  IQDay.NegativeSentimentLD = (isnull(IQDay.NegativeSentimentLD,0) + IQDayTmp.NegativeSentiment) ,        
  IQDay.NoOfHitsLD =(IQDay.NoOfHitsLD+Number_Of_Hits)  
 FROM IQAgent_DaySummary as IQDay      
 INNER JOIN (      
  SELECT             
     IQSearch.ClientGUID as ClientGUID,      
     convert (date,MResult.LocalDate)  as Local_DateTime,      
     MResult.MediaType as MediaType,      
	 MResult.SearchRequestID,
     COUNT(*) AS Number_Docs,      
     Sum(isnull(MResult.NumberOfHits,0))  as Number_Of_Hits,
     Sum(isnull(MResult.Audience,0))  as Audience,      
     Sum(isnull(MResult.IQMediaValue,0))  as IQMediaValue,  
     sum (isnull(MResult.PositiveSentiment,0)) as PositiveSentiment,         
     sum (isnull(MResult.NegativeSentiment,0)) as NegativeSentiment ,                  
     MResult.category as SubMediaType  
  FROM @MediaResultTable as MResult      
  INNER JOIN IQAgent_SearchRequest As IQSearch with(nolock) on IQSearch.ID = MResult.SearchRequestID      
  GROUP BY      
  convert (date,MResult.LocalDate),IQSearch.ClientGUID,MResult.MediaType,MResult.SearchRequestID, MResult.category 
 ) as IQDayTmp on IQDay.ClientGuid = IQDayTmp.ClientGUID 
 and IQDay.MediaType = IQDayTmp.MediaType 
 and IQDay.DayDate = IQDayTmp.Local_DateTime      
 and IQDay.SubMediaType = IQDayTmp.SubMediaType       
 and IQDay._SearchRequestID = IQDayTmp.SearchRequestID
        
		SET @QueryDetail ='update day summary table to update no of docs on local date and other counts for newly inserted record'
		 SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
		 INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
		 SET @Stopwatch = GetDate()  

		--IQ Day Report Insert      
		Insert Into IQAgent_DaySummary    
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
    SubMediaType     ,
	_SearchRequestID    
   )      
          
 SELECT             
  IQSearch.ClientGUID as ClientGUID,      
  convert (date,MResult.LocalDate) as DayDate,      
  MResult.MediaType as MediaType,      
  COUNT(*) AS NoOfDocs,      
  Sum(isnull(MResult.NumberOfHits,0))  as NoOfHits,
  Sum(isnull(MResult.Audience,0))  as Audience,      
  Sum(isnull(MResult.IQMediaValue,0))  as IQMediaValue,  
  sum (isnull(MResult.PositiveSentiment,0)) as PositiveSentiment,         
  sum (isnull(MResult.NegativeSentiment,0)) as NegativeSentiment,
  0,
  0,
  0,
  0,
  0,
  0,
   MResult.category as SubMediaType ,
   MResult.SearchRequestID           
 FROM @MediaResultTable as MResult      
 INNER JOIN IQAgent_SearchRequest As IQSearch with(nolock) on IQSearch.ID = MResult.SearchRequestID      
 LEFT Join IQAgent_DaySummary AS IQDay with(nolock) on  IQDay.ClientGuid = IQSearch.ClientGUID 
	 and IQDay.MediaType = MResult.MediaType 
	 and IQDay.DayDate =  convert (date,MResult.LocalDate)      
	 and IQDay.SubMediaType = MResult.category
	 and IQDay._SearchRequestID = MResult.SearchRequestID
 where IQDay.ID is null      
 GROUP BY     
 convert (date,MResult.LocalDate),IQSearch.ClientGUID, MResult.SearchRequestID ,MResult.MediaType,MResult.category
        
		SET @QueryDetail ='insert in day summary table for local day dates which not already exist'
	  SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
	  INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
	  SET @Stopwatch = GetDate() 

   COMMIT TRANSACTION;        
  END TRY      
  BEGIN CATCH        
   ROLLBACK TRANSACTION;        
  END CATCH        

  SET @QueryDetail ='0'
	 SET @TimeDiff = DateDiff(ms, @SPStartTime, GetDate())
	 INSERT INTO IQ_SPTimeTracking([Guid],SPName,Input,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,'<Input><XmlData>'+ convert(nvarchar(max),@XmlData) +'</XmlData></Input>',@QueryDetail,@TimeDiff)       
END