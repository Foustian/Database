-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_RL_GUIDS_SelectBySTATSKEDPROGParams]
	@FromDate			DATETIME,	
	@ToDate				DATETIME,
	@IQ_Dma_Num			VARCHAR(MAX),
	@IQ_Class			VARCHAR(MAX),
	@IQ_Cat				VARCHAR(MAX),
	@Title120			VARCHAR(MAX),
	@Desc100			VARCHAR(MAX),
	@Station_Affil		VARCHAR(MAX)
AS
BEGIN	
	SET NOCOUNT ON;
	
	DECLARE @Query NVARCHAR(MAX)

   SET @Query = 'Select	RL_GUIDS.RL_GUID from STATSKEDPROG inner join RL_GUIDS on STATSKEDPROG.IQ_CC_Key=RL_GUIDS.IQ_CC_Key where 
			    								STATSKEDPROG.iq_local_air_date between '''+CONVERT(varchar(Max),@FromDate)+''' and '''+CONVERT(Varchar(Max),@ToDate)+''' and
												STATSKEDPROG.IQ_Dma_Num in ('+@IQ_Dma_Num+') and
												STATSKEDPROG.IQ_Cat in ('+@IQ_Cat+') and
												STATSKEDPROG.IQ_Class in ('+@IQ_Class+') and
												STATSKEDPROG.Station_Affil in ('+@Station_Affil+') '
												
							IF @Title120 IS NOT NULL OR @Title120 <> ''
							BEGIN
									SET @Query = @Query + ' AND (STATSKEDPROG.Title120  like (''%'+@Title120+'%''))'	
							END
							
							IF @Desc100 IS NOT NULL OR @Desc100 <> ''
							BEGIN
									SET @Query = @Query + ' AND (STATSKEDPROG.Desc100  like (''%'+@Desc100+'%''))'	
							END	
	
	EXEC SP_EXECUTESQL @Query
	
END
