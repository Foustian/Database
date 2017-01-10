CREATE PROCEDURE [dbo].[usp_v5_Dashboard_PRResults_Select]
(
	@ClientGUID			UNIQUEIDENTIFIER,
	@SearchRequestIDXml	XML,
	@FromDate			DATETIME,
	@ToDate				DATETIME,
	@MediaType			VARCHAR(50),
	@MediaTypeAccessXml xml
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SPStartTime DATETIME=GetDate(),
			@Stopwatch DATETIME=GetDate(),
			@SPTrackingID UNIQUEIDENTIFIER = NEWID(),
			@SPName VARCHAR(100) ='usp_v5_Dashboard_PRResults_Select',
			@TimeDiff DECIMAL(18,2),
			@QueryDetail VARCHAR(500)

	DECLARE @MediaTypeAccessTbl TABLE(MediaType VARCHAR(50), SubMediaType VARCHAR(50), HasAccess BIT)

	INSERT INTO @MediaTypeAccessTbl
	 (
		MediaType,
		SubMediaType,
		HasAccess
	 )
	 SELECT
		MT.A.value('@MediaType','VARCHAR(50)'),
		MT.A.value('@SubMediaType','VARCHAR(50)'),
		MT.A.value('@HasAccess','BIT')
	 FROM
			@MediaTypeAccessXml.nodes('list/item') AS MT(A)
	 WHERE
			MT.A.value('@TypeLevel','INT') = 2	

	DECLARE @SRIDTbl TABLE(ID BIGINT)
	DECLARE	@SRIDCount INT=0

	INSERT INTO @SRIDTbl
	(
		ID
	)
	SELECT
			Search.req.value('@id','BIGINT') 
	FROM
			@SearchRequestIDXml.nodes('list/item') as Search(req)  

	SELECT
			@SRIDCount = COUNT(*)
	FROM
			@SRIDTbl AS SRID

	Declare @FDate datetime=NULL,  
			@TDate datetime=NULL		
  
	IF(@FromDate is not null AND @ToDate is not null)  
		BEGIN  
		   Declare @IsDST bit,  
			 @gmt decimal(18,2),  
			 @dst decimal(18,2)  
     
		   Select  
			 @gmt=Client.gmt,  
			 @dst=Client.dst  
		   From  
			 Client  
		   Where  
			 ClientGUID=@ClientGUID  
   
		   SET @FDate=@FromDate  
		   SET @TDate=DATEADD(MINUTE,1439,Convert(datetime, @ToDate))  
     
		   Select @IsDST=dbo.fnIsDayLightSaving(@FDate);  
   
		   If(@IsDST=1)  
		   BEGIN  
			 Set @FDate=DATEADD(HOUR,-(@gmt),CONVERT(datetime,@FDate))  
			 Set @FDate=DATEADD(HOUR,-@dst,CONVERT(datetime, @FDate))  
		   END  
		   ELSE  
		   BEGIN  
			 Set @FDate=DATEADD(HOUR,-(@gmt),CONVERT(datetime, @FDate))  
		   END  
   
		   Select @IsDST=dbo.fnIsDayLightSaving(@TDate);  
   
		   If(@IsDST=1)  
		   BEGIN  
			 Set @TDate=DATEADD(HOUR,-(@gmt),@TDate)  
			 Set @TDate=DATEADD(HOUR,-@dst,@TDate)  
		   END  
		   ELSE  
		   BEGIN  
			 Set @TDate=DATEADD(HOUR,-(@gmt),@TDate)  
		   END  
		END 

	IF(@SRIDCount > 0)
		BEGIN
			
			SELECT top 10
					Publication,
					NoOfDocs,
					Mentions,
					PositiveSentiment,
					NegativeSentiment,
					SubMediaType
			FROM
			(
				SELECT top 10
					Publication,
					count(IQAgent_PQResults.ID) as NoOfDocs,
					ISNULL(sum(CONVERT(BIGINT,Number_Hits)),0) as Mentions,
					ISNULL(sum(IQAgent_MediaResults.PositiveSentiment),0) as PositiveSentiment,
					ISNULL(sum(IQAgent_MediaResults.NegativeSentiment),0) as NegativeSentiment,
					MAX(IQAgent_MediaResults.v5Category) AS SubMediaType
				FROM 
						IQAgent_MediaResults WITH(NOLOCK)
							INNER JOIN	IQAgent_PQResults WITH (NOLOCK)
								ON	IQAgent_MediaResults._MediaID = IQAgent_PQResults.ID
								AND	IQAgent_MediaResults.v5MediaType = @MediaType
								AND	IQAgent_MediaResults.v5Category = IQAgent_PQResults.v5SubMediaType
								AND	IQAgent_MediaResults.IsActive = 1
							INNER JOIN @MediaTypeAccessTbl AS MTA
								ON	IQAgent_MediaResults.v5MediaType = MTA.MediaType
								AND	IQAgent_MediaResults.v5Category = MTA.SubMediaType
								AND	MTA.HasAccess = 1 
							INNER JOIN IQAgent_SearchRequest WITH (NOLOCK)
								ON IQAgent_PQResults.IQAgentSearchRequestID = IQAgent_SearchRequest.ID
								AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
								AND IQAgent_SearchRequest.IsActive > 0
								AND IQAgent_PQResults.IsActive = 1
							INNER JOIN @SRIDTbl AS SRID
								ON IQAgent_SearchRequest.ID = SRID.ID
				WHERE
					((@FDate is null or @TDate is null) OR IQAgent_PQResults.MediaDate BETWEEN @FDate AND @TDate)
				GROUP BY Publication
				ORDER BY ISNULL(sum(CONVERT(BIGINT,Number_Hits)),0) desc,count(IQAgent_PQResults.ID) desc

				UNION

				SELECT top 10
					Publication,
					count(IQAgent_NMResults.ID) as NoOfDocs,
					ISNULL(sum(CONVERT(BIGINT,Number_Hits)),0) as Mentions,
					ISNULL(sum(IQAgent_MediaResults.PositiveSentiment),0) as PositiveSentiment,
					ISNULL(sum(IQAgent_MediaResults.NegativeSentiment),0) as NegativeSentiment,
					MAX(IQAgent_MediaResults.v5Category) AS SubMediaType
				FROM	
						IQAgent_MediaResults
							INNER JOIN	IQAgent_NMResults WITH (NOLOCK)
								ON	IQAgent_MediaResults._MediaID = IQAgent_NMResults.ID
								AND	IQAgent_MediaResults.v5MediaType = @MediaType
								AND	IQAgent_MediaResults.v5Category = 'LN'
								AND	IQAgent_MediaResults.v5Category = IQAgent_NMResults.v5SubMediaType
								AND IQAgent_MediaResults.IsActive = 1
							INNER JOIN @MediaTypeAccessTbl AS MTA
								ON	IQAgent_MediaResults.v5MediaType = MTA.MediaType
								AND	IQAgent_MediaResults.v5Category = MTA.SubMediaType
								AND	MTA.HasAccess = 1 
							INNER JOIN IQAgent_SearchRequest WITH (NOLOCK)
								ON IQAgent_NMResults.IQAgentSearchRequestID = IQAgent_SearchRequest.ID
								AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
								AND IQAgent_SearchRequest.IsActive > 0
								AND IQAgent_NMResults.IsActive = 1
							INNER JOIN @SRIDTbl AS SRID
								ON IQAgent_SearchRequest.ID = SRID.ID
				WHERE
					((@FDate is null or @TDate is null) OR IQAgent_MediaResults.MediaDate BETWEEN @FDate AND @TDate)
				GROUP BY Publication
				ORDER BY ISNULL(sum(CONVERT(BIGINT,Number_Hits)),0) desc,count(IQAgent_NMResults.ID) desc
			) AS PRResults
			ORDER BY Mentions DESC, NoOfDocs DESC

			SET @QueryDetail ='get top publications for pq'
			SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
			INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
			SET @Stopwatch = GetDate()

			;WITH tempAuthors as
			(
				SELECT  Tbl.Authors.value('.', 'varchar(100)') AS Author,
				IQAgent_PQResults.ID,
				Number_Hits,
				IQAgent_MediaResults.PositiveSentiment,
				IQAgent_MediaResults.NegativeSentiment,
				IQAgent_MediaResults.v5Category AS SubMediaType
				FROM 
						IQAgent_MediaResults WITH(NOLOCK)
							INNER JOIN	IQAgent_PQResults WITH(NOLOCK)
								ON	IQAgent_MediaResults._MediaID = IQAgent_PQResults.ID
								AND	IQAgent_MediaResults.v5MediaType = @MediaType
								AND	IQAgent_MediaResults.v5Category = IQAgent_PQResults.v5SubMediaType
								AND	IQAgent_MediaResults.IsActive = 1
							INNER JOIN @MediaTypeAccessTbl AS MTA
								ON	IQAgent_MediaResults.v5MediaType = MTA.MediaType
								AND	IQAgent_MediaResults.v5Category = MTA.SubMediaType
								AND	MTA.HasAccess = 1 
							CROSS APPLY Authors.nodes('authors/author') as Tbl(Authors)
							INNER JOIN IQAgent_SearchRequest WITH (NOLOCK)
								ON IQAgent_PQResults.IQAgentSearchRequestID = IQAgent_SearchRequest.ID
								AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
								AND IQAgent_SearchRequest.IsActive > 0
								AND IQAgent_PQResults.IsActive = 1
							INNER JOIN @SRIDTbl AS SRID
								ON IQAgent_SearchRequest.ID = SRID.ID
			WHERE
				((@FDate is null or @TDate is null) OR IQAgent_PQResults.MediaDate BETWEEN @FDate AND @TDate)
			)
				
		SELECT top 10
				tempAuthors.Author,
				count(ID) as NoOfDocs,
				ISNULL(sum(CONVERT(BIGINT,Number_Hits)),0) as Mentions,
				ISNULL(sum(CONVERT(BIGINT,PositiveSentiment)),0)  as PositiveSentiment,
				ISNULL(sum(CONVERT(BIGINT,NegativeSentiment)),0)  as NegativeSentiment,
				MAX(SubMediaType) AS SubMediaType
			FROM tempAuthors
			GROUP BY tempAuthors.Author
			ORDER BY ISNULL(sum(CONVERT(BIGINT,Number_Hits)),0) desc,count(ID) desc

			SET @QueryDetail ='get top authors for pq'
			SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
			INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
			SET @Stopwatch = GetDate()
			
		END
	ELSE
		BEGIN			
			
			SELECT top 10
					Publication,
					NoOfDocs,
					Mentions,
					PositiveSentiment,
					NegativeSentiment,
					SubMediaType
				FROM						
				(							
						SELECT top 10
							Publication,
							count(IQAgent_PQResults.ID) as NoOfDocs,
							ISNULL(sum(CONVERT(BIGINT,Number_Hits)),0) as Mentions,
							ISNULL(sum(IQAgent_MediaResults.PositiveSentiment),0) as PositiveSentiment,
							ISNULL(sum(IQAgent_MediaResults.NegativeSentiment),0) as NegativeSentiment,
							MAX(IQAgent_MediaResults.v5Category) AS SubMediaType
						FROM 
								IQAgent_MediaResults WITH(NOLOCK)
									INNER JOIN	IQAgent_PQResults WITH (NOLOCK)
										ON	IQAgent_MediaResults._MediaID = IQAgent_PQResults.ID
										AND	IQAgent_MediaResults.v5MediaType = @MediaType
										AND	IQAgent_MediaResults.v5Category = IQAgent_PQResults.v5SubMediaType
										AND	IQAgent_MediaResults.IsActive = 1
									INNER JOIN @MediaTypeAccessTbl AS MTA
										ON	IQAgent_MediaResults.v5MediaType = MTA.MediaType
										AND	IQAgent_MediaResults.v5Category = MTA.SubMediaType
										AND	MTA.HasAccess = 1
									INNER JOIN IQAgent_SearchRequest WITH (NOLOCK)
										ON IQAgent_PQResults.IQAgentSearchRequestID = IQAgent_SearchRequest.ID
										AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
										AND IQAgent_SearchRequest.IsActive > 0
										AND IQAgent_PQResults.IsActive = 1
						WHERE
							((@FDate is null or @TDate is null) OR IQAgent_PQResults.MediaDate BETWEEN @FDate AND @TDate)
						GROUP BY Publication
						ORDER BY ISNULL(sum(CONVERT(BIGINT,Number_Hits)),0) desc,count(IQAgent_PQResults.ID) desc

						UNION

						SELECT top 10
							Publication,
							count(IQAgent_NMResults.ID) as NoOfDocs,
							ISNULL(sum(CONVERT(BIGINT,Number_Hits)),0) as Mentions,
							ISNULL(sum(IQAgent_MediaResults.PositiveSentiment),0) as PositiveSentiment,
							ISNULL(sum(IQAgent_MediaResults.NegativeSentiment),0) as NegativeSentiment,
							MAX(IQAgent_MediaResults.v5Category) AS SubMediaType
						FROM	IQAgent_MediaResults
									INNER JOIN	IQAgent_NMResults WITH (NOLOCK)
										ON	IQAgent_MediaResults._MediaID = IQAgent_NMResults.ID
										AND	IQAgent_MediaResults.v5MediaType = @MediaType
										AND	IQAgent_MediaResults.v5Category = 'LN'
										AND	IQAgent_MediaResults.v5Category = IQAgent_NMResults.v5SubMediaType
										AND IQAgent_MediaResults.IsActive = 1
									INNER JOIN @MediaTypeAccessTbl AS MTA
										ON	IQAgent_MediaResults.v5MediaType = MTA.MediaType
										AND	IQAgent_MediaResults.v5Category = MTA.SubMediaType
										AND	MTA.HasAccess = 1 
									INNER JOIN IQAgent_SearchRequest WITH (NOLOCK)
										ON IQAgent_NMResults.IQAgentSearchRequestID = IQAgent_SearchRequest.ID
										AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
										AND IQAgent_SearchRequest.IsActive > 0
										AND IQAgent_NMResults.IsActive = 1
						WHERE
							((@FDate is null or @TDate is null) OR IQAgent_MediaResults.MediaDate BETWEEN @FDate AND @TDate)
						GROUP BY Publication
						ORDER BY ISNULL(sum(CONVERT(BIGINT,Number_Hits)),0) desc,count(IQAgent_NMResults.ID) desc
				) AS PRResults
				ORDER BY Mentions DESC, NoOfDocs DESC

			SET @QueryDetail ='get top publications for pq'
			SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
			INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
			SET @Stopwatch = GetDate()

			;WITH tempAuthors as
				(
					SELECT Tbl.Authors.value('.', 'varchar(100)') AS Author,
					IQAgent_PQResults.ID,
					Number_Hits,
					IQAgent_MediaResults.PositiveSentiment,
					IQAgent_MediaResults.NegativeSentiment,
					IQAgent_MediaResults.v5Category AS SubMediaType
					FROM 
							IQAgent_MediaResults WITH(NOLOCK)
								INNER JOIN	IQAgent_PQResults WITH(NOLOCK)
									ON	IQAgent_MediaResults._MediaID = IQAgent_PQResults.ID
									AND	IQAgent_MediaResults.v5MediaType = @MediaType
									AND	IQAgent_MediaResults.v5Category = IQAgent_PQResults.v5SubMediaType
									AND	IQAgent_MediaResults.IsActive = 1
								INNER JOIN @MediaTypeAccessTbl AS MTA
									ON	IQAgent_MediaResults.v5MediaType = MTA.MediaType
									AND	IQAgent_MediaResults.v5Category = MTA.SubMediaType
									AND	MTA.HasAccess = 1
								CROSS APPLY Authors.nodes('authors/author') as Tbl(Authors)
								INNER JOIN IQAgent_SearchRequest WITH (NOLOCK)
									ON IQAgent_PQResults.IQAgentSearchRequestID = IQAgent_SearchRequest.ID
									AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
									AND IQAgent_SearchRequest.IsActive > 0
									AND IQAgent_PQResults.IsActive = 1
				WHERE
					((@FDate is null or @TDate is null) OR IQAgent_PQResults.MediaDate BETWEEN @FDate AND @TDate)
				)
				
					
				SELECT top 10
					tempAuthors.Author,
					count(ID) as NoOfDocs,
					ISNULL(sum(CONVERT(BIGINT,Number_Hits)),0) as Mentions,
					ISNULL(sum(CONVERT(BIGINT,PositiveSentiment)),0)  as PositiveSentiment,
					ISNULL(sum(CONVERT(BIGINT,NegativeSentiment)),0)  as NegativeSentiment,
					MAX(SubMediaType) AS SubMediaType
				FROM tempAuthors
				GROUP BY tempAuthors.Author
				ORDER BY ISNULL(sum(CONVERT(BIGINT,Number_Hits)),0) desc,count(ID) desc

			SET @QueryDetail ='get top authors for pq'
			SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
			INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
			SET @Stopwatch = GetDate()			

		END

END