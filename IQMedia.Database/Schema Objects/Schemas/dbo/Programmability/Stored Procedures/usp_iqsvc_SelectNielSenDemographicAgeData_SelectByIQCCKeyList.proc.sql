CREATE PROCEDURE [dbo].[usp_iqsvc_SelectNielSenDemographicAgeData_SelectByIQCCKeyList]
(
	@IQCCKeyList xml,
	@ClientGuid uniqueidentifier	
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @StopWatch datetime, @SPStartTime datetime, @SPTrackingID uniqueidentifier, @TimeDiff decimal(18,2), @SPName varchar(100), @QueryDetail varchar(500)
 
	DECLARE @TempTable AS TABLE(IQ_CC_KEY Varchar(28), IQ_CC_KEY_Time Varchar(14), IQ_DMA varchar(4))
	DECLARE @MultiPlier float
	
	Set @SPStartTime = GetDate()
	Set @Stopwatch = GetDate()
	SET @SPTrackingID = NEWID()
	SET @SPName = 'usp_iqsvc_SelectNielSenDemographicAgeData_SelectByIQCCKeyList'  

	select @MultiPlier = CONVERT(float,ISNULL((select Value from IQClient_CustomSettings where Field = 'Multiplier' and _ClientGuid = @ClientGuid),(select Value from IQClient_CustomSettings where Field = 'Multiplier' and _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))))
		
	SELECT 
			Tbl.c.value('@iq_cc_key','varchar(30)') as IQ_CC_KEY,
			CASE WHEN  SQAD_SHAREVALUE = 0 OR SQAD_SHAREVALUE IS NULL THEN
				CONVERT(DECIMAL(18,2),Avg_Ratings_Pt * 100* @MultiPlier * (SELECT CPPVALUE FROM IQ_SQAD WHERE IQ_SQAD.SQADMARKETID = IQ_Station.SQADMARKETID AND IQ_SQAD.DAYPARTID = IQ_Nielsen_Averages.DAYPARTID))
			ELSE
				CONVERT(DECIMAL(18,2), SQAD_SHAREVALUE * @MultiPlier)
			END
			as  SQAD_SHAREVALUE,
				
		CASE 

			WHEN AM18_20 =0 OR  AM18_20  IS NULL THEN
				CAST((Avg_Ratings_Pt) * (IQ_Station.UM18_20) AS INT)
			ELSE
				AM18_20
			END
			as MALE_AUDIENCE_18_20,
		CASE   
			WHEN AM21_24 =0 OR  AM21_24  IS NULL THEN
				CAST((Avg_Ratings_Pt) * (IQ_Station.UM21_24) AS INT)
				
			ELSE
				AM21_24 
			END
			as MALE_AUDIENCE_21_24,
		CASE    
			WHEN AM25_34 =0 OR  AM25_34 IS NULL THEN
				CAST((Avg_Ratings_Pt) * (IQ_Station.UM25_34) AS INT)
				
			ELSE
				 AM25_34  
			END
			as MALE_AUDIENCE_25_34,
		CASE   
			WHEN AM35_49 =0 OR  AM18_20  IS NULL THEN
				CAST((Avg_Ratings_Pt) * (IQ_Station.UM35_49) AS INT)
			ELSE
				AM35_49 
			END
			as MALE_AUDIENCE_35_49,
		CASE
			WHEN AM50_54 =0 OR  AM50_54  IS NULL THEN
				CAST((Avg_Ratings_Pt) * (IQ_Station.UM50_54) AS INT)
			ELSE
				AM50_54 
			END
			as MALE_AUDIENCE_50_54,
		CASE
			WHEN AM55_64 =0 OR  AM55_64  IS NULL THEN
				CAST((Avg_Ratings_Pt) * (IQ_Station.UM55_64) AS INT)
			ELSE
				AM55_64 
			END
			as MALE_AUDIENCE_55_64,
		CASE
			WHEN AM65 =0 OR  AM65  IS NULL THEN
				CAST((Avg_Ratings_Pt) * (IQ_Station.UM65) AS INT)
			ELSE
				AM65 
			END
			as MALE_AUDIENCE_ABOVE_65,
		CASE
			WHEN AF18_20 =0 OR  AF18_20  IS NULL THEN
				CAST((Avg_Ratings_Pt) * (IQ_Station.UF18_20) AS INT)
			ELSE
				AF18_20
			END
			as FEMALE_AUDIENCE_18_20,
		CASE 
			WHEN AF21_24 =0 OR  AF21_24  IS NULL THEN
				CAST((Avg_Ratings_Pt) * (IQ_Station.UF21_24) AS INT)
			ELSE
				AF21_24 
			END
			as FEMALE_AUDIENCE_21_24,
		CASE
			WHEN AF25_34 =0 OR  AF25_34 IS NULL THEN
				CAST((Avg_Ratings_Pt) * (IQ_Station.UF25_34) AS INT)
			ELSE
				AF25_34 
			END
			as FEMALE_AUDIENCE_25_34,
		CASE	
			WHEN AF35_49 =0 OR  AF18_20  IS NULL THEN
				CAST((Avg_Ratings_Pt) * (IQ_Station.UF35_49) AS INT)
			ELSE
				AF35_49 
			END
			as FEMALE_AUDIENCE_35_49,
		CASE
			WHEN AF50_54 =0 OR  AF50_54  IS NULL THEN
				CAST((Avg_Ratings_Pt) * (IQ_Station.UF50_54) AS INT)
			ELSE
				 AF50_54
			END
			as FEMALE_AUDIENCE_50_54,
		CASE
			WHEN AF55_64 =0 OR  AF55_64  IS NULL THEN
				CAST((Avg_Ratings_Pt) * (IQ_Station.UF55_64) AS INT)
			ELSE
				AF55_64 
			END
			as FEMALE_AUDIENCE_55_64,
		CASE
			WHEN AF65 =0 OR  AF65  IS NULL THEN
				CAST((Avg_Ratings_Pt) * (IQ_Station.UF65) AS INT)
			ELSE
				AF65  
			END
			as FEMALE_AUDIENCE_ABOVE_65,
			case when [IQ_NIELSEN_SQAD].SQAD_SHAREVALUE = 0 OR [IQ_NIELSEN_SQAD].SQAD_SHAREVALUE IS NULL THEN
			CAST(0 AS BIT)
			ELSE 
			CAST(1 AS BIT) 
			END AS IsActualNielsen
			
			
	FROM 
		@IQCCKeyList.nodes('list/item') AS Tbl(c)
			INNER JOIN IQ_Station
				ON SUBString(Tbl.c.value('@iq_cc_key','varchar(30)'),1,charindex('_',Tbl.c.value('@iq_cc_key','varchar(30)'))-1)=IQ_station.IQ_Station_ID
			LEFT OUTER JOIN	[IQ_NIELSEN_SQAD] WITH (NOLOCK)
				ON Tbl.c.value('@iq_cc_key','varchar(30)') = [IQ_NIELSEN_SQAD] .IQ_CC_Key
				AND [IQ_NIELSEN_SQAD].IQ_Start_Point=1
			LEFT OUTER JOIN 
				IQ_Nielsen_Averages WITH (NOLOCK)
				ON [IQ_NIELSEN_SQAD].iq_cc_key is null
				AND IQ_Nielsen_Averages.IQ_Start_Point = 1
				AND Affil_IQ_CC_Key =  CASE WHEN TBL.c.value('@iq_dma','varchar(3)') = '000' 
				THEN IQ_Station_ID ELSE Station_Affil + '_' + TimeZone END + '_' + SUBSTRING(Tbl.c.value('@iq_cc_key','varchar(30)'),CHARINDEX('_',Tbl.c.value('@iq_cc_key','varchar(30)')) +1,13)			
			
	SET @QueryDetail ='Completed'
	SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
--	 INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)

END