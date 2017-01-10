CREATE PROCEDURE [dbo].[usp_iqsvc_IQ_NIELSEN_SQAD_SelectNielSenDataByRecordFileGuid]
	@Guid uniqueidentifier,
	@IsRawMedia bit,
	@IQ_Start_Point int,
	@IQ_Dma_Num varchar(4),
	@ClientGuid uniqueidentifier
AS
BEGIN
	DECLARE @IQ_CC_Key varchar(28)
	DECLARE @Duration int
	DECLARE @RecordFileGuid uniqueidentifier
	
	DECLARE @MultiPlier float
	IF(@IsRawMedia =0)
	BEGIN
		 Select
			@Duration =  IQCore_Clip.EndOffset-IQCore_Clip.StartOffset + 1,
			@RecordFileGuid =CASE 
			WHEN IQCore_Recordfile._ParentGuid is null then IQCore_Recordfile.[Guid]
			ELSE IQCore_Recordfile._ParentGuid
			END

			From IQCore_Clip
			INNER JOIN IQCore_Recordfile
			ON IQCore_Clip._RecordfileGuid = IQCore_Recordfile.Guid
			WHERE IQCore_Clip.Guid = @Guid
	END
		ELSE
	BEGIN
			SET @RecordFileGuid = @Guid
	END
    

	select @MultiPlier = CONVERT(float,ISNULL((select Value from IQClient_CustomSettings where Field = 'Multiplier' and _ClientGuid = @ClientGuid),(select Value from IQClient_CustomSettings where Field = 'Multiplier' and _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))))
	
	SELECT 
		  @IQ_CC_Key = LTRIM(RTRIM(d.SourceID)) + '_' +
		  SUBSTRING(CONVERT(VARCHAR(13),b.Startdate,112),1,13) +
		  '_' + SUBSTRING(CONVERT(VARCHAR(13),b.Startdate,108),1,2) + '00' 
	FROM IQCore_Recordfile as a WITH (NOLOCK)
		  Inner Join IQCore_Recording as b WITH (NOLOCK)
			ON a._RecordingID  = b.ID
		  Inner Join IQCore_Source as d WITH (NOLOCK)
			ON b._SourceGuid = d.Guid
			and a.Guid = @RecordFileGuid
       
	SELECT 
		StationVals.IQ_Start_Point,
		CASE
			WHEN SQAD_SHAREVALUE =0 OR SQAD_SHAREVALUE IS NULL THEN
				CASE WHEN @IsRawMedia =1 THEN 
					REPLACE(Convert(varchar,CAST((CAST(Avg_Ratings_Pt * 100 * @MultiPlier * (SELECT CPPVALUE FROM IQ_SQAD WHERE IQ_SQAD.SQADMARKETID = StationVals.SQADMARKETID AND IQ_SQAD.DAYPARTID = StationVals.DAYPARTID) AS DECIMAL)) as money),1),'.00','')
				ELSE
					REPLACE(Convert(varchar,CAST((CAST(Avg_Ratings_Pt * 100 * @MultiPlier * (CAST(@Duration AS DECIMAL)/30)  * (SELECT CPPVALUE FROM IQ_SQAD WHERE IQ_SQAD.SQADMARKETID = StationVals.SQADMARKETID AND IQ_SQAD.DAYPARTID = StationVals.DAYPARTID) AS DECIMAL)) as money),1),'.00','')
				END + '(E)' 
			ELSE
				CASE WHEN @IsRawMedia =1 THEN 
					REPLACE(Convert(varchar,CAST((CAST((SQAD_SHAREVALUE * @MultiPlier) AS DECIMAL)) as money),1),'.00','')
				ELSE 
					REPLACE(Convert(varchar,CAST((CAST((SQAD_SHAREVALUE * (CAST(@Duration AS DECIMAL)/30) * @MultiPlier) AS DECIMAL)) as money),1),'.00','')
				END 
				+ '(A)' 
			END as  SQAD_SHAREVALUE,
				
		CASE 
			WHEN AUDIENCE =0 OR AUDIENCE IS NULL THEN
				REPLACE(Convert(varchar,CAST((CAST((Avg_Ratings_Pt) * (StationVals.UNIVERSE) AS DECIMAL)) as money),1),'.00','')
			ELSE
				REPLACE(Convert(varchar,CAST(AUDIENCE as money),1),'.00','') 
			END
			as AUDIENCE
	FROM
		[IQ_NIELSEN_SQAD] 
			RIGHT OUTER JOIN 
			(
				SELECT 
					@IQ_CC_KEY as Org_IQ_CC_KEY, 
					IQ_STation.SQADMARKETID,
					IQ_STation.Universe,
					IQ_NielSen_Averages.DAYPARTID,
					IQ_NielSen_Averages.Avg_Ratings_Pt,
					IQ_NielSen_Averages.IQ_Start_Point
				FROM
					IQ_STation  INNER JOIN
						IQ_NielSen_Averages 
							ON IQ_NielSen_Averages.Affil_IQ_CC_KEY = CASE WHEN @IQ_Dma_Num = '000' THEN IQ_Station_ID ELSE Station_Affil + '_' + TimeZone END + '_' + SUBSTRING(@IQ_CC_KEY,CHARINDEX('_',@IQ_CC_KEY) +1,13)
							AND (@IsRawMedia = 1 OR IQ_NielSen_Averages.IQ_START_POINT = @IQ_Start_Point)
							AND LTRIM(RTRIM(Substring(@IQ_CC_KEY,1,Charindex('_', @IQ_CC_KEY)-1))) = IQ_Station_ID 	
			)	AS StationVals 
				ON	[IQ_NIELSEN_SQAD].iq_cc_key=Org_IQ_CC_KEY	
				AND [IQ_NIELSEN_SQAD].IQ_START_POINT = StationVals.IQ_STart_Point
				AND (@IsRawMedia = 1 OR [IQ_NIELSEN_SQAD].IQ_START_POINT = @IQ_Start_Point)
	ORDER BY IQ_START_POINT asc
END