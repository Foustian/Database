-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_IQ_NIELSEN_SQAD_SelectByIQCCKeyList]
	@IQCCKeyList xml,
	@ClientGuid uniqueidentifier	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @TempTable AS TABLE(IQ_CC_KEY Varchar(28),IQ_CC_KEY_Time Varchar(14),IQ_DMA varchar(4))
	DECLARE @MultiPlier float
	
	select @MultiPlier = CONVERT(float,ISNULL((select Value from IQClient_CustomSettings where Field = 'Multiplier' and _ClientGuid = @ClientGuid),(select Value from IQClient_CustomSettings where Field = 'Multiplier' and _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))))
	/*print @MultiPlier

	INSERT INTO @TempTable
		SELECT
				a.b.value('@iq_cc_key','varchar(max)'),
				Substring(a.b.value('@iq_cc_key','varchar(max)'), Charindex('_', a.b.value('@iq_cc_key','varchar(max)'))+10, LEN(a.b.value('@iq_cc_key','varchar(max)'))) as  IQCCTime,
				a.b.value('@iq_dma','varchar(max)')
		FROM
				@IQCCKeyList.nodes('list/item') a(b) 
	*/			
	SELECT 
			Tbl.c.value('@iq_cc_key','varchar(30)') as IQ_CC_KEY,
			CASE WHEN  SQAD_SHAREVALUE = 0 OR SQAD_SHAREVALUE IS NULL THEN
				Convert(varchar,CONVERT(DECIMAL,Avg_Ratings_Pt * 100* @MultiPlier * (SELECT CPPVALUE FROM IQ_SQAD WHERE IQ_SQAD.SQADMARKETID = IQ_Station.SQADMARKETID AND IQ_SQAD.DAYPARTID = IQ_Nielsen_Averages.DAYPARTID))) 
			ELSE
				Convert(varchar,CONVERT(DECIMAL, SQAD_SHAREVALUE * @MultiPlier)) 
			END
			as  SQAD_SHAREVALUE,
			CASE
				WHEN  AUDIENCE = 0 OR AUDIENCE IS NULL THEN
					Convert(varchar,CAST((Avg_Ratings_Pt) * (IQ_Station.UNIVERSE) AS DECIMAL))
				ELSE 
					AUDIENCE
				END
			as AUDIENCE,
			case when [IQ_NIELSEN_SQAD].SQAD_SHAREVALUE = 0 OR [IQ_NIELSEN_SQAD].SQAD_SHAREVALUE IS NULL THEN
			CAST(0 AS BIT)
			ELSE 
			CAST(1 AS BIT) 
			END AS IsActualNielsen
			
			
	FROM 
		@IQCCKeyList.nodes('list/item') AS Tbl(c)
			inner join IQ_Station
				ON SUBString(Tbl.c.value('@iq_cc_key','varchar(30)'),1,charindex('_',Tbl.c.value('@iq_cc_key','varchar(30)'))-1)=IQ_station.IQ_Station_ID
			left outer join	[IQ_NIELSEN_SQAD] 
				ON Tbl.c.value('@iq_cc_key','varchar(30)') = [IQ_NIELSEN_SQAD] .IQ_CC_Key
				AND [IQ_NIELSEN_SQAD].IQ_Start_Point=1
		LEFT OUTER JOIN 
			IQ_Nielsen_Averages 
			ON [IQ_NIELSEN_SQAD].iq_cc_key is null
			AND IQ_Nielsen_Averages.IQ_Start_Point = 1
			AND Affil_IQ_CC_Key =  CASE WHEN TBL.c.value('@iq_dma','varchar(3)') = '000' 
			THEN IQ_Station_ID ELSE Station_Affil + '_' + TimeZone END + '_' + SUBSTRING(Tbl.c.value('@iq_cc_key','varchar(30)'),CHARINDEX('_',Tbl.c.value('@iq_cc_key','varchar(30)')) +1,13)			
				
	
	/*SELECT 
			chNeilSen.orgIQ_CC_KEY as IQ_CC_KEY,
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
			as AUDIENCE,
			case when msNeilSen.SQAD_SHAREVALUE = 0 OR msNeilSen.SQAD_SHAREVALUE IS NULL THEN
			CAST(0 AS BIT)
			ELSE 
			CAST(1 AS BIT) 
			END AS IsActualNielsen
			
			
	FROM 
		[IQ_NIELSEN_SQAD] msNeilSen 
			RIGHT OUTER JOIN 
				(SELECT 
						MAX(s1.[IQ_CC_KEY]) as IQ_CC_KEy,
						Tbl.IQ_CC_KEY as orgIQ_CC_KEY,
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
					tbl.IQ_CC_KEY
			) chNeilSen
  ON 
		msNeilSen.IQ_CC_KEY = chNeilSen.IQ_CC_KEY
		AND IQ_Start_POINT = MINIQCCKEY
		LEFT OUTER JOIN 
			IQ_Nielsen_Averages ON
				IQ_Nielsen_Averages.IQ_Start_Point = CASE WHEN MINIQCCKEY IS NULL  THEN 1 ELSE MINIQCCKEY END 
				AND Affil_IQ_CC_Key =  CASE WHEN chNeilSen.IQ_DMA = '000' THEN chNeilSen.IQ_Station_ID ELSE Station_Affil + '_' + TimeZone END + '_' + SUBSTRING(chNeilSen.orgIQ_CC_KEY,CHARINDEX('_',chNeilSen.orgIQ_CC_KEY) +1,13)
	
	*/
	
END
