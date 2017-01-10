CREATE PROCEDURE [dbo].[usp_v5_Dashboard_Archive_PRResults_Select]
(
	@MediaIDXml xml,
	@Source varchar(20),
	@Medium varchar(15),
	@ClientGUID UNIQUEIDENTIFIER,
	@MediaTypeAccessXml xml
)
AS
BEGIN

	declare @ReportRule xml
			
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
		
	create table #tempMediaIDs (ID bigint, MediaDate DATETIME)
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

	SELECT top 10
					Publication,
					NoOfDocs,
					Mentions,
					PositiveSentiment,
					NegativeSentiment
	FROM
	(
	SELECT top 10
		Publication,
		count(ArchivePQ.ArchivePQKey) as NoOfDocs,
		ISNULL(sum(CONVERT(BIGINT,Number_Hits)),0) as Mentions,
		ISNULL(sum(ArchivePQ.PositiveSentiment),0) as PositiveSentiment,
		ISNULL(sum(ArchivePQ.NegativeSentiment),0) as NegativeSentiment
	FROM ArchivePQ WITH (NOLOCK)
		INNER JOIN IQArchive_Media WITH (NOLOCK)
			ON IQArchive_Media._ArchiveMediaID = ArchivePQ.ArchivePQKey 
			AND IQArchive_Media.v5MediaType = @Medium
			AND IQArchive_Media.v5SubMediaType = ArchivePQ.v5SubMediaType
		INNER JOIN @MediaTypeAccessTbl AS MTA
			ON	IQArchive_Media.v5MediaType = MTA.MediaType
			AND IQArchive_Media.v5SubMediaType = MTA.SubMediaType
			AND	MTA.HasAccess = 1
		INNER JOIN #tempMediaIDs 
			ON IQArchive_Media.ID = #tempMediaIDs.ID
	GROUP BY Publication
	ORDER BY ISNULL(sum(CONVERT(BIGINT,Number_Hits)),0) desc,count(ArchivePQ.ArchivePQKey) desc

	UNION

	SELECT TOP 10
			Publication,
			COUNT(ArchiveNM.ArchiveNMKey) AS NoOfDocs,
			ISNULL(SUM(CONVERT(BIGINT, Archivenm.Number_Hits)),0) AS Mentions,
			ISNULL(SUM(ArchiveNM.PositiveSentiment),0) AS PositiveSentiment,
			ISNULL(SUM(ArchiveNM.NegativeSentiment),0) AS NegativeSentiment
	FROM
			ArchiveNM WITH(NOLOCK)
				INNER JOIN IQArchive_Media WITH (NOLOCK)
				ON IQArchive_Media._ArchiveMediaID = ArchiveNM.ArchiveNMKey 
				AND IQArchive_Media.v5MediaType = @Medium			
				AND IQArchive_Media.v5SubMediaType = ArchiveNM.v5SubMediaType
			INNER JOIN @MediaTypeAccessTbl AS MTA
				ON	IQArchive_Media.v5MediaType = MTA.MediaType
				AND IQArchive_Media.v5SubMediaType = MTA.SubMediaType
				AND	MTA.HasAccess = 1
		INNER JOIN #tempMediaIDs 
			ON IQArchive_Media.ID = #tempMediaIDs.ID
	GROUP BY Publication
	ORDER BY ISNULL(sum(CONVERT(BIGINT,Number_Hits)),0) desc,count(ArchiveNM.ArchiveNMKey) desc
	) AS TEMP
	ORDER BY Mentions DESC, NoOfDocs DESC

	;WITH tempAuthors as
	(
		SELECT distinct Tbl.Authors.value('.', 'varchar(100)') AS Author
		FROM ArchivePQ
		CROSS APPLY Author.nodes('authors/author') as Tbl(Authors)
	)
				
	SELECT top 10
		tempAuthors.Author,
		count(ArchivePQ.ArchivePQKey) as NoOfDocs,
		ISNULL(sum(CONVERT(BIGINT,Number_Hits)),0) as Mentions,
		ISNULL(sum(ArchivePQ.PositiveSentiment),0) as PositiveSentiment,
		ISNULL(sum(ArchivePQ.NegativeSentiment),0) as NegativeSentiment
	FROM tempAuthors
		INNER JOIN ArchivePQ WITH (NOLOCK)
			ON ArchivePQ.Author.exist('/authors/author[(text()[1])=sql:column("tempAuthors.Author")]') = 1
		INNER JOIN IQArchive_Media WITH (NOLOCK)
			ON IQArchive_Media._ArchiveMediaID = ArchivePQ.ArchivePQKey 
			AND IQArchive_Media.v5MediaType = @Medium
			AND IQArchive_Media.v5SubMediaType = ArchivePQ.v5SubMediaType
		INNER JOIN @MediaTypeAccessTbl AS MTA
			ON	IQArchive_Media.v5MediaType = MTA.MediaType
			AND IQArchive_Media.v5SubMediaType = MTA.SubMediaType
			AND	MTA.HasAccess = 1
		INNER JOIN #tempMediaIDs 
			ON IQArchive_Media.ID = #tempMediaIDs.ID
	GROUP BY tempAuthors.Author
	ORDER BY ISNULL(sum(CONVERT(BIGINT,Number_Hits)),0) desc,count(ArchivePQ.ArchivePQKey) desc

END