CREATE PROCEDURE [dbo].[usp_IQAgent_SelectNielsenDemographicAgeDataByIQCCKey]
(
	@IQ_CC_Key varchar(28),
	@StartPoint smallint
)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT 
			@IQ_CC_Key as IQ_CC_Key,
			@StartPoint as StartPoint,
			CASE WHEN  SQAD_SHAREVALUE = 0 OR SQAD_SHAREVALUE IS NULL THEN
				CONVERT(FLOAT, Avg_Ratings_Pt * 100 * (SELECT CPPVALUE FROM IQ_SQAD WHERE IQ_SQAD.SQADMARKETID = IQ_Station.SQADMARKETID AND IQ_SQAD.DAYPARTID = IQ_Nielsen_Averages.DAYPARTID))
			ELSE
				CONVERT(FLOAT, SQAD_SHAREVALUE)
			END
			as SQAD_ShareValue,
		CASE 

			WHEN AM18_20 =0 OR  AM18_20  IS NULL THEN
				CAST(ROUND((Avg_Ratings_Pt) * (IQ_Station.UM18_20), 0) AS INT)
			ELSE
				AM18_20
			END
			as MaleAudience_18_20,
		CASE   
			WHEN AM21_24 =0 OR  AM21_24  IS NULL THEN
				CAST(ROUND((Avg_Ratings_Pt) * (IQ_Station.UM21_24), 0) AS INT)
				
			ELSE
				AM21_24 
			END
			as MaleAudience_21_24,
		CASE    
			WHEN AM25_34 =0 OR  AM25_34 IS NULL THEN
				CAST(ROUND((Avg_Ratings_Pt) * (IQ_Station.UM25_34), 0) AS INT)
				
			ELSE
				 AM25_34  
			END
			as MaleAudience_25_34,
		CASE   
			WHEN AM35_49 =0 OR  AM35_49  IS NULL THEN
				CAST(ROUND((Avg_Ratings_Pt) * (IQ_Station.UM35_49), 0) AS INT)
			ELSE
				AM35_49 
			END
			as MaleAudience_35_49,
		CASE
			WHEN AM50_54 =0 OR  AM50_54  IS NULL THEN
				CAST(ROUND((Avg_Ratings_Pt) * (IQ_Station.UM50_54), 0) AS INT)
			ELSE
				AM50_54 
			END
			as MaleAudience_50_54,
		CASE
			WHEN AM55_64 =0 OR  AM55_64  IS NULL THEN
				CAST(ROUND((Avg_Ratings_Pt) * (IQ_Station.UM55_64), 0) AS INT)
			ELSE
				AM55_64 
			END
			as MaleAudience_55_64,
		CASE
			WHEN AM65 =0 OR  AM65  IS NULL THEN
				CAST(ROUND((Avg_Ratings_Pt) * (IQ_Station.UM65), 0) AS INT)
			ELSE
				AM65 
			END
			as MaleAudience_Above_65,
		CASE
			WHEN AF18_20 =0 OR  AF18_20  IS NULL THEN
				CAST(ROUND((Avg_Ratings_Pt) * (IQ_Station.UF18_20), 0) AS INT)
			ELSE
				AF18_20
			END
			as FemaleAudience_18_20,
		CASE 
			WHEN AF21_24 =0 OR  AF21_24  IS NULL THEN
				CAST(ROUND((Avg_Ratings_Pt) * (IQ_Station.UF21_24), 0) AS INT)
			ELSE
				AF21_24 
			END
			as FemaleAudience_21_24,
		CASE
			WHEN AF25_34 =0 OR  AF25_34 IS NULL THEN
				CAST(ROUND((Avg_Ratings_Pt) * (IQ_Station.UF25_34), 0) AS INT)
			ELSE
				AF25_34 
			END
			as FemaleAudience_25_34,
		CASE	
			WHEN AF35_49 =0 OR  AF18_20  IS NULL THEN
				CAST(ROUND((Avg_Ratings_Pt) * (IQ_Station.UF35_49), 0) AS INT)
			ELSE
				AF35_49 
			END
			as FemaleAudience_35_49,
		CASE
			WHEN AF50_54 =0 OR  AF50_54  IS NULL THEN
				CAST(ROUND((Avg_Ratings_Pt) * (IQ_Station.UF50_54), 0) AS INT)
			ELSE
				 AF50_54
			END
			as FemaleAudience_50_54,
		CASE
			WHEN AF55_64 =0 OR  AF55_64  IS NULL THEN
				CAST(ROUND((Avg_Ratings_Pt) * (IQ_Station.UF55_64), 0) AS INT)
			ELSE
				AF55_64 
			END
			as FemaleAudience_55_64,
		CASE
			WHEN AF65 =0 OR  AF65  IS NULL THEN
				CAST(ROUND((Avg_Ratings_Pt) * (IQ_Station.UF65), 0) AS INT)
			ELSE
				AF65  
			END
			as FemaleAudience_Above_65,
			case when [IQ_NIELSEN_SQAD].SQAD_SHAREVALUE = 0 OR [IQ_NIELSEN_SQAD].SQAD_SHAREVALUE IS NULL THEN
				CAST(0 AS BIT)
			ELSE 
				CAST(1 AS BIT) 
			END AS IsActualNielsen
			
	FROM 
		[IQ_Station]
			LEFT OUTER JOIN	[IQ_NIELSEN_SQAD] WITH (NOLOCK)
				ON [IQ_NIELSEN_SQAD].IQ_CC_Key = @iq_cc_key
				AND [IQ_NIELSEN_SQAD].IQ_Start_Point = @StartPoint
			LEFT OUTER JOIN 
				IQ_Nielsen_Averages WITH (NOLOCK)
				ON [IQ_NIELSEN_SQAD].iq_cc_key is null
				AND IQ_Nielsen_Averages.IQ_Start_Point = @StartPoint
				AND Affil_IQ_CC_Key =
					CASE WHEN [IQ_Station].Dma_Num = '000' 
						THEN @iq_cc_key
						ELSE Station_Affil + '_' + TimeZone + '_' + SUBSTRING(@IQ_CC_Key, CHARINDEX('_', @IQ_CC_Key) + 1, 13)
					END
	WHERE
		IQ_station.IQ_Station_ID = SUBSTRING(@IQ_CC_Key, 1, CHARINDEX('_',@IQ_CC_Key) - 1)

END