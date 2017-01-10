CREATE PROCEDURE [dbo].[usp_IQAgent_SelectNielsenDataByDateRange]
(
	@StartDate datetime,
	@EndDate datetime
)
AS
BEGIN
	SET NOCOUNT ON;							
	
	SELECT
		IQ_Station_ID + SUBSTRING(Affil_IQ_CC_Key, LEN(Affil_IQ_CC_Key) - 13, 14) as IQ_CC_Key,
		CONVERT(FLOAT,IQ_Nielsen_Averages.Avg_Ratings_Pt * 100 * (SELECT CPPVALUE FROM IQ_SQAD WHERE IQ_SQAD.SQADMARKETID = IQ_Station.SQADMARKETID AND IQ_SQAD.DAYPARTID = IQ_Nielsen_Averages.DAYPARTID)) as SQAD_SHAREVALUE,
		CAST(ROUND(IQ_Nielsen_Averages.Avg_Ratings_Pt * IQ_Station.UNIVERSE, 0) AS INT) as AUDIENCE,
		CAST(0 AS BIT) AS IsActualNielsen
	FROM
		IQ_Station 
			JOIN
				IQ_Nielsen_Averages WITH (NOLOCK)
				--ON SUBSTRING(Affil_IQ_CC_Key, 0, LEN(Affil_IQ_CC_Key) - 13) IN (IQ_Station_ID, Station_Affil + '_' + TimeZone)
				ON SUBSTRING(Affil_IQ_CC_Key, 0, LEN(Affil_IQ_CC_Key) - 13) = CASE WHEN Dma_Num = '000' THEN IQ_Station_ID ELSE Station_Affil + '_' + TimeZone END
				AND IQ_Nielsen_Averages.IQ_Start_Point = 1
	WHERE SUBSTRING(Affil_IQ_CC_Key, LEN(Affil_IQ_CC_Key) - 12, 13) >= convert(varchar(8), @StartDate, 112) + '_' + convert(varchar(2), @StartDate, 108) + '00'
	  AND SUBSTRING(Affil_IQ_CC_Key, LEN(Affil_IQ_CC_Key) - 12, 13) <= convert(varchar(8), @EndDate, 112) + '_' + convert(varchar(2), @EndDate, 108) + '00'
END