-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_v4_IQ_NIELSEN_SQAD_SelectByIQCCKeyList]
	@IQCCKeyList xml,
	@ClientGuid uniqueidentifier	
AS
BEGIN
	
	SET NOCOUNT ON;
	DECLARE @TempTable AS TABLE(IQ_CC_KEY Varchar(28),IQ_CC_KEY_Time Varchar(14),IQ_DMA varchar(4))
	DECLARE @MultiPlier float
	
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
				WHEN  AUDIENCE = 0 OR AUDIENCE IS NULL THEN
					CAST((Avg_Ratings_Pt) * (IQ_Station.UNIVERSE) AS int)
				ELSE 
					AUDIENCE
				END
			as AUDIENCE,
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
			
		
END
