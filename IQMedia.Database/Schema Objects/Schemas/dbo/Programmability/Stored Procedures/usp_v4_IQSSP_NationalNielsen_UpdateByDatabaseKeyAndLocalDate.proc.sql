CREATE PROCEDURE [dbo].[usp_v4_IQSSP_NationalNielsen_UpdateByDatabaseKeyAndLocalDate]
	@DatabaseKey varchar(10),
	@LocalDate date,
	@Station_Affil varchar(255)
AS
BEGIN
	DECLARE @Audience bigint,@MediaValue decimal(18,2) , @IsActual bit
	
	IF(UPPER(@Station_Affil) = 'ABC' OR UPPER(@Station_Affil) = 'CBS' OR UPPER(@Station_Affil) = 'NBC' OR UPPER(@Station_Affil) = 'CW' OR UPPER(@Station_Affil) = 'FOX' OR UPPER(@Station_Affil) = 'UNIVISION'OR UPPER(@Station_Affil) = 'ION')
	BEGIN
		DECLARE @TempTable AS TABLE(IQ_CC_KEY Varchar(28),IQ_DMA varchar(4),title120 varchar(100))
	
		INSERT INTO @TempTable
		SELECT 
			IQ_CC_KEY,
			IQ_DMA_Num,
			title120
		FROM	
			IQ_SSP_Test
		WHERE
			Database_Key = @DatabaseKey
			AND CONVERT(Date,iq_local_air_date) = @LocalDate
			AND Station_Affil =  @Station_Affil

		IF((select COUNT(*) FROM @TempTable) > 1)
		BEGIN
			DECLARE @CppDayPart2Val float
			SELECT @CppDayPart2Val = cppvalue FROM IQ_SQAD Where daypartid = 2 and SQADMarketID = 997
	
			;With TempNielsenValues
			AS (
					SELECT 
			
						CASE WHEN  SQAD_SHAREVALUE = 0 OR SQAD_SHAREVALUE IS NULL THEN
							CONVERT(DECIMAL,Avg_Ratings_Pt * 100*  
																CASE WHEN IQ_Station.SQADMARKETID = 997 AND IQ_Nielsen_Averages.DAYPARTID = 6 THEN
																	@CppDayPart2Val
																ELSE
																	(SELECT CPPVALUE FROM IQ_SQAD WHERE IQ_SQAD.SQADMARKETID = IQ_Station.SQADMARKETID AND IQ_SQAD.DAYPARTID = IQ_Nielsen_Averages.DAYPARTID)
																END)
						ELSE
							CONVERT(DECIMAL, SQAD_SHAREVALUE)
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
							0
						ELSE
							1
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

			SELECT
					@Audience = ISNULL(sum (AUDIENCE),0),
					@MediaValue =  ISNULL(sum(SQAD_SHAREVALUE),0),
					@IsActual =  Min(IsActual)
			FROM 
				   TempNielsenValues

			IF EXISTS(SELECT top 1 ID FROM IQSSP_NationalNielsen WHERE LocalDate = @LocalDate AND DatabaseKey = @DatabaseKey AND Station_Affil = @Station_Affil)
			BEGIN
				UPDATE 
						IQSSP_NationalNielsen
				SET
						Audience = @Audience,
						MediaValue = @MediaValue,
						IsActual = @IsActual
				WHERE 
						IQSSP_NationalNielsen.DatabaseKey = @DatabaseKey
						AND IQSSP_NationalNielsen.LocalDate = @LocalDate
						AND IQSSP_NationalNielsen.Station_Affil = @Station_Affil
			END
			ELSE
			BEGIN
				INSERT INTO IQSSP_NationalNielsen
				(
					DatabaseKey,
					LocalDate,
					Station_Affil,
					Audience,
					MediaValue,
					Title120,
					IsActual
				)

				SELECT
					@DatabaseKey,
					@LocalDate,
					@Station_Affil,
					@Audience,
					@MediaValue,
					(SELECT MAX(title120) from @TempTable),
					@IsActual
			END

		END
	END
END