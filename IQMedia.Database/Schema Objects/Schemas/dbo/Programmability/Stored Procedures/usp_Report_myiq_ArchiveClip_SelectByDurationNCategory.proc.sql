﻿-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description: Website ==> MyIQ Report
			--		This Will get data from ArchiveClip table by Fromdate and Todate and CategoryGuid selected
			--		This will include NielsenData if @IsNielSenData is True
-- =============================================
CREATE PROCEDURE [dbo].[usp_Report_myiq_ArchiveClip_SelectByDurationNCategory]
	@ClientGUID uniqueidentifier,
	@SortField			VARCHAR(250),
	@IsAscending		bit,
	@FromDate		date,
	@ToDate		date,
	@CategoryGUID		uniqueidentifier,
	@IsNielSenData		bit
AS
BEGIN
	SET NOCOUNT ON
	
	DECLARE @Query NVARCHAR(MAX)

	DECLARE @MultiPlier decimal(18,2)
	
	--select @MultiPlier = CONVERT(decimal(18,2),ISNULL(Value,1)) from IQClient_CustomSettings where Field = 'Multiplier' and (_ClientGuid = @ClientGUID OR IQClient_CustomSettings._ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))
	select @MultiPlier = CONVERT(decimal(18,2),ISNULL(Value,1)) from IQClient_CustomSettings where Field = 'Multiplier' and (_ClientGuid = @ClientGUID OR IQClient_CustomSettings._ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))
	
	
	SET @Query = ' WITH TempIQCore_Recordfile  '
	SET @Query = @Query + ' AS ( '
	
	SET @Query = @Query + 'Select  ROW_NUMBER() OVER (ORDER BY '
	
	IF @SortField IS NOT NULL AND @SortField != ''
		BEGIN		
				set @Query = @Query + @SortField	
		END
	ELSE
		BEGIN
				SET @Query = @Query + ' ArchiveClip.ClipCreationDate '
		END
	
	IF @IsAscending=0
		BEGIN
				SET @Query = @Query + ' DESC '
		END
    
    SET @Query = @Query + 	') as RowNumber,
    
		ArchiveClip.ArchiveClipKey,
		ArchiveClip.ClipID,
		ArchiveClip.ClipTitle,
		ArchiveClip.[Description],
		ArchiveClip.ClipDate, 
		Substring(ArchiveClip.IQ_CC_KEY, Charindex(''_'', ArchiveClip.IQ_CC_KEY)+10, LEN(ArchiveClip.IQ_CC_KEY)) as IQ_CC_KEY_Time ,
		ArchiveClip.IQ_CC_KEY,
		Dma_Num,
		Dma_Name,
		IQ_Station_ID,
		Station_Affil,
		TimeZone,
		SQADMARKETID,
		UNIVERSE,
		ArchiveClip.CategoryGuid as CategoryGuid,
		CustomCategory.CategoryName as CategoryName
	  FROM
			ArchiveClip
			
			INNER JOIN CustomCategory 
			ON ArchiveClip.CategoryGuid = CustomCategory.CategoryGUID
			
				LEFT OUTER JOIN IQ_Station 
					on LTRIM(RTRIM(Substring(ArchiveClip.IQ_CC_KEY,1,Charindex(''_'', ArchiveClip.IQ_CC_KEY)-1))) = IQ_Station.IQ_Station_ID
	WHERE
			ArchiveClip.ClientGUID='''+CONVERT(varchar(40),@ClientGUID)+''''
			IF(@CategoryGUID IS NOT NULL)
				BEGIN
				SET @Query = @Query +  ' AND ArchiveClip.CategoryGuid = '''+ CONVERT(varchar(40),@CategoryGUID) +''''
				END
			
			SET @Query = @Query + ' AND CONVERT(date,ArchiveClip.CreatedDate) between CONVERT(date,'''+CONVERT(varchar(10),@FromDate) +''') and CONVERT(date,'''+CONVERT(varchar(10),@ToDate) +''')
			 AND ArchiveClip.IsActive = 1)
	
	SELECT 
				RowNumber,
				ArchiveClipKey,
				ClipID,
				ClipTitle,
				[Description],
				ClipDate,
				Dma_Name,CategoryGuid,CategoryName'
				
				IF(@IsNielSenData = 1)
				BEGIN
					SET @Query = @Query + 	',CASE
					WHEN  SQAD_SHAREVALUE = 0 OR SQAD_SHAREVALUE IS NULL THEN convert(bit,0) else convert(bit,1) end as IsActualNielsen,
					CASE WHEN  SQAD_SHAREVALUE = 0 OR SQAD_SHAREVALUE IS NULL THEN
						
						Convert(varchar,CONVERT(DECIMAL,Avg_Ratings_Pt * 100 * '+convert(varchar, @MultiPlier)+' *(Convert(Decimal,(EndOffset - StartOffset + 1))/30) * (SELECT CPPVALUE FROM IQ_SQAD WHERE IQ_SQAD.SQADMARKETID = tbl.SQADMARKETID AND IQ_SQAD.DAYPARTID = tblavg.DAYPARTID))) 
											ELSE
											
						Convert(varchar,CONVERT(DECIMAL, SQAD_SHAREVALUE * '+CONVERT(varchar, @MultiPlier)+' *(Convert(Decimal,(EndOffset - StartOffset + 1))/30))) 
					END
					as SQAD_SHAREVALUE,
				CASE
					WHEN  AUDIENCE = 0 OR AUDIENCE IS NULL THEN
						Convert(varchar,CAST((Avg_Ratings_Pt) * (tbl.UNIVERSE) AS DECIMAL))
					ELSE
						AUDIENCE
					END
				  as AUDIENCE '
				  
				  END
		SET @Query = @Query +' FROM 
					TempIQCore_Recordfile tbl
						LEFT OUTER JOIN IQCore_Clip 
							on tbl.ClipID = IQCore_Clip.Guid'
						
						IF(@IsNielSenData = 1)
							begin	
							SET @Query = @Query + ' LEFT OUTER JOIN IQ_Nielsen_Averages tblavg ON
							tblavg.IQ_Start_Point = CASE WHEN StartOffset = 0 THEN 1 ELSE CEILING(StartOffset /900.0) END  
							AND Affil_IQ_CC_Key =  CASE WHEN Dma_Num =''000'' THEN tbl.IQ_Station_ID ELSE tbl.Station_Affil + ''_'' + TimeZone END  + ''_'' + SUBSTRING(tbl.IQ_CC_Key,CHARINDEX(''_'',tbl.IQ_CC_Key) +1,13)							
						LEFT OUTER JOIN [IQ_NIELSEN_SQAD] s1 
						ON
						Tbl.IQ_CC_Key =  s1.IQ_CC_KEY 
						AND s1.IQ_Start_Point = CASE WHEN StartOffset = 0 THEN 1 ELSE CEILING(StartOffset /900.0) END ' 
							END
							
					SET @Query = @Query + ' ORDER BY RowNumber' 
	print @Query 
	
	EXEC sp_executesql @Query

	
END
