CREATE PROCEDURE [dbo].[usp_IQAgent_SelectNielsenDemographicAgeDataByDateRange]
(
	@StartDate datetime,
	@EndDate datetime	
)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		IQ_Station_ID + SUBSTRING(Affil_IQ_CC_Key, LEN(Affil_IQ_CC_Key) - 13, 14) as IQ_CC_Key,
		CAST(IQ_Start_Point AS SMALLINT) as StartPoint,
		CONVERT(FLOAT, Avg_Ratings_Pt * 100 * (SELECT CPPVALUE FROM IQ_SQAD WHERE IQ_SQAD.SQADMARKETID = IQ_Station.SQADMARKETID AND IQ_SQAD.DAYPARTID = IQ_Nielsen_Averages.DAYPARTID)) as SQAD_ShareValue,
		CAST(ROUND((Avg_Ratings_Pt) * (IQ_Station.UM18_20), 0) AS INT) as MaleAudience_18_20,
		CAST(ROUND((Avg_Ratings_Pt) * (IQ_Station.UM21_24), 0) AS INT)as MaleAudience_21_24,
		CAST(ROUND((Avg_Ratings_Pt) * (IQ_Station.UM25_34), 0) AS INT) as MaleAudience_25_34,
		CAST(ROUND((Avg_Ratings_Pt) * (IQ_Station.UM35_49), 0) AS INT) as MaleAudience_35_49,
		CAST(ROUND((Avg_Ratings_Pt) * (IQ_Station.UM50_54), 0) AS INT) as MaleAudience_50_54,
		CAST(ROUND((Avg_Ratings_Pt) * (IQ_Station.UM55_64), 0) AS INT) as MaleAudience_55_64,
		CAST(ROUND((Avg_Ratings_Pt) * (IQ_Station.UM65), 0) AS INT) as MaleAudience_Above_65,
		CAST(ROUND((Avg_Ratings_Pt) * (IQ_Station.UF18_20), 0) AS INT) as FemaleAudience_18_20,
		CAST(ROUND((Avg_Ratings_Pt) * (IQ_Station.UF21_24), 0) AS INT) as FemaleAudience_21_24,
		CAST(ROUND((Avg_Ratings_Pt) * (IQ_Station.UF25_34), 0) AS INT) as FemaleAudience_25_34,
		CAST(ROUND((Avg_Ratings_Pt) * (IQ_Station.UF35_49), 0) AS INT) as FemaleAudience_35_49,
		CAST(ROUND((Avg_Ratings_Pt) * (IQ_Station.UF50_54), 0) AS INT) as FemaleAudience_50_54,
		CAST(ROUND((Avg_Ratings_Pt) * (IQ_Station.UF55_64), 0) AS INT) as FemaleAudience_55_64,
		CAST(ROUND((Avg_Ratings_Pt) * (IQ_Station.UF65), 0) AS INT) as FemaleAudience_Above_65,
		CAST(0 AS BIT) AS IsActualNielsen
			
	FROM 
		IQ_Station 
			JOIN
				IQ_Nielsen_Averages WITH (NOLOCK)
				ON SUBSTRING(Affil_IQ_CC_Key, 0, LEN(Affil_IQ_CC_Key) - 13) = CASE WHEN Dma_Num = '000' THEN IQ_Station_ID ELSE Station_Affil + '_' + TimeZone END
	WHERE SUBSTRING(Affil_IQ_CC_Key, LEN(Affil_IQ_CC_Key) - 12, 13) >= convert(varchar(8), @StartDate, 112) + '_' + convert(varchar(2), @StartDate, 108) + '00'
	  AND SUBSTRING(Affil_IQ_CC_Key, LEN(Affil_IQ_CC_Key) - 12, 13) <= convert(varchar(8), @EndDate, 112) + '_' + convert(varchar(2), @EndDate, 108) + '00'
			
END