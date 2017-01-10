USE [IQMediaGroup]
GO

/****** Object:  StoredProcedure [dbo].[usp_DBJob_RefreshIQAgentDayHourSummary_NEW_BuildSummaryTables]    Script Date: 10/20/2016 3:17:59 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[usp_DBJob_RefreshIQAgentDayHourSummary_NEW_BuildSummaryTables]        
@ClientGUID UNIQUEIDENTIFIER
AS        
BEGIN         
 SET NOCOUNT ON;        
 SET XACT_ABORT ON;
        
  
 BEGIN TRY  
	
	DECLARE @Status SMALLINT

	INSERT INTO  #TmpDaySummaryResults
			(
				[ClientGuid],
				[MediaDate],
				[_SearchRequestID],
				[MediaType],
				[SubMediaType],
				[NoOFDocs],
				[NoOfHits],
				[Audience],
				[PositiveSentiment],
				[NegativeSentiment],
				[MediaValue]
			)
		SELECT  @ClientGUID,
			    CONVERT(DATE,tv.GMTDateTime),
				SearchRequestID,
				v5MediaType,
				v5Category,
				COUNT(tv.ID) AS NoOfDocs,
				SUM( ISNULL(Number_Hits,0)) AS NoOfHits,
				SUM( ISNULL(Nielsen_Audience,0)) AS Nielsen_Audience,
				SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
				SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment,
				SUM( ISNULL(IQAdShareValue,0)) AS IQMediaValue
		FROM  #IQAgent_TVResults tv  WITH(NOLOCK) 
		GROUP BY SearchRequestID, CONVERT(DATE,GMTDateTime), v5MediaType,v5Category
	
	INSERT INTO  #TmpDaySummaryLDResults
			(
				[ClientGuid],
				[LocalMediaDate],
				[_SearchRequestID],
				[MediaType],
				[SubMediaType],
				[NoOFDocs],
				[NoOfHits],
				[Audience],
				[PositiveSentiment],
				[NegativeSentiment],
				[MediaValue]
		
			)
		SELECT  @ClientGUID,
				LocalDateTime,
				SearchRequestID,
				v5MediaType,
				v5Category,
				COUNT(tv.ID) AS NoOfDocs,
				SUM( ISNULL(Number_Hits,0)) AS NoOfHits,
				SUM( ISNULL(Nielsen_Audience,0)) AS Nielsen_Audience,
				SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
				SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment,
				SUM( ISNULL(IQAdShareValue,0)) AS IQMediaValue
		FROM  #IQAgent_TVResults tv  WITH(NOLOCK) 
		GROUP BY SearchRequestID,LocalDateTime,v5MediaType,v5Category

	INSERT INTO  #TmpHourSummaryResults
			(
				[ClientGuid],
				[MediaDateTime],
				[_SearchRequestID],
				[MediaType],
				[SubMediaType],
				[NoOFDocs],
				[NoOfHits],
				[Audience],
				[PositiveSentiment],
				[NegativeSentiment],
				[MediaValue]
			)
		SELECT  @ClientGUID,
				DateTimeHour,
				SearchRequestID,
				v5MediaType,
				v5Category,
				COUNT(tv.ID) AS NoOfDocs,
				SUM( ISNULL(Number_Hits,0)) AS NoOfHits,
				SUM( ISNULL(Nielsen_Audience,0)) AS Nielsen_Audience,
				SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
				SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment,
				SUM( ISNULL(IQAdShareValue,0)) AS IQMediaValue
			--	SUM( ISNULL(Earned,0)) AS Heard_Earned,
			--	SUM( ISNULL(Paid,0)) AS Heard_Paid
		FROM  #IQAgent_TVResults tv  WITH(NOLOCK) 
		GROUP BY SearchRequestID,DateTimeHour, v5MediaType,v5Category

-- End of Section For TV     

-- Section For NM
		
	INSERT INTO  #TmpDaySummaryResults
				(
				[ClientGuid],
				[MediaDate],
				[_SearchRequestID],
				[MediaType],
				[SubMediaType],
				[NoOFDocs],
				[NoOfHits],
				[Audience],
				[PositiveSentiment],
				[NegativeSentiment],
				[MediaValue]
				)
		SELECT  @ClientGUID,
				CONVERT(DATE,GMTDateTime),
				SearchRequestID,
				v5MediaType,
				v5Category,
				COUNT(nm.ID) AS NoOfDocs,
				SUM( ISNULL(Number_Hits,0)) AS NoOfHits,
				SUM( ISNULL(Nielsen_Audience,0)) AS Nielsen_Audience,
				SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
				SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment,
				SUM( ISNULL(IQAdShareValue,0)) AS IQAdShareValue
			FROM  #IQAgent_NMResults  NM WITH(NOLOCK) 
			GROUP BY SearchRequestID,CONVERT(DATE,GMTDateTime),v5MediaType,v5Category
	
        INSERT INTO  #TmpDaySummaryLDResults
				(
				[ClientGuid],
				[LocalMediaDate],
				[_SearchRequestID],
				[MediaType],
				[SubMediaType],
				[NoOFDocs],
				[NoOfHits],
				[Audience],
				[PositiveSentiment],
				[NegativeSentiment],
				[MediaValue]
				)
		SELECT  @ClientGUID,
				LocalDateTime,
				SearchRequestID,
				v5MediaType,
				v5Category,
				COUNT(nm.ID) AS NoOfDocs,
				SUM( ISNULL(Number_Hits,0)) AS NoOfHits,
				SUM( ISNULL(Nielsen_Audience,0)) AS Nielsen_Audience,
				SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
				SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment,
				SUM( ISNULL(IQAdShareValue,0)) AS IQAdShareValue
			FROM  #IQAgent_NMResults  NM WITH(NOLOCK) 
			GROUP BY SearchRequestID,LocalDateTime,v5MediaType,v5Category

        INSERT INTO  #TmpHourSummaryResults
				(
				[ClientGuid],
				[MediaDateTime],
				[_SearchRequestID],
				[MediaType],
				[SubMediaType],
				[NoOFDocs],
				[NoOfHits],
				[Audience],
				[PositiveSentiment],
				[NegativeSentiment],
				[MediaValue]
				)
		SELECT  @ClientGUID,
				DateTimeHour,
				SearchRequestID,
				v5MediaType,
				v5Category,
				COUNT(nm.ID) AS NoOfDocs,
				SUM( ISNULL(Number_Hits,0)) AS NoOfHits,
				SUM( ISNULL(Nielsen_Audience,0)) AS Nielsen_Audience,
				SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
				SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment,
				SUM( ISNULL(IQAdShareValue,0)) AS IQAdShareValue
		FROM  #IQAgent_NMResults  NM WITH(NOLOCK) 
		GROUP BY SearchRequestID, DateTimeHour,v5MediaType,v5Category


-- End of Section For NM

-- Section For SM
	        
	INSERT INTO  #TmpDaySummaryResults
				(
				[ClientGuid],
				[MediaDate],
				[_SearchRequestID],
				[MediaType],
				[SubMediaType],
				[NoOFDocs],
				[NoOfHits],
				[Audience],
				[PositiveSentiment],
				[NegativeSentiment],
				[MediaValue]
				)
		SELECT  @ClientGUID,
				CONVERT(DATE,GMTDateTime),
				SearchRequestID,
				v5MediaType,
				v5Category,
				COUNT(sm.ID) AS NoOfDocs,
				SUM( ISNULL(Number_Hits,0)) AS NoOfHits,
				SUM( ISNULL(Nielsen_Audience,0)) AS Nielsen_Audience,
				SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
				SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment,
				SUM( ISNULL(IQAdShareValue,0)) AS IQAdShareValue
			FROM  #IQAgent_SMResults  sm WITH(NOLOCK) 
			GROUP BY SearchRequestID, CONVERT(DATE,GMTDateTime),v5MediaType,v5Category

        INSERT INTO  #TmpDaySummaryLDResults
				(
				[ClientGuid],
				[LocalMediaDate],
				[_SearchRequestID],
				[MediaType],
				[SubMediaType],
				[NoOFDocs],
				[NoOfHits],
				[Audience],
				[PositiveSentiment],
				[NegativeSentiment],
				[MediaValue]
				)
		SELECT  @ClientGUID,
				LocalDateTime,
				SearchRequestID,
				v5MediaType,
				v5Category,
				COUNT(sm.ID) AS NoOfDocs,
				SUM( ISNULL(Number_Hits,0)) AS NoOfHits,
				SUM( ISNULL(Nielsen_Audience,0)) AS Nielsen_Audience,
				SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
				SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment,
				SUM( ISNULL(IQAdShareValue,0)) AS IQAdShareValue
			FROM  #IQAgent_SMResults  sm WITH(NOLOCK) 
			GROUP BY SearchRequestID,LocalDateTime,v5MediaType,v5Category

	 INSERT INTO  #TmpHourSummaryResults
				(
				[ClientGuid],
				[MediaDateTime],
				[_SearchRequestID],
				[MediaType],
				[SubMediaType],
				[NoOFDocs],
				[NoOfHits],
				[Audience],
				[PositiveSentiment],
				[NegativeSentiment],
				[MediaValue]
				)
		SELECT  @ClientGUID,
				DateTimeHour,
				SearchRequestID,
				v5MediaType,
				v5Category,
				COUNT(sm.ID) AS NoOfDocs,
				SUM( ISNULL(Number_Hits,0)) AS NoOfHits,
				SUM( ISNULL(Nielsen_Audience,0)) AS Nielsen_Audience,
				SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
				SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment,
				SUM( ISNULL(IQAdShareValue,0)) AS IQAdShareValue
			FROM  #IQAgent_SMResults  sm WITH(NOLOCK) 
			GROUP BY SearchRequestID,DateTimeHour,v5MediaType,v5Category
			
	-- End of Section For SM
 
-- Section For  Twitter

	INSERT INTO #TmpDaySummaryResults
					(
					MediaDate,
					ClientGUID,
					MediaType,
					SubMediaType,
					_SearchRequestID,
					NoOfDocs,
					NoOfHits,
					Audience,
					MediaValue,
					PositiveSentiment,
					NegativeSentiment
					)
		SELECT		CONVERT(DATE,GMTDateTime),
					@ClientGUID,
					v5MediaType,
					v5Category,
					SearchRequestID,
					COUNT(tw.ID) AS NoOfDocs,
					SUM( ISNULL(tw.Number_Hits,0)) AS NoOfHits,
					SUM( ISNULL(Nielsen_Audience,0)) AS Audience,
					SUM( ISNULL(IQAdShareValue ,0)) AS IQMediaValue,
					SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
					SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment
					FROM #IQAgent_TwitterResults  tw WITH(NOLOCK) 
					GROUP BY SearchRequestID,CONVERT(DATE,GMTDateTime),v5MediaType,v5Category

        INSERT INTO #TmpDaySummaryLDResults
					(
						LocalMediaDate,
						ClientGUID,
						MediaType,
						SubMediaType,
						_SearchRequestID,
						NoOfDocs,
						NoOfHits,
						Audience,
						MediaValue,
						PositiveSentiment,
						NegativeSentiment
					)
			   SELECT 	LocalDateTime,
						@ClientGUID,
						v5MediaType,
						v5Category,
						SearchRequestID,
						COUNT(tw.ID) AS NoOfDocs,
						SUM( ISNULL(tw.Number_Hits,0)) AS NoOfHits,
						SUM( ISNULL(Nielsen_Audience,0)) AS Audience,
						SUM( ISNULL(IQAdShareValue ,0)) AS IQMediaValue,
						SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
						SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment
				FROM #IQAgent_TwitterResults  tw WITH(NOLOCK) 
				GROUP BY SearchRequestID,LocalDateTime,v5MediaType,v5Category

        INSERT INTO #TmpHourSummaryResults
					(
					MediaDateTime,
					ClientGUID,
					MediaType,
					SubMediaType,
					_SearchRequestID,
					NoOfDocs,
					NoOfHits,
					Audience,
					MediaValue,
					PositiveSentiment,
					NegativeSentiment
					)
			 SELECT DateTimeHour,
					@ClientGUID,
					v5MediaType,
					v5Category,
					SearchRequestID,
					COUNT(tw.ID) AS NoOfDocs,
					SUM( ISNULL(tw.Number_Hits,0)) AS NoOfHits,
					SUM( ISNULL(Nielsen_Audience,0)) AS Audience,
					SUM( ISNULL([IQAdShareValue] ,0)) AS IQMediaValue,
					SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
					SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment
	 		FROM #IQAgent_TwitterResults  tw WITH(NOLOCK) 
			GROUP BY SearchRequestID,DateTimeHour,v5MediaType,v5Category

-- End of Section For Twitter

-- Section For TM TVEyes

    Insert into #TmpDaySummaryResults
		( 
		MediaDate,
		ClientGUID,
		MediaType,
		SubMediaType,		
		_SearchRequestID,
		NoOfDocs,
		NoOfHits,
		Audience,
		MediaValue,
		PositiveSentiment,
		NegativeSentiment
		)
	SELECT 
		CONVERT(DATE,GMTDateTime),
		@ClientGUID,
		v5MediaType,
		v5Category,
		SearchRequestID,
		COUNT(tv.ID) AS NoOfDocs,
		0 AS NoOfHits,
		0 AS Audience,
		0 AS IQMediaValue,
		SUM(ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
		SUM(ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM	#IQAgent_TVEyesResults tv WITH(NOLOCK) 
	GROUP BY SearchRequestID,CONVERT(DATE,GMTDateTime),v5MediaType,v5Category

	Insert into #TmpDaySummaryLDResults
		( 
		LocalMediaDate,
		ClientGUID,
		MediaType,
		SubMediaType,		
		_SearchRequestID,
		NoOfDocs,
		NoOfHits,
		Audience,
		MediaValue,
		PositiveSentiment,
		NegativeSentiment
		)
	SELECT 
		LocalDateTime,
		@ClientGUID,
		v5MediaType,
		v5Category,
		SearchRequestID,
		COUNT(tv.ID) AS NoOfDocs,
		0 AS NoOfHits,
		0 AS Audience,
		0 AS IQMediaValue,
		SUM(ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
		SUM(ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM	#IQAgent_TVEyesResults tv WITH(NOLOCK) 
	GROUP BY SearchRequestID,LocalDateTime,v5MediaType,v5Category

	Insert into #TmpHourSummaryResults
		( 
		MediaDateTime,
		ClientGUID,
		MediaType,
		SubMediaType,		
		_SearchRequestID,
		NoOfDocs,
		NoOfHits,
		Audience,
		MediaValue,
		PositiveSentiment,
		NegativeSentiment
		)
	SELECT 
		DateTimeHour,
		@ClientGUID,
		v5MediaType,
		v5Category,
		SearchRequestID,
		COUNT(tv.ID) AS NoOfDocs,
		0 AS NoOfHits,
		0 AS Audience,
		0 AS IQMediaValue,
		SUM(ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
		SUM(ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM	#IQAgent_TVEyesResults tv WITH(NOLOCK) 
	GROUP BY SearchRequestID,DateTimeHour,v5MediaType,v5Category

-- End of Section For TM TVEyes
			 	 
-- Section For PM

        INSERT INTO #TmpDaySummaryResults
					(
					MediaDate,
					ClientGUID,
					MediaType,
					SubMediaType,
					_SearchRequestID,
					NoOfDocs,
					NoOfHits,
					Audience,
					MediaValue,
					PositiveSentiment,
					NegativeSentiment
					)
		SELECT 
					CONVERT(DATE,GMTDateTime),
					@ClientGUID,
					v5MediaType,
					v5Category,
					SearchRequestID,
					COUNT(pm.ID) AS NoOfDocs,
					0 AS NoOfHits,
					SUM( ISNULL(pm.Nielsen_Audience,0)) AS Audience,
					0 AS IQMediaValue,
					SUM(ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
					SUM(ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
			   FROM	#IQAgent_BLPMResults  pm WITH(NOLOCK) 
			   GROUP BY SearchRequestID,CONVERT(DATE,GMTDateTime),v5MediaType,v5Category

        INSERT INTO #TmpDaySummaryLDResults
					(
						LocalMediaDate,
						ClientGUID,
						MediaType,
						SubMediaType,
						_SearchRequestID,
						NoOfDocs,
						NoOfHits,
						Audience,
						MediaValue,
						PositiveSentiment,
						NegativeSentiment
					)
		SELECT 
						LocalDateTime,
						@ClientGUID,
						v5MediaType,
						v5Category,
						SearchRequestID,
						COUNT(pm.ID) AS NoOfDocs,
						0 AS NoOfHits,
						SUM( ISNULL(pm.Nielsen_Audience,0)) AS Audience,
						0 AS IQMediaValue,
						SUM(ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
						SUM(ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
					FROM	#IQAgent_BLPMResults  pm WITH(NOLOCK) 
					GROUP BY SearchRequestID,LocalDateTime,v5MediaType,v5Category

        INSERT INTO #TmpHourSummaryResults
						(
						MediaDateTime,
						ClientGUID,
						MediaType,
						SubMediaType,
						_SearchRequestID,
						NoOfDocs,
						NoOfHits,
						Audience,
						MediaValue,
						PositiveSentiment,
						NegativeSentiment
						)
       	SELECT 
						DateTimeHour,
						@ClientGUID,
						v5MediaType,
						v5Category,
						SearchRequestID,
						COUNT(pm.ID) AS NoOfDocs,
						0 AS NoOfHits,
						SUM( ISNULL(pm.Nielsen_Audience,0)) AS Audience,
						0 AS IQMediaValue,
						SUM(ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
						SUM(ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
				  FROM	#IQAgent_BLPMResults  pm WITH(NOLOCK) 
				  GROUP BY SearchRequestID,DateTimeHour,v5MediaType,v5Category

-- End of Section For PM

-- Section For PQ

	    INSERT INTO #TmpDaySummaryResults
				(
				MediaDate,
				ClientGUID,
				MediaType,
				SubMediaType,
				_SearchRequestID,
				NoOfDocs,
				NoOfHits,
				Audience,
				MediaValue,
				PositiveSentiment,
				NegativeSentiment
				)
		SELECT 
				CONVERT(DATE,GMTDateTime),
				@ClientGUID,
				v5MediaType,
				v5Category,
				SearchRequestID,
				COUNT(pq.ID) AS NoOfDocs,
				SUM(ISNULL(pq.Number_Hits,0)) AS NoOfHits,    
				0 AS Audience,
				0 AS IQMediaValue,
				SUM(ISNULL(PositiveSentiment,0)) AS PositiveSentiment,         
				SUM(ISNULL(NegativeSentiment,0)) AS NegativeSentiment
		FROM #IQAgent_PQResults  pq WITH (NOLOCK) 
		GROUP BY SearchRequestID, CONVERT(DATE,GMTDateTime),v5MediaType,v5Category

        	INSERT INTO #TmpDaySummaryLDResults
				(
				LocalMediaDate,
				ClientGUID,
				MediaType,
				SubMediaType,
				_SearchRequestID,
				NoOfDocs,
				NoOfHits,
				Audience,
				MediaValue,
				PositiveSentiment,
				NegativeSentiment
				)
		SELECT 
				LocalDateTime,
				@ClientGUID,
				v5MediaType,
				v5Category,
				SearchRequestID,
				COUNT(pq.ID) AS NoOfDocs,
				SUM(ISNULL(pq.Number_Hits,0)) AS NoOfHits,  
				0 AS Audience,
				0 AS IQMediaValue,
				SUM(ISNULL(PositiveSentiment,0)) AS PositiveSentiment,         
					SUM(ISNULL(NegativeSentiment ,0)) AS NegativeSentiment
           FROM #IQAgent_PQResults  pq WITH(NOLOCK) 
		   GROUP BY SearchRequestID,LocalDateTime,v5MediaType,v5Category

           INSERT INTO #TmpHourSummaryResults
				(
				MediaDateTime,
				ClientGUID,
				MediaType,
				SubMediaType,
				_SearchRequestID,
				NoOfDocs,
				NoOfHits,
				Audience,
				MediaValue,
				PositiveSentiment,
				NegativeSentiment
				)
       	SELECT 
				DateTimeHour,
				@ClientGUID,
				v5MediaType,
				v5Category,
				SearchRequestID,
				COUNT(pq.ID) AS NoOfDocs,
				SUM(ISNULL(pq.Number_Hits,0)) AS NoOfHits,  
				0 AS Audience,
				0 AS IQMediaValue,
				SUM(ISNULL(PositiveSentiment,0)) AS PositiveSentiment,         
					SUM(ISNULL(NegativeSentiment ,0)) AS NegativeSentiment
  			FROM #IQAgent_PQResults  pq WITH(NOLOCK) 
		    GROUP BY SearchRequestID,DateTimeHour,v5MediaType,v5Category

-- End of Section For PQ
	 
   		   Create index idx1_IQAnalytic_TmpDaySummaryResults on #TmpDaySummaryResults(ClientGUID,_SearchRequestID,MediaDate,MediaType,SubMediaType)
		   Create index idx1_IQAnalytic_TmpDaySummaryLDResults on #TmpDaySummaryLDResults(ClientGUID,_SearchRequestID,LocalMediaDate,MediaType,SubMediaType)
		   Create index idx1_IQAnalytic_TmpHourSummaryResults on #TmpHourSummaryResults(ClientGUID,_SearchRequestID,MediaDateTime,MediaType,SubMediaType)

RETURN 0      

END TRY        
BEGIN CATCH        

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
				@CreatedBy='usp_DBJob_RefreshIQAgentDayHourSummary_NEW_BuildSummaryTables',
				@ModifiedBy='usp_DBJob_RefreshIQAgentDayHourSummary_NEW_BuildSummaryTables',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
				
		
		EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT
		Return 1
END CATCH      
  

    
END
























GO


