CREATE PROCEDURE [dbo].[usp_iqsvc_IQ_NIELSEN_SQAD_SelectNielSenDataByRecordFileGuidList]
	@GuidList xml,
	@ClientGuid uniqueidentifier
AS
BEGIN
	DECLARE @TempTable AS TABLE([Guid] uniqueidentifier,IQ_CC_KEY Varchar(28),IQ_DMA varchar(4))
	DECLARE @MultiPlier float
	select @MultiPlier = CONVERT(float,ISNULL((select Value from IQClient_CustomSettings where Field = 'Multiplier' and _ClientGuid = @ClientGuid),(select Value from IQClient_CustomSettings where Field = 'Multiplier' and _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))))

	INSERT INTO @TempTable
		SELECT
				a.b.value('@guid','uniqueidentifier'),
				LTRIM(RTRIM(IQCore_Source.SourceID)) + '_' +
					SUBSTRING(CONVERT(VARCHAR(13),IQCore_Recording.Startdate,112),1,13) +
					'_' + SUBSTRING(CONVERT(VARCHAR(13),IQCore_Recording.Startdate,108),1,2) + '00' ,
				a.b.value('@iq_dma','varchar(max)')
		FROM
				@GuidList.nodes('list/item') a(b)
						left outer join IQCore_Recordfile  WITH (NOLOCK)
							ON a.b.value('@guid','uniqueidentifier') = IQCore_Recordfile.Guid
							Inner Join IQCore_Recording WITH (NOLOCK)
								ON IQCore_Recordfile._RecordingID  = IQCore_Recording.ID
							Inner Join IQCore_Source WITH (NOLOCK)
								ON IQCore_Recording._SourceGuid = IQCore_Source.Guid
								
	
	SELECT
			chNeilSen.orgIQ_CC_KEY as IQ_CC_Key,
			chNeilSen.[Guid],
			CASE WHEN  SQAD_SHAREVALUE = 0 OR SQAD_SHAREVALUE IS NULL THEN
				Convert(varchar,CONVERT(DECIMAL,Avg_Ratings_Pt * 100* @MultiPlier * (SELECT CPPVALUE FROM IQ_SQAD WHERE IQ_SQAD.SQADMARKETID = chNeilSen.SQADMARKETID AND IQ_SQAD.DAYPARTID = IQ_Nielsen_Averages.DAYPARTID))) + '(E)'
			ELSE
				Convert(varchar,CONVERT(DECIMAL, SQAD_SHAREVALUE * @MultiPlier)) + '(A)'
			END
			as  SQAD_SHAREVALUE,
			CASE
				WHEN  AUDIENCE = 0 OR AUDIENCE IS NULL THEN
					Convert(varchar,CAST((Avg_Ratings_Pt) * (chNeilSen.UNIVERSE) AS DECIMAL))
				ELSE 
					AUDIENCE
				END
			as AUDIENCE
	FROM 
		[IQ_NIELSEN_SQAD] msNeilSen 
			RIGHT OUTER JOIN 
				(SELECT 
						MAX(s1.[IQ_CC_KEY]) as IQ_CC_KEy,
						MAX(Tbl.IQ_CC_KEY) as orgIQ_CC_KEY,
						[Guid],
						MIN(IQ_Start_Point) as MINIQCCKEY,
						MAX(tbl.IQ_DMA) as IQ_DMA,
						MAX(is1.Universe) as Universe,
						MAX(is1.SQADMARKETID) as SQADMARKETID,
						MAX(is1.Station_Affil) as Station_Affil,
						MAX(is1.TimeZone) as TimeZone,
						MAX(is1.IQ_Station_ID) as IQ_Station_ID
				FROM 
						@TempTable AS Tbl 
							LEFT OUTER JOIN  [IQ_NIELSEN_SQAD] as s1
								ON Tbl.IQ_CC_KEY = s1.IQ_CC_Key
							LEFT OUTER JOIN IQ_Station is1
								ON LTRIM(RTRIM(Substring(Tbl.IQ_CC_KEY,1,Charindex('_', Tbl.IQ_CC_KEY)-1))) = is1.IQ_Station_ID
							
				GROUP BY 
					tbl.[Guid]
			) chNeilSen
  ON 
		msNeilSen.IQ_CC_KEY = chNeilSen.IQ_CC_KEY
		AND IQ_Start_POINT = MINIQCCKEY
		LEFT OUTER JOIN 
			IQ_Nielsen_Averages ON
				IQ_Nielsen_Averages.IQ_Start_Point = CASE WHEN MINIQCCKEY IS NULL  THEN 1 ELSE MINIQCCKEY END 
				AND Affil_IQ_CC_Key =  CASE WHEN chNeilSen.IQ_DMA = '000' THEN chNeilSen.IQ_Station_ID ELSE Station_Affil + '_' + TimeZone END + '_' + SUBSTRING(chNeilSen.orgIQ_CC_KEY,CHARINDEX('_',chNeilSen.orgIQ_CC_KEY) +1,13)
END