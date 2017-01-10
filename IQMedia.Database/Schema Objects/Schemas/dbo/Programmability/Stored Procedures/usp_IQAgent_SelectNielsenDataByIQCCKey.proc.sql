CREATE PROCEDURE [dbo].[usp_IQAgent_SelectNielsenDataByIQCCKey]
	@IQ_CC_Key varchar(28)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT
			@IQ_CC_Key as IQ_CC_Key,
			CASE WHEN SQAD_SHAREVALUE = 0 OR SQAD_SHAREVALUE IS NULL THEN
				CONVERT(FLOAT, Avg_Ratings_Pt * 100 * (SELECT CPPVALUE FROM IQ_SQAD WHERE IQ_SQAD.SQADMARKETID = IQ_Station.SQADMARKETID AND IQ_SQAD.DAYPARTID = IQ_Nielsen_Averages.DAYPARTID))
			ELSE
				CONVERT(FLOAT, SQAD_SHAREVALUE)
			END
			as  SQAD_ShareValue,
			CASE
				WHEN  AUDIENCE = 0 OR AUDIENCE IS NULL THEN
					CAST(ROUND(IQ_Nielsen_Averages.Avg_Ratings_Pt * IQ_Station.UNIVERSE, 0) AS INT)
				ELSE 
					CAST(AUDIENCE AS INT)
				END
			as Audience,
			case when SQAD_SHAREVALUE = 0 OR SQAD_SHAREVALUE IS NULL THEN
				CAST(0 AS BIT)
			ELSE 
				CAST(1 AS BIT) 
			END AS IsActualNielsen
	FROM 
		[IQ_Station] 
			LEFT OUTER JOIN	[IQ_NIELSEN_SQAD] WITH (NOLOCK)
				ON [IQ_NIELSEN_SQAD].IQ_CC_Key = @IQ_CC_Key
				AND [IQ_NIELSEN_SQAD].IQ_Start_Point = 1
			LEFT OUTER JOIN 
				[IQ_Nielsen_Averages] WITH (NOLOCK)
				ON [IQ_NIELSEN_SQAD].iq_cc_key is null
				AND [IQ_Nielsen_Averages].IQ_Start_Point = 1
				AND Affil_IQ_CC_Key =
					CASE WHEN [IQ_Station].Dma_Num = '000' 
						THEN @IQ_CC_Key
						ELSE Station_Affil + '_' + TimeZone + '_' + SUBSTRING(@IQ_CC_Key, CHARINDEX('_', @IQ_CC_Key) + 1, 13)
					END
	WHERE
		IQ_station.IQ_Station_ID = SUBSTRING(@IQ_CC_Key, 1, CHARINDEX('_',@IQ_CC_Key) - 1)

END