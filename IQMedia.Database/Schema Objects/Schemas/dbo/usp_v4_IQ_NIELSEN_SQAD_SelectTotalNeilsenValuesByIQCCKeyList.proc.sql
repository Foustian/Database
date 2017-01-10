CREATE PROCEDURE [dbo].[usp_v4_IQ_NIELSEN_SQAD_SelectTotalNeilsenValuesByIQCCKeyList]
	@IQCCKeyList xml,
	@ClientGuid uniqueidentifier,
	@National_ADShareValue float output,
	@National_Nielsen_Audience bigint output,
	@National_Nielsen_Result char(1) output
AS
BEGIN
	DECLARE @TempTable AS TABLE(IQ_CC_KEY Varchar(28),IQ_CC_KEY_Time Varchar(14),IQ_DMA varchar(4))
	DECLARE @MultiPlier float
	
	DECLARE @CppDayPart2Val float
	SELECT @CppDayPart2Val = cppvalue FROM IQ_SQAD Where daypartid = 2 and SQADMarketID = 997
	
	select @MultiPlier = CONVERT(float,ISNULL((select Value from IQClient_CustomSettings where Field = 'Multiplier' and _ClientGuid = @ClientGuid),(select Value from IQClient_CustomSettings where Field = 'Multiplier' and _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))))
		
	;With TempNielsenValues
	AS (
			SELECT 
			
				CASE WHEN  SQAD_SHAREVALUE = 0 OR SQAD_SHAREVALUE IS NULL THEN
					CONVERT(DECIMAL,Avg_Ratings_Pt * 100* @MultiPlier * 
														CASE WHEN IQ_Station.SQADMARKETID = 997 AND IQ_Nielsen_Averages.DAYPARTID = 6 THEN
															@CppDayPart2Val
														ELSE
															(SELECT CPPVALUE FROM IQ_SQAD WHERE IQ_SQAD.SQADMARKETID = IQ_Station.SQADMARKETID AND IQ_SQAD.DAYPARTID = IQ_Nielsen_Averages.DAYPARTID)
														END)
				ELSE
					CONVERT(DECIMAL, SQAD_SHAREVALUE * @MultiPlier)
				END
				as  SQAD_SHAREVALUE,
				CASE
					WHEN  AUDIENCE = 0 OR AUDIENCE IS NULL THEN
						CAST((Avg_Ratings_Pt) * (IQ_Station.UNIVERSE) AS DECIMAL)
					ELSE 
						AUDIENCE
					END
				as AUDIENCE,
				CASE WHEN  SQAD_SHAREVALUE = 0 OR SQAD_SHAREVALUE IS NULL THEN
					'0'
				ELSE
					'1' 
				END	as IsActual
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
	)	
	select 
			@National_ADShareValue = ISNULL(sum(SQAD_SHAREVALUE),0),
			@National_Nielsen_Audience = ISNULL(sum (AUDIENCE),0),
			@National_Nielsen_Result = Min(IsActual)
	from 
			TempNielsenValues
END