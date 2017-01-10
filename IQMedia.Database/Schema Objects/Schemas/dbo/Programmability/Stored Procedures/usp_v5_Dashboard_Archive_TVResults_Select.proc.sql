CREATE PROCEDURE [dbo].[usp_v5_Dashboard_Archive_TVResults_Select]
(
	@MediaIDXml xml,
	@Source varchar(20),
	@Medium varchar(15),
	@ClientGUID UNIQUEIDENTIFIER,
	@MediaTypeAccessXml xml
)
AS
BEGIN

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

	declare @ReportRule xml			
		
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
		IQ_Station_ID,
		MAX(Dma_Num) as DMA_Num,
		MAX(DMA_Name) as DMA_Name,
		count(ArchiveClip.ArchiveClipKey) as NoOfDocs,
		ISNULL(sum(CONVERT(BIGINT,Number_Hits)),0) as Mentions,
		ISNULL(sum(CASE WHEN IQAdShareValue > 0 THEN IQAdShareValue ELSE 0 END),0) as MediaValue,
		ISNULL(sum(CASE WHEN Nielsen_Audience > 0 THEN CONVERT(BIGINT,Nielsen_Audience) ELSE 0 END),0) as Audience,
		ISNULL(sum(ArchiveClip.PositiveSentiment),0) as PositiveSentiment,
		ISNULL(sum(ArchiveClip.NegativeSentiment),0) as NegativeSentiment
	FROM 
		ArchiveClip WITH (NOLOCK)
			INNER JOIN IQ_Station WITH (NOLOCK)
				ON SUBSTRING(ArchiveClip.IQ_CC_Key, 0, CHARINDEX('_', ArchiveClip.IQ_CC_Key)) = IQ_Station.IQ_Station_ID
			INNER JOIN IQArchive_Media WITH (NOLOCK)
				ON IQArchive_Media._ArchiveMediaID = ArchiveClip.ArchiveClipKey 
				and IQArchive_Media.v5SubMediaType = ArchiveClip.v5SubMediaType
				AND IQArchive_Media.v5MediaType = @Medium
			INNER JOIN @MediaTypeAccessTbl AS MTA
					ON	IQArchive_Media.v5MediaType = MTA.MediaType
					AND IQArchive_Media.v5SubMediaType = MTA.SubMediaType
					AND	MTA.HasAccess = 1
			INNER JOIN #tempMediaIDs 
				ON IQArchive_Media.ID = #tempMediaIDs.ID
	GROUP BY 
		IQ_Station.IQ_Station_ID
	ORDER BY ISNULL(sum(CONVERT(BIGINT,Number_Hits)),0) desc,count(ArchiveClip.ArchiveClipKey) desc

	SELECT top 10 
		DMA_Num as DMA_Num,
		MAX(DMA_Name) as DMA_Name,
		count(ArchiveClip.ArchiveClipKey) as NoOfDocs,
		ISNULL(sum(CONVERT(BIGINT,Number_Hits)),0) as Mentions,
		ISNULL(sum(CASE WHEN IQAdShareValue > 0 THEN IQAdShareValue ELSE 0 END),0) as MediaValue,
		ISNULL(sum(CASE WHEN Nielsen_Audience > 0 THEN CONVERT(BIGINT,Nielsen_Audience) ELSE 0 END),0) as Audience,
		ISNULL(sum(ArchiveClip.PositiveSentiment),0) as PositiveSentiment,
		ISNULL(sum(ArchiveClip.NegativeSentiment),0) as NegativeSentiment
	FROM 
		ArchiveClip WITH (NOLOCK)
			INNER JOIN IQ_Station WITH (NOLOCK)
				ON SUBSTRING(ArchiveClip.IQ_CC_Key, 0, CHARINDEX('_', ArchiveClip.IQ_CC_Key)) = IQ_Station.IQ_Station_ID
			INNER JOIN IQArchive_Media WITH (NOLOCK)
				ON IQArchive_Media._ArchiveMediaID = ArchiveClip.ArchiveClipKey 
				and IQArchive_Media.v5SubMediaType = ArchiveClip.v5SubMediaType
				AND IQArchive_Media.v5MediaType = @Medium
			INNER JOIN @MediaTypeAccessTbl AS MTA
					ON	IQArchive_Media.v5MediaType = MTA.MediaType
					AND IQArchive_Media.v5SubMediaType = MTA.SubMediaType
					AND	MTA.HasAccess = 1
			INNER JOIN #tempMediaIDs 
				ON IQArchive_Media.ID = #tempMediaIDs.ID
	GROUP BY 
		IQ_Station.DMA_Num
	ORDER BY ISNULL(sum(CONVERT(BIGINT,Number_Hits)),0) desc,count(ArchiveClip.ArchiveClipKey) desc		
END