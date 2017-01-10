CREATE PROCEDURE [dbo].[usp_v5_IQDashboard_AdhocSummary_SelectByID]
(
	@MediaIDXml xml,
	@Source varchar(20),
	@Medium varchar(15),
	@ClientGUID UNIQUEIDENTIFIER
)
AS
BEGIN
	SET NOCOUNT ON;
	
	declare @ReportRule xml,
			@FromDate date,
			@ToDate date,
			@DateRange int
		
	create table #tempMediaIDs (ID bigint, MediaDate DATETIME, SortDate DATETIME)
	DECLARE @tblTemp TABLE (ID BIGINT)
		
	IF @Source = 'Library'
	BEGIN			
		INSERT INTO @tblTemp
		(ID)	
		SELECT tbl.c.value('@id', 'bigint')
		FROM @MediaIDXml.nodes('list/item') as tbl(c)	

	END
	ELSE IF @Source = 'Report'
	BEGIN
		SELECT @ReportRule = ReportRule FROM IQ_Report WHERE ID = @MediaIDXml.value('(/list/item/@id)[1]', 'bigint') AND ClientGuid = @ClientGUID AND IsActive = 1
			
		IF @ReportRule is not null
		BEGIN
			INSERT INTO @tblTemp	
			SELECT tbl.c.query('.').value('.','bigint') as ID
			FROM @ReportRule.nodes('Report/Library/ArchiveMediaSet/ID') as tbl(c)
		END
	END

	INSERT INTO #tempMediaIDs
		(
			ID,
			MediaDate
		)
		SELECT
				TblTemp.ID,
				IQArchive_Media.MediaDate
		FROM
				@tblTemp AS TblTemp
					INNER JOIN	IQArchive_Media
						ON	TblTemp.ID = IQArchive_Media.ID
						AND IQArchive_Media.ClientGUID = @ClientGUID
						AND IQArchive_Media.IsActive = 1
						AND @Medium = 'Overview' OR IQArchive_Media.v5MediaType = @Medium
		
	SELECT 
			@FromDate = Min(Cast(MediaDate as date)),
			@ToDate = Max(Cast(MediaDate as date))
	FROM 
			#tempMediaIDs as tmp
						
	SET @DateRange = Datediff(DAY, @FromDate, @ToDate)

	UPDATE
			#tempMediaIDs
	SET
			SortDate = CASE WHEN @DateRange > 2 THEN CONVERT(DATE, MediaDate) ELSE Dateadd(HOUR, Datediff(Hour, 0, MediaDate), 0)  END

	SET @Medium = Isnull(@Medium, 'Overview')
		
	SELECT			
			SortDate AS DayDate,	
			v5MediaType AS MediaType,  
			IQArchive_Media.v5SubMediaType AS SubMediaType,
			Count(*) as NoOfDocs,
			Sum(Cast(ArchiveClip.Number_Hits AS BIGINT)) AS NoOfHits,
			SUM(CAST(case when ArchiveClip.Nielsen_Audience < 0 then 0 else	ArchiveClip.Nielsen_Audience end AS BIGINT)) AS Audience,
			SUM(CAST(case when ArchiveClip.IQAdShareValue  < 0 then 0 else ArchiveClip.IQAdShareValue end AS BIGINT)) AS IQMediaValue,
			Sum(Cast(IQArchive_Media.PositiveSentiment as bigint)) as PositiveSentiment,
			Sum(Cast(IQArchive_Media.NegativeSentiment as bigint)) as NegativeSentiment				
	FROM
			IQArchive_Media WITH (NOLOCK)
				INNER JOIN #tempMediaIDs 
					ON IQArchive_Media.ID = #tempMediaIDs.ID
				INNER JOIN ArchiveClip WITH (NOLOCK)
					ON ArchiveClip.ArchiveClipKey = IQArchive_Media._ArchiveMediaID AND IQArchive_Media.v5SubMediaType = Archiveclip.v5SubMediaType								
	WHERE	
			@Medium = 'Overview' OR IQArchive_Media.v5MediaType = @Medium
	Group By SortDate, 
			 IQArchive_Media.v5MediaType,
			 IQArchive_Media.v5SubMediaType

	UNION

	SELECT
			SortDate AS DayDate,	
			v5MediaType AS MediaType,  
			IQArchive_Media.v5SubMediaType AS SubMediaType,
			Count(*) as NoOfDocs,
			Sum(Cast(ArchiveNM.Number_Hits AS BIGINT)) AS NoOfHits,
			SUM(CAST(case when ArchiveNM.Compete_Audience < 0 then 0 else ArchiveNM.Compete_Audience end AS BIGINT)) AS Audience,
			SUM(CAST(case when ArchiveNM.IQAdShareValue  < 0 then 0 else ArchiveNM.IQAdShareValue end AS BIGINT)) AS IQMediaValue,
			Sum(Cast(IQArchive_Media.PositiveSentiment as bigint)) as PositiveSentiment,
			Sum(Cast(IQArchive_Media.NegativeSentiment as bigint)) as NegativeSentiment
	FROM
			IQArchive_Media WITH (NOLOCK)
				INNER JOIN #tempMediaIDs 
					ON IQArchive_Media.ID = #tempMediaIDs.ID
				INNER JOIN ArchiveNM WITH (NOLOCK)
					ON ArchiveNM.ArchiveNMKey = IQArchive_Media._ArchiveMediaID AND IQArchive_Media.v5SubMediaType = ArchiveNM.v5SubMediaType								
	WHERE	
			@Medium = 'Overview' OR IQArchive_Media.v5MediaType = @Medium
	Group By SortDate, 
			 IQArchive_Media.v5MediaType,
			 IQArchive_Media.v5SubMediaType

	UNION

	SELECT
			SortDate AS DayDate,	
			v5MediaType AS MediaType,  
			IQArchive_Media.v5SubMediaType AS SubMediaType,
			Count(*) as NoOfDocs,
			Sum(Cast(ArchiveSM.Number_Hits AS BIGINT)) AS NoOfHits,
			SUM(CAST(case when ArchiveSM.Compete_Audience < 0 then 0 else ArchiveSM.Compete_Audience end AS BIGINT)) AS Audience,
			SUM(CAST(case when ArchiveSM.IQAdShareValue  < 0 then 0 else ArchiveSM.IQAdShareValue end AS BIGINT)) AS IQMediaValue,
			Sum(Cast(IQArchive_Media.PositiveSentiment as bigint)) as PositiveSentiment,
			Sum(Cast(IQArchive_Media.NegativeSentiment as bigint)) as NegativeSentiment
	FROM
			IQArchive_Media WITH (NOLOCK)
				INNER JOIN #tempMediaIDs 
					ON IQArchive_Media.ID = #tempMediaIDs.ID
				INNER JOIN ArchiveSM WITH (NOLOCK)
					ON ArchiveSM.ArchiveSMKey = IQArchive_Media._ArchiveMediaID AND IQArchive_Media.v5SubMediaType = ArchiveSM.v5SubMediaType								
	WHERE	
			@Medium = 'Overview' OR IQArchive_Media.v5MediaType = @Medium
	Group By SortDate, 
			 IQArchive_Media.v5MediaType,
			 IQArchive_Media.v5SubMediaType

	UNION

	SELECT
			SortDate AS DayDate,	
			v5MediaType AS MediaType,  
			IQArchive_Media.v5SubMediaType AS SubMediaType,
			Count(*) as NoOfDocs,
			Sum(Cast(ArchiveTweets.Number_Hits AS BIGINT)) AS NoOfHits,
			SUM(CAST(ArchiveTweets.Actor_FollowersCount AS BIGINT)) AS Audience,
			0 AS IQMediaValue,
			Sum(Cast(IQArchive_Media.PositiveSentiment as bigint)) as PositiveSentiment,
			Sum(Cast(IQArchive_Media.NegativeSentiment as bigint)) as NegativeSentiment
	FROM
			IQArchive_Media WITH (NOLOCK)
				INNER JOIN #tempMediaIDs 
					ON IQArchive_Media.ID = #tempMediaIDs.ID
				INNER JOIN ArchiveTweets WITH (NOLOCK)
					ON ArchiveTweets.ArchiveTweets_Key = IQArchive_Media._ArchiveMediaID AND IQArchive_Media.v5SubMediaType = ArchiveTweets.v5SubMediaType								
	WHERE	
			@Medium = 'Overview' OR IQArchive_Media.v5MediaType = @Medium
	Group By SortDate, 
			 IQArchive_Media.v5MediaType,
			 IQArchive_Media.v5SubMediaType

	UNION

	SELECT
			SortDate AS DayDate,	
			v5MediaType AS MediaType,  
			IQArchive_Media.v5SubMediaType AS SubMediaType,
			Count(*) as NoOfDocs,
			Sum(Cast(ArchivePQ.Number_Hits AS BIGINT)) AS NoOfHits,
			0 AS Audience,
			0 AS IQMediaValue,
			Sum(Cast(IQArchive_Media.PositiveSentiment as bigint)) as PositiveSentiment,
			Sum(Cast(IQArchive_Media.NegativeSentiment as bigint)) as NegativeSentiment
	FROM
			IQArchive_Media WITH (NOLOCK)
				INNER JOIN #tempMediaIDs 
					ON IQArchive_Media.ID = #tempMediaIDs.ID
				INNER JOIN ArchivePQ WITH (NOLOCK)
					ON ArchivePQ.ArchivePQKey = IQArchive_Media._ArchiveMediaID AND IQArchive_Media.v5SubMediaType = ArchivePQ.v5SubMediaType								
	WHERE	
			@Medium = 'Overview' OR IQArchive_Media.v5MediaType = @Medium
	Group By SortDate, 
			 IQArchive_Media.v5MediaType,
			 IQArchive_Media.v5SubMediaType

	UNION

	SELECT
			SortDate AS DayDate,	
			v5MediaType AS MediaType,  
			IQArchive_Media.v5SubMediaType AS SubMediaType,
			Count(*) as NoOfDocs,
			Sum(Cast(1 AS BIGINT)) AS NoOfHits,
			SUM(CAST (ArchiveBLPM.Circulation AS BIGINT)) AS Audience,
			0 AS IQMediaValue,
			Sum(Cast(IQArchive_Media.PositiveSentiment as bigint)) as PositiveSentiment,
			Sum(Cast(IQArchive_Media.NegativeSentiment as bigint)) as NegativeSentiment
	FROM
			IQArchive_Media WITH (NOLOCK)
				INNER JOIN #tempMediaIDs 
					ON IQArchive_Media.ID = #tempMediaIDs.ID
				INNER JOIN ArchiveBLPM WITH (NOLOCK)
					ON ArchiveBLPM.ArchiveBLPMKey = IQArchive_Media._ArchiveMediaID AND IQArchive_Media.v5SubMediaType = ArchiveBLPM.v5SubMediaType								
	WHERE	
			@Medium = 'Overview' OR IQArchive_Media.v5MediaType = @Medium
	Group By SortDate, 
			 IQArchive_Media.v5MediaType,
			 IQArchive_Media.v5SubMediaType

	UNION

	SELECT
			SortDate AS DayDate,	
			v5MediaType AS MediaType,  
			IQArchive_Media.v5SubMediaType AS SubMediaType,
			Count(*) as NoOfDocs,
			Sum(Cast(1 AS BIGINT)) AS NoOfHits,
			0 AS Audience,
			0 AS IQMediaValue,
			Sum(Cast(IQArchive_Media.PositiveSentiment as bigint)) as PositiveSentiment,
			Sum(Cast(IQArchive_Media.NegativeSentiment as bigint)) as NegativeSentiment
	FROM
			IQArchive_Media WITH (NOLOCK)
				INNER JOIN #tempMediaIDs 
					ON IQArchive_Media.ID = #tempMediaIDs.ID
				INNER JOIN ArchiveTVEyes WITH (NOLOCK)
					ON ArchiveTVEyes.ArchiveTVEyesKey = IQArchive_Media._ArchiveMediaID AND IQArchive_Media.v5SubMediaType = ArchiveTVEyes.v5SubMediaType								
	WHERE	
			@Medium = 'Overview' OR IQArchive_Media.v5MediaType = @Medium
	Group By SortDate, 
			 IQArchive_Media.v5MediaType,
			 IQArchive_Media.v5SubMediaType

	UNION

	SELECT
			SortDate AS DayDate,	
			v5MediaType AS MediaType,  
			IQArchive_Media.v5SubMediaType AS SubMediaType,
			Count(*) as NoOfDocs,
			Sum(Cast(1 AS BIGINT)) AS NoOfHits,
			0 AS Audience,
			0 AS IQMediaValue,
			Sum(Cast(IQArchive_Media.PositiveSentiment as bigint)) as PositiveSentiment,
			Sum(Cast(IQArchive_Media.NegativeSentiment as bigint)) as NegativeSentiment
	FROM
			IQArchive_Media WITH (NOLOCK)
				INNER JOIN #tempMediaIDs 
					ON IQArchive_Media.ID = #tempMediaIDs.ID
				INNER JOIN ArchiveMisc WITH (NOLOCK)
					ON ArchiveMisc.ArchiveMiscKey = IQArchive_Media._ArchiveMediaID AND IQArchive_Media.v5SubMediaType = ArchiveMisc.v5SubMediaType								
	WHERE	
			@Medium = 'Overview' OR IQArchive_Media.v5MediaType = @Medium
	Group By SortDate, 
			 IQArchive_Media.v5MediaType,
			 IQArchive_Media.v5SubMediaType		

	UNION

	SELECT
			SortDate AS DayDate,	
			v5MediaType AS MediaType,  
			IQArchive_Media.v5SubMediaType AS SubMediaType,
			Count(*) as NoOfDocs,
			Sum(Cast(1 AS BIGINT)) AS NoOfHits,
			0 AS Audience,
			0 AS IQMediaValue,
			Sum(Cast(IQArchive_Media.PositiveSentiment as bigint)) as PositiveSentiment,
			Sum(Cast(IQArchive_Media.NegativeSentiment as bigint)) as NegativeSentiment
	FROM
			IQArchive_Media WITH (NOLOCK)
				INNER JOIN #tempMediaIDs 
					ON IQArchive_Media.ID = #tempMediaIDs.ID
				INNER JOIN ArchiveRadio WITH (NOLOCK)
					ON ArchiveRadio.ArchiveRadioKey = IQArchive_Media._ArchiveMediaID AND IQArchive_Media.v5SubMediaType = ArchiveRadio.v5SubMediaType								
	WHERE	
			@Medium = 'Overview' OR IQArchive_Media.v5MediaType = @Medium
	Group By SortDate, 
			 IQArchive_Media.v5MediaType,
			 IQArchive_Media.v5SubMediaType	 		
END
