-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_STATSKEDPROG_SelectBySTATSKEDPROGParams]
(
	@FromDate			DATETIME,	
	@ToDate				DATETIME,
	@IQ_Dma_Num			VARCHAR(MAX),
	@IQ_Class			VARCHAR(MAX),
	@IQ_Cat				VARCHAR(MAX),
	@Title120			VARCHAR(MAX),
	@Desc100			VARCHAR(MAX),
	@Station_Affil		VARCHAR(MAX)
)
AS
BEGIN	
	SET NOCOUNT ON;
	
	DECLARE @Query NVARCHAR(MAX)

   SET @Query = 'Select	IQ_CC_KEY from STATSKEDPROG where 
			    								STATSKEDPROG.iq_local_air_date between '''+CONVERT(varchar(Max),@FromDate)+''' and '''+CONVERT(Varchar(Max),@ToDate)+'''' 
												
							IF (@IQ_Dma_Num IS NOT NULL AND @IQ_Dma_Num!='' AND LOWER(@IQ_Dma_Num)!='all' )
								BEGIN
										SET @Query=@Query+ ' AND STATSKEDPROG.IQ_Dma_Num in ('+@IQ_Dma_Num+')'
								END
								
							IF (@IQ_Cat IS NOT NULL AND @IQ_Cat!='' AND LOWER(@IQ_Cat)!='all')
								BEGIN
										SET @Query=@Query+ ' AND STATSKEDPROG.IQ_Cat in ('+@IQ_Cat+')'
								END
								
							IF(@IQ_Class IS NOT NULL AND @IQ_Class!='' AND LOWER(@IQ_Class)!='all')
								BEGIN
										SET @Query=@Query+' AND STATSKEDPROG.IQ_Class in ('+@IQ_Class+') '
								END
								
							IF (@Station_Affil IS NOT NULL AND @Station_Affil!='' AND LOWER(@Station_Affil)!='all')
								BEGIN
										SET @Query=@Query+' AND STATSKEDPROG.Station_Affil in ('+@Station_Affil+')'
								END
												
							IF @Title120 IS NOT NULL AND @Title120 != ''
							BEGIN
									SET @Query = @Query + ' AND (STATSKEDPROG.Title120  like (''%'+@Title120+'%''))'	
							END
							
							IF @Desc100 IS NOT NULL AND @Desc100 != ''
							BEGIN
									SET @Query = @Query + ' AND (STATSKEDPROG.Desc100  like (''%'+@Desc100+'%''))'	
							END	
	
	EXEC SP_EXECUTESQL @Query
	
END
