CREATE PROCEDURE [dbo].[usp_v5_Dashboard_Archive_FOResults_Select]
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
				CompeteURL,
				count(ArchiveSM.ArchiveSMKey) as NoOfDocs,
				ISNULL(sum(CONVERT(BIGINT,Number_Hits)),0) as Mentions,
				ISNULL(sum(CASE WHEN IQAdShareValue > 0 THEN IQAdShareValue ELSE 0 END),0) as MediaValue,
				ISNULL(sum(CASE WHEN Compete_Audience > 0 THEN CONVERT(BIGINT,Compete_Audience) ELSE 0 END),0) as Audience,
				ISNULL(sum(ArchiveSM.PositiveSentiment),0) as PositiveSentiment,
				ISNULL(sum(ArchiveSM.NegativeSentiment),0) as NegativeSentiment
			FROM 
				ArchiveSM WITH (NOLOCK)
					INNER JOIN IQArchive_Media WITH (NOLOCK)
						ON IQArchive_Media._ArchiveMediaID = ArchiveSM.ArchiveSMKey 						
						AND IQArchive_Media.v5MediaType = @Medium
						AND IQArchive_Media.v5SubMediaType = ArchiveSM.v5SubMediaType
					INNER JOIN @MediaTypeAccessTbl AS MTA
						ON	IQArchive_Media.v5MediaType = MTA.MediaType
						AND IQArchive_Media.v5SubMediaType = MTA.SubMediaType
						AND	MTA.HasAccess = 1
					INNER JOIN #tempMediaIDs 
						ON IQArchive_Media.ID = #tempMediaIDs.ID
			GROUP BY 
				CompeteURL
			ORDER BY ISNULL(sum(CONVERT(BIGINT,Number_Hits)),0) desc,count(ArchiveSM.ArchiveSMKey) desc		

END