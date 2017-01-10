CREATE FUNCTION [dbo].[ufnGetNationalNeilsenDataByIQCCKeyList]
(	
	@Title	varchar(255),
	@AirDate	date,
	@IQ_Station_ID varchar(150),
	@ClientGuid uniqueidentifier
)
RETURNS @NielsenSum TABLE 
(
	National_ADShareValue decimal(18,2) NULL,
	National_Nielsen_Audience bigint NULL,
	National_Nielsen_Result char(1) NULL
)
AS
BEGIN 

	DECLARE @TempTable AS TABLE(IQ_CC_KEY Varchar(28),IQ_DMA varchar(4))
	DECLARE @Station_Affil varchar(255)
	
	INSERT INTO @TempTable
	SELECT 
			IQ_CC_KEY,
			IQ_DMA_Num
	FROM	
			IQ_SSP_Test
	WHERE
			title120 = @Title
			AND CONVERT(Date,iq_local_air_date) = @AirDate

	SELECT @Station_Affil = Station_Affil From IQ_Station Where IQ_Station_ID = @IQ_Station_ID 
	IF(@Station_Affil = 'ABC' OR @Station_Affil = 'CBS' OR @Station_Affil = 'NBC' OR @Station_Affil = 'CW' OR @Station_Affil = 'FOX' OR @Station_Affil = 'Univision')
	BEGIN
		IF((select COUNT(*) FROM @TempTable) > 1)
		BEGIN
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
						@TempTable AS Tbl
							inner join IQ_Station
								ON SUBString(Tbl.IQ_CC_KEY,1,charindex('_',Tbl.IQ_CC_KEY)-1)=IQ_station.IQ_Station_ID
							left outer join	[IQ_NIELSEN_SQAD] 
								ON Tbl.IQ_CC_KEY = [IQ_NIELSEN_SQAD] .IQ_CC_Key
								AND [IQ_NIELSEN_SQAD].IQ_Start_Point=1
							LEFT OUTER JOIN 
								IQ_Nielsen_Averages 
									ON [IQ_NIELSEN_SQAD].iq_cc_key is null
									AND IQ_Nielsen_Averages.IQ_Start_Point = 1
									AND Affil_IQ_CC_Key =  CASE WHEN Tbl.IQ_DMA = '000' 
									THEN IQ_Station_ID ELSE Station_Affil + '_' + TimeZone END + '_' + SUBSTRING(Tbl.IQ_CC_KEY,CHARINDEX('_',Tbl.IQ_CC_KEY) +1,13)			
			)	
			INSERT INTO @NielsenSum
			select ISNULL(sum(SQAD_SHAREVALUE),0) as 	National_ADShareValue, ISNULL(sum (AUDIENCE),0) as National_Nielsen_Audience,CASE WHEN Min(IsActual) = '1' THEN 'A' ELSE 'E' END as  National_Nielsen_Result from TempNielsenValues
	
		END
		ELSE
		BEGIN
			INSERT INTO @NielsenSum
			select NULL	National_ADShareValue, NULL as National_Nielsen_Audience, NULL as  National_Nielsen_Result
		END	
	END
	ELSE
	BEGIN
		INSERT INTO @NielsenSum
		select NULL	National_ADShareValue, NULL as National_Nielsen_Audience, NULL as  National_Nielsen_Result
	END
	

	
	RETURN;
END

